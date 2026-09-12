import 'package:flutter/material.dart';

/// Common Dart/Flutter extensions.
extension StringExtensions on String {
  /// Capitalize the first letter.
  String get capitalize =>
      isEmpty ? '' : '${this[0].toUpperCase()}${substring(1)}';

  /// Get the file extension without the dot.
  String get fileExtension {
    final dotIndex = lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == length - 1) return '';
    return substring(dotIndex + 1).toLowerCase();
  }

  /// Get the file name without extension.
  String get fileNameWithoutExtension {
    final dotIndex = lastIndexOf('.');
    if (dotIndex == -1) return this;
    return substring(0, dotIndex);
  }
}

extension ContextExtensions on BuildContext {
  /// Access the theme data.
  ThemeData get theme => Theme.of(this);

  /// Access the text theme.
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Access the color scheme.
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Get the screen size.
  Size get screenSize => MediaQuery.sizeOf(this);

  /// Get the screen width.
  double get screenWidth => MediaQuery.sizeOf(this).width;

  /// Get the screen height.
  double get screenHeight => MediaQuery.sizeOf(this).height;
}
