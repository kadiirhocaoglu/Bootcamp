import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

import '../../models/message_model.dart';

class MessagingService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<String> getCurrentUserId() async {
    final currentUser = _firebaseAuth.currentUser;
    return currentUser!.uid;
  }

  Stream<List<Message>> getMessages(String currentUserId, String chatId) {
    final messagesRef = _firebaseFirestore
        .collection('chats')
        .doc(chatId)
        .collection('messages');

    return messagesRef.orderBy('timestamp', descending: true).snapshots().map(
        (snapshot) =>
            snapshot.docs.map((doc) => Message.fromMap(doc.data())).toList());
  }

  Future<DocumentReference> sendMessage(String message, String currentUserId,
      String recipientId, String chatId) async {
    final currentUserRef =
        _firebaseFirestore.collection('users').doc(currentUserId);
    final recipientRef =
        _firebaseFirestore.collection('users').doc(recipientId);
    final chatData = {
      'users': [currentUserId, recipientId],
    };
    final chatDatas = {
      'chatId': chatId,
      'recipientId': recipientId,
    };
   
 final currentUserChatsRef =
      currentUserRef.collection('chats').doc(chatId);
  final recipientChatsRef =
      recipientRef.collection('chats').doc(chatId);

await currentUserChatsRef.set(chatDatas);
  await recipientChatsRef.set(chatDatas);

    final chatRef = _firebaseFirestore.collection('chats').doc(chatId);
    await chatRef.set(chatData);

    final messageMap = {
      'senderId': currentUserId,
      'recipientId': recipientId,
      'content': message,
      'isRead': false,
      'timestamp': Timestamp.now(),
      'isMe': true,
    };

    final docRef = await chatRef.collection('messages').add(messageMap);
    return docRef;
  }
Future<void> getChatDetails(String chatId) async {
  final chatRef = _firebaseFirestore.collection('chats').doc(chatId);
  final chatSnapshot = await chatRef.get();

  if (chatSnapshot.exists) {
    final chatData = chatSnapshot.data();
    final List<String>? users = List<String>.from(chatData?['users'] ?? []);

    for (String? userId in users!) {
      final userRef = _firebaseFirestore.collection('users').doc(userId);
      final userSnapshot = await userRef.get();

      if (userSnapshot.exists) {
        final userData = userSnapshot.data();
        if (userData != null) {
          // Kullanıcı verilerine erişmek için userData kullanabilirsiniz
          print('User ID: $userId');
          print('Username: ${userData['username']}');
          print('Email: ${userData['email']}');
          print('---');

          // Alıcı bilgilerine erişmek için alıcı ID'sini alın
          final recipientId = chatData?['recipientId'];
          if (recipientId != null) {
            final recipientRef =
                _firebaseFirestore.collection('users').doc(recipientId);
            final recipientSnapshot = await recipientRef.get();

            if (recipientSnapshot.exists) {
              final recipientData = recipientSnapshot.data();
              if (recipientData != null) {
                // Alıcı verilerine erişmek için recipientData kullanabilirsiniz
                print('Recipient ID: $recipientId');
                print('Recipient Name: ${recipientData['name']}');
                print('Recipient Profile Picture: ${recipientData['profilePicture']}');
                print('---');
              } else {
                print('Recipient data is null for ID: $recipientId');
              }
            } else {
              print('Recipient not found: $recipientId');
            }
          }
        } else {
          print('User data is null for ID: $userId');
        }
      } else {
        print('User not found: $userId');
      }
    }
  } else {
    print('Chat not found: $chatId');
  }
}


  Future<void> markMessageAsRead(String messageId) async {
    await _firebaseFirestore
        .collection('messages')
        .doc(messageId)
        .update({'isRead': true});
  }

  Future<List<DocumentSnapshot>> getChats(String currentUserId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('chats')
        .where('users', arrayContains: currentUserId)
        .get();

    return snapshot.docs;
  }

  Future<void> sendNotification(String recipientToken, String message) async {
    const serverKey = 'AIzaSyCSqSDVBCg_EwslmIWdwPYAgK1LsHVpI28';
    const url = 'https://fcm.googleapis.com/fcm/send';

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'key=$serverKey',
    };

    final body = {
      'notification': {
        'title': 'Yeni Mesaj',
        'body': message,
      },
      'priority': 'high',
      'to': recipientToken,
    };

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      print('Bildirim gönderildi');
    } else {
      print('Bildirim gönderilirken hata oluştu: ${response.reasonPhrase}');
    }
  }

  Future<String> _getRecipientToken(String recipientId) async {
    final userDoc =
        await _firebaseFirestore.collection('users').doc(recipientId).get();
    final token = userDoc.data()?['fcmToken'] as String;

    return token;
  }

  Future<void> configureFirebaseMessaging() async {
    await _firebaseMessaging.requestPermission();
    final token = await _firebaseMessaging.getToken();
    print('Firebase Messaging Token: $token');

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received message: ${message.notification?.body}');
    });
  }

  Stream<List<Message>> getHelpMessages(String helpId) async* {
    final messagesRef = FirebaseFirestore.instance
        .collection('helps')
        .doc(helpId)
        .collection('messages');

    yield* messagesRef.orderBy('timestamp', descending: true).snapshots().map(
        (snapshot) =>
            snapshot.docs.map((doc) => Message.fromMap(doc.data())).toList());
  }

  Future<List<DocumentSnapshot>> getPreviousChats(String currentUserId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('chats')
        .where('users', arrayContains: currentUserId)
        .get();

    return snapshot.docs;
  }
}
