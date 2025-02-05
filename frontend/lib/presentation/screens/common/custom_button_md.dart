import 'package:flutter/material.dart';

class CustomButtonMD extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const CustomButtonMD({Key? key, required this.label, required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
      return Container(
        height: 43.0,
        width: 165.0,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.0),
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xff3dadff), Color(0xff1986fc)],
            )
        ),
        child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
            ),
            onPressed: onPressed,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
              ),
            )
        ),
      );
  }
}