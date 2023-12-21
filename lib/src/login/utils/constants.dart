import 'package:flutter/material.dart';

class DateConfig {
  static const String APP_DATE = String.fromEnvironment("APP_DATE");
}

double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;
double screenHeight(BuildContext context) => MediaQuery.of(context).size.height;

Color stripBackgroundColor = Colors.grey[300]!;
Color stripTextColor = Colors.grey[600]!;
const Color kBgDarkColor = Color(0xFFD8ECF3);
const Color kTitleTextColor = Color(0xFF30384D);
const kPrimaryColor = Color(0xFFDBBA78);
const anuGold = Color(0xFFBE830E);
const anuBrickRed = Color(0xFFD89E7A);
const anuLightGold = Color(0xFFDBBA78);
const anuCopper = Color(0xFFBE4E0E);
const autumnBrown = Color(0xFFb65d22);

List<Color> kDefaultSiiColors = const [
  anuLightGold,
  anuBrickRed,
  anuGold,
  autumnBrown,
  anuCopper,
];

String APP_VERSION = "";
const SOLID_REGISTER_URL = "/idp/register/";

const double smallTextContainerHeight = 20;
const double smallTextSize = 14.0;

/// Directory name constants
const MAIN_RES_DIR = "solid-health";
const MED_DIR = "medical";
const SHARING_DIR = "sharing";
const SHARED_DIR = "shared";
const UPDATES_DIR = "updates";
const ENC_DIR = "encryption";
const ANALYTIC_DIR = "analytics";
const LOGS_DIR = "logs";
const PROFILE = "profile";
const CARD_ME = "card#me";
const UPDATE_DIR = "updates";

const PUB_KEY_FILE = "public-key.ttl";
const PERM_LOG_FILE = "permissions-log.ttl";
const MED_FILE = "medical.ttl";

const ENC_KEY_FILE = "enc-keys.ttl";
const IND_KEY_FILE = "ind-keys.ttl";

const PROFILE_POSTFIX = "profile/card#me";
const UPDATE_FILE_LOC = "$MAIN_RES_DIR/$UPDATE_DIR/";


// Folders
const List<String> FOLDERS = [
  MAIN_RES_DIR,
  '$MAIN_RES_DIR/$SHARING_DIR',
  '$MAIN_RES_DIR/$SHARED_DIR',
  '$MAIN_RES_DIR/$MED_DIR',
  '$MAIN_RES_DIR/$ENC_DIR',
  '$MAIN_RES_DIR/$LOGS_DIR'
];

const SHARED_DIR_PAT = "$MAIN_RES_DIR/$SHARED_DIR/";
// const UPDATE_FILE_LOC = "$MAIN_RES_DIR/$UPDATES_DIR/";

const PROFILE_CARD_ME = "$PROFILE/$CARD_ME";

/// Directory path constants
const MED_DIR_LOC = "$MAIN_RES_DIR/$MED_DIR";
const SHARING_DIR_LOC = "$MAIN_RES_DIR/$SHARING_DIR";
const SHARED_DIR_LOC = "$MAIN_RES_DIR/$SHARED_DIR";
const ENC_DIR_LOC = "$MAIN_RES_DIR/$ENC_DIR";
const LOG_DIR_LOC = "$MAIN_RES_DIR/$LOGS_DIR";

// Files
const Map FILES = {
  '$SHARING_DIR_LOC': [
    PUB_KEY_FILE,
    '$PUB_KEY_FILE.acl',
  ],
  '$LOG_DIR_LOC': [
    PERM_LOG_FILE,
    '$PERM_LOG_FILE.acl',
  ],
  '$SHARED_DIR_LOC': ['.acl'],
  '$MED_DIR_LOC': [MED_FILE, '$MED_FILE.acl'],
  '$ENC_DIR_LOC': [ENC_KEY_FILE, IND_KEY_FILE],
};
