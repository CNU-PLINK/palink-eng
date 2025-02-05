import 'package:get/get.dart';
import 'package:palink_v2/di/locator.dart';
import 'package:palink_v2/domain/model/chat/conversation.dart';
import 'package:palink_v2/domain/usecase/get_chatroom_by_user.dart';
import 'package:palink_v2/domain/model/character/character.dart';
import 'package:palink_v2/domain/repository/character_repository.dart';

class MyconversationsViewmodel extends GetxController {
  final GetChatroomByUser getChatroomByUser = Get.put(getIt<GetChatroomByUser>());
  final CharacterRepository characterRepository = Get.put(getIt<CharacterRepository>());

  List<Conversation> chatrooms = [];
  Map<int, Character> characters = {};

  MyconversationsViewmodel();

  @override
  void onInit() {
    super.onInit();
    _loadChatRooms();
  }

  void _loadChatRooms() async {
    try {
      var fetchedData = await getChatroomByUser.execute();
      chatrooms = fetchedData;

      for (var conversation in chatrooms) {
        var characterId = conversation.characterId;

        var character = await characterRepository.getCharacterById(characterId);
        characters[characterId] = character;
      }

      update();
    } catch (e) {
      //Get.snackbar('Error', 'Failed to load chatrooms');
    }
  }
}
