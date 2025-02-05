import 'package:flutter/material.dart';

class FeelingBar extends StatelessWidget {
  final String feeling;

  FeelingBar({super.key, required this.feeling});

  @override
  Widget build(BuildContext context) {
    final feelingsList = _parseFeelingString(feeling);

    return Container(
      width: 68,
      margin: const EdgeInsets.only(bottom: 10, top: 4, left: 5),
      child: Text(
        feelingsList.map((feelingData) {
          final feelingType = feelingData['type'] as String;
          final feelingPercentage = feelingData['percentage'] as int;
          return '$feelingType $feelingPercentage%';
        }).join(', '),
        style: const TextStyle(
          color: Colors.black54,
          fontSize: 9,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  List<Map<String, dynamic>> _parseFeelingString(String feelingString) {
    final feelings = feelingString.split(',').map((feeling) {
      final parts = feeling.trim().split(' ');
      return {
        'type': parts[0],
        'percentage': int.parse(parts[1]),
      };
    }).toList();

    return feelings;
  }
}
