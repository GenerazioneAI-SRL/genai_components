class AppError {
  int? code;
  String? message;
  String? details;

  AppError({this.code, this.message, this.details});

  factory AppError.fromJson({
    required dynamic jsonObject,
  }) {
    final error = AppError();
    error.code = jsonObject["code"];
    error.message = jsonObject["message"];
    error.details = jsonObject["details"];
    return error;
  }
}