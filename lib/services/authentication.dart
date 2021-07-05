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

  GoogleSignIn? _googleSignIn;
  FirebaseAuth? _auth;
  FirebaseFirestore? _firestore;

  LoginState get loginState => _loginState;
  String? get uid => _uid;
  String? get displayName => _displayName;
  bool get isAuthenticating => _isAuthenticating;

  AuthenticationState({
    GoogleSignIn? mockSignIn,
    FirebaseAuth? mockFirebaseAuth,
    FirebaseFirestore? mockFirebaseFirestore,
  }) {
    if (mockSignIn != null) {
      _googleSignIn = mockSignIn;
      _auth = mockFirebaseAuth;
      _firestore = mockFirebaseFirestore;
    }
  }

  Future<void> init() async {
    if (Firebase.apps.length < 1) {
      await Firebase.initializeApp();
    }
    _auth ??= FirebaseAuth.instance;
    _firestore ??= FirebaseFirestore.instance;
    _googleSignIn ??= GoogleSignIn();
  }

  Future<void> loginFlowWithAction(
      {required Function postLogin, required BuildContext buildContext}) async {
    _isAuthenticating = true;
    notifyListeners();
    try {
      if (_loginState != LoginState.loggedIn) {
        await _signInWithGoogle();
        if (_loginState == LoginState.oauthFailed) {
          _isAuthenticating = false;
          notifyListeners();
          return;
        }
        await _loadProfile();
        if (_loginState == LoginState.profileSetup) {
          await Navigator.push(
            buildContext,
            MaterialPageRoute(builder: (context) {
              return SetupProfilePage();
            }),
          );
        }
      }
    } catch (e) {
      print("Error Authentication - $e");
    }
    _isAuthenticating = false;
    notifyListeners();
    if (_loginState == LoginState.loggedIn) {
      postLogin();
    }
  }

  Future<void> _signInWithGoogle() async {
    await init();
    final User? fireAuthUser = _auth?.currentUser;
    // Not Authenticated via FireAuth
    if (fireAuthUser == null) {
      _loginState = LoginState.register;
      GoogleSignInAccount? googleUser;
      GoogleSignIn googleSignIn = _googleSignIn!;
      googleUser = await googleSignIn.signIn();

      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        await _auth?.signInWithCredential(credential);
        _uid = _auth?.currentUser!.uid;
      } else {
        _loginState = LoginState.oauthFailed;
      }
    } else {
      _loginState = LoginState.oauthCompleted;
      _uid = fireAuthUser.uid;
    }
  }

  Future<void> _loadProfile() async {
    final DocumentSnapshot hitchSpotsUser =
        await _firestore!.collection('users').doc(_uid).get();
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
