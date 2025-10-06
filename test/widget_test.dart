import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_mimascota_plus/app.dart';

void main() {
  testWidgets('La app carga correctamente', (WidgetTester tester) async {
    // Construye la aplicación
    await tester.pumpWidget(const App());

    // Verifica que el título MiMascota+ esté presente
    expect(find.text('MiMascota+'), findsOneWidget);
  });
}
