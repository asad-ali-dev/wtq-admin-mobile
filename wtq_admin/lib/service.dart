import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wtq_admin/model/user.dart';
import 'package:wtq_admin/string_constants.dart';

class APIService {
  static APIService _instance;
  static Firestore firestore;
  static APIService get instance {
    if (_instance == null) {
      initialize();
      return _instance = APIService();
    }
    return _instance;
  }

  static void initialize() {
    firestore = Firestore.instance;
    firestore.settings(timestampsInSnapshotsEnabled: true);
  }

  Stream<Iterable<User>> fetchUsers(String name) {
    return firestore
        .collection(kKeyUser)
        .where(kFBKeyIsRegistered, isEqualTo: true)
        .where(kFBKeyRegistrationCompetition, isEqualTo: name)
        .orderBy(kFBKeyName)
        .snapshots()
        .map((users) => users.documents.map((user) => User.fromSnapshot(user)));
  }

  void updateUser(User user) {
    firestore.collection(kKeyUser).document(user.id).updateData(user.toJson());
  }
}
