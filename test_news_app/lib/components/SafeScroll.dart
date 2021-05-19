import 'package:flutter/material.dart';


class MyBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}

class SafeScroll extends StatelessWidget {
  SafeScroll({ required this.child});
  Widget child;
  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: MyBehavior(),
      child: SingleChildScrollView(child: child),
    );
  }
}
