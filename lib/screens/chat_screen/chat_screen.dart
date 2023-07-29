import 'package:bootcamp/screens/home/home_swt/details/users_profile/users_profile.dart';
import 'package:bootcamp/style/colors.dart';
import 'package:bootcamp/style/icons/helphub_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/message_model.dart';
import '../../repository/user_repository/messaging_service.dart';

class ChatScreen extends StatefulWidget {
  final String recipientId;

  const ChatScreen({
    Key? key,
    required this.recipientId,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  late MessagingService _messagingService;
  bool _isDisposed = false;
  late String _recipientName = '';
  late String _recipientLastName = '';
  late String _recipientProfileImage = '';
  late String _recipientId = '';

  Future<void> _loadRecipientData() async {
  final recipientData = await getUserData(widget.recipientId);
  if (recipientData.exists && !_isDisposed) {
    setState(() {
      _recipientName = recipientData['firstName'];
      _recipientLastName = recipientData['lastName'];
      _recipientProfileImage = recipientData['profileImageURL'];
      _recipientId = recipientData['userId'];
    });
  }
}

  Future<DocumentSnapshot> getUserData(String userId) async {
    final userData =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return userData;
  }

  Future<void> _handleSendMessage() async {
    final message = _messageController.text;
    if (message.isNotEmpty) {
      final currentUserId = await _messagingService.getCurrentUserId();
      final sentMessage = Message(
        senderId: currentUserId,
        recipientId: widget.recipientId,
        content: message,
        isRead: false,
        timestamp: Timestamp.now(),
        isMe: true,
      );

      _messageController.clear();

      final chatId = generateChatId(currentUserId, widget.recipientId);

      await _messagingService.sendMessage(
          message, currentUserId, widget.recipientId, chatId);
    }
  }

  static String generateChatId(String userId1, String userId2) {
    List<String> sortedIds = [userId1, userId2]..sort();
    return sortedIds.join('_');
  }

  @override
  void initState() {
    super.initState();
    _messagingService = Provider.of<MessagingService>(context, listen: false);
    _loadRecipientData();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _messagingService.getCurrentUserId(),
      builder: (context, snapshotData) {
        if (snapshotData.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshotData.hasError) {
          return Text('Hata: ${snapshotData.error}');
        } else {
          final currentUserId = snapshotData.data!;
          return Scaffold(
            appBar: AppBar(
              title: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>UsersProfile(userId: _recipientId)
                    ),
                  );
                },
                child: Row(
                  children: [
                    if (_recipientProfileImage != null)
                      Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.purple,
                                width: 3,
                              ),
                            ),
                            child: CircleAvatar(
                              backgroundColor: Colors.grey.shade50,
                              backgroundImage: _recipientProfileImage.isNotEmpty
                                  ? NetworkImage(_recipientProfileImage)
                                  : const AssetImage(
                                          'assets/profile/user_profile.png')
                                      as ImageProvider<Object>?,
                              radius: 25,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '$_recipientName $_recipientLastName' ?? '',
                        style: const TextStyle(
                            color: AppColors.purple, fontSize: 25),
                      ),
                    ),
                  ],
                ),
              ),
              iconTheme: const IconThemeData(color: AppColors.purple),
              leading: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Icon(Helphub.back)),
              elevation: 0,
              backgroundColor: Colors.grey.shade50,
            ),
            body: Container(
              color: Colors.grey.shade50,
              child: Column(
                children: [
                  const Divider(
                    thickness: 3,
                    color: AppColors.purple,
                  ),
                  Expanded(
                    child: StreamBuilder<List<Message>>(
                      stream: _messagingService.getMessages(
                        currentUserId,
                        generateChatId(currentUserId, widget.recipientId),
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final messages = snapshot.data!;
                          return ListView.builder(
                            reverse: true,
                            itemCount: messages.length,
                            itemBuilder: (context, index) {
                              final message = messages[index];
                              final isMe = message.senderId == currentUserId;

                              return Align(
                                alignment: isMe
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 4, horizontal: 8),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isMe
                                        ? AppColors.purple
                                        : AppColors.darkGrey,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        message.content,
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        message.formatTimestamp(),
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.white70),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        } else if (snapshot.hasError) {
                          return Text('Hata: ${snapshot.error}');
                        } else {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                      },
                    ),
                  ),
                  SafeArea(
                    child: Column(
                      children: [
                        const Divider(
                          thickness: 3,
                          height: 0,
                          color: AppColors.purple,
                        ),
                        Container(
                          color: Colors.grey.shade50,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal:
                                    MediaQuery.of(context).size.width * 0.02,
                                vertical:
                                    MediaQuery.of(context).size.height * 0.01),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _messageController,
                                    decoration: InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(15),
                                        borderSide: const BorderSide(
                                          color: AppColors.purple,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(15),
                                        borderSide: const BorderSide(
                                          color: AppColors.lightpurple,
                                        ),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 15),
                                      fillColor: AppColors.white,
                                      filled: true,
                                      hintText: 'Mesajınızı yazın...',
                                      hintStyle: const TextStyle(
                                        color: AppColors.darkGrey,
                                      ),
                                    ),
                                    autocorrect: false,
                                    textCapitalization:
                                        TextCapitalization.sentences,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.send,
                                    color: AppColors.purple,
                                  ),
                                  onPressed: _handleSendMessage,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
