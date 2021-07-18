import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hitchspots/utils/widget_switcher.dart';

void main() {
  testWidgets(
    "Shows widget A if condition is true",
    (WidgetTester tester) async {
      Widget a = Text("dataWithA", textDirection: TextDirection.ltr);
      Widget b = Text("dataWithB", textDirection: TextDirection.ltr);
      bool condition = true;
      await tester.pumpWidget(WidgetSwitcherWrapper(
          widgetIfTrue: a, widgetIfFalse: b, condition: condition));
      await tester.pump();

      expect(find.text("dataWithA"), findsOneWidget);
    },
  );
  testWidgets(
    "Shows widget B if condition is false",
    (WidgetTester tester) async {
      Widget a = Text("dataWithA", textDirection: TextDirection.ltr);
      Widget b = Text("dataWithB", textDirection: TextDirection.ltr);
      bool condition = false;
      await tester.pumpWidget(WidgetSwitcherWrapper(
          widgetIfTrue: a, widgetIfFalse: b, condition: condition));
      await tester.pump();

      expect(find.text("dataWithB"), findsOneWidget);
    },
  );
}
