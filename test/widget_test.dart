import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:proyek_pertama/main.dart';

void main() {
  testWidgets('App loads without crash', (WidgetTester tester) async {
    await initializeDateFormatting('id_ID', null);

    // ✅ SET SCREEN SIZE BESAR
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(
      const MyApp(isLoggedIn: true),
    );

    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}