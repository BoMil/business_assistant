import 'package:dio/dio.dart';
import 'package:business_assistant/config/constants/api_endpoints.dart';
import 'package:business_assistant/core/features/authentication/models/requests/update_user_image_request.dart';
import 'package:business_assistant/core/features/authentication/models/responses/user_response.dart';
import 'package:business_assistant/core/utils/api/api_response.dart';
import 'package:business_assistant/core/utils/api/app_interceptor.dart';
import 'package:business_assistant/core/utils/api/dio_exception_handler.dart';

/// Wraps every Identity API call for the logged-in user's own profile.
class UserApiService {
  final Dio dio;

  UserApiService({Dio? dio}) : dio = dio ?? AppInterceptor().dio;

  Future<ApiResponse<UserResponse>> getCurrentUser() async {
    try {
      final response = await dio.get(APIEndpoints.currentUser);
      return ApiResponse.completed(UserResponse.fromJson(response.data));
    } on DioException catch (e) {
      return ApiResponse.error(DioExceptionHandler().handleError(e, dontDisplayToast: true));
    } catch (e) {
      return ApiResponse.error('Something went wrong. Please try again.');
    }
  }

  Future<ApiResponse<bool>> updateUserImage(String? imgUrl) async {
    try {
      await dio.put(APIEndpoints.updateUserImage, data: UpdateUserImageRequest(imgUrl: imgUrl).toJson());
      return ApiResponse.completed(true);
    } on DioException catch (e) {
      return ApiResponse.error(DioExceptionHandler().handleError(e, dontDisplayToast: true));
    } catch (e) {
      return ApiResponse.error('Something went wrong. Please try again.');
    }
  }
}
