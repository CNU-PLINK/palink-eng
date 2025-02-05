import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:langchain/langchain.dart';
import 'package:langchain_openai/langchain_openai.dart';
import 'package:palink_v2/data/models/ai_response/liking_response.dart';

class SentimentService {
  final LLMChain sentimentAnalysisChain;

  SentimentService._(this.sentimentAnalysisChain);

  factory SentimentService.initialize() {
    final openAI = ChatOpenAI(
      apiKey: dotenv.env['API_KEY']!,
      defaultOptions: const ChatOpenAIOptions(
        temperature: 0.6,
        model: 'gpt-4o-mini',
        maxTokens: 50,
      ),
    );

    // Sentiment analysis prompt
    final sentimentAnalysisPrompt = ChatPromptTemplate.fromTemplate('''
      [Instruction]
      - You will assess the change in likability after hearing the user's message. This conversation simulates a casual chat between friends.
      - Analyze your (AI's) emotional state and how likability changes after hearing the user's message. If there is no user message, infer your emotions based on the AI message alone. In this case, the likability change should be 0.

      [Conversation]
      AI (You): {aiMessage}
      User: {userMessage}

      [Output]
      - Return a JSON object with 'feeling' and 'likability'. (Do not generate a string that starts with \```json. Keep the output within 30 characters.)
      - 'feeling': A combination of emotions from the following categories: Joy, Sadness, Anger, Anxiety, Disgust, Neutral, Love. List all applicable emotions, summing up to 100%. Separate values with commas and list the dominant emotion first. (Example: "Joy 60, Neutral 40") (String)
      - 'likability': Must be one of the values: 12, 5, -12, or -18 (Integer)

      [Likability Score Calculation Rules]
      - Likability is determined based on the nature of the user's message:
        - If the message expresses positive emotions or shows consideration → Score: +12
        - If the message is neutral or neither particularly positive nor negative → Score: +5
        - If the message is negative or could make the AI feel uncomfortable → Score: -12
        - If the message includes profanity or derogatory language → Score: -18
    ''');

    // Create LLMChain
    final sentimentAnalysisChain = LLMChain(
      prompt: sentimentAnalysisPrompt,
      llm: openAI,
      outputKey: 'output',
    );

    return SentimentService._(sentimentAnalysisChain);
  }

  Future<LikingResponse?> analyzeSentiment(String userMessage, String aiMessage) async {
    try {
      final input = {'userMessage': userMessage, 'aiMessage': aiMessage};
      final result = await sentimentAnalysisChain.invoke(input);
      final AIChatMessage aiChatMessage = result['output'] as AIChatMessage;
      final String aiContent = aiChatMessage.content;

      // Parse the response as JSON
      final Map<String, dynamic> aiResponseMap = jsonDecode(aiContent);

      // Convert parsed data into LikingResponse
      return LikingResponse.fromJson(aiResponseMap);
    } catch (e) {
      print('Failed to analyze sentiment: $e');
      return null;
    }
  }
}
