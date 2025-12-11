import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pillo/main.dart';

void main() {
  testWidgets('App loads setup screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: PilloApp()));

    expect(find.text('¿Quién es el espía?'), findsOneWidget);
  });
}
