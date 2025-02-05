import 'package:json_annotation/json_annotation.dart';
import 'package:palink_v2/domain/model/analysis/feedback.dart';
import 'feedback_response.dart';

part 'feedbacks_response.g.dart';

@JsonSerializable()
class FeedbacksResponse {
  final List<FeedbackResponse> feedbacks;

  FeedbacksResponse({required this.feedbacks});

  factory FeedbacksResponse.fromJson(Map<String, dynamic> json) => _$FeedbacksResponseFromJson(json);
  Map<String, dynamic> toJson() => _$FeedbacksResponseToJson(this);

  Feedback toDomain() {
    return feedbacks.isNotEmpty ? feedbacks.first.toDomain() : throw Exception('No feedbacks available');
  }
}
