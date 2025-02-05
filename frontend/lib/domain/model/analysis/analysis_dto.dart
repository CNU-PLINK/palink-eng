import 'package:json_annotation/json_annotation.dart';

part 'analysis_dto.g.dart';

@JsonSerializable()
class AnalysisDto {
  final String evaluation;
  @JsonKey(name: 'final_rejection_score')
  final int finalRejectionScore;
  @JsonKey(name: 'final_affinity_score')
  final int finalAffinityScore;
  final String unachievedQuests;
  final String usedRejection;
  final String type;

  AnalysisDto({
    required this.evaluation,
    required this.finalRejectionScore,
    required this.finalAffinityScore,
    required this.unachievedQuests,
    required this.usedRejection,
    required this.type,
  });

  factory AnalysisDto.fromJson(Map<String, dynamic> json) => _$AnalysisDtoFromJson(json);

  Map<String, dynamic> toJson() => _$AnalysisDtoToJson(this);
}
