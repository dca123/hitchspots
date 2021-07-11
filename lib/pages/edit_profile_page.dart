import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hitchspots/services/authentication.dart';
import 'package:provider/provider.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({
    Key? key,
  }) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  TextEditingController _displayName = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final String authUserDisplayName =
        Provider.of<AuthenticationState>(context).displayName ?? "test";
    _displayName.text = authUserDisplayName;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).canvasColor,
        elevation: 0,
        toolbarHeight: 84,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
          color: Colors.black,
        ),
        title: Text(
          "Edit Your Profile",
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
                      .update({'displayName': _displayName.text});
                  Provider.of<AuthenticationState>(context, listen: false)
                      .createProfile(_displayName.text);
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
              Text(
                "Only future contributions will have your new display name",
                style: Theme.of(context).textTheme.caption,
              ),
              SizedBox(
                height: 20,
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
                  helperText: "Public name shown with reviews",
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
