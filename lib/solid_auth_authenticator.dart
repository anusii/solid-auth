part of solid_auth;

Future<void> login(
    BuildContext context,
    String webIdStr,
    List<String> folders,
    Map files,
    FlutterSecureStorage secureStorage,
    WidgetBuilder navToPage) async {
  String issuerUri = await getIssuer(webIdStr);

  // Define scopes. Also possible scopes -> webid, email, api
  final List<String> scopes = <String>[
    'openid',
    'profile',
    'offline_access',
  ];

  // Authentication process for the POD issuer
  var authData =
      // ignore: use_build_context_synchronously
      await authenticate(Uri.parse(issuerUri), scopes, context);

  // Decode access token to get the correct webId
  String accessToken = authData['accessToken'];
  Map<String, dynamic> decodedToken = JwtDecoder.decode(accessToken);
  String webId = decodedToken['webid'];

  // Perform check to see whether all required resources exists
  List resCheckList = await initialStructureTest(authData, folders, files);
  bool allExists = resCheckList.first;

  if (allExists) {
    imageCache.clear();

    // Get profile information
    var rsaInfo = authData['rsaInfo'];
    var rsaKeyPair = rsaInfo['rsa'];
    var publicKeyJwk = rsaInfo['pubKeyJwk'];
    String accessToken = authData['accessToken'];
    String profCardUrl = webId.replaceAll('#me', '');
    String dPopToken =
        genDpopToken(profCardUrl, rsaKeyPair, publicKeyJwk, 'GET');

    String profData = await fetchPrvFile(profCardUrl, accessToken, dPopToken);

    Map profInfo = getFileContent(profData);
    authData['name'] = profInfo['fn'][1];

    // Check if master key is set in the local storage
    bool isKeyExist = await secureStorage.containsKey(
      key: webId,
    );
    authData['keyExist'] = isKeyExist;

    // Navigate to the profile through main screen
    // ignore: use_build_context_synchronously
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: navToPage),
    );
  }
}

/// [files] eg.
// {  sharingDirLoc: [
//     pubKeyFile,
//     '$pubKeyFile.acl',
//   ],
//   logDirLoc: [
//     permLogFile,
//     '$permLogFile.acl',
//   ],
//   sharedDirLoc: ['.acl'],
//   encDirLoc: [encKeyFile, indKeyFile],
// };

Future<List> initialStructureTest(
    Map authData, List<String> folders, Map files) async {
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
    if (await checkResourceExists(resourceUrl, accessToken, dPopToken, false) ==
        'not-exist') {
      allExists = false;
      String resourceUrlStr =
          webId.replaceAll('profile/card#me', containerName);
      resNotExist['folders'].add(resourceUrlStr);
      resNotExist['folderNames'].add(containerName);
    }
  }

  for (var containerName in files.keys) {
    List fileNameList = files[containerName];
    for (String fileName in fileNameList) {
      String resourceUrl =
          webId.replaceAll('profile/card#me', '$containerName/$fileName');
      String dPopToken =
          genDpopToken(resourceUrl, rsaKeyPair, publicKeyJwk, 'GET');
      if (await checkResourceExists(
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

Future<String> checkResourceExists(
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
      'DPoP': dPopToken,
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

Future<String> fetchPrvFile(
  String profCardUrl,
  String accessToken,
  String dPopToken,
) async {
  //return 'This is async function demo';
  final profResponse = await http.get(
    Uri.parse(profCardUrl),
    headers: <String, String>{
      'Accept': '*/*',
      'Authorization': 'DPoP $accessToken',
      'Connection': 'keep-alive',
      'DPoP': dPopToken,
    },
  );

  if (profResponse.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return profResponse.body;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    //print(profResponse.body);
    throw Exception('Failed to load profile data! Try again in a while.');
  }
}

Map getFileContent(String fileInfo) {
  Graph g = Graph();
  g.parseTurtle(fileInfo);
  Map fileContentMap = {};
  List fileContentList = [];
  for (Triple t in g.triples) {
    /**
     * Use
     *  - t.sub -> Subject
     *  - t.pre -> Predicate
     *  - t.obj -> Object
     */
    String predicate = t.pre.value;
    if (predicate.contains('#')) {
      String subject = t.sub.value;
      String attributeName = predicate.split('#')[1];
      String attrVal = t.obj.value;
      if (attributeName != 'type') {
        fileContentList.add([subject, attributeName, attrVal]);
      }
      fileContentMap[attributeName] = [subject, attrVal];
    }
  }

  return fileContentMap;
}
