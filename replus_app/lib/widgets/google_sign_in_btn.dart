import 'package:flutter/material.dart';

class GoogleSignInButton extends StatelessWidget {
  final ValueChanged<bool> onPressed;
  final bool isActive;

  GoogleSignInButton({
    Key key,
    this.onPressed,
    this.isActive,
  }) : super(key: key);

  void handleTap(){
    onPressed(!isActive);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: isActive ? handleTap : null,
      color: Colors.white,
      elevation: 4.0,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Image.asset(
            "assets/images/glogo.png",
            height: 18.0,
            width: 18.0,
          ),
          SizedBox(width: 16.0),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              "Sign in with Google",
              style: TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
