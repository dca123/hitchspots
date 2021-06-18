import 'package:animations/animations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:hitchspots/models/location_card.dart';
import 'package:hitchspots/services/authentication.dart';
import 'package:hitchspots/widgets/location_info_card.dart';
import 'package:provider/provider.dart';
import '../pages/create_review_page.dart';
import 'package:timeago/timeago.dart' as timeago;

class LocationInfoCard2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height * 0.35;
    // 0.35 : 0.65 => 7:13
    // 0.175 : 0.175 : 0.65 => 7 7 26

    return Column(
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: screenHeight),
          child: Column(
            children: [
              Flexible(
                flex: 1,
                fit: FlexFit.tight,
                child: FractionallySizedBox(
                  alignment: Alignment.topCenter,
                  heightFactor: 1,
                  child: ReviewImageRow(),
                ),
              ),
              CardDetails(),
            ],
          ),
        ),
        Expanded(child: ReviewList())
      ],
    );
  }
}

class ReviewImageRow extends StatelessWidget {
  const ReviewImageRow({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
          // borderRadius: radius,
          ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          ReviewImage(
            imageName: "image1",
            heading: 0,
          ),
          ReviewImage(
            imageName: "image1",
            heading: 120,
          ),
          ReviewImage(
            imageName: "image1",
            heading: 240,
          ),
        ],
      ),
    );
  }
}

class ReviewImage extends StatelessWidget {
  const ReviewImage({Key? key, required this.imageName, required this.heading})
      : super(key: key);
  final String imageName;
  final int heading;
  @override
  Widget build(BuildContext context) {
    return Consumer<LocationCardModel>(builder: (context, locationCard, child) {
      return Image.network(
        "https://picsum.photos/400",
        width: MediaQuery.of(context).size.width / 2,
        fit: BoxFit.cover,
      );
    });
  }
}

class ReviewList extends StatelessWidget {
  const ReviewList({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<LocationCardModel>(builder: (context, locationCard, child) {
      return ListView.separated(
        itemCount: locationCard.reviews.length,
        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        separatorBuilder: (BuildContext context, int index) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: const Divider(),
        ),
        itemBuilder: (context, index) {
          var review = locationCard.reviews[index];
          int? reviewTimestamp = review['timestamp'];
          String fuzzyTimeStamp = "Some time ago";
          if (reviewTimestamp != null) {
            DateTime dateTimeSinceEpoch =
                DateTime.fromMillisecondsSinceEpoch(reviewTimestamp);
            fuzzyTimeStamp = timeago.format(dateTimeSinceEpoch);
          }
          return ReviewTile(
            description: '${review['description']}',
            fuzzyTimeAgo: '$fuzzyTimeStamp',
            rating: (review['rating'] ?? 0).toDouble(),
            displayName: '${review['createdByDisplayName']}',
          );
        },
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$displayName",
            style: Theme.of(context).textTheme.subtitle1,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 1.0),
            child: Row(
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
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              '$description',
              style: Theme.of(context).textTheme.bodyText2,
              softWrap: true,
            ),
          )
        ],
      ),
    );
  }
}

class ButtonBar extends StatelessWidget {
  ButtonBar({
    Key? key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: OpenContainer<bool>(
            openColor: Theme.of(context).canvasColor,
            closedElevation: 2,
            onClosed: (success) {
              if (success == true) {
                Future.delayed(const Duration(milliseconds: 500), () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Thank you for contributing!'),
                    ),
                  );
                });
              }
            },
            closedShape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            closedColor: Colors.transparent,
            closedBuilder: (context, openContainer) {
              return ElevatedButton(
                onPressed: () => Provider.of<AuthenticationState>(
                  context,
                  listen: false,
                ).loginFlowWithAction(
                  buildContext: context,
                  postLogin: () => openContainer(),
                ),
                child: Row(
                  children: [
                    Icon(Icons.add),
                    Text(" Review"),
                  ],
                ),
              );
            },
            openBuilder: (context, closedContainer) {
              return CreateReviewPage();
            },
          ),
        )
      ],
    );
    // return Container(
    //   height: 40,
    //   child: ListView(
    //     scrollDirection: Axis.horizontal,
    //     children: [
    //       SizedBox(width: 24.0),
    //       OpenContainer<bool>(
    //         openColor: Theme.of(context).canvasColor,
    //         closedElevation: 2,
    //         onClosed: (success) {
    //           if (success == true) {
    //             Future.delayed(const Duration(milliseconds: 500), () {
    //               ScaffoldMessenger.of(context).showSnackBar(
    //                 SnackBar(
    //                   content: const Text('Thank you for contributing!'),
    //                 ),
    //               );
    //             });
    //           }
    //         },
    //         closedShape:
    //             RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    //         closedBuilder: (context, openContainer) {
    //           return ElevatedButton(
    //             onPressed: () => Provider.of<AuthenticationState>(
    //               context,
    //               listen: false,
    //             ).loginFlowWithAction(
    //               buildContext: context,
    //               postLogin: () => openContainer(),
    //             ),
    //             child: Row(
    //               children: [
    //                 Icon(Icons.add),
    //                 Text(" Review"),
    //               ],
    //             ),
    //           );
    //         },
    //         openBuilder: (context, closedContainer) {
    //           return CreateReviewPage();
    //         },
    //       ),
    //       SizedBox(width: 16.0),
    //       Opacity(
    //         opacity: 1,
    //         child: OutlinedButton(
    //           onPressed: () => () => {},
    //           child: Row(
    //             children: [
    //               Icon(Icons.comment),
    //               Text(" Comments"),
    //             ],
    //           ),
    //         ),
    //       ),
    //     ],
    //   ),
    // );
  }
}

class LocationInfomation extends StatelessWidget {
  const LocationInfomation();
  @override
  Widget build(BuildContext context) {
    return Consumer<LocationCardModel>(builder: (context, locationCard, child) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Container(
            child: Text(
              "${locationCard.locationName}",
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
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
            child: Text(
              "${locationCard.recentReview}",
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.caption,
            ),
          ),
        ],
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
      itemBuilder: (context, index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_outline,
          color: Colors.yellow[700],
        );
      },
      itemCount: 5,
      itemSize: 13,
      unratedColor: Colors.yellow[700],
    );
  }
}

class CardDetails extends StatelessWidget {
  CardDetails({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool hasImages =
        Provider.of<LocationCardModel>(context, listen: false).hasImages;

    return Card(
      margin: EdgeInsets.all(0),
      elevation: 2,
      child: Container(
        padding: EdgeInsets.only(top: 8, bottom: 8, left: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            LocationInfomation(),
            Container(
              child: Row(
                children: [
                  OutlinedButton.icon(
                    icon: Icon(Icons.image),
                    onPressed: () {
                      print('Received click');
                    },
                    label: const Text('Click Me'),
                  ),
                  OutlinedButton.icon(
                    icon: Icon(Icons.image),
                    onPressed: () {
                      print('Received click');
                    },
                    label: const Text('Click Me'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
