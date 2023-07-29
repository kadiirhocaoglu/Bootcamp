import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatDetailsPage extends StatefulWidget {
  final String currentUserId;

  const ChatDetailsPage({super.key, 
    required this.currentUserId,
  });

  @override
  _ChatDetailsPageState createState() => _ChatDetailsPageState();
}

class _ChatDetailsPageState extends State<ChatDetailsPage> {
  String chatId = '';
  List<String> users = [];
  Map<String, dynamic> recipientData = {};

  @override
  void initState() {
    super.initState();
    getChatId();
  }

  Future<void> getChatId() async {
    final chatsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.currentUserId)
        .collection('chats');

    final querySnapshot = await chatsRef.get();

    if (querySnapshot.docs.isNotEmpty) {
      final chatDoc = querySnapshot.docs.first;
      chatId = chatDoc.id;

      await getChatDetails();
    }
  }

  Future<void> getChatDetails() async {
    final chatRef =
        FirebaseFirestore.instance.collection('chats').doc(chatId);
    final chatSnapshot = await chatRef.get();

    if (chatSnapshot.exists) {
      final chatData = chatSnapshot.data();
      users = List<String>.from(chatData?['users'] ?? []);

      final recipientId =
          users.firstWhere((userId) => userId != widget.currentUserId,
              orElse: () => '');

      if (recipientId.isNotEmpty) {
        final recipientRef =
            FirebaseFirestore.instance.collection('users').doc(recipientId);
        final recipientSnapshot = await recipientRef.get();

        if (recipientSnapshot.exists) {
          recipientData = recipientSnapshot.data() ?? {};
        }
      }

      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Details'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (users.isNotEmpty)
              Text('Users: ${users.join(', ')}'),
            if (recipientData.isNotEmpty)
              Column(
                children: [
                  Text('Recipient Name: ${recipientData['name']}'),
                  Text('Recipient Profile Picture: ${recipientData['profilePicture']}'),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(ChatDetailsApp());
}

class ChatDetailsApp extends StatelessWidget {
  const ChatDetailsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat Details',
      home: ChatDetailsPage(
        currentUserId: 'your_current_user_id_here',
      ),
    );
  }
}
