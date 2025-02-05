import 'dart:convert';

import 'package:langchain/langchain.dart';
import 'package:palink_v2/data/models/ai_response/chat_request.dart';
import 'package:palink_v2/data/models/ai_response/chat_response.dart';
import 'response_service.dart';
import 'sentiment_service.dart';

class AIChainService {
  final SequentialChain sequentialChain;
  final SentimentService sentimentService; // Declare SentimentService as a class variable

  AIChainService._(this.sequentialChain, this.sentimentService);

  factory AIChainService.initialize() {
    final responseService = ResponseService.initialize();
    final sentimentService =
    SentimentService.initialize(); // Initialize SentimentService instance

    // Connect each chain in the SequentialChain
    final sequentialChain = SequentialChain(
      chains: [
        responseService.chatChain, // First chain
        sentimentService.sentimentAnalysisChain, // Second chain
      ],
      inputKeys: {'input', 'userMessage'}, // Keys passed as input to the first chain
      outputKeys: {'response', 'output'}, // Keys for final output (sentiment analysis result)
    );

    return AIChainService._(
        sequentialChain, sentimentService); // Pass SentimentService instance
  }

  Future<ChatResponse?> runChain(ChatRequest chatRequest) async {
    try {
      // Check if required values are null
      if (chatRequest.userName == null ||
          chatRequest.persona == null ||
          chatRequest.userMessage == null) {
        print(
            'Error: Missing required values - userName: ${chatRequest.userName}, persona: ${chatRequest.persona}, userMessage: ${chatRequest.userMessage}');
        throw ArgumentError(
            'Required values are missing in chatRequest: userName, persona, and userMessage cannot be null.');
      }

      // Log input values for debugging
      print(
          'Running chain with userName: ${chatRequest.userName}, persona: ${chatRequest.persona}, userMessage: ${chatRequest.userMessage}');

      // Input values for the first chain
      final input = {
        'userName': chatRequest.userName!,
        'persona': chatRequest.persona!,
        'input': chatRequest.userMessage!,
        'userMessage': chatRequest.userMessage!,
      };

      // Execute SequentialChain
      final result = await sequentialChain.invoke(input);

      // Extract AIChatMessage object from the 'response' key
      final AIChatMessage aiChatMessage = result['response'] as AIChatMessage;

      // Extract AI's response content as a string
      final aiMessage = aiChatMessage.content;

      // If aiMessage is a JSON string, parse it to extract necessary data
      final Map<String, dynamic> contentMap = jsonDecode(aiMessage);

      // Now the 'message' field can be used
      final String message = contentMap['message'] as String;

      // Set input for sentiment analysis chain
      final sentimentInput = {
        'response': message, // Use 'message' from the first chain as 'response' for the second chain
        'userMessage': chatRequest.userMessage!, // Pass user message
      };

      // Execute sentiment analysis
      final sentimentResult = await sentimentService.sentimentAnalysisChain.invoke(sentimentInput);

      // Extract necessary data from sentiment analysis result
      final AIChatMessage sentimentChatMessage = sentimentResult['output'] as AIChatMessage;
      final Map<String, dynamic> sentimentContentMap = jsonDecode(sentimentChatMessage.content);

      print('AIChainService: sentimentContentMap: $sentimentContentMap');

      // Convert final result into ChatResponse and return
      return ChatResponse.fromJson({
        ...contentMap,
        ...sentimentContentMap,
      });

    } catch (e) {
      print('Failed to execute chain: $e');
      return null;
    }
  }
}
