import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wtq_admin/admin_page.dart';
import 'package:wtq_admin/string_constants.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:wtq_admin/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: kTxtAppTitle,
      theme: theme,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  BuildContext homeContext;
  bool _isLoading;

  @override
  void initState() {
    super.initState();
    _isLoading = false;
    ifUserLoggedIn();
  }

  Future ifUserLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getKeys().contains(kKeyIsLoggedIn) &&
        prefs.getBool(kKeyIsLoggedIn)) {
      _navigateToAdminPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    homeContext = context;
    return Scaffold(
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Container(
      child: Stack(children: <Widget>[
        _buildBackground(),
        _buildLoginButton(),
      ]),
    );
  }

  Widget _buildBackground() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
            padding: EdgeInsets.only(left: 64.0, right: 64.0),
            child: Image.asset(kImgWTQLogo)),
        Text(kTxtAdminApp,
            style: TextStyle(
                color: Theme.of(context).accentColor,
                fontWeight: FontWeight.bold,
                fontSize: 25.0)),
        _showLoader(_isLoading),
      ],
    );
  }

  Widget _buildLoginButton() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.only(bottom: 64.0),
        child: RaisedButton(
          child: const Text(
            kTxtLogin,
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          color: Theme.of(context).accentColor,
          elevation: 4.0,
          splashColor: Colors.blueGrey,
          onPressed: () {
            _handleSignIn();
          },
        ),
      ),
    );
  }

  Widget _showLoader(bool isLoading) {
    if (!isLoading) {
      return Container(
        height: 10,
      );
    }

    return Container(
        height: 10,
        alignment: Alignment.center,
        child: FadingText(kTxtLoading));
  }

  Future _handleSignIn() async {
    if (_isLoading) {
      return;
    }
    setState(() {
      _isLoading = true;
    });

    try {
      FirebaseUser authenticatedUser = await _authenticateUser();
      var userFromDB = await Firestore.instance
          .collection(kKeyAdmin)
          .where("email", isEqualTo: authenticatedUser.email)
          .getDocuments();
      setState(() {
        _isLoading = false;
      });
      if (userFromDB == null ||
          userFromDB.documents == null ||
          userFromDB.documents.length < 1) {
        signOut();
        _showUnauthorizedDialog();
        return;
      }
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool(kKeyIsLoggedIn, true);
      _navigateToAdminPage();
    } catch (ex) {
      print(ex);
      if (_isLoading) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<FirebaseUser> _authenticateUser() async {
    final GoogleSignIn _googleSignIn = GoogleSignIn();
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final FirebaseUser user = await _auth.signInWithCredential(credential);
    return user;
  }

  void _navigateToAdminPage() {
    Navigator.of(homeContext).pushReplacement(
      MaterialPageRoute(builder: (context) => AdminPage()),
    );
  }

  void signOut() async {
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
  }

  void _showUnauthorizedDialog() {
    showDialog(
      context: homeContext,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text(kMsgUnauthCredentials),
          content: new Text(kMsgUseAuthCredentials),
          actions: <Widget>[
            new FlatButton(
              child: new Text(kTxtOk),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
