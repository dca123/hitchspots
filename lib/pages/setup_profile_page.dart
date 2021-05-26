import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hitchspots/services/authentication.dart';
import 'package:provider/provider.dart';

class SetupProfilePage extends StatefulWidget {
  const SetupProfilePage({
    Key? key,
  }) : super(key: key);

  @override
  _SetupProfilePageState createState() => _SetupProfilePageState();
}

class _SetupProfilePageState extends State<SetupProfilePage> {
  TextEditingController _displayName = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).canvasColor,
        elevation: 0,
        // toolbarHeight: 64,
        toolbarHeight: 84,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
          color: Colors.black,
        ),
        title: Text(
          "Setup your Profile",
          style: Theme.of(context).textTheme.headline6,
        ),
        centerTitle: true,
        actions: [
          Container(
            padding: EdgeInsets.only(right: 16),
            child: IconButton(
              icon: const Icon(Icons.send),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  String userUid = FirebaseAuth.instance.currentUser!.uid;
                  FirebaseFirestore.instance
                      .collection('users')
                      .doc(userUid)
                      .set({'uid': userUid, 'displayName': _displayName.text});
                  Provider.of<AuthenticationState>(context, listen: false)
                      .createProfile();
                  Navigator.pop(context);
                }
              },
              color: Colors.black,
            ),
          )
        ],
      ),
      body: Form(
        key: _formKey,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              SizedBox(
                height: 8,
              ),
              TextFormField(
                controller: _displayName,
                maxLength: 50,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a display name';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Display Name",
                  // hintText: "Briefly describe the location ",
                  helperText: "Public name for contributions",
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
