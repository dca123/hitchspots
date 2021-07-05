import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hitchspots/main.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets("Add a Location", (WidgetTester tester) async {
    await tester.pumpWidget(ProviderWrapper());
    await tester.pumpAndSettle();
    await Future.delayed(Duration(milliseconds: 5000));
    await tester.tap(find.byType(Marker));
    await tester.pumpAndSettle();
    expect(find.text("Add a location"), findsOneWidget);
  });
}
