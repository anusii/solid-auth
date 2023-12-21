// Dart imports:
import 'dart:async';
import 'dart:math';

// Package imports:
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:solid_auth/solid_auth.dart';
import 'package:solid_auth/src/models/get_rdf_data.dart';

const _chars =
    'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890_-';
const _hexChars = '0123456789abcdef';
Random _rnd = Random();

String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
    length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

String getRandomHex(int length) => String.fromCharCodes(Iterable.generate(
    length, (_) => _hexChars.codeUnitAt(_rnd.nextInt(_hexChars.length))));

// Get private profile information using access and dPoP tokens
Future<String> fetchPrvProfile(
    String profCardUrl, String accessToken, String dPopToken) async {
  final profResponse = await http.get(
    Uri.parse(profCardUrl),
    headers: <String, String>{
      'Accept': '*/*',
      'Authorization': 'DPoP $accessToken',
      'Connection': 'keep-alive',
      'DPoP': '$dPopToken',
    },
  );

  if (profResponse.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return profResponse.body;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load profile data! Try again in a while.');
  }
}

// Update profile information
Future<String> updateProfile(String profCardUrl, String accessToken,
    String dPopToken, String query) async {
  final editResponse = await http.patch(
    Uri.parse(profCardUrl),
    headers: <String, String>{
      'Accept': '*/*',
      'Authorization': 'DPoP $accessToken',
      'Connection': 'keep-alive',
      'Content-Type': 'application/sparql-update',
      'Content-Length': query.length.toString(),
      'DPoP': dPopToken,
    },
    body: query,
  );

  if (editResponse.statusCode == 200 || editResponse.statusCode == 205) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return editResponse.body;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to write profile data! Try again in a while.');
  }
}

Future<List> initialStructureTest(
    Map authData, List<String> folders, Map FILES) async {
  var rsaInfo = authData['rsaInfo'];
  var rsaKeyPair = rsaInfo['rsa'];
  var publicKeyJwk = rsaInfo['pubKeyJwk'];
  String accessToken = authData['accessToken'];
  Map<String, dynamic> decodedToken = JwtDecoder.decode(accessToken);

  // Get webID
  String webId = decodedToken['webid'];
  bool allExists = true;
  Map resNotExist = {
    'folders': [],
    'files': [],
    'folderNames': [],
    'fileNames': []
  };

  for (String containerName in folders) {
    String resourceUrl = webId.replaceAll('profile/card#me', '$containerName/');
    String dPopToken =
        genDpopToken(resourceUrl, rsaKeyPair, publicKeyJwk, 'GET');
    if (await checkResourceExistsNew(
            resourceUrl, accessToken, dPopToken, false) ==
        'not-exist') {
      allExists = false;
      String resourceUrlStr =
          webId.replaceAll('profile/card#me', '$containerName');
      resNotExist['folders'].add(resourceUrlStr);
      resNotExist['folderNames'].add(containerName);
    }
  }

  for (var containerName in FILES.keys) {
    List fileNameList = FILES[containerName];
    for (String fileName in fileNameList) {
      String resourceUrl =
          webId.replaceAll('profile/card#me', '$containerName/$fileName');
      String dPopToken =
          genDpopToken(resourceUrl, rsaKeyPair, publicKeyJwk, 'GET');
      if (await checkResourceExistsNew(
              resourceUrl, accessToken, dPopToken, false) ==
          'not-exist') {
        allExists = false;
        resNotExist['files'].add(resourceUrl);
        resNotExist['fileNames'].add(fileName);
      }
    }
  }

  return [allExists, resNotExist];
}

Future<String> checkResourceExistsNew(
    String resUrl, String accessToken, String dPopToken, bool fileFlag) async {
  String contentType;
  String itemType;
  if (fileFlag) {
    contentType = '*/*';
    itemType = '<http://www.w3.org/ns/ldp#Resource>; rel="type"';
  } else {
    /// This is a directory (container)
    contentType = 'application/octet-stream';
    itemType = '<http://www.w3.org/ns/ldp#BasicContainer>; rel="type"';
  }

  final response = await http.get(
    Uri.parse(resUrl),
    headers: <String, String>{
      'Content-Type': contentType,
      'Authorization': 'DPoP $accessToken',
      'Link': itemType,
      'DPoP': '$dPopToken',
    },
  );

  if (response.statusCode == 200 || response.statusCode == 204) {
    // If the server did return a 200 OK response,
    // then return true.
    return 'exist';
  } else if (response.statusCode == 404) {
    // If the server did not return a 200 OK response,
    // then return false.
    return 'not-exist';
  } else {
    return 'other-error';
  }
}

// Generate Sparql query
String genSparqlQuery(
    String action, String subject, String predicate, String object,
    {String? prevObject, String? format}) {
  String query = '';

  switch (action) {
    case "INSERT":
      {
        query = 'INSERT DATA {<$subject> <$predicate> "$object".};';
      }
      break;

    case "DELETE":
      {
        query = 'DELETE DATA {<$subject> <$predicate> "$object".};';
      }
      break;

    case "UPDATE":
      {
        query =
            'DELETE DATA {<$subject> <$predicate> "$prevObject".}; INSERT DATA {<$subject> <$predicate> "$object".};';
      }
      break;

    case "UPDATE_LANG":
      {
        query =
            'DELETE DATA {<$subject> <$predicate> "$prevObject"@en.}; INSERT DATA {<$subject> <$predicate> "$object"@en.};';
      }
      break;

    case "UPDATE_DATE":
      {
        query =
            'DELETE DATA {<$subject> <$predicate> "$prevObject"^^<$format>.}; ' +
                'INSERT DATA {<$subject> <$predicate> "$object"^^<$format>.};';
      }
      break;

    case "READ":
      {
        query = "Invalid";
      }
      break;

    default:
      {
        query = "Invalid";
      }
      break;
  }

  return query;
}

Future<String> getPlainSecureKey(String webId) async {
  FlutterSecureStorage _storage = FlutterSecureStorage();
  String secureKey = await _storage.read(key: webId) ?? '';
  return secureKey;
}

Future<List> getContainerList(Map authData, String containerUrl) async {
  List<String> containerList = [];
  List<String> resourceList = [];
  String homePage;

  var rsaInfo = authData['rsaInfo'];
  var rsaKeyPair = rsaInfo['rsa'];
  var publicKeyJwk = rsaInfo['pubKeyJwk'];

  String accessToken = authData['accessToken'];
  //Map<String, dynamic> decodedToken = JwtDecoder.decode(accessToken);

  String dPopTokenHome =
      genDpopToken(containerUrl, rsaKeyPair, publicKeyJwk, 'GET');

  final profResponse = await http.get(
    Uri.parse(containerUrl),
    headers: <String, String>{
      'Accept': '*/*',
      'Authorization': 'DPoP $accessToken',
      'Connection': 'keep-alive',
      'DPoP': '$dPopTokenHome',
    },
  );

  if (profResponse.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    //var tagObjsJson = jsonDecode(profResponse.body) as Map;
    homePage = profResponse.body;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load profile data! Try again in a while.');
  }

  PodProfile homePageFile = PodProfile(homePage);

  List rdfDataPrefixList = homePageFile.dividePrvRdfData();
  List rdfDataList = rdfDataPrefixList.first;

  for (var i = 0; i < rdfDataList.length; i++) {
    if (rdfDataList[i].contains('ldp:contains')) {
      var itemList = rdfDataList[i].split('<');

      for (var j = 0; j < itemList.length; j++) {
        // if (containerList.length >= 200) {
        //   break;
        // }
        if (itemList[j].contains('/>')) {
          var item = itemList[j].replaceAll('/>,', '');
          item = item.replaceAll('/>.', '');
          item = item.replaceAll(' ', '');
          // if((item.contains('H')) | (item.contains('R'))){
          //   containerList.add(item);
          // }
          containerList.add(item);
        } else if (itemList[j].contains('>')) {
          var item = itemList[j].replaceAll('>,', '');
          item = item.replaceAll('>.', '');
          item = item.replaceAll(' ', '');
          resourceList.add(item);
        }
      }
    }
  }

  return [containerList, resourceList];
}
