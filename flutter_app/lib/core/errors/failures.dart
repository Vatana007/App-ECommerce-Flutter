abstract class Failure {
  final String message;
  final int? statusCode;

  const Failure(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

class ServerFailure extends Failure {
  const ServerFailure(super.message, [super.statusCode]);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection. Please check your network.']);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Authentication failed. Please sign in again.', super.statusCode = 401]);
}

class ValidationFailure extends Failure {
  final Map<String, dynamic>? errors;
  const ValidationFailure(super.message, [this.errors, super.statusCode = 422]);
}
