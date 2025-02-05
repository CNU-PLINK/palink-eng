import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:palink_v2/core/theme/app_colors.dart';
import 'package:palink_v2/core/theme/app_fonts.dart';
import 'package:palink_v2/presentation/screens/chatting/controller/chat_loading_viewmodel.dart';
import 'package:palink_v2/presentation/screens/chatting/controller/chat_viewmodel.dart';
import 'package:palink_v2/presentation/screens/common/custom_button_md.dart';
import 'package:sizing/sizing.dart';

import 'chat_screen.dart';

class ChatLoadingScreen extends StatelessWidget {
  final ChatLoadingViewModel viewModel;

  const ChatLoadingScreen({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 0.08.sh),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 0.68.sh,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildProfileImage(),
                    Center(
                      child: Text(
                        "${viewModel.character.name}'s Background",
                        style: textTheme().titleLarge,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 0.07.sw, vertical: 0.02.sh),
                      child:
                      _buildStyledDescription(viewModel.character.description!),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 0.04.sh),
            Obx(() {
              // Show "Start Chat" button when loading is complete
              if (!viewModel.isLoading.value) {
                return Column(
                  children: [
                    Text(
                      'Have you understood the character’s personality?',
                      style: textTheme()
                          .bodyMedium
                          ?.copyWith(color: Colors.black38, fontSize: 14.0),
                    ),
                    const SizedBox(height: 14),
                    CustomButtonMD(
                        label: 'Start Chat',
                        onPressed: () {
                          _startChat(); // Navigate to the chat screen when the button is pressed
                        }),
                  ],
                );
              } else {
                return const SpinKitThreeBounce(
                    color: AppColors.deepBlue,
                    size: 30); // Show loading animation while waiting
              }
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    return Container(
      padding: const EdgeInsets.all(10),
      width: 120,
      height: 120,
      child: Image.asset(viewModel.character.image),
    );
  }

  Widget _buildStyledDescription(String description) {
    List<String> lines = description.split('\n');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            lines[0],
            style: textTheme().titleSmall?.copyWith(
                color: Colors.black54,
                fontSize: 16.0,
                fontWeight: FontWeight.normal),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 18.0), // Spacing between the title and content
        for (var i = 1; i < lines.length; i++) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(right: 6.0), // Spacing between icon and text
                child: Icon(Icons.check_circle, color: Colors.blue, size: 16),
              ),
              Expanded(
                child: Text(
                  lines[i],
                  style: textTheme().bodyMedium?.copyWith(height: 1.4),
                ),
              ),
            ],
          ),
          // Add Divider except for the last item
          if (i < lines.length - 1)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 4.0),
              child: Divider(
                color: Colors.grey, // Line color
                thickness: 0.5, // Line thickness
                height: 16.0, // Spacing above and below the line
              ),
            ),
        ],
      ],
    );
  }

  // Method to navigate to the chat screen
  void _startChat() {
    final conversationId = viewModel.conversation.value?.conversationId;
    final tip = viewModel.initialTip.value; // Use the new tip variable
    final initialIsEnd = viewModel.isEnd.value; // Use the new isEnd variable

    Get.off(() => ChatScreen(
      viewModel: Get.put(
          ChatViewModel(chatRoomId: conversationId!, character: viewModel.character)),
      initialTip: tip,
      initialIsEnd: initialIsEnd,
    ));
  }
}
