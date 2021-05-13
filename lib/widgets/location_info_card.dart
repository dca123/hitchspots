import 'package:flutter/material.dart';

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
      LocationInfomation(locationName: locationName),
      ButtonBar(maximizePanel: maximizePanel),
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
    return Expanded(
      child: ListView(
        children: [
          ReviewTile(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Divider(),
          ),
          ReviewTile(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Divider(),
          ),
          ReviewTile(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Divider(),
          ),
          ReviewTile(),
        ],
      ),
    );
  }
}

class ReviewTile extends StatelessWidget {
  const ReviewTile({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Dev Dog",
            style: Theme.of(context).textTheme.subtitle1,
          ),
          Row(
            children: [
              StarRatingsBar(),
              Text(
                " 5 Years Ago",
                style: Theme.of(context).textTheme.caption,
              ),
            ],
          ),
          Text(
            'Lorem ipsum dolor sit amet, consectetur adipiscing'
            'elit, sed do eiusmod tempor incididunt ut labore et'
            'dolore magna aliqua. Egestas maecenas pharetra'
            ' convallis posuere morbi leo urna molestie.',
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
      child: ListView(
        padding: const EdgeInsets.only(bottom: 8.0),
        scrollDirection: Axis.horizontal,
        children: [
          SizedBox(width: 24.0),
          ElevatedButton(
            onPressed: () => {},
            child: Row(
              children: [
                Icon(Icons.add),
                Text("Review"),
              ],
            ),
          ),
          SizedBox(width: 16.0),
          OutlinedButton(
            onPressed: () => maximizePanel(),
            child: Row(
              children: [
                Icon(Icons.comment),
                Text("Comments"),
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
    return Container(
      padding: EdgeInsets.only(top: 24.0, left: 24.0, bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$locationName",
            style: Theme.of(context).textTheme.headline6,
          ),
          Row(
            children: [
              Text(
                "4.9",
                style: Theme.of(context).textTheme.caption,
              ),
              StarRatingsBar(),
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
  }
}

class StarRatingsBar extends StatelessWidget {
  const StarRatingsBar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.star,
          size: 12.0,
          color: Colors.green[700],
        ),
        Icon(
          Icons.star,
          size: 12.0,
          color: Colors.green[700],
        ),
        Icon(
          Icons.star,
          size: 12.0,
          color: Colors.green[700],
        ),
        Icon(
          Icons.star_border_outlined,
          size: 12.0,
        ),
        Icon(
          Icons.star_border_outlined,
          size: 12.0,
        ),
      ],
    );
  }
}
