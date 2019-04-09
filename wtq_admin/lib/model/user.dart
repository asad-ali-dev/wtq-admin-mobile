import 'package:cloud_firestore/cloud_firestore.dart';

class UserCache {
  User _user;

  User get user => _user;

  Future<User> getCurrentUser(String id, {bool useCached = true}) async {
    if (_user != null && useCached) {
      return _user;
    }
    _user = User.fromSnapshot(
        await Firestore.instance.collection('users').document(id).get());
    return _user;
  }

  void clear() => _user = null;
}

class User {
  final String id;
  final String name;
  final String email;
  final String photoUrl;
  final String mobileNumber;
  final bool isRegistered;
  final bool isContributor;
  final bool isPresent;
  bool isRegistrationConfirmed;
  final DocumentReference reference;

  Contribution contribution;
  Registration registration;
  ProfessionalDetails profession;
  StudentDetails student;

  User({
    this.name,
    this.id,
    this.email,
    this.reference,
    this.photoUrl,
    this.isRegistered = false,
    this.isContributor = false,
    this.isPresent = false,
    this.isRegistrationConfirmed = false,
    this.mobileNumber,
  });

  User.fromMap(Map<String, dynamic> map, {this.reference})
      : id = map['id'],
        name = map['name'],
        email = map['email'],
        photoUrl = map['photoUrl'],
        isRegistered = map['isRegistered'],
        isContributor = map['isContributor'],
        isPresent = map['isPresent'],
        isRegistrationConfirmed = map['isRegistrationConfirmed'],
        mobileNumber = map['mobileNumber'] {
    if (isContributor) contribution = Contribution.fromMap(map['contribution']);
    if (isRegistered) registration = Registration.fromMap(map['registration']);
    if (map['professionalDetails'] != null)
      profession = ProfessionalDetails.fromMap(map['professionalDetails']);
    if (map['studentDetails'] != null)
      student = StudentDetails.fromMap(map['studentDetails']);
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "photoUrl": photoUrl,
        "isRegistered": isRegistered,
        "mobileNumber": mobileNumber,
        "isPresent": isPresent,
        "isRegistrationConfirmed": isRegistrationConfirmed,
        "isContributor": isContributor
      };

  User.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);
}

class Registration {
  final String competition;
  final String occupation;
  final String reasonToAttend;
  final DocumentReference reference;

  Registration(
      {this.competition, this.occupation, this.reasonToAttend, this.reference});

  Registration.fromMap(Map<dynamic, dynamic> map, {this.reference})
      : occupation = map['occupation'],
        competition = map['competition'],
        reasonToAttend = map['reasonToAttend'];

  Map<String, dynamic> toJson() => {
        "occupation": this.occupation,
        "competition": this.competition,
        "reasonToAttend": this.reasonToAttend,
      };

  Registration.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);
}

class Contribution {
  final bool isVolunteer;
  final bool isLogisticsAdministrator;
  final bool isSpeaker;
  final bool isSocialMediaMarketingPerson;

  Contribution({
    this.isSocialMediaMarketingPerson,
    this.isLogisticsAdministrator,
    this.isSpeaker,
    this.isVolunteer,
  });

  Contribution.fromMap(Map<dynamic, dynamic> map)
      : isSpeaker = map['speaker'],
        isSocialMediaMarketingPerson = map['socialMediaMarketing'],
        isLogisticsAdministrator = map['administrationAndLogistics'],
        isVolunteer = map['volunteer'];

  Map<String, dynamic> toJson() => {
        "socialMediaMarketing": isSocialMediaMarketingPerson,
        "speaker": isSpeaker,
        "administrationAndLogistics": isLogisticsAdministrator,
        "volunteer": isVolunteer
      };
}

class StudentDetails {
  final String uniName;
  final String program;
  final String currentYear;
  final DocumentReference reference;

  StudentDetails(
      {this.uniName, this.program, this.currentYear, this.reference});

  StudentDetails.fromMap(Map<dynamic, dynamic> map, {this.reference})
      : program = map['program'],
        uniName = map['uniName'],
        currentYear = map['currentYear'];

  Map<String, dynamic> toJson() => {
        "program": this.program,
        "uniName": this.uniName,
        "currentYear": this.currentYear,
      };

  StudentDetails.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);
}

class ProfessionalDetails {
  final String yearsOfExp;
  final String organizationName;
  final String designation;
  final String techStack;
  final DocumentReference reference;

  ProfessionalDetails(
      {this.yearsOfExp,
      this.organizationName,
      this.designation,
      this.techStack,
      this.reference});

  ProfessionalDetails.fromMap(Map<dynamic, dynamic> map, {this.reference})
      : organizationName = map['organizationName'],
        yearsOfExp = map['yearsOfExp'],
        designation = map['designation'],
        techStack = map['techStack'];

  Map<String, dynamic> toJson() => {
        "organizationName": this.organizationName,
        "yearsOfExp": this.yearsOfExp,
        "designation": this.designation,
        "techStack": this.techStack,
      };

  ProfessionalDetails.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);
}
