import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat/widgets/message_bubble.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});

  @override
  Widget build(BuildContext context) {
    final authenticatedUser = FirebaseAuth.instance.currentUser!;

    // when a new document is added to the chat collection, the builder method will be called t update the ui state
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chat')
          .orderBy('createdAt',
              descending: true) //displays messages in ascending order
          .snapshots(),
      builder: (ctx, chatSnapshots) {
        if (chatSnapshots.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (!chatSnapshots.hasData || chatSnapshots.data!.docs.isEmpty) {
          return const Center(
            child: Text('no messages found'),
          );
        }
        if (chatSnapshots.hasError) {
          return const Center(
            child: Text('An error occurred'),
          );
        }
        final loadedMessages = chatSnapshots.data!.docs;
        return ListView.builder(
            padding: const EdgeInsets.only(
              bottom: 40,
              left: 13,
              right: 13,
            ),
            reverse: true,
            itemCount: loadedMessages.length,
            itemBuilder: (ctx, index) {
              final chatMessage = loadedMessages[index].data();
              final nextChatMessage = index + 1 < loadedMessages.length
                  ? loadedMessages[index + 1].data()
                  : null;

              final currentMessageUsername = chatMessage['username'];
              final nextMessageUsername =
                  nextChatMessage != null ? nextChatMessage['username'] : null;
              final currentMessageUserId = chatMessage['userId'];
              final nextMessageUserId =
                  nextChatMessage != null ? nextChatMessage['userId'] : null;
              final nextUserIsSame = currentMessageUserId == nextMessageUserId;
              if (nextUserIsSame) {
                return MessageBubble.next(
                    message: chatMessage['text'],
                    isMe: authenticatedUser.uid == currentMessageUserId);
              } else {
                return MessageBubble.first(
                    userImage: chatMessage['userImage'],
                    username: chatMessage['username'],
                    message: chatMessage['text'],
                    isMe: authenticatedUser.uid == currentMessageUserId);
              }
              // return Text(loadedMessages[index].data()['text']);
            });
      },
    );
  }
}
