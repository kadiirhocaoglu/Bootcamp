import 'package:cloud_firestore/cloud_firestore.dart';

import 'message_model.dart';

class ChatInfo {
  final String chatId;
  final String profileImageUrl;
  final String firstName;
  final String lastName;

  ChatInfo({
    required this.chatId,
    required this.profileImageUrl,
    required this.firstName,
    required this.lastName,
  });

}


 
