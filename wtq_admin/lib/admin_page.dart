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
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
            actions: <Widget>[
            IconButton(
              icon: Icon(Icons.exit_to_app),
              onPressed: () {
                _onSignOut();
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
      child: Column(
        children: <Widget>[Expanded(child: _streamBuilder(name))],
      ),
    );
  }

  StreamBuilder<QuerySnapshot> _streamBuilder(String name) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
          .collection(kKeyUser)
          .where("isRegistered", isEqualTo: true).where("registration.competition", isEqualTo: name)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return Center(
            child: Text(
              'Nothing found!',
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
    return ListView(
      padding: const EdgeInsets.only(top: 20.0),
      children: snapshot.map((data) => _buildListItem(context, data)).toList(),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    final user = User.fromSnapshot(data);
    print(user.isRegistrationConfirmed);
    Icon listIcon = user.isRegistrationConfirmed
        ? Icon(
            Icons.done,
            color: Colors.green,
          )
        : Icon(Icons.done, color: Colors.grey[300]);
    return ListTile(
      title: Text(user.name),
      subtitle: Text(user.email),
      trailing: listIcon,
      onTap: () {
        _markUserConfirmation(user);
      },
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
