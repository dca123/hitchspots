import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:hitchspots/models/location_card.dart';
import 'package:hitchspots/services/authentication.dart';
import 'package:provider/provider.dart';
import '../pages/create_review_page.dart';
import 'package:timeago/timeago.dart' as timeago;

class LocationInfoCard extends AnimatedWidget {
  const LocationInfoCard({
    Key? key,
    required this.radius,
    required this.maximizePanel,
    required Animation<double> animation,
  }) : super(key: key, listenable: animation);

  final BorderRadiusGeometry radius;
  final Function maximizePanel;
  static final _sizeTween = Tween<double>(begin: 100, end: 200);
  static final _borderRadius = Tween<double>(begin: 24, end: 0);

  @override
  Widget build(BuildContext context) {
    final animation = listenable as Animation<double>;
    final BorderRadiusGeometry radius = BorderRadius.only(
      topLeft: Radius.circular(_borderRadius.evaluate(animation)),
      topRight: Radius.circular(_borderRadius.evaluate(animation)),
    );

    return Column(children: [
      Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          borderRadius: radius,
        ),
        height: _sizeTween.evaluate(animation),
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            ReviewImage(imageName: "image1"),
            ReviewImage(imageName: "image2"),
            ReviewImage(imageName: "image3"),
            ReviewImage(imageName: "image4"),
            ReviewImage(imageName: "image5"),
          ],
        ),
      ),
      Card(
        margin: EdgeInsets.all(0),
        elevation: 2,
        child: Column(
          children: [
            LocationInfomation(),
            ButtonBar(
              maximizePanel: maximizePanel,
              animation: animation,
            ),
          ],
        ),
      ),
      ReviewList()
    ]);
  }
}

class ReviewImage extends StatelessWidget {
  const ReviewImage({Key? key, required this.imageName}) : super(key: key);
  final String imageName;
  @override
  Widget build(BuildContext context) {
    return Image.asset(
      "assets/locations/$imageName.jpg",
      width: 144,
      fit: BoxFit.cover,
    );
  }
}

class ReviewList extends StatelessWidget {
  const ReviewList({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<LocationCardModel>(builder: (context, locationCard, child) {
      return Expanded(
        child: ListView.separated(
          itemCount: locationCard.reviews.length,
          separatorBuilder: (BuildContext context, int index) => const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Divider(),
          ),
          itemBuilder: (context, index) {
            var review = locationCard.reviews[index];
            DateTime reviewTimestamp =
                DateTime.fromMillisecondsSinceEpoch(review['timestamp']);
            String fuzzyTimeStamp = timeago.format(reviewTimestamp);
            return ReviewTile(
              description: '${review['description']}',
              fuzzyTimeAgo: '$fuzzyTimeStamp',
              rating: review['rating'].toDouble(),
              displayName: '${review['createdByDisplayName']}',
            );
          },
        ),
      );
    });
  }
}

class ReviewTile extends StatelessWidget {
  const ReviewTile({
    Key? key,
    required this.fuzzyTimeAgo,
    required this.description,
    required this.rating,
    required this.displayName,
  }) : super(key: key);

  final String description;
  final double rating;
  final String fuzzyTimeAgo;
  final String displayName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$displayName",
            style: Theme.of(context).textTheme.subtitle1,
          ),
          Row(
            children: [
              StarRatingsBar(
                rating: rating,
              ),
              Text(
                ' $fuzzyTimeAgo',
                style: Theme.of(context).textTheme.caption,
              ),
            ],
          ),
          Text(
            '$description',
            style: Theme.of(context).textTheme.bodyText2,
            softWrap: true,
          )
        ],
      ),
    );
  }
}

class ButtonBar extends AnimatedWidget {
  ButtonBar({Key? key, required this.maximizePanel, required animation})
      : super(key: key, listenable: animation);
  final Function maximizePanel;
  @override
  Widget build(BuildContext context) {
    final animation = listenable as Animation<double>;

    return Container(
      height: 44,
      margin: EdgeInsets.only(bottom: 16),
      child: ListView(
        padding: EdgeInsets.only(bottom: 8),
        scrollDirection: Axis.horizontal,
        children: [
          SizedBox(width: 24.0),
          ElevatedButton(
            onPressed: () async {
              print(Provider.of<AuthenticationState>(context, listen: false)
                  .loginState);
              Provider.of<AuthenticationState>(context, listen: false)
                  .loginFlowWithAction(
                buildContext: context,
                postLogin: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return CreateReviewPage();
                    },
                  ),
                ),
              );
            },
            child: Row(
              children: [
                Icon(Icons.add),
                Text(" Review"),
              ],
            ),
          ),
          SizedBox(width: 16.0),
          if (!animation.isCompleted)
            OutlinedButton(
              onPressed: () => maximizePanel(),
              child: Row(
                children: [
                  Icon(Icons.comment),
                  Text(" Comments"),
                ],
              ),
            ),
          // SizedBox(width: 16.0),
          // OutlinedButton(
          //   onPressed: () => {},
          //   child: Row(
          //     children: [
          //       Icon(Icons.navigation),
          //       Text("Open in Google Maps"),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }
}

class LocationInfomation extends StatelessWidget {
  const LocationInfomation();
  @override
  Widget build(BuildContext context) {
    return Consumer<LocationCardModel>(builder: (context, locationCard, child) {
      return Container(
        padding: EdgeInsets.only(top: 20.0, left: 24.0, bottom: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${locationCard.locationName}",
              style: Theme.of(context).textTheme.headline6,
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Text(
                  "${locationCard.locationRating}",
                  style: Theme.of(context).textTheme.caption,
                ),
                StarRatingsBar(rating: locationCard.locationRating),
                Text(
                  "(${locationCard.reviewCount})",
                  style: Theme.of(context).textTheme.caption,
                ),
              ],
            ),
            Container(
              margin: EdgeInsets.only(right: 24),
              child: Text(
                "${locationCard.recentReview}",
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.caption,
              ),
            )
          ],
        ),
      );
    });
  }
}

class StarRatingsBar extends StatelessWidget {
  const StarRatingsBar({Key? key, required this.rating}) : super(key: key);
  final double rating;
  @override
  Widget build(BuildContext context) {
    return RatingBarIndicator(
      rating: rating,
      itemBuilder: (context, index) => Icon(
        Icons.star,
        color: Colors.yellow[700],
      ),
      itemCount: 5,
      itemSize: 13,
    );
  }
}
