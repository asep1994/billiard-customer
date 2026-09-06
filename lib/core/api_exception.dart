/// Mirrors the shape of billiard-api's error responses: a human-readable
/// `message` plus, for a 422 validation failure, `errors` keyed by field.
class ApiException implements Exception {
  final int? statusCode;
  final String message;
  final Map<String, List<String>> errors;

  ApiException({required this.message, this.statusCode, this.errors = const {}});

  /// The first validation message for [field], if any.
  String? fieldError(String field) => errors[field]?.first;

  @override
  String toString() => message;
}
