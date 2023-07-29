import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String? uid;
  final String username;
  final String firstName;
  final String lastName;
  final int phone;
  final String email;
  String? profileImageURL;

  UserModel({
    this.uid,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
    this.profileImageURL,
  });

  factory UserModel.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return UserModel(
      uid: data['userId'],
      username: data['username'],
      firstName: data['firstName'],
      lastName: data['lastName'],
      phone: data['phone'],
      email: data['email'],
    );
  }
}
