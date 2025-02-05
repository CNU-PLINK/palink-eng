import 'package:get/get.dart';
import 'package:palink_v2/data/mapper/ai_response_mapper.dart';
import 'package:palink_v2/data/models/ai_response/ai_message_request.dart';
import 'package:palink_v2/data/models/ai_response/ai_message_response.dart';
import 'package:palink_v2/data/models/ai_response/ai_response.dart';
import 'package:palink_v2/data/models/ai_response/liking_response.dart';
import 'package:palink_v2/data/models/ai_response/rejection_response.dart';
import 'package:palink_v2/data/models/chat/ai_response_response.dart';
import 'package:palink_v2/data/models/chat/message_response.dart';
import 'package:palink_v2/di/locator.dart';
import 'package:palink_v2/domain/model/character/character.dart';
import 'package:palink_v2/domain/model/chat/message.dart';
import 'package:palink_v2/domain/model/user/user.dart';
import 'package:palink_v2/domain/repository/chat_repository.dart';
import 'package:palink_v2/domain/repository/open_ai_repository.dart';
import 'package:palink_v2/presentation/screens/chatting/controller/tip_viewmodel.dart';
import 'fetch_chat_history_usecase.dart';
import 'generate_tip_usecase.dart';
import 'get_user_info_usecase.dart';

class GenerateResponseUsecase {
  final ChatRepository chatRepository = getIt<ChatRepository>();
  final OpenAIRepository aiRepository = getIt<OpenAIRepository>();
  final GetUserInfoUseCase getUserInfoUseCase;
  final FetchChatHistoryUsecase fetchChatHistoryUsecase;
  final GenerateTipUsecase generateTipUsecase;

  GenerateResponseUsecase(
      this.getUserInfoUseCase, this.fetchChatHistoryUsecase, this.generateTipUsecase);

  Future<Map<String?, dynamic>> execute(int conversationId, Character character,
      String userMessage, List<String> unachievedQuests) async {
    User? user = await getUserInfoUseCase.execute();

    // Retrieve chat history
    final chatHistoryResponse = await fetchChatHistoryUsecase.execute(conversationId);
    String chatHistory = _formatChatHistory(chatHistoryResponse!);

    // Generate AI response request including chat history
    AIMessageResponse? aiMessageResponse =
    await aiRepository.getChatResponse(AIMessageRequest(
      persona: character.persona,
      userName: user!.name,
      userMessage: userMessage,
      chatHistory: chatHistory,
    ));

    MessageResponse? messageResponse;
    AIResponse? aiResponse;
    if (aiMessageResponse != null) {
      // Generate affinity analysis (commented out)
      // LikingResponse? likingResponse = await aiRepository.judgeSentiment(userMessage, aiMessageResponse!.message);

      // Determine rejection score
      RejectionResponse? rejectionResponse = await aiRepository.judgeRejection(userMessage);

      // Convert response using a mapper
      aiResponse = aiMessageResponse.toAIResponse(rejectionResponse!, character);

      // Save message
      var messageRequest = aiResponse.toMessageRequest();
      messageResponse =
      await chatRepository.saveMessage(conversationId, messageRequest);
      List<AIResponseResponse> aiResponseResponse =
      await chatRepository.fetchAIResponseByMessageId(
          conversationId, messageResponse!.messageId);

      // Retrieve final score from AIResponseResponse
      if (aiResponseResponse != null) {
        aiResponse.finalAffinityScore = aiResponseResponse[0].finalAffinityScore;
        aiResponse.finalRejectionScore = aiResponseResponse[0].finalRejectionScore;
      }

      // Generate tip
      final tip = await generateTipUsecase.execute(
          messageResponse!.messageId, aiResponse.text, unachievedQuests);

      final tipViewModel = Get.find<TipViewModel>();
      tip != null
          ? tipViewModel.updateTip(tip.answer)
          : tipViewModel.updateTip('Tip has not been generated yet!');
    }

    // Return AIResponse and isEnd as a Map
    return {
      "aiResponse": aiResponse,
      "messageId": messageResponse?.messageId,
      "isEnd": aiMessageResponse?.isEnd ?? false, // Set to false if isEnd is null
    };
  }

  // Function to convert chatHistoryResponse into JSON or text format
  String _formatChatHistory(List<Message> chatHistoryResponse) {
    // Convert messages sequentially into text format
    return chatHistoryResponse
        .map((message) => "${message.sender}: ${message.messageText}")
        .join("\n");
  }
}
