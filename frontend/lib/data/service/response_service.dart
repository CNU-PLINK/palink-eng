import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:langchain/langchain.dart';
import 'package:langchain_openai/langchain_openai.dart';
import 'package:palink_v2/data/models/ai_response/ai_message_request.dart';
import 'package:palink_v2/data/models/ai_response/ai_message_response.dart';

class ResponseService {
  final ConversationChain chatChain;
  final ConversationBufferMemory memoryBuffer;

  ResponseService._(this.chatChain, this.memoryBuffer);

  // Initialization with API key validation
  factory ResponseService.initialize() {
    final apiKey = dotenv.env['API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('API_KEY is not set in the .env file');
    }

    final memoryBuffer = ConversationBufferMemory(
      memoryKey: 'history',
      inputKey: 'input',
      returnMessages: false,
    );

    final openAI = ChatOpenAI(
      apiKey: apiKey,
      defaultOptions: const ChatOpenAIOptions(
        temperature: 0.8,
        model: 'gpt-4o-mini',
        maxTokens: 100,
      ),
    );

    final chatChain = ConversationChain(
      memory: memoryBuffer,
      llm: openAI,
      prompt: ChatPromptTemplate.fromTemplate('''
        You must respond appropriately to the last message.
        Address the USER as {userName}. If {userName} includes a full name, you should call friendly name.
        Below is your character description:

        {persona}

        You must return a JSON object containing 'message' and 'isEnd'. (Do not generate a string that starts with \```json.)
         
        - message: Represents the content of the message. (string) 
        - isEnd: If the user’s last message or the previous conversation history includes an acceptance (e.g., "Okay", "Sure!", "Alright, I'll help", "Leave it to me", "I'll do it"), set isEnd to true. Otherwise, the default is false. If isEnd is false, you should persist in making the request. (bool)

        [Rules] 
        - Maintain context and respond to {userName}'s last message. Do not repeat what you have previously said.
        - If a request was made before, continue the request instead of introducing a new one.
        - Use Natural English and avoid using formal language.
        - If the conversation history is empty, start by making a request.
        - In the conversation history, if `sender` is `true`, it means the user spoke; if `false`, the AI spoke. However, the very first request message should always be considered as coming from the conversation partner, even if `sender` is `true`.
        - The 'message' should not exceed 80 characters.
        - If the user has already accepted the request or if the overall conversation has deviated from "request refusal" (e.g., "Will you date me?"), set `isEnd` to true.

        [Conversation History]
        - {chatHistory}

        [{userName}'s Last Message]
        {userName}: {input}
      '''),

      inputKey: 'input',
      outputKey: 'response',
    );

    return ResponseService._(chatChain, memoryBuffer);
  }

  // Generates a response from the AI
  Future<AIMessageResponse?> getChatResponse(AIMessageRequest messageRequest) async {
    try {
      // Prepare input parameters
      final input = {
        'userName': messageRequest.userName!,
        'persona': messageRequest.persona!,
        'input': messageRequest.userMessage!,
        'chatHistory': messageRequest.chatHistory!,
      };

      // Invoke the chat chain
      final result = await chatChain.invoke(input);

      // Extract AIChatMessage object
      final AIChatMessage aiChatMessage = result['response'] as AIChatMessage;

      // Extract AI's response content as a string
      final String aiContent = aiChatMessage.content;

      // Parse the response as JSON
      final Map<String, dynamic> aiResponseMap = jsonDecode(aiContent);

      // Convert parsed data into AIMessageResponse
      return AIMessageResponse.fromJson(aiResponseMap);
    } catch (e, stackTrace) {
      print('Error during chat response generation: $e');
      return null;
    }
  }
}
