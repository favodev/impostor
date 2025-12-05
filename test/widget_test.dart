// Widget test for Impostor game
//
// Tests the basic app functionality

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impostor/main.dart';

void main() {
  testWidgets('App loads setup screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: ImpostorApp()));

    // Verify that the app title is displayed
    expect(find.text('IMPOSTOR'), findsOneWidget);
    expect(find.text('¿Quién es el espía?'), findsOneWidget);
  });
}
