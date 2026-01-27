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
    print(' Remote Datasource: Starting register API call');
    
    try {
      final response = await _apiClient.post(
        ApiEndpoints.register,
        data: user.toJson(),
      );
      
      print(' Remote Datasource: Got response from register API');
      print('Response data: ${response.data}');

      if (response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        final registeredUser = AuthApiModel.fromJson(data);
        print('Remote Datasource: Registration successful');
        return registeredUser;
      } else {
        print(' Remote Datasource: Registration failed - ${response.data['message']}');
        throw Exception(response.data['message'] ?? 'Registration failed');
      }
    } catch (e) {
      print('Remote Datasource: Exception during register - ${e.toString()}');
      rethrow;
    }
  }

 @override
Future<String> uploadImage(File image) async {
  try {
    // Create multipart request for file upload
    final formData = FormData.fromMap({
      'profilePicture': await MultipartFile.fromFile(
        image.path,
        filename: image.path.split('/').last,
      ),
    });

    final response = await _apiClient.put(
      ApiEndpoints.userProfile, // '/auth/profile'
      data: formData,
      options: Options(
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      ),
    );

    if (response.statusCode == 200) {
      return response.data['message'] ?? "Profile updated successfully";
    } else {
      return "Failed to update profile";
    }
  } on DioException catch (e) {
    throw Exception(
      "Server Error: ${e.response?.data['message'] ?? e.message}",
    );
  } catch (e) {
    throw Exception("Unexpected Error: $e");
  }
}

  @override
  Future<AuthApiModel?> getUserById(String authId) {
    // TODO: implement getUserById
    throw UnimplementedError();
  }
}