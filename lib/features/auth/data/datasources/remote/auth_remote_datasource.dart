import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:musicapp/core/api/api_client.dart';
import 'package:musicapp/core/api/api_endpoints.dart';
import 'package:musicapp/core/services/storage/token_service.dart';
import 'package:musicapp/core/services/storage/user_session_service.dart';
import 'package:musicapp/features/auth/data/datasources/auth_datasource.dart';
import 'package:musicapp/features/auth/data/models/auth_api_model.dart';


final authRemoteDatasourceProvider = Provider<IAuthRemoteDataSource>((ref) {
  return AuthRemoteDatasource(
    apiClient: ref.read(apiClientProvider),
    userSessionService: ref.read(userSessionServiceProvider),
    tokenService: ref.read(tokenServiceProvider),
  );
});

class AuthRemoteDatasource implements IAuthRemoteDataSource {
  final ApiClient _apiClient;
  final UserSessionService _userSessionService;
  final TokenService _tokenService;

  AuthRemoteDatasource({
    required ApiClient apiClient,
    required UserSessionService userSessionService,
    required TokenService tokenService,
  }) : _apiClient = apiClient,
       _userSessionService = userSessionService,
       _tokenService = tokenService;

  @override
  Future<AuthApiModel?> login(String email, String password) async {
    final response = await _apiClient.post(
      ApiEndpoints.login,
      data: {'email': email, 'password': password},
    );

    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>;
      final user = AuthApiModel.fromJson(data);

      await _userSessionService.saveUserSession(
        userId: user.authId!,
        email: user.email,
        name: user.name,
      );
      // Save token to TokenService
      final token = response.data['token'];
      // Later store token in secure storage
      await _tokenService.saveToken(token);
      return user;
    }

    return null;
  }

  @override
  Future<AuthApiModel> register(AuthApiModel user) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.register,
        data: user.toJson(),
      );

      if (response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        final registeredUser = AuthApiModel.fromJson(data);
        return registeredUser;
      } else {
        throw Exception(response.data['message'] ?? 'Registration failed');
      }
    } catch (e) {
      rethrow;
    }
  }


@override
Future<String> uploadImage(File image) async {
  try {
    String? token = _tokenService.getToken();

    final formData = FormData.fromMap({
      'profilePicture': await MultipartFile.fromFile(
        image.path,
        filename: image.path.split('/').last,
      ),
    });

    final response = await _apiClient.put(
      ApiEndpoints.userProfile,
      data: formData,
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'multipart/form-data',
        },
      ),
    );

    if (response.statusCode == 200) {
      final data = response.data as Map<String, dynamic>;
      String newImageName = 'profile_image.jpg';

      // Safely extract the image name from nested data
      if (data['success'] == true && data['data'] != null) {
        final uploadData = data['data'];
        if (uploadData is Map<String, dynamic>) {
          String serverImageName = uploadData['profilePicture']?.toString() ?? 
                              uploadData['filename']?.toString() ?? 
                              newImageName;
          
          // Extract just the filename if server returns full path
          if (serverImageName.contains('/')) {
            newImageName = serverImageName.split('/').last;
          } else {
            newImageName = serverImageName;
          }
        } else if (uploadData is String) {
          newImageName = uploadData;
        }
      }

      // Update local storage so the UI updates immediately
      await _userSessionService.saveUserProfileImage(newImageName);
      return newImageName;
    } else {
      return "Failed to update profile";
    }
  } on DioException catch (e) {
    // Gracefully handle server-side errors
    throw Exception(
      "Server Error: ${e.response?.data?['message'] ?? e.message}",
    );
  } catch (e) {
    throw Exception("Unexpected Error: $e");
  }
}


  @override
  Future<AuthApiModel?> getUserById(String authId) {
    throw UnimplementedError();
  }
}