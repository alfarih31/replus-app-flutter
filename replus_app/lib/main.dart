import 'package:flutter/material.dart';
import 'package:replus_app/login.dart';

void main() {
  runApp(
    new MaterialApp(
      home: new SignInDemo(),
      routes: <String, WidgetBuilder> {
        '/main': (context) => new Main_page(),
      },
    )
  );
}

class Main_page extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Replus App',
      home: new DefaultTabController(
        length: 2,
        child: new Scaffold(
          appBar: new AppBar(
            title: new Text('Main Page'),
            bottom: new TabBar(
              tabs: <Widget>[
                new Tab(text: 'Rooms'),
                new Tab(text: 'Settings',)
              ],
            ),
          ),
          body: new TabBarView(
            children: <Widget>[
              new Text('ROOMS1, ROOMS 2'),
              new Text('Logout, Status')
            ],
          ),
        ),
      ),
    );
  }
}