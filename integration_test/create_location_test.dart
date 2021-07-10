import 'package:flutter_test/flutter_test.dart';
import 'package:hitchspots/main.dart';
import 'package:hitchspots/utils/provider_wrapper.dart';
import 'package:hitchspots/widgets/fabs/add_location_fab.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets("Add a Location", (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderWrapper(
        app: HitchSpotApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(AddLocationWrapper));
    await tester.pumpAndSettle();
    expect(find.text("Add a location"), findsOneWidget);
  });
}
