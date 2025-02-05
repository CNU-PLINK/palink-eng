import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:palink_v2/core/theme/app_fonts.dart';
import 'package:palink_v2/presentation/screens/common/appbar_perferred_size.dart';
import 'package:palink_v2/presentation/screens/mypage/controller/myfeedbacks_viewmodel.dart';
import 'feedback_history_view.dart';

class MyfeedbacksView extends StatelessWidget {
  final MyfeedbacksViewmodel viewModel = Get.put(MyfeedbacksViewmodel());
  final ScrollController _scrollController = ScrollController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('My Feedback History', style: textTheme().titleMedium),
        centerTitle: false,
        bottom: appBarBottomLine(),
      ),
      body: GetBuilder<MyfeedbacksViewmodel>(
        builder: (viewModel) {
          if (viewModel.chatrooms.isEmpty) {
            return const Center(child: Text('No feedback available.'));
          }
          var reversedChatrooms = viewModel.chatrooms.reversed.toList();

          return ListView.builder(
            controller: _scrollController,
            itemCount: reversedChatrooms.length,
            reverse: false,

            itemBuilder: (context, index) {
              var chatroom = reversedChatrooms[index];
              var character = viewModel.characters[chatroom.characterId];
              return Column(
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 15.0),
                    tileColor: Colors.white,
                    leading: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(character!.image)
                    ),
                    title: Text(character != null ? character.name : '익명', style: textTheme().titleMedium),
                    subtitle: Text(_formatDate(chatroom.day)),
                    horizontalTitleGap: 30.0,
                    onTap: () {
                      Get.to(() => FeedbackHistoryView(chatroomId: chatroom.conversationId, character: character));
                    },
                  ),
                  const Divider(
                    height: 0,
                    thickness: 0.5,
                    color: Colors.grey,
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  // Date formatting function
  String _formatDate(DateTime date) {
    return '${date.year} Year ${date.month} Month ${date.day} Day ${date.hour}:${date.minute}';
  }
}
