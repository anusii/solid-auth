part of solid_auth;

typedef AuthWidgetBuilder = Widget Function(
    BuildContext context, Map authData, String webId);

class PodLoginScreen extends StatefulWidget {
  final String serverURL;
  final String solidPageURL;
  final String solidProjectURL;
  final String pageHeader;
  final ImageProvider backgroundImage;
  final SvgPicture? svgPic;
  final Image? assetImage;
  final Color cardColor;
  final List<AuthWidgetBuilder> widgetBuilders;
  const PodLoginScreen(
      {Key? key,
      required this.serverURL,
      required this.solidPageURL,
      required this.solidProjectURL,
      required this.pageHeader,
      required this.backgroundImage,
      this.svgPic,
      this.assetImage,
      required this.cardColor,
      required this.widgetBuilders})
      : super(key: key);

  @override
  State<PodLoginScreen> createState() => _PodLoginScreenState();
}

class _PodLoginScreenState extends State<PodLoginScreen> {
  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: 'Unknown',
    installerStore: 'Unknown',
  );

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;

      APP_VERSION = DateConfig.APP_DATE == ''
          ? "Version ${_packageInfo.version} of today"
          : "Version ${_packageInfo.version} of ${DateConfig.APP_DATE}";
    });
  }

  // @override
  // Widget build(BuildContext context) {
  //   var webIdController = TextEditingController()..text = widget.serverURL;

  //   return const Placeholder();
  // }

  @override
  Widget build(BuildContext context) {
    var webIdController = TextEditingController()..text = widget.serverURL;
    return Scaffold(
        body: SafeArea(
            child: Container(
      decoration: screenWidth(context) < 1175
          ? BoxDecoration(
              image: DecorationImage(
                  //image: AssetImage('assets/images/anu_aerial_view_square.jpg'),
                  image: widget.backgroundImage,
                  fit: BoxFit.cover))
          : null,
      child: Row(
        children: [
          screenWidth(context) < 1175
              ? Container()
              : Expanded(
                  flex: 7,
                  child: Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: widget.backgroundImage, fit: BoxFit.cover)),
                  )),
          Expanded(
              flex: 5,
              child: Container(
                margin: EdgeInsets.symmetric(
                    horizontal: screenWidth(context) < 1175
                        ? screenWidth(context) < 750
                            ? screenWidth(context) * 0.05
                            : screenWidth(context) * 0.25
                        : screenWidth(context) * 0.05),
                //margin: EdgeInsets.symmetric(horizontal: 50),
                child: SingleChildScrollView(
                  child: Card(
                    elevation: 5,
                    color: widget.cardColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    child: Column(
                      children: [
                        Container(
                          height: screenHeight(context) > 750 ? 500 : 485,
                          padding: EdgeInsets.all(30),
                          child: Column(
                            children: [
                              widget.svgPic != null
                                  ? GestureDetector(
                                      onTap: () => launchUrl(
                                          Uri.parse(widget.solidPageURL)),
                                      child: Container(
                                        height: 180,
                                        margin:
                                            EdgeInsets.only(left: 0, right: 20),
                                        child: widget.svgPic,
                                      ),
                                    )
                                  : Container(),
                              widget.assetImage ?? Container(),
                              Divider(height: 15, thickness: 2),
                              SizedBox(
                                height: 20,
                              ),
                              Text(widget.pageHeader,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Colors.black,
                                  )),
                              SizedBox(
                                height: 20.0,
                              ),
                              TextFormField(
                                controller: webIdController,
                                decoration: InputDecoration(
                                  border: UnderlineInputBorder(),
                                ),
                              ),
                              screenHeight(context) > 720
                                  ? SizedBox(
                                      height: 20.0,
                                    )
                                  : SizedBox(
                                      height: 10.0,
                                    ),
                              createSolidLoginRow(
                                  context,
                                  webIdController,
                                  FOLDERS,
                                  FILES,
                                  widget.widgetBuilders.first,
                                  widget.widgetBuilders.last),
                              SizedBox(
                                height: 20.0,
                              ),
                              Align(
                                  alignment: Alignment.centerRight,
                                  child: GestureDetector(
                                    onTap: () => launchUrl(
                                        Uri.parse(widget.solidProjectURL)),
                                    child: Container(
                                      margin:
                                          EdgeInsets.only(left: 0, right: 20),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Text('Visit '),
                                          Text(
                                            widget.solidProjectURL,
                                            textAlign: TextAlign.right,
                                            style: TextStyle(
                                                fontSize:
                                                    screenWidth(context) > 400
                                                        ? 15
                                                        : 13,
                                                color: Colors.blue,
                                                decoration:
                                                    TextDecoration.underline),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )),
                            ],
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(15),
                              bottomRight: Radius.circular(15),
                            ),
                            color: stripBackgroundColor,
                          ),
                          height: smallTextContainerHeight,
                          child: Center(
                            child: Text(
                              APP_VERSION,
                              style: TextStyle(
                                color: stripTextColor,
                                fontSize: smallTextSize,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              )),
        ],
      ),
    )));
  }

  Row createTextLabel(String labelText) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 60.0,
        ),
        Text(
          'Use $labelText',
          style: TextStyle(
            color: Colors.grey[900],
            letterSpacing: 2.0,
            fontSize: 17.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(
          height: 25.0,
        ),
      ],
    );
  }

  launchIssuerReg(String _issuerUri) async {
    var url;
    if (_issuerUri == widget.serverURL) {
      url = '$_issuerUri/idp/reg';
    } else {
      url = '$_issuerUri/register';
    }

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Row createSolidLoginRow(
    BuildContext context,
    TextEditingController _webIdTextController,
    List<String> FOLDERS,
    Map FILES,
    AuthWidgetBuilder existConditionBuilder,
    AuthWidgetBuilder noExistsConditionBuilder,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Expanded(
            child: TextButton(
          style: TextButton.styleFrom(
            padding: screenHeight(context) > 720
                ? EdgeInsets.all(20)
                : EdgeInsets.all(10),
            backgroundColor: kBgDarkColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () async {
            String _issuerUri = await getIssuer(_webIdTextController.text);
            String reg_url = _issuerUri + SOLID_REGISTER_URL;
            launchUrl(Uri.parse(reg_url));
          },
          child: Text(
            'NEW POD',
            style: TextStyle(
              color: kTitleTextColor,
              letterSpacing: 2.0,
              fontSize: 15.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        )),
        SizedBox(
          width: 15.0,
        ),
        Expanded(
          child: TextButton(
            style: TextButton.styleFrom(
              padding: screenHeight(context) > 720
                  ? EdgeInsets.all(20)
                  : EdgeInsets.all(10),
              backgroundColor: kPrimaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              showAnimationDialog(
                context,
                7,
                'Logging in...',
                false,
              );

              String _issuerUri = await getIssuer(_webIdTextController.text);

              final List<String> _scopes = <String>[
                'openid',
                'profile',
                'offline_access',
              ];

              var authData =
                  await authenticate(Uri.parse(_issuerUri), _scopes, context);

              //var rsaInfo = authData['rsaInfo'];
              //var tokenResponse = authData['tokenResponse'];
              //var rsaKeyPair = rsaInfo['rsa'];
              //var publicKeyJwk = rsaInfo['pubKeyJwk'];

              /// Perform check to see whether all required resources exists.
              List resCheckList =
                  await restApi.initialStructureTest(authData, FOLDERS, FILES);
              bool allExists = resCheckList.first;

              if (allExists) {
                imageCache.clear();

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => existConditionBuilder(
                        context, authData, _webIdTextController.text),
                  ),
                  (Route<dynamic> route) =>
                      false, // This predicate ensures all previous routes are removed
                );
              } else {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => noExistsConditionBuilder(
                        context, authData, _webIdTextController.text),
                  ),
                );
              }
            },
            child: Text(
              'LOGIN',
              style: TextStyle(
                color: Colors.white,
                letterSpacing: 2.0,
                fontSize: 15.0,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ),
      ],
    );
  }
}

Widget loginPage(
    String serverURL,
    String solidPageURL,
    String solidProjectURL,
    String pageHeader,
    ImageProvider backgroundImage,
    SvgPicture? svgPic,
    Image? assetImage,
    Color cardColor,
    List<AuthWidgetBuilder> widgetBuilders) {
  return PodLoginScreen(
    serverURL: serverURL,
    solidPageURL: solidPageURL,
    solidProjectURL: solidProjectURL,
    pageHeader: pageHeader,
    backgroundImage: backgroundImage,
    cardColor: cardColor,
    widgetBuilders: widgetBuilders,
  );
}
