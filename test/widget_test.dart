// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:converter_nest/core/constants/app_strings.dart';
import 'package:converter_nest/core/constants/app_colors.dart';

void main() {
  test('App constants smoke test', () {
    expect(AppStrings.appName, 'Converter Nest');
    expect(AppColors.primary, const Color(0xFFFCD535));
  });
}
