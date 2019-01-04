import 'package:flutter/material.dart';

class ShowSnackBar {
  final GlobalKey<ScaffoldState> scaffoldKey;
  ShowSnackBar({this.scaffoldKey});

  void show(String action, bool active) {
    final snackbar =  active ?
                  SnackBar(
                    backgroundColor: Colors.blueGrey,
                    content: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text('$action room...'),
                      CircularProgressIndicator(),
                      ],
                    ),
                  ) :
                  SnackBar(
                    backgroundColor: Colors.blueGrey,
                    duration: Duration(seconds: 2),
                    content: Text('$action room success'),
                    action: SnackBarAction(
                      label: 'OK',
                      onPressed: () {},
                    ),
                  );
    scaffoldKey.currentState.showSnackBar(snackbar);
  }
}
