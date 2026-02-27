import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:passgrinder/main.dart';
import 'package:passgrinder/services/generator_service.dart';

void main() {
  testWidgets('App renders HomeScreen without errors', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<GeneratorService>(
        create: (_) => GeneratorService(),
        child: const PassGrinderApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify the app renders key UI elements
    expect(find.text('Master Password'), findsOneWidget);
    expect(find.text('Unique Phrase (optional)'), findsOneWidget);
  });
}
