import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:palink_v2/core/theme/app_fonts.dart';
import 'package:palink_v2/di/locator.dart';
import 'package:palink_v2/presentation/screens/chatting/view/components/custom_btn_small.dart';
import 'package:palink_v2/presentation/screens/mypage/controller/mypage_viewmodel.dart';
import 'package:palink_v2/presentation/screens/mypage/view/component/profile_section.dart';
import 'package:palink_v2/presentation/screens/mypage/view/component/user_info_section.dart';
import 'package:palink_v2/presentation/screens/mypage/view/myfeedbacks_view.dart';
import '../../common/appbar_perferred_size.dart';
import 'myconversations_view.dart';

class MypageView extends StatelessWidget {
  final MypageViewModel mypageViewmodel = Get.put(getIt<MypageViewModel>());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('PALINK', style: textTheme().titleLarge),
        centerTitle: false,
        actions: [
          IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      content: const Text('Coming soon. \nLook forward to the next update ☺️'),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Close',
                              style: TextStyle(color: Colors.black)),
                        ),
                      ],
                    );
                  },
                );
              }),
        ],
        bottom: appBarBottomLine(),
      ),
      body: SingleChildScrollView( // Added: Make it scrollable
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfileSection(mypageViewmodel: mypageViewmodel),
              const SizedBox(height: 20),
              UserInfoCard(mypageViewmodel: mypageViewmodel),
              const SizedBox(height: 10),
              Card(
                color: Colors.white,
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                      title: const Text('View Chat History'),
                      onTap: () => Get.to(() => MyconversationsView()),
                      trailing: const Icon(Icons.arrow_forward_ios),
                    ),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                      title: const Text('View Past Feedbacks'),
                      onTap: () => Get.to(() => MyfeedbacksView()),
                      trailing: const Icon(Icons.arrow_forward_ios),
                    ),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                      title: const Text('View My Test Results'),
                      onTap: () => _showComingSoonDialog(context),
                      trailing: const Icon(Icons.arrow_forward_ios),
                    ),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                      title: const Text('View My Emotion List'),
                      onTap: () => _showComingSoonDialog(context),
                      trailing: const Icon(Icons.arrow_forward_ios),
                    ),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                      title: const Text('Logout'),
                      onTap: () => mypageViewmodel.logout(),
                      trailing: const Icon(Icons.arrow_forward_ios),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showComingSoonDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: const Text('Coming soon. \nLook forward to the next update ☺️'),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close', style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }
}
