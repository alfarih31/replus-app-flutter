import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:replus_app/api.dart';

class Home extends StatelessWidget {
  Home({Key key, @required this.firebaseData, @required this.apiClient})
    : super(key: key);
  final FirebaseUser firebaseData;
  final API apiClient;

  Future<String> fetch() async {
    return apiClient.getToken();
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
              new Tab(text: 'Rooms',),
              new Tab(text: 'Settings',),
            ],
          ),
        ),
        body: new TabBarView(
          children: <Widget>[
            Center(
              child: FutureBuilder<String>(
                future: fetch(),
                builder:(context, snapshot){
                  if(snapshot.hasData) return Text(snapshot.data);
                  else if(snapshot.hasError) return Text(snapshot.error);
                  return new CircularProgressIndicator();
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