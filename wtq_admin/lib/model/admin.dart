import 'package:cloud_firestore/cloud_firestore.dart';

class Admin {
  final String email;

  Admin({
    this.email,
  });

  Admin.fromMap(Map<String, dynamic> map)
      : email = map['email'];

  Map<String, dynamic> toJson() => {
        "email": email,
      };

  Admin.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data);
}
