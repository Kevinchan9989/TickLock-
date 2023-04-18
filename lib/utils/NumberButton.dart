import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pwmanager/themes/color.dart';

class NumberButton extends StatelessWidget {
  final int number;
  final Function(int) onPressed;

  const NumberButton({required this.number, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onPressed(number),
      child: Container(
        height: 65,
        width: 65,
        decoration: BoxDecoration(
          color: MainColor.primaryColor10,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 5,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Center(
          child: Text(
            number.toString(),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
