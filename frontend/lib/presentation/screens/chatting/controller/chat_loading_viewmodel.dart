import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:palink_v2/di/locator.dart';
import 'package:palink_v2/domain/model/character/character.dart';
import 'package:palink_v2/domain/model/chat/conversation.dart';
import 'package:palink_v2/domain/model/user/user.dart';
import 'package:palink_v2/domain/usecase/generate_initial_message_usecase.dart';
import 'package:palink_v2/domain/usecase/create_conversation_usecase.dart';
import 'package:palink_v2/domain/usecase/get_user_info_usecase.dart';

class ChatLoadingViewModel extends GetxController {
  final CreateConversationUseCase createConversationUseCase =
      getIt<CreateConversationUseCase>();
  final GenerateInitialMessageUsecase generateInitialMessageUsecase =
      getIt<GenerateInitialMessageUsecase>();
  final GetUserInfoUseCase getUserInfoUseCase = getIt<GetUserInfoUseCase>();

  final Character character;
  var conversation = Rxn<Conversation>();
  var initialTip = ''.obs;
  var isEnd = false.obs;
  var isLoading = true.obs;
  var errorMessage = ''.obs;
  var user = Rxn<User>();

  ChatLoadingViewModel({required this.character});

  @override
  void onInit() {
    super.onInit();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      user.value = await getUserInfoUseCase.execute();
      await _createConversationAndInitialMessage();
    } catch (e) {
      errorMessage.value = 'Initialization failed: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _createConversationAndInitialMessage() async {
    try {
      // Create Conversation
      conversation.value = await _createConversation();
      if (conversation.value != null && user.value != null) {
        final conversationId = conversation.value!.conversationId;
        // Generate Initial Message and tip
        final result =
            await _createInitialMessage(conversationId, user.value!.name);
        if (result != null) {
          initialTip.value = result['tip'] as String;
          isEnd.value = result['isEnd'] as bool;
        }
      }
    } catch (e) {
      errorMessage.value = 'Failed to create conversation and initial message: $e';
      // Display error message
      Get.snackbar('Error', 'Failed to generate the initial message. Please exit and re-enter the chat room.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.indigo,
          colorText: Colors.white);
    }
  }

  Future<Conversation?> _createConversation() async {
    try {
      return await createConversationUseCase.execute(character);
    } catch (e) {
      errorMessage.value = 'Failed to create conversation: $e';
      return null;
    }
  }

  Future<Map<String, dynamic>?> _createInitialMessage(
      int conversationId, String userName) async {
    try {
      return await generateInitialMessageUsecase
          .execute(conversationId, userName, character.persona, []);
    } catch (e) {
      errorMessage.value = 'Failed to generate initial message: $e';
      return null;
    }
  }
}
