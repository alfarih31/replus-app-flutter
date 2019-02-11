import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:replus_app/widgets/google_sign_in_btn.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:replus_app/api.dart';
import 'package:replus_app/routes/rooms.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: <String>[
    'email',
    'https://www.googleapis.com/auth/contacts.readonly',
  ],
);
final FlutterSecureStorage cache = FlutterSecureStorage();
final FirebaseAuth _auth = FirebaseAuth.instance;
API apiClient;
Map cacheData;

void main() async {
  cacheData = await cache.readAll();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Replus App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        accentColor: Colors.blueAccent,
      ),
      home: new MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPage createState() => new _MainPage();
}

class _MainPage extends State<MainPage> {
  bool signed;
  bool connection;
  bool signInButton;
  FirebaseUser _currentUser;
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    signed = cacheData['loggedIn'] == '1' ? true : false;
    connection = false;
    signInButton = true;
  }

  void logoutUser(bool state) {
    setState(() {
      signed = state;
      signInButton = !state;});
  }

  Future handleSignIn(bool val) async {
    try {
      await checkConnection(val);
      GoogleSignInAccount currentUser = await _googleSignIn.signIn();
      GoogleSignInAuthentication gSA = await currentUser.authentication;
      final snackbar = SnackBar(
                    content: Text('Signed in Successfully'),
                    backgroundColor: Colors.blueGrey,
                  );
      _currentUser = await _auth.signInWithGoogle(
        idToken: gSA.idToken, accessToken: gSA.accessToken
      );
      apiClient = new API(uid: _currentUser.uid);
      scaffoldKey.currentState.showSnackBar(snackbar);
      await apiClient.initDone;
      cache.write(key: 'uid', value: _currentUser.uid);
      cache.write(key: 'loggedIn', value: '1');
      cacheData = await cache.readAll();
      setState(() => signed = !signed);
    } catch (error) {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Row(
              mainAxisAlignment:  MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Text(error.toString()),
                )
              ],
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Ok'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        }
      );
      setState(() => signInButton = !signInButton);
    }
  }

  Widget buildAuth() {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.grey[200],
      body: ConstrainedBox(
        constraints: const BoxConstraints.expand(),
        child: authScreen(),
        )
    );
  }

  Widget authScreen() {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            child: Image(
              image: AssetImage('assets/images/repluslogo.png'),
              height: 200,
              width: 200,
              color: Colors.blue[900],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              GoogleSignInButton(
                onPressed: handleSignIn,
                isActive: signInButton,
              ),
              Padding(padding: EdgeInsets.all(5.0),),
              SizedBox(
                width: 25.0,
                height: 25.0,
                child: RawMaterialButton(
                  shape: CircleBorder(),
                  elevation: 0.0,
                  onPressed: () {},
                  fillColor: connection ? Colors.green[700] : Colors.red,
                ),
              ),
            ],
          ),
        ],
      );
  }

  Future checkConnection(bool val) async {
    try {
      setState(() => signInButton = val);
      Center(child: CircularProgressIndicator(),);
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        setState(() {connection = !val;});
      }
    } on SocketException catch (_) {
      setState(() => connection = val);
      throw Exception('You\'re offline');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: signed ? Home(firebaseData:_currentUser, logoutTap: logoutUser) : buildAuth(),
    );
  }
}

class Home extends StatelessWidget {
  Home({Key key, @required this.firebaseData, this.logoutTap}) : super(key: key);
  final FirebaseUser firebaseData;
  final ValueChanged<bool> logoutTap;

  Future logOut(BuildContext context) async {
    await _googleSignIn.signOut();
    await cache.deleteAll();
    logoutTap(false);
  }

  @override
  Widget build(BuildContext ctxt) {
    return new DefaultTabController(
      length: 3,
      child: new Scaffold(
        appBar: new AppBar(
          title: new Text('Replus App'),
          bottom: new TabBar(
            tabs: <Widget>[
              new Tab(text: 'Rooms', icon: Icon(Icons.home)),
              new Tab(text: 'Settings', icon: Icon(Icons.settings)),
            ],
          ),
          leading: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(padding: EdgeInsets.all(5.0),),
              ImageIcon(
                AssetImage('assets/images/repluslogo.png'),
                size: 46.0,
                color: Colors.blue[900],
              ),
            ],
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.exit_to_app, size: 36.0,),
              onPressed: () => logOut(ctxt),
            ),
          ],
        ),
        body: new TabBarView(
          children: <Widget>[
            new MainRoom(uid: cacheData['uid']),
            new Text('Settings Page'),
          ],
        ),
      ),
    );
  }
}