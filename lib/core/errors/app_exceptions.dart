/// Custom exception classes for the app.
class AppException implements Exception {
  final String message;
  final String? code;
  const AppException(this.message, {this.code});

  @override
  String toString() =>
      'AppException: $message${code != null ? ' (code: $code)' : ''}';
}

class StorageException extends AppException {
  const StorageException(super.message, {super.code});
}

class ConversionException extends AppException {
  const ConversionException(super.message, {super.code});
}

class FileException extends AppException {
  const FileException(super.message, {super.code});
}
