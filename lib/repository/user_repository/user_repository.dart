// TODO Implement this library.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../models/user_model.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  Future<UserModel?> getUserData(String userId) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection('users')
      .where('userId', isEqualTo: userId)
      .limit(1)
      .get();

    if (snapshot.docs.isNotEmpty) {
      DocumentSnapshot documentSnapshot = snapshot.docs.first;
      UserModel user = UserModel.fromSnapshot(documentSnapshot);
      return user;
    } else {
      return null;
    }
  }

  Future<UserModel> addStatus(
    String uid,
    String username,
    String firstName,
    String lastName,
    String email,
    int phone,

  ) async {
    await Firebase.initializeApp();

    var ref = _firestore.collection('users');

    await ref.doc(uid).set({
      'userId': uid,
      'username': username,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,

    });

    return UserModel(
      uid: uid,
      username: username,
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,

    );
  }


}