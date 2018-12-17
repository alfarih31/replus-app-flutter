import 'dart:async';
import 'dart:convert' show json;

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:replus_app/widgets/google_sign_in_btn.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:replus_app/home.dart';
import 'package:replus_app/api.dart';

GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: <String>[
    'email',
    'https://www.googleapis.com/auth/contacts.readonly',
  ],
);

final FirebaseAuth _auth = FirebaseAuth.instance;

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Replus App',
      home: new MainPage(),
    );
  }
}
class MainPage extends StatefulWidget {
  @override
  MainPageState createState() => new MainPageState();
}

class MainPageState extends State<MainPage> {
  bool signed;
  FirebaseUser _currentUser;
  API apiClient;

  @override
  void initState() {
    super.initState();
    signed = false;
  }

  Future<void> _handleSignIn() async {
    try {
      GoogleSignInAccount currentUser = await _googleSignIn.signIn();
      GoogleSignInAuthentication gSA = await currentUser.authentication;
      _currentUser = await _auth.signInWithGoogle(
        idToken: gSA.idToken, accessToken: gSA.accessToken
      );
      final apiClient = new API(uid: _currentUser.uid);
      await apiClient.init();
      setState(() => status = 'SIGNED_IN');
    } catch (error) {
      print(error);
    }
  }

  Future<void> _handleSignOut() async {
    _googleSignIn.disconnect();
  }

  Widget buildAuth() {
    return MaterialApp(
      title: 'Replus App Authentication',
      theme: ThemeData.dark().copyWith(
            primaryColor: Colors.blueGrey[600],
            accentColor: Colors.deepOrange[200],
          ),
      home: authScreen(),
    );
  }

  Widget authScreen() {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          GoogleSignInButton(
            onPressed: _handleSignIn,
          ),
        ],
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ConstrainedBox(
          constraints: const BoxConstraints.expand(),
          child: signed ? new Home(firebaseData: _currentUser, apiClient: apiClient,) : buildAuth();
        ));
  }
}