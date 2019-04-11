import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wtq_admin/main.dart';
import 'package:wtq_admin/model/user.dart';
import 'package:wtq_admin/string_constants.dart';

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  BuildContext _adminPageContext;
  @override
  Widget build(BuildContext context) {
    _adminPageContext = context;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          actions: <Widget>[
            IconButton(
              tooltip: kTxtLogout,
              icon: Icon(Icons.exit_to_app),
              onPressed: () {
                _showSignOutDialog();
              },
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: kTxtCoding),
              Tab(text: kTxtTesting),
              Tab(text: kTxtDesign),
            ],
          ),
          title: Text(kTitleAdmin),
        ),
        body: TabBarView(
          children: [
            _buildListOfCompetition(kFBValueCoding),
            _buildListOfCompetition(kFBValueTesting),
            _buildListOfCompetition(kFBValueDesign),
          ],
        ),
      ),
    );
  }

  void _showSignOutDialog() {
    showDialog(
      context: _adminPageContext,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(kTxtLogout),
          content: Text(kMsgSureToLogout),
          actions: <Widget>[
            FlatButton(
              child: Text(kTxtNo),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text(kTxtYes),
              onPressed: () {
                _onSignOut();
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  void _onSignOut() async {
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (context) => MyHomePage()));
  }

  Widget _buildListOfCompetition(String name) {
    return Container(
      child: _streamBuilder(name),
    );
  }

  StreamBuilder<QuerySnapshot> _streamBuilder(String name) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
          .collection(kKeyUser)
          .where(kFBKeyIsRegistered, isEqualTo: true)
          .where(kFBKeyRegistrationCompetition, isEqualTo: name)
          .orderBy(kFBKeyName)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return Center(
            child: Text(
              kTxtNothingFound,
              style: Theme.of(context).textTheme.title.copyWith(
                    color: Colors.black26,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          );
        return _buildList(context, snapshot.data.documents);
      },
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    if (snapshot == null) return Container();
    if (snapshot.length < 1) return Container();
    return Column(
      children: <Widget>[
        _buildCompetitionCounter(snapshot),
        Expanded(
          child: ListView(
            children:
                snapshot.map((data) => _buildListItem(context, data)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildCompetitionCounter(List<DocumentSnapshot> snapshot) {
    var totalCompParticipants = snapshot.length.toString();
    var confirmedCompParticipants = snapshot
        .where((data) => data[kFBKeyIsRegistrationConfirmed] == true)
        .toList()
        .length
        .toString();
    return Container(
        padding: EdgeInsets.only(top: 24, bottom: 8),
        child: Text(confirmedCompParticipants + "/" + totalCompParticipants));
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    final user = User.fromSnapshot(data);
    Icon listIcon = user.isRegistrationConfirmed
        ? Icon(
            Icons.done,
            color: Colors.green,
          )
        : Icon(Icons.done, color: Colors.grey[300]);
    String thirdLine = "";
    if (user.profession != null) thirdLine = user.profession.organizationName;
    if (user.student != null) thirdLine = user.student.uniName;
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(user.photoUrl),
      ),
      title: _titleWidget(user),
      isThreeLine: true,
      subtitle: Text(user.email + "\n" + thirdLine),
      trailing: listIcon,
      onTap: () {
        _markUserConfirmation(user);
      },
    );
  }

  Widget _titleWidget(User user) {
    return Container(
      child: Row(
        children: <Widget>[
          Expanded(child: Text(user.name, overflow: TextOverflow.ellipsis)),
          _buildProfessionTag(user),
        ],
      ),
    );
  }

  Widget _buildProfessionTag(User user) {
    return Container(
      margin: EdgeInsets.only(left: 4),
      padding: EdgeInsets.only(left: 10, top: 2, right: 10, bottom: 2),
      decoration: BoxDecoration(
          color: user.registration.occupation == kFBKeyStudent
              ? Theme.of(context).accentColor
              : Theme.of(context).primaryColor,
          borderRadius: BorderRadius.all(Radius.circular(10.0))),
      child: Center(
          child: Text(user.registration.occupation,
              style: TextStyle(fontSize: 12, color: Colors.white))),
    );
  }

  void _markUserConfirmation(User user) {
    user.isRegistrationConfirmed = !user.isRegistrationConfirmed;
    Firestore.instance
        .collection(kKeyUser)
        .document(user.id)
        .updateData(user.toJson());
  }
}
