import 'package:flutter/material.dart';
import 'package:palink_v2/core/theme/app_colors.dart';

class QuestBox extends StatelessWidget {
  final String questText;

  const QuestBox({super.key, required this.questText});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:
          const EdgeInsets.only(top: 10.0, bottom: 10.0, left: 0.0, right: 8.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6.0),
        gradient: const LinearGradient(
          colors: [Color(0xff6BB2FF), Color(0xff2A91FF)],
          begin: Alignment.topLeft,
          end: Alignment.topRight
        ),
        border: Border.all(
          color: Colors.grey,
          width: 0.6,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 2.0,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // 텍스트를 왼쪽 정렬
        children: [
          const Text(
            'Quest In Progress',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6.0),
          // 퀘스트 내용
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.keyboard_arrow_right, color: Colors.white70, size: 16), // 체크 아이콘 추가
              const SizedBox(width: 1.0),
              Flexible(
                child: Text(
                  questText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
