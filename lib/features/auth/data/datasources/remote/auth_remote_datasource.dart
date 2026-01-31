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
          newImageName = uploadData['profilePicture']?.toString() ?? 
                        uploadData['filename']?.toString() ?? 
                        newImageName;
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
//  @override
// Future<String> uploadImage(File image) async {
//   try {

//     String? token = _tokenService.getToken();
//     // Create multipart request for file upload
//     final formData = FormData.fromMap({
//       'profilePicture': await MultipartFile.fromFile(
//         image.path,
//         filename: image.path.split('/').last,
//       ),
//     });

//     final response = await _apiClient.put(
//       ApiEndpoints.userProfile,
//       data: formData,
//       options: Options(
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'multipart/form-data',
//         },
//       ),
//     );

//     if (response.statusCode == 200) {
//       // Handle different response formats safely
//       if (response.data is Map<String, dynamic>) {
//         final data = response.data as Map<String, dynamic>;
        
//         // Try to extract filename from different possible response structures
//         if (data['success'] == true && data['data'] != null) {
//           final uploadData = data['data'];
//           if (uploadData is Map<String, dynamic>) {
//             return uploadData['filename']?.toString() ?? uploadData['profilePicture']?.toString() ?? 'profile_image.jpg';
//           } else if (uploadData is String) {
//             return uploadData;
//           }
//         }
        
//         // Fallback to message field
//         return data['message']?.toString() ?? "Profile updated successfully";
//       } else if (response.data is String) {
//         return response.data;
//       } else {
//         return "Profile updated successfully";
//       }
//     } else {
//       return "Failed to update profile";
//     }
//   } on DioException catch (e) {
//     throw Exception(
//       "Server Error: ${e.response?.data?['message'] ?? e.message}",
//     );
//   } catch (e) {
//     throw Exception("Unexpected Error: $e");
//   }
// }

  @override
  Future<AuthApiModel?> getUserById(String authId) {
    // TODO: implement getUserById
    throw UnimplementedError();
  }
}