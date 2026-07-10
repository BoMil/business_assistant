/// Generic API response wrapper used by all Cubits.
///
/// Every network operation goes through three states:
///   loading   → request is in flight (show a spinner)
///   completed → request succeeded (show data)
///   error     → request failed (show error message)
///
/// Usage in a Cubit:
///   emit(state.copyWith(loginResponse: ApiResponse.loading('Logging in...')));
///   try {
///     final data = await repo.login(request);
///     emit(state.copyWith(loginResponse: ApiResponse.completed(data)));
///   } catch (e) {
///     emit(state.copyWith(loginResponse: ApiResponse.error(e.toString())));
///   }
enum ResponseStatus { loading, completed, error }

class ApiResponse<T> {
  ResponseStatus status;
  T? data;
  String message;
  String statusCode;

  ApiResponse.loading(this.message)
      : status = ResponseStatus.loading,
        statusCode = '';

  ApiResponse.completed(this.data)
      : status = ResponseStatus.completed,
        message = '',
        statusCode = '';

  ApiResponse.error(this.message, {this.statusCode = ''})
      : status = ResponseStatus.error;

  bool get isLoading => status == ResponseStatus.loading;
  bool get isCompleted => status == ResponseStatus.completed;
  bool get isError => status == ResponseStatus.error;
}
