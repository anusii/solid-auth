// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:fluttersolidauth/models/Responsive.dart';
import 'package:fluttersolidauth/screens/PrivateProfile.dart';
import 'package:fluttersolidauth/models/Constants.dart';

class PrivateScreen extends StatelessWidget {
  Map authData; // Authentication data
  String webId; // User WebId
  PrivateScreen({Key key, @required this.authData, @required this.webId}): super(key: key);

  @override
  Widget build(BuildContext context) {
    // Assign loading screen
    var loadingScreen = PrivateProfile(authData: authData, webId: webId);

    // Setup Scaffold to be responsive
    return Scaffold(
      body: Responsive(
        mobile: loadingScreen, 
        tablet: Row(
          children: [
            Expanded(
              flex: 10,
              child: loadingScreen,
            ),
          ],
        ),
        desktop: Row(
          children: [
            Expanded(
              flex: screenWidth(context) < 1300 ? 10 : 8,
              child: loadingScreen,
            ),
          ],
        ),
      )
    );
  }
}
