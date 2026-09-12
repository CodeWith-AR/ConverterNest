import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:converter_nest/modules/image_converter/viewmodels/image_converter_viewmodel.dart';
import 'package:converter_nest/modules/image_converter/widgets/format_selector_grid.dart';

void main() {
  group('ImageConversionOptions', () {
    test('default values are set', () {
      const opts = ImageConversionOptions();
      expect(opts.quality, 90);
      expect(opts.rotationDegrees, 0);
      expect(opts.flipH, false);
      expect(opts.flipV, false);
      expect(opts.targetWidth, isNull);
      expect(opts.targetHeight, isNull);
    });

    test('copyWith updates fields correctly', () {
      const opts = ImageConversionOptions();
      final updated = opts.copyWith(
        quality: 75,
        rotationDegrees: 180,
        flipH: true,
      );
      expect(updated.quality, 75);
      expect(updated.rotationDegrees, 180);
      expect(updated.flipH, true);
      expect(updated.flipV, false);
    });
  });

  group('FormatSelectorGrid Widget', () {
    testWidgets('renders formats and selects one', (tester) async {
      String? selected;
      final formats = ['JPG', 'PNG', 'WEBP'];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FormatSelectorGrid(
              formats: formats,
              selected: selected,
              onSelected: (fmt) => selected = fmt,
            ),
          ),
        ),
      );

      expect(find.text('JPG'), findsOneWidget);
      expect(find.text('PNG'), findsOneWidget);
      expect(find.text('WEBP'), findsOneWidget);

      await tester.tap(find.text('PNG'));
      await tester.pump();
      expect(selected, 'PNG');
    });
  });
}
