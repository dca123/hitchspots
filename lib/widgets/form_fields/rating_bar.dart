import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class RatingBarFormField extends FormField<double> {
  RatingBarFormField({
    required Function(double?) onSaved,
    required double initialValue,
  }) : super(
          validator: (value) {
            if (value == null || value == 0) {
              return 'Please select a rating';
            }
            onSaved(value);
            return null;
          },
          onSaved: onSaved,
          initialValue: initialValue,
          builder: (FormFieldState<double> ratingFormContext) {
            return Column(
              children: [
                RatingBar(
                  initialRating: initialValue,
                  glow: false,
                  itemPadding: EdgeInsets.symmetric(horizontal: 8.0),
                  allowHalfRating: true,
                  ratingWidget: RatingWidget(
                    full: Icon(Icons.star, color: Colors.yellow[700]),
                    half: Icon(Icons.star_half, color: Colors.yellow[700]),
                    empty: Icon(Icons.star_outline, color: Colors.yellow[700]),
                  ),
                  onRatingUpdate: (value) => ratingFormContext.didChange(value),
                ),
                if (ratingFormContext.hasError)
                  Column(
                    children: [
                      SizedBox(height: 16),
                      Text(
                        ratingFormContext.errorText!,
                        style: Theme.of(ratingFormContext.context)
                            .textTheme
                            .caption!
                            .apply(
                                color: Theme.of(ratingFormContext.context)
                                    .errorColor),
                      ),
                    ],
                  ),
              ],
            );
          },
        );
}
