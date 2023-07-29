
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Message {
  final String senderId;
  final String recipientId;
  final String content;
  final bool isRead;
  final Timestamp timestamp;
  final bool isMe;
  

  String formatTimestamp() {
  final dateTime = timestamp.toDate();
  final timeFormat = DateFormat.Hm().format(dateTime);
  return timeFormat;
}

  Message({
    required this.senderId,
    required this.recipientId,
    required this.content,
    required this.isRead,
    required this.timestamp,
    required this.isMe,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'recipientId': recipientId,
      'content': content,
      'isRead': isRead,
      'timestamp': timestamp,
      'isMe': isMe,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      senderId: map['senderId'],
      recipientId: map['recipientId'],
      content: map['content'],
      isRead: map['isRead'],
      timestamp: map['timestamp'],
      isMe: map['isMe'],
    );
  }
}
