import 'package:flutter/material.dart';
import 'package:palink_v2/core/theme/app_fonts.dart';




class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const CustomButton({Key? key, required this.label, required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 6,
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
      height: 50.0,
      width: screenWidth * 0.8,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(7.0),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: textTheme().displayMedium,
        ),
      ),
    );
  }
}
