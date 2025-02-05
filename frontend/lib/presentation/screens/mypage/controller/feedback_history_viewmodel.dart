import 'package:get/get.dart';
import 'package:palink_v2/di/locator.dart';
import 'package:palink_v2/domain/model/analysis/feedback.dart';
import 'package:palink_v2/domain/model/character/character.dart';
import 'package:palink_v2/domain/usecase/get_feedback_by_conversation_usecase.dart';

class FeedbackHistoryViewModel extends GetxController {
  final GetFeedbackByConversationUsecase getFeedbackByConversationUsecase = Get.put(getIt<GetFeedbackByConversationUsecase>());

  Feedback? feedback;
  Character? character;
  int chatroomId;
  RxBool feedbackNotFound = true.obs;


  FeedbackHistoryViewModel({
    required this.chatroomId,
  });

  @override
  void onInit() {
    super.onInit();
    feedbackNotFound.value = true;
    loadFeedbackData();
  }

  void loadFeedbackData() async {
    try {
      feedback = await getFeedbackByConversationUsecase.execute(chatroomId);
      feedbackNotFound.value = false;
      update();
    } catch (e) {
      if (e.toString().contains('404')) {
        feedbackNotFound.value = true;
      } else {
        //Get.snackbar('Error', 'Failed to load feedback');
      }
      update();
    }
  }
}
