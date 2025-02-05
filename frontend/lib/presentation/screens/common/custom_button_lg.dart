import 'package:flutter/material.dart';

class CustomButtonLG extends StatelessWidget {
  final String label;
  VoidCallback onPressed;

  CustomButtonLG({Key? key, required this.label, required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      height: 50.0,
      width: screenWidth * 0.8,

      decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
          borderRadius: BorderRadius.circular(10.0),
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
              fontSize: 20,
            ),
          )
      ),
    );
  }
}
