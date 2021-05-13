import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:hitchspots/models/location_card.dart';
import 'package:provider/provider.dart';
import '../pages/create_review_page.dart';

class LocationInfoCard extends StatelessWidget {
  const LocationInfoCard(
      {Key? key,
      required this.radius,
      required this.maximizePanel,
      required this.locationName})
      : super(key: key);

  final BorderRadiusGeometry radius;
  final Function maximizePanel;
  final String locationName;
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          borderRadius: radius,
        ),
        height: 103.0,
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
            LocationInfomation(locationName: locationName),
            ButtonBar(maximizePanel: maximizePanel),
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
            return ReviewTile(
              description: '${review['description']}',
              rating: review['rating'].toDouble(),
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
    required this.description,
    required this.rating,
  }) : super(key: key);

  final String description;
  final double rating;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Dev Dog",
            style: Theme.of(context).textTheme.subtitle1,
          ),
          Row(
            children: [
              StarRatingsBar(
                rating: rating,
              ),
              Text(
                " 5 Years Ago",
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

class ButtonBar extends StatelessWidget {
  const ButtonBar({required this.maximizePanel});
  final Function maximizePanel;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      margin: EdgeInsets.only(bottom: 16),
      child: ListView(
        padding: EdgeInsets.only(bottom: 8),
        scrollDirection: Axis.horizontal,
        children: [
          SizedBox(width: 24.0),
          ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) {
                return CreateReviewPage();
              }),
            ),
            child: Row(
              children: [
                Icon(Icons.add),
                Text(" Review"),
              ],
            ),
          ),
          SizedBox(width: 16.0),
          OutlinedButton(
            onPressed: () => maximizePanel(),
            child: Row(
              children: [
                Icon(Icons.comment),
                Text(" Comments"),
              ],
            ),
          ),
          SizedBox(width: 16.0),
          OutlinedButton(
            onPressed: () => {},
            child: Row(
              children: [
                Icon(Icons.navigation),
                Text("Open in Google Maps"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LocationInfomation extends StatelessWidget {
  const LocationInfomation({required this.locationName});
  final String locationName;
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
                  "(1,004)",
                  style: Theme.of(context).textTheme.caption,
                ),
              ],
            ),
            Text(
              "Near Irving St, San Francisco",
              style: Theme.of(context).textTheme.caption,
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
