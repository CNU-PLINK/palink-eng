import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:langchain/langchain.dart';
import 'package:langchain_openai/langchain_openai.dart';
import 'package:palink_v2/data/models/ai_response/analysis_request.dart';
import 'package:palink_v2/data/models/ai_response/analysis_response.dart';

class ConversationAnalysisService {
  final LLMChain conversationAnalysisChain;

  ConversationAnalysisService._(this.conversationAnalysisChain);

  // Initialization with exception handling for API key
  factory ConversationAnalysisService.initialize() {
    final apiKey = dotenv.env['API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('API_KEY is not set in .env file');
    }

    final openAI = ChatOpenAI(
      apiKey: apiKey,
      defaultOptions: const ChatOpenAIOptions(
        temperature: 0.8,
        model: "gpt-4o-mini",
        maxTokens: 340,
      ),
    );

    // Conversation analysis prompt
    final conversationAnalysisPrompt = ChatPromptTemplate.fromTemplate('''
    Your task is to evaluate the user's conversation skills based on the given chat history, rejection methods used, and unmet quest objectives.
    The goal is to assess the user's ability to **decline requests** effectively.
    The chat history includes the user's messages under 'userMessage' and the AI's responses under 'text'.
    The rejection method used in the user's message is labeled as 'rejection_content', and its score is recorded as 'rejection_score'.
    Evaluate the user's ability to **refuse requests appropriately** while considering the AI character's personality.

    [Chat History]
    {chatHistory}

    [Character Personality]
    - If the AI character is **Jinhyuk**, the user should express their intentions **firmly** rather than focusing on the character’s emotions.
      If the user frequently uses passive refusals (e.g., adding 😥 or apologizing too often), point it out in the feedback.
    - If the AI character is **Miyeon**, the user should **consider the character’s emotions** when declining.
    - If the AI character is **Sejin**, the user should **clearly state reasons** for refusal.
    - If the AI character is **Hyuna**, the user should **firmly reject persistent requests**.
    - This is character description : {description}

    [Evaluation Criteria]
    - Analyze the user's **ability to decline** and provide constructive feedback on how they can improve.
    - If there are notable phrases in the chat history, you may **quote them directly** for praise or criticism.
    - If the user’s messages **hurt the AI character’s feelings** or if the user is **too passive**, mention it in the feedback.
    - If the user **strayed from the conversation topic** or **accepted a request instead of refusing**, point it out.

    [Output Format]
    Return a JSON object with 'evaluation' (string), 'usedRejection' (string), and 'type' (string).
    (**Do not generate a string starting with \```json. The response must be within 290 characters.**)

    - 'evaluation': A **300-character** evaluation of the user's conversation skills **from the AI's perspective**.
      This should not only **assess** the user's ability but also **provide constructive feedback** for improvement.
    - 'usedRejection': A **comma-separated list** of unique rejection categories the user applied.
    - 'type': A **fun, nickname-style classification** of the user's refusal style.
      Example: **"Parrot Refuser", "Resolute Refuser", "Emotional Refuser", "Approval Refuser", "Blunt Refuser"**.
      Feel free to be creative in naming the type.
    ''');

    final conversationAnalysisChain = LLMChain(
      llm: openAI,
      prompt: conversationAnalysisPrompt,
      outputKey: 'analysis',
    );

    return ConversationAnalysisService._(conversationAnalysisChain);
  }

  Future<AnalysisResponse?> analyzeConversation(
      AnalysisRequest analysisRequest) async {
    try {
      final String chatHistoryString = analysisRequest.chatHistory.toString();
      final String descriptionString = analysisRequest.description.toString();

      final inputs = {'chatHistory': chatHistoryString, 'description': descriptionString};

      final result = await conversationAnalysisChain.invoke(inputs);

      // Extracting AI response
      final AIChatMessage aiChatMessage = result['analysis'] as AIChatMessage;

      // Debugging: Log AI response content
      print('DEBUG: AIChatMessage Content: ${aiChatMessage.content}');

      final String aiContent = aiChatMessage.content;
      final Map<String, dynamic> aiResponseMap = jsonDecode(aiContent);

      return AnalysisResponse.fromJson(aiResponseMap);
    } catch (e, stackTrace) {
      print('Failed to analyze rejection: $e');
      return null;
    }
  }
}
