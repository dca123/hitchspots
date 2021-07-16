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

  AuthenticationState(
      {GoogleSignIn? mockSignIn,
      FirebaseAuth? mockFirebaseAuth,
      FirebaseFirestore? mockFirebaseFirestore,
      String? displayName}) {
    _googleSignIn = mockSignIn;
    _auth = mockFirebaseAuth;
    _firestore = mockFirebaseFirestore;
    _displayName = displayName;
  }

  Future<void> ensureFirebaseInit() async {
    if (Firebase.apps.length < 1) {
      await Firebase.initializeApp();
    }
    _auth ??= FirebaseAuth.instance;
    _firestore ??= FirebaseFirestore.instance;
    _googleSignIn ??= GoogleSignIn();
    if (_checkandLoadFireAuthUser()) {
      await _loadProfile();
    }
  }

  Future<void> loginFlowWithAction(
      {required Function postLogin, required BuildContext buildContext}) async {
    _isAuthenticating = true;
    notifyListeners();
    try {
      if (_loginState != LoginState.loggedIn) {
        if (!_checkandLoadFireAuthUser()) {
          await _signInWithGoogle();
        }
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

  ///Checks for the firebase auth user and loads it if it exists
  bool _checkandLoadFireAuthUser() {
    final User? fireAuthUser = _auth?.currentUser;
    if (fireAuthUser != null) {
      _loginState = LoginState.oauthCompleted;
      _uid = fireAuthUser.uid;
      return true;
    }
    return false;
  }

  /// Sign in via google when not authenticated via FireAuth
  Future<void> _signInWithGoogle() async {
    await ensureFirebaseInit();
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

  void logout() {
    _auth!.signOut();
    _resetAuthState();
    _loginState = LoginState.loggedOut;
  }

  void _resetAuthState() {
    _uid = null;
    _displayName = null;
  }
}
