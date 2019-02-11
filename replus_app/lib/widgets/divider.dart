import 'package:flutter/material.dart';

class RowDivider extends StatelessWidget {
  final double height;
  final Color color;
  RowDivider({this.height, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: 1.1,
      color: color,
      margin: const EdgeInsets.only(right: 10.0, left: 10.0),
    );
  }
}

class ColumnDivider extends StatelessWidget {
  final double width;
  final Color color;
  ColumnDivider({this.width, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1.1,
      width: width,
      color: color,
      margin: const EdgeInsets.only(top: 10.0, bottom: 10.0),
    );
  }
}