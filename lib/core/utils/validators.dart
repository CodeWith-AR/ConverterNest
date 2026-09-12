class Validators {
  Validators._();

  static String? required(String? v) {
    if (v == null || v.trim().isEmpty) return 'This field is required';
    return null;
  }

  static String? minLength(String? v, int min) {
    if (v == null || v.length < min) return 'Must be at least $min characters';
    return null;
  }

  static String? maxLength(String? v, int max) {
    if (v != null && v.length > max) return 'Must be at most $max characters';
    return null;
  }

  static String? email(String? v) {
    if (v == null || v.isEmpty) return 'Email is required';
    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!regex.hasMatch(v)) return 'Invalid email';
    return null;
  }

  static String? fileName(String? v) {
    if (v == null || v.trim().isEmpty) return 'File name is required';
    final regex = RegExp(r'[<>:"/\\|?*]');
    if (regex.hasMatch(v)) return 'File name contains invalid characters';
    return null;
  }
}
