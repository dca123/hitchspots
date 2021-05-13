import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateLocationPage extends StatelessWidget {
  const CreateLocationPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    void addLocation() {
      // FirebaseFirestore.instance
      //     .collection('locations')
      //     .add({'text': 'testMessage'})
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Thank you for contributing!'),
        ),
      );
      Future.delayed(Duration(milliseconds: 100), () {
        Navigator.pop(context);
      });
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).canvasColor,
        elevation: 0,
        // toolbarHeight: 64,
        toolbarHeight: 84,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
          color: Colors.black,
        ),
        title: Text(
          "Add a location",
          style: Theme.of(context).textTheme.headline6,
        ),
        centerTitle: true,
        actions: [
          Container(
            padding: EdgeInsets.only(right: 16),
            child: IconButton(
              icon: const Icon(Icons.send),
              onPressed: () => addLocation(),
              color: Colors.black,
            ),
          )
        ],
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Location",
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Icon(
                  Icons.star_border_outlined,
                  size: 36,
                ),
                Icon(
                  Icons.star_border_outlined,
                  size: 36,
                ),
                Icon(
                  Icons.star_border_outlined,
                  size: 36,
                ),
                Icon(
                  Icons.star_border_outlined,
                  size: 36,
                ),
                Icon(
                  Icons.star_border_outlined,
                  size: 36,
                ),
              ],
            ),
            TextField(
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Add name",
                  hintText: "Simple Location Description"),
            ),
            TextField(
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Experience",
                  hintText: "Your Experience"),
              keyboardType: TextInputType.multiline,
            ),
            OutlinedButton(
                onPressed: () => {},
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_enhance),
                    Text("Add Photos"),
                  ],
                ))
          ],
        ),
      ),
    );
  }
}
