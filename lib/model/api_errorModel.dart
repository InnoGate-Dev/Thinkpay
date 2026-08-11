class ApiError {
  final String error;

  ApiError({required this.error});

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(error: json['error'] ?? 'Unknown error');
  }

  @override
  String toString() => error;
}
