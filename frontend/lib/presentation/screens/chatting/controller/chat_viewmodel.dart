import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:palink_v2/core/theme/app_fonts.dart';
import 'package:palink_v2/data/models/ai_response/ai_response.dart';
import 'package:palink_v2/data/models/mindset/mindset_response.dart';
import 'package:palink_v2/di/locator.dart';
import 'package:palink_v2/domain/model/character/character.dart';
import 'package:palink_v2/domain/model/chat/message.dart';
import 'package:palink_v2/domain/usecase/fetch_chat_history_usecase.dart';
import 'package:palink_v2/domain/usecase/get_random_mindset_usecase.dart';
import 'package:palink_v2/domain/usecase/send_user_message_usecase.dart';
import 'package:palink_v2/presentation/screens/chatting/view/chat_end_loading_screen.dart';
import 'package:palink_v2/presentation/screens/common/custom_button_md.dart';
import 'chat_end_loading_viewmodel.dart';

class ChatViewModel extends GetxController {
  final int chatRoomId;
  final Character character;

  final FetchChatHistoryUsecase fetchChatHistoryUsecase =
  getIt<FetchChatHistoryUsecase>();
  final SendUserMessageUsecase sendMessageUsecase =
  getIt<SendUserMessageUsecase>();
  final GetRandomMindsetUseCase getRandomMindsetUseCase =
  getIt<GetRandomMindsetUseCase>();

  TextEditingController textController = TextEditingController();
  var messages = <Message>[].obs;
  var isLoading = false.obs;
  var questStatus = List<bool>.filled(5, false)
      .obs; // List indicating quest achievements
  var isQuestPopupShown = false.obs;
  var unachievedQuests = <String>[].obs;

  // Variable to track the number of "Firm Rejections"
  var firmRejectionCount = 0.obs;

  var aiResponse;
  var isEnd;
  var messageId;

  // Variable to keep track of the number of chats
  var chatCount = 0.obs;

  ChatViewModel({
    required this.chatRoomId,
    required this.character,
  });


  // Update the quest status
  void updateQuestStatus(int questIndex) {
    if (questIndex >= 0 && questIndex < questStatus.length) {
      questStatus[questIndex] = true;
      updateUnachievedQuests(); // Initialize the unachieved quests
    }
  }

  @override
  void onInit() {
    super.onInit();
    _loadMessages(); // Load and first AI message on screen
    updateUnachievedQuests(); // Initialize the unachieved quests
  }

  @override
  void onClose() {
    textController.dispose();
    super.onClose();
  }

  // Method to fetch chat history
  Future<void> _loadMessages() async {
    isLoading.value = true;
    try {
      var loadedMessages =
      await fetchChatHistoryUsecase.execute(chatRoomId); // Fetch chat history
      messages.value = loadedMessages!.reversed
          .toList(); // Add messages to the list in reverse order
    } catch (e) {
      print('Failed to load messages: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Method to send a message
  Future<void> sendMessage() async {
    if (textController.text.isEmpty) return;
    isLoading.value = true;
    try {
      var userMessage = await sendMessageUsecase.saveUserMessage(
          textController.text, chatRoomId);
      if (userMessage != null) {
        messages.insert(0, userMessage); // Add user message to the list
      }

      var responseMap = await sendMessageUsecase.generateAIResponse(
          chatRoomId, character, getUnachievedQuests());

      aiResponse = responseMap['aiResponse'] as AIResponse;
      isEnd = responseMap['isEnd'] as bool;
      messageId = responseMap['messageId'] as int?;

      if (responseMap.isNotEmpty) {
        Message? aiMessage =
        convertAIResponseToMessage(aiResponse!, messageId.toString());
        if (aiMessage != null) {
          messages.insert(0, aiMessage); // Add AI message to the list
        }
        chatCount.value += 1;

        // Update "Firm Rejection" category count
        if (aiResponse.rejectionContent.contains('Firm Rejection')) {
          firmRejectionCount.value += 1;
        }

        _handleQuestAchievements(aiResponse!); // aiResponse
        _checkIfConversationEnded(aiResponse, isEnd);
        textController.clear(); // Clear the text field
        // Check conditions and show toast message
        checkQuestGuideConditions();
      } else {
        print('No AI response received.');
      }
    } catch (e) {
      print('Message sending failed: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Convert AIResponse to Message
  Message? convertAIResponseToMessage(AIResponse aiResponse, String messageId) {
    return Message(
      sender: false,
      messageText: aiResponse.text,
      timestamp: DateTime.now().toIso8601String(),
      affinityScore: 50 + aiResponse.affinityScore,
      feeling: aiResponse.feeling,
      rejectionScore: aiResponse.rejectionScore,
      id: messageId,
    );
  }

  // Check if the conversation has ended
  Future<void> _checkIfConversationEnded(AIResponse aiResponse,
      bool isEnd) async {
    int requiredChats = _getRequiredChatLimitsForCharacter(character.name);
    debugPrint('Required Chats: ${requiredChats}');
    if (chatCount.value > requiredChats ||
        isEnd ||
        questStatus[0]
    ) {
      var fetchedMindset = await getRandomMindsetUseCase.execute();

      // Wait for 3 seconds
      await Future.delayed(const Duration(seconds: 2));

      // Navigate to chat end screen
      navigateToChatEndScreen(fetchedMindset!);
    }
  }

  // Navigate to chat end screen
  void navigateToChatEndScreen(MindsetResponse fetchedMindset) {
    Get.off(() =>
        ChatEndLoadingView(
            chatEndLoadingViewModel: Get.put(ChatEndLoadingViewModel(
                mindset: fetchedMindset,
                character: character,
                finalRejectionScore: aiResponse.finalRejectionScore,
                finalAffinityScore: aiResponse.affinityScore,
                unachievedQuests: getUnachievedQuests(),
                conversationId: chatRoomId))));
  }

  // Fetch quest information
  Future<String> getQuestInformation() async {
    return character.quest;
  }

  // Add reaction to a message
  void addReactionToMessage(Message message, String reaction) {
    final updatedReactions = List<String>.from(message.reactions);
    updatedReactions.add(reaction);

    final index = messages.indexOf(message);
    if (index != -1) {
      final updatedMessages = List<Message>.from(messages);
      updatedMessages[index] =
          message.copyWith(reactions: updatedReactions);
      messages.value = updatedMessages;
    }
  }

  // Show quest popup only once on the first entry
  Future<void> showQuestPopupIfFirstTime(BuildContext context) async {
    if (!isQuestPopupShown.value) {
      await showQuestPopup(context);
      isQuestPopupShown.value = true;
    }
  }

  // Show quest popup
  Future<void> showQuestPopup(BuildContext context) async {
    final questInfo = await getQuestInformation();
    List<String> questItems = questInfo.split('\n');

    await Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Quest while conversing with ${character.name}',
                style: textTheme().titleMedium,
              ),
              const SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: questItems.map((quest) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6.0),
                    child: Row(
                      children: [
                        Icon(
                          questStatus[questItems.indexOf(quest)]
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                          color: questStatus[questItems.indexOf(quest)]
                              ? Colors.blueAccent
                              : Colors.grey,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            quest,
                            maxLines: null,
                            overflow: TextOverflow.visible,
                            style: questStatus[questItems.indexOf(quest)]
                                ? const TextStyle(
                              decoration: TextDecoration.lineThrough,
                              color: Colors.black,
                            )
                                : const TextStyle(color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 30),
              CustomButtonMD(
                onPressed: () {
                  Get.back();
                },
                label: 'Got it!',
              ),
            ],
          ),
        ),
      ),
    );
  }


  // Handle quest achievements
  Future<void> _handleQuestAchievements(AIResponse aiResponse) async {
    if (aiResponse.rejectionContent != null &&
        aiResponse.rejectionContent.isNotEmpty) {
      for (int questIndex = 1;
      questIndex < questContentMap[character.name]!.length;
      questIndex++) {
        bool isQuestAchieved = _isQuestAchieved(questIndex, aiResponse);
        if (isQuestAchieved && !questStatus[questIndex]) {
          updateQuestStatus(questIndex);
          String questContent =
              questContentMap[character.name]?[questIndex] ?? 'Unknown Quest';

          Get.snackbar(
            "Quest Achieved!",
            "Quest Achieved! $questContent",
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.blue[700],
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );

          if (areMainQuestsAchieved()) {
            var fetchedMindset = await getRandomMindsetUseCase.execute();
            await Future.delayed(const Duration(seconds: 2));
            navigateToChatEndScreen(fetchedMindset!);
          }
        }
      }

      if (_isQuestAchieved(0, aiResponse) && !questStatus[0]) {
        updateQuestStatus(0);
        String questContent = questContentMap[character.name]?[0] ??
            'Unknown Quest';

        Get.snackbar(
          "Quest Achieved!",
          "Quest Achieved! $questContent",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.blue[700],
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    }
  }


  // Check if the quest is achieved
  bool _isQuestAchieved(int questIndex, AIResponse aiResponse) {
    List<String> rejectionContent = aiResponse.rejectionContent;
    List<String> questConditions =
        questConditionMap[character.name]?[questIndex] ?? [];

    if (firmRejectionCount.value >= 2 &&
        !rejectionContent.contains('Repeated Firm Rejection for Multiple Requests')) {
      rejectionContent.add('Repeated Firm Rejection for Multiple Requests');
    }

    // Quest 1: Process only if all other quests (1-4) are achieved
    if (questIndex == 0) {
      // Check if all other quests (1-4) are achieved
      for (int i = 1; i <= 4; i++) {
        if (!_isQuestAchieved(i, aiResponse)) {
          return false; // If any quest is not achieved, quest 0 cannot be achieved
        }
      }
    }

    // Negative rejection categories
    const negativeRejectionCategories = [
      "Obvious Lie",
      "Insult or Verbal Abuse",
      "Acceptance of Rejection",
      "Indifferent or Cold Response",
      "Sarcastic Attitude",
      "Rejection Without a Reason",
      "Off-Topic Response",
      "Unenthusiastic Response (3 or fewer characters)",
      "Blaming the Other Party"
    ];

    // Prevent quest achievement if the response contains any negative rejection category
    if (rejectionContent.any((category) => negativeRejectionCategories.contains(category))) {
      return false;
    }

    // Return true if at least one quest condition is met
    return questConditions.any((condition) => rejectionContent.contains(condition));
  }

  // Define quest contents for each character
  final Map<String, List<String>> questContentMap = {
    'Miyeon': [
      'Successfully Reject',
      'Attempt a Conversation to Understand the Situation of the Other Party',
      'Express Empathy for the Other Party’s Feelings',
      'Provide a Rational Reason for Not Helping',
      'Find a Compromise by Making Mutual Concessions',
    ],
    'Sejin': [
      'Successfully Reject',
      'Express Gratitude for Past Help',
      'Include Emotional Elements in the Rejection',
      'Provide a Rational Reason for Not Helping',
      'Find a Compromise by Making Mutual Concessions',
    ],
    'Hyuna': [
      'Successfully Reject',
      'State That There is Not Enough Time',
      'Show Respect for the Other Party’s Request',
      'Provide a Rational Reason for Not Helping',
      'Clearly Express Your Position Against Persistent Requests',
    ],
    'Jinhyuk': [
      'Successfully Reject',
      'Clearly Express Rejection Intent',
      'Present Logical Justifications',
      'Maintain a Consistent Stance',
      'Clearly Express Discomfort with Rude Behavior',
    ],
  };

  // Define quest conditions for each character (Mapped to rejection categories)
  final Map<String, List<List<String>>> questConditionMap = {
    'Miyeon': [
      [], // Quest 1: Successfully Reject (No specific rejection category)
      ['Verify Request Details'], // Quest 2: Attempt a Conversation to Understand the Situation
      ['Express Regret', 'Express Willingness to Help', 'Show Empathy for the Situation'], // Quest 3: Express Empathy for Feelings
      ['Rejection with a Reason'], // Quest 4: Provide a Rational Reason for Not Helping
      ['Suggest an Alternative'], // Quest 5: Find a Compromise by Making Mutual Concessions
    ],
    'Sejin': [
      [], // Quest 1: Successfully Reject
      ['Express Gratitude for Past Help'], // Quest 2: Express Gratitude
      ['Express Regret for Not Accepting', "Express Willingness to Help"], // Quest 3: Include Emotional Elements
      ['Rejection with a Reason'], // Quest 4: Provide a Rational Reason for Not Helping
      ['Suggest an Alternative'], // Quest 5: Suggest an Alternative Solution
    ],
    'Hyuna': [
      [], // Quest 1: Successfully Reject
      ['Time Constraint'], // Quest 2: Reject Due to Time Constraints
      ['Show Empathy for the Situation'], // Quest 3: Express Respect
      ['Rejection with a Reason'], // Quest 4: Provide a Rational Reason for Not Helping
      ['Repeated Firm Rejection for Multiple Requests'], // Quest 5: Clearly Express Position Against Persistent Requests
    ],
    'Jinhyuk': [
      [], // Quest 1: Successfully Reject
      ['Firm Rejection'], // Quest 2: Do Not Compromise
      ['Rejection with a Reason'], // Quest 3: Present Logical Justifications
      ['Repeated Firm Rejection for Multiple Requests'], // Quest 4: Maintain a Consistent Stance
      ['Clearly Establish Boundaries'], // Quest 5: Clearly Express Discomfort with Rude Behavior
    ],
  };

  // Check if all main quests (2, 3, 4, 5) are achieved
  bool areMainQuestsAchieved() {
    // Check if quests 2, 3, 4, and 5 are all achieved
    return questStatus[1] && questStatus[2] && questStatus[3] && questStatus[4];
  }

  // Get list of unachieved quests
  List<String> getUnachievedQuests() {
    List<String> unachievedQuests = [];
    for (int i = 1; i < questStatus.length; i++) {
      if (!questStatus[i]) {
        unachievedQuests
            .add(questContentMap[character.name]?[i] ?? 'Unknown Quest');
      }
    }
    return unachievedQuests;
  }

  // Get the required chat limit based on character
  int _getRequiredChatLimitsForCharacter(String characterName) {
    switch (characterName) {
      case 'Miyeon':
        return 11;
      case 'Sejin':
        return 11;
      case 'Hyuna':
        return 11;
      case 'Jinhyuk':
        return 11;
      default:
        return 0;
    }
  }

  // Method to update the list of unachieved quests
  void updateUnachievedQuests() {
    unachievedQuests.clear(); // Clear the existing list
    for (int i = 1; i < questStatus.length; i++) {
      if (!questStatus[i]) {
        unachievedQuests.add(
            questContentMap[character.name]?[i] ?? 'Unknown Quest');
      }
    }
  }

  // Method to check conditions and display a toast message
  void checkQuestGuideConditions() {
    // Check for the specific rejection category 'Acceptance of Rejection'
    if (aiResponse.rejectionContent.contains('Acceptance of Rejection')) {
      showToastMessage(
          'Do not accept the rejection, try rejecting it again!'); // Show the toast message
    }

    // Existing condition for chat count
    if (chatCount.value > 6) {
      showToastMessage('Try following the quest and rejecting once! 😊');
    }
  }

  void showToastMessage(String message) {
    Get.snackbar(
      'Chat Tip!', // Title
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.black.withOpacity(0.6),
      // Semi-transparent black background
      colorText: Colors.white,
      // White text
      margin: const EdgeInsets.all(16),
      // Margin around the toast
      borderRadius: 8.0,
      // Rounded corners
      duration: const Duration(seconds: 3), // Duration to show the message
    );
  }
}
