// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:fluttersolidauth/models/Constants.dart';

// Widget to setup respostive designs
class Responsive extends StatelessWidget {

  final Widget mobile;
  final Widget tablet;
  final Widget desktop;

  const Responsive({
    Key key,
    @required this.mobile,
    @required this.tablet,
    @required this.desktop,
  }) : super(key: key);

  static bool isMobile(BuildContext context) =>
    screenWidth(context) < 650;

  static bool isTablet(BuildContext context) =>
    screenWidth(context) < 1100 &&
    screenWidth(context) >= 650;

  static bool isDesktop(BuildContext context) =>
    screenWidth(context) >= 1100;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints){
        //If width is more than 1100 consider it as desktop
        if(constraints.maxWidth >= 1100) {
          return desktop;
        } 
        //If width is in between 1100 and 650 consider it as tablet
        else if(constraints.maxWidth >= 650){
          return tablet;
        } 
        //If width is less than 650 consider it as mobile
        else {
          return mobile;
        }
      },
    );
  }
}