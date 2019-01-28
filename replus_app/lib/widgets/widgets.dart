import 'package:flutter/material.dart';

class ShowSnackBar {
  final GlobalKey<ScaffoldState> scaffoldKey;
  ShowSnackBar({this.scaffoldKey});

  void show(String action, bool active, bool status) {
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
                    content: Text(status ? '$action room success' : '$action room failed'),
                    action: SnackBarAction(
                      label: 'OK',
                      onPressed: () {},
                    ),
                  );
    scaffoldKey.currentState.showSnackBar(snackbar);
  }
}

class CustomDialog extends StatelessWidget {
  final String title, hintText, caption, validate, labelText;
  final IconData icon;
  final ValueChanged onPressed;
  final TextEditingController controller;
  final GlobalKey<FormState> formKey;
  CustomDialog({this.hintText,
                this.title,
                this.caption,
                this.labelText,
                this.validate,
                this.icon,
                this.onPressed,
                this.controller,
                this.formKey});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      child: Container(
        color: Colors.white10,
        alignment: Alignment.center,
        child: Container(
          height: 240,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25.0),
            color: Colors.white,
            border: Border.all(
              color: Colors.blueGrey,
              width: 2.0,
            )
          ),
          margin: EdgeInsets.only(left: 20.0, right:20.0),
          child: ListView(
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            children: <Widget>[
              SizedBox(
                height: 55,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25.0),
                      topRight: Radius.circular(25.0),
                    ),
                    color: Colors.blue[300],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Padding(padding: EdgeInsets.all(4.0),),
                      Icon(icon, size: 45, color: Colors.white,),
                      Padding(padding: EdgeInsets.all(4.0),),
                      Material(
                        color: Colors.transparent,
                        child: Text(title, style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white,),),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                color: Colors.transparent,
                width: 340.0,
                height: 175.0,
                child: Scaffold(
                  backgroundColor: Colors.transparent,
                  body: Container(
                    margin: EdgeInsets.fromLTRB(10.0, 12.0, 10.0, 0),
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[Text(caption, style: TextStyle(color: Colors.blue, fontSize: 22.0),)],
                          ),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: labelText,
                              hintText: hintText,
                              fillColor: Colors.white,
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                )
                              ),
                            autofocus: true,
                            controller: controller,
                            keyboardType: TextInputType.text,
                            validator: (value) {
                              if(value.isEmpty) return validate;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  floatingActionButton: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          IconButton(
                            highlightColor: Colors.blueGrey[300],
                            icon: Icon(Icons.clear, color: Colors.red, size: 35.0),
                            onPressed: () {
                              FocusScope.of(context).requestFocus(FocusNode());
                              Navigator.of(context).pop();
                            },
                          ),
                          Padding(padding: EdgeInsets.all(12.0),),
                          IconButton(
                            highlightColor: Colors.blueGrey[300],
                            icon: Icon(Icons.save, color: Colors.blue, size: 35.0,),
                            onPressed: () {
                              if(formKey.currentState.validate()) {
                                Navigator.of(context).pop();
                                onPressed(Null);
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  resizeToAvoidBottomPadding: false,
                ),
              ),
            ],
          ),
        )
      ),
    );
  }
}
