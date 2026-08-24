import 'package:dio/dio.dart';
import 'package:business_assistant/config/constants/api_endpoints.dart';
import 'package:business_assistant/core/features/inventory/models/requests/create_category_request.dart';
import 'package:business_assistant/core/features/inventory/models/requests/update_category_request.dart';
import 'package:business_assistant/core/features/inventory/models/responses/category_response.dart';
import 'package:business_assistant/core/utils/api/api_response.dart';
import 'package:business_assistant/core/utils/api/app_interceptor.dart';
import 'package:business_assistant/core/utils/api/dio_exception_handler.dart';

/// Wraps every Business API call for Categories — backs the Inventory
/// feature's "category" picker on the product form (getCategories()).
class CategoryApiService {
  final Dio dio;

  CategoryApiService({Dio? dio}) : dio = dio ?? AppInterceptor().dio;

  Future<ApiResponse<List<CategoryResponse>>> getCategories() async {
    try {
      final response = await dio.get(APIEndpoints.categories);
      final categories = (response.data as List).map((json) => CategoryResponse.fromJson(json)).toList();
      return ApiResponse.completed(categories);
    } on DioException catch (e) {
      return ApiResponse.error(DioExceptionHandler().handleError(e, dontDisplayToast: true));
    } catch (e) {
      return ApiResponse.error('Something went wrong. Please try again.');
    }
  }

  /// Returns the new category's id on success.
  Future<ApiResponse<String>> createCategory(CreateCategoryRequest request) async {
    try {
      final response = await dio.post(APIEndpoints.categories, data: request.toJson());
      return ApiResponse.completed(response.data.toString());
    } on DioException catch (e) {
      return ApiResponse.error(DioExceptionHandler().handleError(e, dontDisplayToast: true));
    } catch (e) {
      return ApiResponse.error('Something went wrong. Please try again.');
    }
  }

  Future<ApiResponse<bool>> updateCategory(String id, UpdateCategoryRequest request) async {
    try {
      await dio.put(APIEndpoints.categoryById(id), data: request.toJson());
      return ApiResponse.completed(true);
    } on DioException catch (e) {
      return ApiResponse.error(DioExceptionHandler().handleError(e, dontDisplayToast: true));
    } catch (e) {
      return ApiResponse.error('Something went wrong. Please try again.');
    }
  }

  Future<ApiResponse<bool>> deleteCategory(String id) async {
    try {
      await dio.delete(APIEndpoints.categoryById(id));
      return ApiResponse.completed(true);
    } on DioException catch (e) {
      return ApiResponse.error(DioExceptionHandler().handleError(e, dontDisplayToast: true));
    } catch (e) {
      return ApiResponse.error('Something went wrong. Please try again.');
    }
  }
}
