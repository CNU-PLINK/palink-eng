import 'package:palink_v2/data/models/ai_response/tip_request.dart';
import 'package:palink_v2/data/models/ai_response/tip_response.dart';
import 'package:palink_v2/data/models/tip/tip_create_request.dart';
import 'package:palink_v2/di/locator.dart';
import 'package:palink_v2/domain/model/tip/tip.dart';
import 'package:palink_v2/domain/repository/open_ai_repository.dart';
import 'package:palink_v2/domain/repository/tip_repository.dart';

class GenerateTipUsecase {
  final OpenAIRepository aiRepository = getIt<OpenAIRepository>();
  final TipRepository tipRepository = getIt<TipRepository>();

  Future<TipResponse?> execute(
      int messageId, String message, List<String> unachievedQuests) async {
    TipRequest input = TipRequest(
      message: message,
      unachievedQuests: unachievedQuests,
    );

    TipResponse? tipResponse = await aiRepository.createTip(input);
    TipResponse? newTipResponse;
    if (tipResponse != null) {
      // combine the tip text and reason
      String combinedTipText =
          '${tipResponse.answer}';
      // save the tip to the database
      tipRepository.createTip(
        TipCreateRequest(
          messageId: messageId,
          tipText: combinedTipText, // save the combined tip text
        ),
      );
      newTipResponse = TipResponse(
        answer: combinedTipText,
        reason: combinedTipText,
      );
    }
    return newTipResponse;
  }
}
