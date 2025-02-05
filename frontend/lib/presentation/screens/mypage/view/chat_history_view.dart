import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:palink_v2/domain/model/character/character.dart';
import 'package:palink_v2/presentation/screens/chatting/view/components/messages.dart';
import 'package:palink_v2/presentation/screens/common/appbar_perferred_size.dart';
import 'package:palink_v2/presentation/screens/main_screens.dart';
import 'package:palink_v2/presentation/screens/mypage/controller/chat_history_viewmodel.dart';
import 'package:sizing/sizing.dart';

import 'feedback_history_view.dart';

class ChatHistoryView extends StatelessWidget {
  final int chatroomId;
  final ChatHistoryViewmodel viewModel;
  final Character character;

  ChatHistoryView({required this.chatroomId, required this.character})
      : viewModel = Get.put(ChatHistoryViewmodel(chatroomId: chatroomId));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Chat History'),
        bottom: appBarBottomLine(),
      ),
      body: Stack(
        children: [
          // Make the message section scrollable
          Positioned.fill(
            child: Obx(() {
              // If conversation data has not been loaded
              if (viewModel.conversationNotFound.value) {
                return const Center(
                  child: Text(
                    'The conversation has not been saved.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                );
              }
              // If conversation exists, display the message list
              return SingleChildScrollView(
                child: SizedBox(
                  height: 0.8.sh,
                  child: Messages(
                    messages: viewModel.messages ?? [],
                    userId: chatroomId,
                    characterImg: character.image ?? '',
                    onReactionAdded: (message, reaction) {},
                  ),
                ),
              );
            }),
          ),
          // Fix the buttons at the bottom
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Add a "View Feedback" button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.grey,
                        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 30.0), // Adjust button size
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0), // Square corners
                        ),
                      ),
                      onPressed: () {
                        Get.off(() => const MainScreens());
                      },
                      child: const Text('Go to Home'),
                    ),
                    const SizedBox(width: 20), // Add spacing between buttons
                    // "Go to Home" button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 30.0), // Adjust button size
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0), // Square corners
                        ),
                      ),
                      onPressed: () {
                        Get.to(() => FeedbackHistoryView(
                          chatroomId: chatroomId,
                          character: character,
                        ));
                      },
                      child: const Text('View Feedback'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
