import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:palink_v2/core/theme/app_colors.dart';
import 'package:palink_v2/core/theme/app_fonts.dart';
import 'package:palink_v2/di/locator.dart';
import 'package:palink_v2/domain/model/chat/message.dart';
import 'package:palink_v2/presentation/screens/chatting/controller/chat_viewmodel.dart';
import 'package:palink_v2/presentation/screens/chatting/controller/tip_viewmodel.dart';
import 'package:palink_v2/presentation/screens/chatting/view/components/chat_profile_section.dart';
import 'package:palink_v2/presentation/screens/common/custom_button_md.dart';
import 'package:sizing/sizing.dart';
import '../../../../domain/model/chat/quest.dart';
import 'components/messages.dart';
import 'components/tip_button.dart';

class ChatSample extends StatelessWidget {
  ChatSample({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.white, // Default background color = White
        appBar: AppBar(
          toolbarHeight: 0.1.sh,
          backgroundColor: Colors.grey[100],
          title: ProfileSection(
            imagePath: '',
            characterName: 'Miyeon',
            questStatus: [false, true, false, false, false].obs,
            onProfileTapped: () =>
                showQuestPopup(context), // Show quest popup when profile is clicked
            unachievedQuests: [
              'Try to understand the other person’s situation',
              'This is an unachieved quest ABCDEFGHIJK',
              'Quest 3'
            ].obs,
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
                    child: Messages(
                      messages: dummyMessages.reversed.toList(),
                      userId: 1,
                      characterImg: 'assets/images/char1.png',
                      onReactionAdded: (message, reaction) {},
                    )),
                _sendMessageField(),
              ],
            ),
            // Add a dark overlay when the tip button is expanded
            Positioned(
              bottom: 114,
              right: 20,
              child: TipButton(
                  tipContent: 'Tip content included',
                  isExpanded: false,
                  isLoading: false,
                  onToggle: () {},
                  backgroundColor: AppColors.deepBlue),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sendMessageField() => SafeArea(
    child: Container(
      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(color: Color.fromARGB(18, 0, 0, 0), blurRadius: 10),
        ],
      ),
      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end, // Align elements at the bottom of the Row
        children: [
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              minLines: 1, // Minimum number of lines
              maxLines: 3, // Maximum number of lines
              keyboardType: TextInputType.multiline,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
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
          const SizedBox(width: 10), // Add space between the text field and button
          Align(
            alignment: Alignment.bottomCenter, // Fix send button to the bottom
            child: IconButton(
              onPressed: () {
                // Add message sending functionality
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

  void showQuestPopup(BuildContext context) async {
    // Sample quest list
    final List<Quest> quests = [
      Quest(title: 'Try to understand the other person’s situation', isAchieved: true),
      Quest(title: 'This is an unachieved quest', isAchieved: false),
      Quest(title: 'Quest 3', isAchieved: false),
    ];

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
                'Quests for conversation with Miyeon',
                style: textTheme().titleMedium,
              ),
              const SizedBox(height: 20),
              // Display quest list
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: quests.map((quest) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6.0),
                    child: Row(
                      children: [
                        // Checkmark and text
                        Icon(
                          quest.isAchieved
                              ? Icons.check_box
                              : Icons.check_box_outline_blank_sharp,
                          color: quest.isAchieved ? Colors.blueAccent : Colors.grey,
                        ),
                        const SizedBox(width: 10),
                        // Strike-through text if achieved, allow line breaks
                        Expanded(
                          child: Text(
                            quest.title,
                            maxLines: null, // No maximum line limit
                            overflow: TextOverflow.visible, // Display overflowing text
                            style: quest.isAchieved
                                ? const TextStyle(
                              decoration: TextDecoration.lineThrough,
                              color: Colors.black,
                            )
                                : const TextStyle(color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 30),
              CustomButtonMD(
                onPressed: () {
                  Get.back(); // Close dialog
                },
                label: 'Got it!',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final List<Message> dummyMessages = [
  Message(
    id: '1',
    sender: true, // The message is from the user
    messageText: 'Hello! How are you feeling today?',
    timestamp: '2024-09-26T10:30:24',
    affinityScore: 80,
    feeling: 'Neutral 20, Anger 80',
    rejectionScore: [1, 0],
    reactions: [],
  ),
  Message(
    id: '2',
    sender: true, // The message is from the user
    messageText: 'I feel great too! What are your plans for today?',
    timestamp: '2024-09-26T10:35:55',
    affinityScore: 90,
    feeling: 'Neutral 20, Anger 80',
    rejectionScore: [0, 2],
    reactions: [],
  ),
  Message(
    id: '3',
    sender: false, // The message is from the character
    messageText: 'I’m not sure yet. Shall we decide while talking?',
    timestamp: '2024-09-26T10:36:44',
    affinityScore: 75,
    feeling: 'Joy 10, Sadness 10, Neutral 20, Anger 60',
    rejectionScore: [1],
    reactions: [],
  ),
  Message(
    id: '4',
    sender: true, // The message is from the user
    messageText: 'Sounds good! Let’s find something fun to do together!',
    timestamp: '2024-09-26T10:40:30',
    affinityScore: 95,
    feeling: 'Joy 10, Sadness 10, Neutral 20, Anger 60',
    rejectionScore: [0],
    reactions: [],
  ),
];
