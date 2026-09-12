/// Base failure class for error handling.
abstract class Failure {
  final String message;
  const Failure(this.message);

  @override
  String toString() => message;
}

class StorageFailure extends Failure {
  const StorageFailure([super.message = 'Storage operation failed']);
}

class FileNotFoundFailure extends Failure {
  const FileNotFoundFailure([super.message = 'File not found']);
}

class ConversionFailure extends Failure {
  const ConversionFailure([super.message = 'Conversion failed']);
}

class PermissionFailure extends Failure {
  const PermissionFailure([super.message = 'Permission denied']);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Something went wrong']);
}
