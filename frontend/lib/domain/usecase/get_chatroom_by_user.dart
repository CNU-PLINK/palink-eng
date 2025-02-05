import 'package:palink_v2/data/mapper/conversation_mapper.dart';
import 'package:palink_v2/domain/model/chat/conversation.dart';
import 'package:palink_v2/domain/repository/chat_repository.dart';
import 'package:palink_v2/data/models/chat/conversation_response.dart';
import 'package:palink_v2/domain/repository/user_repository.dart';

class GetChatroomByUser {
  final ChatRepository chatRepository;
  final UserRepository userRepository;

  GetChatroomByUser(this.chatRepository, this.userRepository);

  Future<List<Conversation>> execute() async {
    int? userId = userRepository.getUserId();

    List<ConversationResponse> response =
        await chatRepository.fetchConversationsByUserId(userId!);

    // List<ConversationResponse> -> List<Conversation>
    List<Conversation> conversations =
        response.map((convResp) => convResp.toDomain()).toList();
    return conversations;
  }
}
