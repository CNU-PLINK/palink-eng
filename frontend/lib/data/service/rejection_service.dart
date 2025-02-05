import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:langchain/langchain.dart';
import 'package:langchain_openai/langchain_openai.dart';
import 'package:palink_v2/data/models/ai_response/rejection_response.dart';

class RejectionService {
  final LLMChain rejectionJudgmentChain;

  RejectionService._(this.rejectionJudgmentChain);

  factory RejectionService.initialize() {
    final openAI = ChatOpenAI(
      apiKey: dotenv.env['API_KEY']!,
      defaultOptions: const ChatOpenAIOptions(
        temperature: 0.4,
        model: 'gpt-4o-mini',
        maxTokens: 50,
      ),
    );

    // Rejection category classification prompt
    final rejectionPrompt = ChatPromptTemplate.fromTemplate('''
      Your task is to classify the given message into a rejection category.
      If the message is less than 10 characters long, return **only one** most plausible rejection category.

      [Message]
      message: {message}

      [Rejection Categories]
      Acceptance: ("Okay", "Sure", "Got it", "Alright, what can I do?", "Sounds good, let's do it!" etc. If acceptance words are detected, categorize as 'Acceptance' only. No overlapping categories.)
      Expressing Empathy: ("That must have been tough", "I understand", etc.)
      Offering an Alternative: (Providing an alternative solution, but **not** explicitly rejecting. If the message includes "Okay, but let's do it somewhere else!", it does **not** count. Examples: "I can help in another way.")
      Firm Rejection: ("No", "I don't want to", "I can't", etc.)
      Clarifying the Request: ("What do you need help with?", "What is it about?", etc.)
      Expressing Gratitude for Past Favors: ("Thanks for helping me last time!", etc.)
      Apologizing for Past Mistakes: ("I got too emotional and snapped, sorry." etc.)
      Setting Boundaries: ("I feel uncomfortable talking about this.", etc.)
      Time Constraints: ("I only have 10 minutes.", "I'm busy right now, make it quick.", etc.)
      Reiterating Firm Rejection to Repeated Requests: ("I already said no, and I really can't this time.", "I told you before, I can't help.", etc.)
      Justified Rejection: (Providing **a clear reason** for rejecting. Example: "I have another appointment, so I can't." "I have work, so it's difficult." etc.)
      Expressing Regret for Not Accepting: ("I'm really sorry", "I'll help next time!", etc.)
      Ignoring or Dismissing: ("Why should I care?", "Handle it yourself.", etc.)
      Sarcasm: ("Oh, you think you can handle that?", etc.)
      Indifferent or Uncooperative Response: ("I don't know", "Whatever", etc.)
      Unjustified Rejection: ("No", "Not gonna do it", etc., without providing any explanation.)
      Blaming the Other Person: ("It's your fault, so I won't help.", etc.)
      Off-Topic Responses: ("What should I have for dinner?", "Do you want to date me?", etc.)
      Insincere, Short Replies (Three or fewer characters): ("Yes", "Nah", etc.)
      Obvious Lies: ("I can't, I'm going on a space trip tomorrow.", "My grandmother passed away.", etc.)
      Profanity or Personal Attacks: ("Get lost", "F*** off", "You're crazy", "Idiot", "Your mother...", etc.)

      [Output Format]
      Return the rejection categories as a JSON object. The output should be within **50 characters**.
      - The output should be in a JSON object with **'rejectionContent'**.
      - 'rejectionContent' is a list of up to **two** rejection categories. If there is no matching category, return an empty list.
      - Example output:
        ```json
        "rejectionContent": ["Firm Rejection", "Setting Boundaries"]
        ```
      - If no category applies, return:
        ```json
        "rejectionContent": []
        ```
      **Do not generate a string that starts with \```json.**
    ''');

    final rejectionJudgmentChain = LLMChain(
      prompt: rejectionPrompt,
      llm: openAI,
      outputKey: 'rejection',
    );

    return RejectionService._(rejectionJudgmentChain);
  }

  Future<RejectionResponse?> judgeRejection(String message) async {
    try {
      final inputs = {'message': message};
      final result = await rejectionJudgmentChain.invoke(inputs);
      final AIChatMessage aiChatMessage = result['rejection'] as AIChatMessage;

      final String aiContent = aiChatMessage.content;
      final Map<String, dynamic> aiResponseMap = jsonDecode(aiContent);

      return RejectionResponse.fromJson(aiResponseMap);
    } catch (e) {
      print('Failed to analyze rejection: $e');
      return null;
    }
  }
}
