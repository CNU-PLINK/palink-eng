import 'package:palink_v2/data/mapper/ai_response_mapper.dart';
import 'package:palink_v2/data/models/ai_response/ai_response.dart';
import 'package:palink_v2/data/models/ai_response/liking_response.dart';
import 'package:palink_v2/data/models/ai_response/ai_message_request.dart';
import 'package:palink_v2/data/models/ai_response/ai_message_response.dart';
import 'package:palink_v2/data/models/chat/ai_response_response.dart';
import 'package:palink_v2/data/models/chat/message_response.dart';
import 'package:palink_v2/di/locator.dart';
import 'package:palink_v2/domain/repository/open_ai_repository.dart';
import 'package:palink_v2/domain/repository/chat_repository.dart';
import 'generate_tip_usecase.dart';

// Use case for generating the initial AI message
class GenerateInitialMessageUsecase {
  final ChatRepository chatRepository = getIt<ChatRepository>();
  final OpenAIRepository aiRepository = getIt<OpenAIRepository>();
  final GenerateTipUsecase generateTipUsecase;

  GenerateInitialMessageUsecase(this.generateTipUsecase);

  Future<Map<String, dynamic>?> execute(
      int conversationId, String userName, String persona, List<String> unachievedQuests) async {
    String userMessage = 'You should start the conversation by making a request first.';
    userMessage = cleanString(userMessage); // Remove special characters

    // Generate response
    AIMessageResponse? aiMessageResponse = await aiRepository.getChatResponse(AIMessageRequest(
      persona: persona,
      userName: userName,
      userMessage: userMessage,
      chatHistory: '', // Add chat history
    ));

    MessageResponse? messageResponse;
    AIResponse? aiResponse;
    if (aiMessageResponse != null) {
      // Remove liking analysis
      // LikingResponse? likingResponse = await aiRepository.judgeSentiment(userMessage, aiMessageResponse!.message);

      // Convert AIMessageResponse to AIResponse using a mapper
      aiResponse = aiMessageResponse.toInitialAIResponse();

      // Save message
      var messageRequest = aiResponse.toInitialMessageRequest();
      messageResponse = await chatRepository.saveMessage(conversationId, messageRequest);

      // Generate a tip
      final tip = await generateTipUsecase.execute(
          messageResponse!.messageId, aiResponse.text, unachievedQuests);

      // Return AI response and tip
      return {
        'aiResponse': aiResponse,
        "messageId": messageResponse?.messageId.toString(),
        'tip': tip?.answer ?? 'No default tip available.',
        'isEnd': aiMessageResponse.isEnd ?? false,
      };
    }
  }

  String cleanString(String input) {
    // Remove whitespace and special characters
    return input.replaceAll(RegExp(r'[\u200B-\u200D\uFEFF]'), '').trim();
  }
}
