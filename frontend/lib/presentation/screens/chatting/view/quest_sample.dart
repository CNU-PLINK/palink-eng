import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:palink_v2/core/theme/app_colors.dart';
import 'package:palink_v2/core/theme/app_fonts.dart';
import 'package:palink_v2/di/locator.dart';
import 'package:palink_v2/presentation/screens/chatting/controller/chat_viewmodel.dart';
import 'package:palink_v2/presentation/screens/chatting/controller/tip_viewmodel.dart';
import 'package:palink_v2/presentation/screens/chatting/view/components/chat_profile_section.dart';
import 'package:palink_v2/presentation/screens/common/custom_button_md.dart';
import 'package:sizing/sizing.dart';
import 'components/messages.dart';
import 'components/tip_button.dart';

class QuestSample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.white, // Default background color = White
        appBar: AppBar(
          backgroundColor: Colors.grey[100],
          toolbarHeight: 0.1.sh,
          title: ProfileSection(
            imagePath: '',
            characterName: 'Miyeon',
            questStatus: [false, true, false, false, false].obs,
            onProfileTapped: () =>
                showQuestPopup(context), // Show quest popup when profile is clicked
            unachievedQuests: [
              'Attempt a conversation to understand the situation of the other person',
              'This is an unachieved quest ABCDEFGHIJKLMNOPQRSTUVWXYZ',
              'Quest 3'
            ].obs,
          ),
          centerTitle: true,
          elevation: 0,
        ),
        extendBodyBehindAppBar: false,
        body: const Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('         Message')
              ],
            ),
          ],
        ),
      ),
    );
  }

  void showQuestPopup(BuildContext context) async {
    const questInfo =
        'Attempt a conversation to understand the situation of the other person\n'
        'Attempt a conversation to understand the situation of the other person\n'
        'Attempt a conversation to understand the situation of the other person\n'
        'Attempt a conversation to understand the situation of the other person\n'
        'Attempt a conversation to understand the situation of the other person';

    // Split questInfo by '\n' to create a list
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
                'Quests when talking with Miyeon',
                style: textTheme().titleMedium,
              ),
              const SizedBox(height: 20),
              Text(
                'Quests are displayed at the top right of the profile.\n'
                    'When a quest is achieved, a checkmark appears next to the quest icon.\n'
                    'Click on the profile if you want to check the quest progress.',
                style: textTheme().bodySmall,
              ),
              const SizedBox(height: 10),
              // Iterate through questItems list and add a Text widget for each item with spacing
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: questItems.map((quest) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6.0), // Add spacing between each item
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
    );
  }
}
