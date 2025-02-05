import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:palink_v2/core/theme/app_colors.dart';
import 'package:palink_v2/core/theme/app_fonts.dart';
import 'package:palink_v2/data/models/mindset/mindset_response.dart';
import 'package:palink_v2/di/locator.dart';
import 'package:palink_v2/presentation/screens/chatting/controller/chat_viewmodel.dart';
import 'package:palink_v2/presentation/screens/chatting/controller/tip_viewmodel.dart';
import 'package:palink_v2/presentation/screens/chatting/view/components/chat_profile_section.dart';
import 'package:palink_v2/presentation/screens/common/custom_button_md.dart';
import 'package:sizing/sizing.dart';
import 'components/messages.dart';
import 'components/tip_button.dart';

class ChatScreen extends StatelessWidget {
  final ChatViewModel viewModel;
  final TipViewModel tipViewModel = Get.put(getIt<TipViewModel>());
  final String initialTip; // Tip for the first AI message
  final bool initialIsEnd;

  ChatScreen({
    super.key,
    required this.viewModel,
    required this.initialTip,
    required this.initialIsEnd,
  });

  @override
  Widget build(BuildContext context) {
    // Ensure the quest popup appears only on the first load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewModel.showQuestPopupIfFirstTime(context);
    });

    if (initialIsEnd) {
      debugPrint('initialIsEnd is true');
      viewModel.navigateToChatEndScreen(
          "The conversation has ended because the rejection was accepted."
          as MindsetResponse);
    }

    // Update the initial tip
    tipViewModel.updateTip(initialTip);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.white, // Default background color = white
        appBar: AppBar(
          toolbarHeight: 0.1.sh,
          backgroundColor: Colors.grey[100],
          title: ProfileSection(
            imagePath: viewModel.character.image,
            characterName: viewModel.character.name,
            questStatus: viewModel.questStatus,
            onProfileTapped: () =>
                viewModel.showQuestPopup(context), // Show quest popup on profile click
            unachievedQuests: viewModel.unachievedQuests,
          ),
          centerTitle: true,
          elevation: 0,
        ),
        extendBodyBehindAppBar: false,
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: Obx(() {
                    return viewModel.messages.isEmpty
                        ? const Center(
                      child: Text(
                        'No messages available.',
                        style: TextStyle(color: Colors.black),
                      ),
                    )
                        : Messages(
                      messages: viewModel.messages,
                      userId: viewModel.chatRoomId,
                      characterImg: viewModel.character.image,
                      onReactionAdded: (message, reaction) {
                        viewModel.addReactionToMessage(message, reaction);
                      },
                    );
                  }),
                ),
                _sendMessageField(viewModel),
              ],
            ),
            // Add a darkened background layer when the tip button is expanded
            Obx(() {
              return tipViewModel.isExpanded.value
                  ? Positioned.fill(
                child: GestureDetector(
                  onTap: () {
                    tipViewModel.toggle(); // Close the tip button when tapping the background
                  },
                  child: Container(
                    color: Colors.black45, // Semi-transparent black background
                  ),
                ),
              )
                  : const SizedBox.shrink();
            }),
            Positioned(
              bottom: 114,
              right: 20,
              child: Obx(() {
                return TipButton(
                  tipContent: tipViewModel.tipContent.value,
                  isExpanded: tipViewModel.isExpanded.value,
                  isLoading: tipViewModel.isLoading.value,
                  onToggle: tipViewModel.toggle,
                  backgroundColor: tipViewModel.tipContent.value.isEmpty
                      ? Colors.white70
                      : AppColors.deepBlue,
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sendMessageField(ChatViewModel viewModel) => SafeArea(
    child: Container(
      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(color: Color.fromARGB(18, 0, 0, 0), blurRadius: 10),
        ],
      ),
      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end, // Align elements at the bottom
        children: [
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              minLines: 1, // Minimum number of lines
              maxLines: 3, // Maximum number of lines
              keyboardType: TextInputType.multiline,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              controller: viewModel.textController,
              decoration: InputDecoration(
                hintText: "Enter your message here",
                contentPadding:
                EdgeInsets.symmetric(horizontal: 0.05.sw, vertical: 0.01.sh),
                hintStyle: const TextStyle(
                  fontSize: 16,
                ),
                fillColor: Colors.white,
                filled: true,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: const BorderSide(
                    color: Colors.white,
                    width: 0.2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: const BorderSide(
                    color: Colors.black26,
                    width: 0.2,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10), // Add spacing between the text field and button
          Align(
            alignment: Alignment.bottomCenter, // Fix send button at the bottom
            child: IconButton(
              onPressed: () {
                if (viewModel.textController.text.isNotEmpty) {
                  viewModel.sendMessage();
                  viewModel.textController.clear();
                }
              },
              icon: const Icon(Icons.send),
              color: Colors.blue,
              iconSize: 25,
            ),
          ),
        ],
      ),
    ),
  );

  bool _isDialogOpen = false;

  void showQuestPopup(BuildContext context) async {
    if (!_isDialogOpen) {
      _isDialogOpen = true;
      final questInfo = await viewModel.getQuestInformation();
      // Split questInfo by '\n' into a list
      List<String> questItems = questInfo.split('\n');

      await Get.dialog(
        Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Quest while chatting with ${viewModel.character.name}',
                  style: textTheme().titleMedium,
                ),
                const SizedBox(height: 20),
                Text(
                  'Quests are displayed in the top right of the profile.\n'
                      'When a quest is completed, a checkmark will appear next to the quest icon.\n'
                      'To check quests, tap the profile.',
                  style: textTheme().bodySmall,
                ),
                const SizedBox(height: 10),
                // Iterate through questItems list and add Text widgets with spacing
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: questInfo.split('\n').map((quest) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6.0), // Add spacing between items
                      child: Text(
                        quest,
                        style: textTheme().bodyMedium,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 30),
                CustomButtonMD(
                  onPressed: () {
                    Get.back(); // Close the dialog
                  },
                  label: 'Got it!',
                ),
              ],
            ),
          ),
        ),
      ).then((_) {
        _isDialogOpen = false;
      });
    }
  }
}
