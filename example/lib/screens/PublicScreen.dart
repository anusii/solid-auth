// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:fluttersolidauth/models/Responsive.dart';
import 'package:fluttersolidauth/screens/PublicProfile.dart';

class PublicScreen extends StatelessWidget {
  String webId;

  PublicScreen({Key? key, required this.webId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Navigate to public profile with a loading screen
    var loadingScreen = PublicProfile(webId: webId);
    return Scaffold(
        body: Responsive(
      mobile: loadingScreen,
      tablet: loadingScreen,
      desktop: loadingScreen,
    ));
  }
}
