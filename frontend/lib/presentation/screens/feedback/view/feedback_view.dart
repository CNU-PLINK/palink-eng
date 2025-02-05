import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:palink_v2/core/theme/app_colors.dart';
import 'package:palink_v2/presentation/screens/chatting/view/components/liking_bar.dart';
import 'package:palink_v2/presentation/screens/common/appbar_perferred_size.dart';
import 'package:palink_v2/presentation/screens/common/custom_btn.dart';
import 'package:palink_v2/presentation/screens/feedback/controller/feedback_viewmodel.dart';
import 'package:palink_v2/presentation/screens/main_screens.dart';
import 'package:sizing/sizing.dart';

class FeedbackView extends StatelessWidget {
  final FeedbackViewmodel viewModel;

  FeedbackView({Key? key, required this.viewModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Final Conversation Feedback'),
        bottom: appBarBottomLine(),
      ),
      body: Column(
        children: [
          // Scrollable section with fixed height
          SizedBox(
            height: 0.75.sh, // 75% of the screen height
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text('My Rejection Type',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Colors.black38)),
                  const SizedBox(height: 2),
                  Text(
                    viewModel.analysisDto.type,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  _buildProfileImage(),
                  SizedBox(height: 0.045.sh),
                  Container(
                    padding: const EdgeInsets.all(15.0),
                    width: 0.9.sw,
                    color: AppColors.lightBlue,
                    child: Text(
                      viewModel.analysisDto.evaluation,
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                  SizedBox(height: 0.05.sh),
                  const Text(
                    'Methods Used',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(_formatAsList(viewModel.analysisDto.usedRejection)),
                  SizedBox(height: 0.05.sh),
                  const Text(
                    'Unachieved Quests',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(_formatAsList(viewModel.analysisDto.unachievedQuests)),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
          // Button placed at the bottom
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: CustomButton(
                onPressed: () {
                  // Action when "Next" button is pressed
                  Get.off(() => MainScreens());
                },
                label: 'Next',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    return Container(
      padding: const EdgeInsets.all(10),
      width: 120,
      height: 120,
      child: Image.asset(viewModel.character.image), // Ensure the image path is correct
    );
  }

  // Formats a comma-separated string into a numbered or bullet-pointed list
  String _formatAsList(String commaSeparatedString) {
    // If the string is empty or contains only whitespace, return "No rejection methods used"
    if (commaSeparatedString.trim().isEmpty) {
      return 'No rejection methods used';
    }
    final items = commaSeparatedString.split(',').map((item) => item.trim()).toList();
    return items.asMap().entries.map((entry) => '${entry.key + 1}. ${entry.value}').join('\n');
  }
}
