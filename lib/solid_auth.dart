library solid_auth;

/// Dart imports:
import 'dart:async';
import 'dart:convert';

/// Flutter imports:
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

/// Package imports:
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fast_rsa/fast_rsa.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:rdflib/rdflib.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


/// Project imports:
import 'package:solid_auth/platform_info.dart';
import 'package:solid_auth/src/openid/openid_client_io.dart' as oidc_mobile;
import 'package:solid_auth/src/auth_manager/auth_manager_abstract.dart';
import 'package:solid_auth/src/openid/openid_client.dart';
import 'package:solid_auth/src/jwt/dart_jsonwebtoken.dart';

part 'solid_auth_client.dart';
part 'solid_auth_issuer.dart';
part 'solid_auth_authenticator.dart';

/// Set port number to be used in localhost
const int _port = 4400;

/// To get platform information
PlatformInfo currPlatform = PlatformInfo();

/// Initialise authentication manager
AuthManager authManager = AuthManager();
