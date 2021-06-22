import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hitchspots/pages/setup_profile_page.dart';

enum LoginState {
  loggedIn,
  loggedOut,
  oauthCompleted,
  oauthFailed,
  register,
  profileSetup,
}

class AuthenticationState extends ChangeNotifier {
  LoginState _loginState = LoginState.loggedOut;
  String? _uid;
  String? _displayName;
  bool _isAuthenticating = false;

  // late FirebaseAuth _auth;
  FirebaseAuth? _auth;

  LoginState get loginState => _loginState;
  String? get uid => _uid;
  String? get displayName => _displayName;
  bool get isAuthenticating => _isAuthenticating;

  Future<void> init() async {
    if (Firebase.apps.length < 1) {
      await Firebase.initializeApp();
    }
    _auth ??= FirebaseAuth.instance;
  }

  Future<void> loginFlowWithAction(
      {required Function postLogin, required BuildContext buildContext}) async {
    _isAuthenticating = true;
    notifyListeners();
    if (_loginState != LoginState.loggedIn) {
      await signInWithGoogle();
      if (_loginState == LoginState.oauthFailed) return;
      await loadProfile();
      if (_loginState == LoginState.profileSetup) {
        await Navigator.push(
          buildContext,
          MaterialPageRoute(builder: (context) {
            return SetupProfilePage();
          }),
        );
      }
    }
    _isAuthenticating = false;
    notifyListeners();
    if (_loginState == LoginState.loggedIn) {
      postLogin();
    }
  }

  Future<void> signInWithGoogle() async {
    await init();
    final User? fireAuthUser = _auth?.currentUser;
    // Not Authenticated via FireAuth
    if (fireAuthUser == null) {
      _loginState = LoginState.register;
      GoogleSignInAccount? googleUser;
      try {
        googleUser = await GoogleSignIn().signIn();
      } catch (e) {
        print(e);
      }

      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        await _auth?.signInWithCredential(credential);
        _uid = FirebaseAuth.instance.currentUser!.uid;
      } else {
        _loginState = LoginState.oauthFailed;
      }
    } else {
      _loginState = LoginState.oauthCompleted;
      _uid = fireAuthUser.uid;
    }
  }

  Future<void> loadProfile() async {
    final DocumentSnapshot hitchSpotsUser =
        await FirebaseFirestore.instance.collection('users').doc(_uid).get();
    if (hitchSpotsUser.exists) {
      _displayName = hitchSpotsUser.get("displayName");
      _loginState = LoginState.loggedIn;
    } else {
      _loginState = LoginState.profileSetup;
    }
  }

  void createProfile(String displayName) {
    _displayName = displayName;
    _loginState = LoginState.loggedIn;
  }

  void signOut() {
    _auth?.signOut();
    _loginState = LoginState.loggedOut;
  }
}
