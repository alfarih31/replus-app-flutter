import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:replus_app/widgets/google_sign_in_btn.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:replus_app/api.dart';
import 'package:replus_app/room.dart';

GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: <String>[
    'email',
    'https://www.googleapis.com/auth/contacts.readonly',
  ],
);

final FirebaseAuth _auth = FirebaseAuth.instance;
API apiClient;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Replus App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
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
    signed = false;
    connection = false;
    signInButton = true;
  }

  Future<void> handleSignIn() async {
    try {
      await checkConnection();
      GoogleSignInAccount currentUser = await _googleSignIn.signIn();
      GoogleSignInAuthentication gSA = await currentUser.authentication;
      final snackbar = SnackBar(
                    content: Text('Signed in Successfully'),
                    backgroundColor: Colors.blueGrey,
                  );
      scaffoldKey.currentState.showSnackBar(snackbar);
      _currentUser = await _auth.signInWithGoogle(
        idToken: gSA.idToken, accessToken: gSA.accessToken
      );
      apiClient = new API(uid: _currentUser.uid);
      await apiClient.initDone;
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
                  setState(() => signInButton = !signInButton);
                },
              ),
            ],
          );
        }
      );
      throw Exception(error.toString());
    }
  }

  Future signInPressed(bool val) async {
    setState(() => signInButton = val);
    Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        CircularProgressIndicator(),
      ],
    );
    try {
      await handleSignIn();
      setState(() => signed = !signed);
    } catch(error) {}
  }

  Widget buildAuth() {
    return Scaffold(
      key: scaffoldKey,
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
                onPressed: connection ? signInPressed : checkConnection(),
                isActive: signInButton,
              ),
              Padding(padding: EdgeInsets.all(5.0),),
              SizedBox(
                width: 25.0,
                height: 25.0,
                child: RawMaterialButton(
                  shape: CircleBorder(),
                  elevation: 5.0,
                  onPressed: () {},
                  fillColor: connection ? Colors.green[700] : Colors.red,
                ),
              ),
            ],
          ),
        ],
      );
  }

  Future<void> checkConnection() async {
    try {
      Center(child: CircularProgressIndicator(),);
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        setState(() => connection = true);
      }
    } on SocketException catch (_) {
      connection = false;
      throw Exception('You\'re offline');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: signed ? Home(firebaseData:_currentUser) : buildAuth(),
    );
  }
}
class Home extends StatelessWidget {
  Home({Key key, @required this.firebaseData,}) : super(key: key);
  final FirebaseUser firebaseData;
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext ctxt) {
    return new DefaultTabController(
      length: 3,
      child: new Scaffold(
        key: scaffoldKey,
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
        ),
        body: new TabBarView(
          children: <Widget>[
            Center(
              child: FutureBuilder(
                future: apiClient.getUserData(),
                builder: (ctxt, snapshot) {
                  if(snapshot.connectionState == ConnectionState.done) {
                    if(snapshot.hasData) return new MainRoom(uid: firebaseData.uid, userData: snapshot.data,);
                  } else return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      CircularProgressIndicator(),
                      Padding(padding: EdgeInsets.all(5.0),),
                      Text('Fetching user data...', style: TextStyle(fontSize: 12.0, color: Colors.blueGrey),),
                    ],
                  );
                },
              ),
            ),
            new Text('Settings Page'),
          ],
        ),
      ),
    );
  }
}