import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:palink_v2/presentation/screens/chatting/view/components/custom_quest_button.dart';
import 'package:palink_v2/presentation/screens/chatting/view/components/quest_box.dart';
import 'package:sizing/sizing.dart';

class ProfileSection extends StatelessWidget {
  final String imagePath;
  final String characterName;
  final RxList<bool> questStatus;
  final Function onProfileTapped;
  final RxList<String> unachievedQuests;

  ProfileSection({
    required this.imagePath,
    required this.characterName,
    required this.questStatus,
    required this.onProfileTapped,
    required this.unachievedQuests,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            width: 0.45.sw,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() => QuestBox(questText: getCurrentQuest())), // Update on state change
              ],
            ),
          ),
        ),
        Obx(() => InkWell(
          onTap: () => onProfileTapped(),
          child: Column(
            children: [
              Row(
                children: List.generate(5, (index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                    child: Icon(
                      questStatus[index] ? Icons.check_circle : Icons.circle_outlined,
                      color: questStatus[index] ? Colors.blue : Colors.grey,
                      size: 12,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 8),
              CustomQuestButton(
                label: 'View Quest',
                onPressed: () {
                  onProfileTapped();
                },
              ),
            ],
          ),
        )),
      ],
    );
  }

  // Function to get the first unachieved quest
  String getCurrentQuest() {
    return unachievedQuests.isNotEmpty
        ? unachievedQuests.first
        : 'All quests have been completed!';
  }
}
