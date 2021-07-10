import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hitchspots/widgets/form_fields/rating_bar.dart';

void main() {
  testWidgets(
    "Shows no error when dragged across",
    (WidgetTester tester) async {
      double ratingValue = 0;
      final GlobalKey<FormState> _key = GlobalKey<FormState>();

      await tester.pumpWidget(
        FormWrapper(
          formKey: _key,
          child: RatingBarFormField(
            onSaved: (value) {
              ratingValue = value!;
            },
            initialValue: ratingValue,
          ),
        ),
      );

      expect(find.byType(RatingBarFormField), findsOneWidget);

      await tester.flingFrom(
        tester.getCenter(find.byType(RatingBar)),
        Offset(60, 0),
        30,
      );
      _key.currentState!.validate();
      await tester.pump();

      expect(find.text("Please select a rating"), findsNothing);
      expect(ratingValue, equals(4));
    },
  );
  testWidgets(
    "Shows error message not when dragged across",
    (WidgetTester tester) async {
      double ratingValue = 0;
      final GlobalKey<FormState> _key = GlobalKey<FormState>();

      await tester.pumpWidget(
        FormWrapper(
          formKey: _key,
          child: RatingBarFormField(
            onSaved: (value) {
              ratingValue = value!;
            },
            initialValue: ratingValue,
          ),
        ),
      );

      expect(find.byType(RatingBarFormField), findsOneWidget);

      _key.currentState!.validate();
      await tester.pump();

      expect(find.text("Please select a rating"), findsOneWidget);
      expect(ratingValue, equals(0));
    },
  );
}

class FormWrapper extends StatelessWidget {
  const FormWrapper({
    required GlobalKey<FormState> this.formKey,
    required this.child,
  });

  final GlobalKey<FormState> formKey;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Form(
        key: formKey,
        child: Column(
          children: [child],
        ),
      ),
    );
  }
}
