import 'package:animations/animations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:hitchspots/models/location_card.dart';
import 'package:hitchspots/services/authentication.dart';
import 'package:provider/provider.dart';
import '../pages/create_review_page.dart';
import 'package:timeago/timeago.dart' as timeago;

class LocationInfoCard extends StatelessWidget {
  LocationInfoCard({
    required this.cardDetailsKey,
    required this.animationController,
    required this.maximizePanel,
  }) : imageHeight = Tween<double>(begin: 0.35, end: 0.45).animate(
          CurvedAnimation(
            parent: animationController,
            curve: Interval(0.35, 1.0, curve: Curves.linear),
          ),
        );
  final cardDetailsKey;
  final AnimationController animationController;
  final Animation<double> imageHeight;
  final Function maximizePanel;

  Widget _buildHeaderAnimation(BuildContext context, Widget? widget) {
    final screenHeight = MediaQuery.of(context).size.height * imageHeight.value;

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
              CardDetails(
                animationController: animationController,
                maximizePanel: maximizePanel,
              ),
            ],
          ),
        ),
        Expanded(child: ReviewList())
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // 0.35 : 0.65 => 7:13
    // 0.175 : 0.175 : 0.65 => 7 7 26
    return Consumer<LocationCardModel>(builder: (context, locationCard, child) {
      if (locationCard.hasImages) {
        return AnimatedBuilder(
            animation: animationController, builder: _buildHeaderAnimation);
      } else {
        return Column(
          children: [
            CardDetails(
              key: cardDetailsKey,
              animationController: animationController,
              maximizePanel: maximizePanel,
            ),
            Expanded(child: ReviewList())
          ],
        );
      }
    });
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
        """https://maps.googleapis.com/maps/api/streetview?location=${locationCard.coordinates.latitude},${locationCard.coordinates.longitude}
        &fov=120&heading=$heading&size=456x456&key=${env['MAPS_API_KEY']}""",
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
    required this.maximizePanel,
    required this.animationController,
  })  : opacity = Tween<double>(begin: 1, end: 0).animate(
          CurvedAnimation(
            parent: animationController,
            curve: Interval(0.35, 1.0, curve: Curves.linear),
          ),
        ),
        super(key: key);
  final Animation<double> opacity;
  final AnimationController animationController;
  final Function maximizePanel;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          OpenContainer<bool>(
            clipBehavior: Clip.none,
            tappable: false,
            openColor: Theme.of(context).canvasColor,
            closedElevation: 0,
            closedColor: Theme.of(context).canvasColor,
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
            closedBuilder: (context, openContainer) {
              return ElevatedButton.icon(
                onPressed: () => Provider.of<AuthenticationState>(
                  context,
                  listen: false,
                ).loginFlowWithAction(
                  buildContext: context,
                  postLogin: () => openContainer(),
                ),
                icon: Icon(Icons.add),
                label: Text("Review"),
              );
            },
            openBuilder: (context, closedContainer) {
              return CreateReviewPage();
            },
          ),
          SizedBox(width: 16.0),
          Opacity(
            opacity: opacity.value,
            child: OutlinedButton(
              onPressed: () => maximizePanel(),
              child: Row(
                children: [
                  Icon(Icons.comment),
                  Text(" Comments"),
                ],
              ),
            ),
          ),
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

class CardDetails extends StatefulWidget {
  CardDetails({
    Key? key,
    required this.animationController,
    required this.maximizePanel,
  }) : super(key: key);
  final AnimationController animationController;
  final Function maximizePanel;

  @override
  _CardDetailsState createState() => _CardDetailsState();
}

class _CardDetailsState extends State<CardDetails> {
  late Animation<double> paddingTop;

  Widget _buildAnimation(BuildContext context, Widget? child) {
    return Card(
      margin: EdgeInsets.all(0),
      elevation: 2,
      child: Container(
        padding: EdgeInsets.only(top: paddingTop.value, bottom: 8, left: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            LocationInfomation(),
            SizedBox(
              height: 8,
            ),
            ButtonBar(
              animationController: widget.animationController,
              maximizePanel: widget.maximizePanel,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasImages =
        Provider.of<LocationCardModel>(context, listen: false).hasImages;

    paddingTop = Tween<double>(
      begin: 16,
      end: !hasImages ? MediaQuery.of(context).padding.top + 16 : 16,
    ).animate(
      CurvedAnimation(
        parent: widget.animationController,
        curve: Interval(0.35, 1, curve: Curves.linear),
      ),
    );
    return AnimatedBuilder(
        animation: widget.animationController, builder: _buildAnimation);
  }
}
