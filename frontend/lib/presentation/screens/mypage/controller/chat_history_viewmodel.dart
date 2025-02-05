import 'package:get/get.dart';
import 'package:palink_v2/di/locator.dart';
import 'package:palink_v2/domain/model/character/character.dart';
import 'package:palink_v2/domain/model/chat/message.dart';
import 'package:palink_v2/domain/usecase/fetch_chat_history_usecase.dart';

class ChatHistoryViewmodel extends GetxController {
  final FetchChatHistoryUsecase getChatHistoryUsecase = Get.put(getIt<FetchChatHistoryUsecase>());

  List<Message>? messages;
  Character? character;
  int chatroomId;
  RxBool conversationNotFound = true.obs;


  ChatHistoryViewmodel({
    required this.chatroomId,
  });

  @override
  void onInit() {
    super.onInit();
    conversationNotFound.value = true;
    loadMessages();
  }

  void loadMessages() async {
    try {
      messages = await getChatHistoryUsecase.execute(chatroomId);
      messages = messages!.reversed.toList();
      conversationNotFound.value = false;
      update();
    } catch (e) {
      if (e.toString().contains('404')) {
        conversationNotFound.value = true;
      } else {
        Get.snackbar('Error', 'Failed to load feedback');
      }
      update();
    }
  }
}
