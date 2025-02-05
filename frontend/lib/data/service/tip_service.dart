import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:langchain/langchain.dart';
import 'package:langchain_openai/langchain_openai.dart';
import 'package:palink_v2/data/models/ai_response/tip_request.dart';
import 'package:palink_v2/data/models/ai_response/tip_response.dart';

class TipService {
  final LLMChain tipChain;

  TipService._(this.tipChain);

  // Initialization with exception handling for API key
  factory TipService.initialize() {
    final apiKey = dotenv.env['API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('API_KEY is not set in .env file');
    }

    final openAI = ChatOpenAI(
      apiKey: apiKey,
      defaultOptions: const ChatOpenAIOptions(
        temperature: 0.7,
        model: 'gpt-4o-mini',
        maxTokens: 300,
      ),
    );

    final rejectionPrompt = ChatPromptTemplate.fromTemplate('''[INSTRUCTION]
You must generate an appropriate response based on the given description. The response should be returned as a JSON object with 'answer' and 'reason' fields. 
(Do not generate a string that starts with triple quotes. The total output should be within 150 characters.)

Generate a response for the following message (Do not include the recipient's name in the response): 
message: {message}

[RULES] 
- You are a close friend of the conversation partner. The partner may make difficult-to-refuse requests, express anger, or be in a conflict situation.
- You must provide an appropriate response to their remarks.
- You should remain calm in the conversation and use **"I-statements"** and **nonviolent communication** to guide the conversation in a constructive direction.
- If emotions need to be expressed, use a variety of **emotion words** to clearly convey your feelings and generate the most suitable response.
- When generating a response, consider the following **unachieved quests**: {unachievedQuests}
- Prioritize the first quest in the list when crafting your response.

[TONE]
- When generating 'answer', speak in a **casual, friendly tone**, as you are talking to a close friend. **Do not use formal speech**. 
  (Example: "Thank you" → "Thanks", "I'm sorry" → "Sorry, my bad." or "my bad" or "sorry", "I request" → "Can you do me a favor?")

[ADDITIONAL RULES] 
- **Never apologize** unless you have actually done something wrong.
- If the other person makes a request, **never accept it** outright. Instead, **reject it properly** in a logical manner.
- The output must contain **'answer'** and **'reason'**.
- When generating 'answer', use the provided **unachieved quests** to craft a refusal that aligns with the quest conditions.
- 'reason' should explain **why** 'answer' was generated, using **formal language (not casual speech).''');

    final tipChain = LLMChain(
      llm: openAI,
      prompt: rejectionPrompt,
      outputKey: 'tip',
    );

    return TipService._(tipChain);
  }

  Future<TipResponse?> createTip(TipRequest tipRequest) async {
    try {
      final input = {
        'message': tipRequest.message!,
        'unachievedQuests': tipRequest.unachievedQuests!
      };

      print('TipService.createTip input: $input');
      final result = await tipChain.invoke(input);
      print('TipService.createTip result: $result');
      final AIChatMessage aiChatMessage = result['tip'] as AIChatMessage;
      final String aiContent = aiChatMessage.content;

      final Map<String, dynamic> aiResponseMap = jsonDecode(aiContent);

      return TipResponse.fromJson(aiResponseMap);

    } catch (e) {
      print('Failed to generate tip: $e');
      return null;
    }
  }
}
