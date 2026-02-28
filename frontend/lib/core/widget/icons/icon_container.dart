import 'package:flutter/material.dart';

class IconContainer extends StatelessWidget {
  final Widget child;
  final Color? color;

  const IconContainer({super.key, required this.child, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12.5),
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            blurRadius: 0.25,
            offset: Offset(0.25, 1.25),
            spreadRadius: 0.15,
          ),
        ],
      ),
      child: child,
    );
  }
}
