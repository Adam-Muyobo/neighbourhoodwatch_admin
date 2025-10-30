import 'package:flutter/material.dart';

Widget neumorphicSurface({required Widget child, double radius = 12}) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.grey[200],
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.35),
          offset: const Offset(8, 8),
          blurRadius: 16,
        ),
        BoxShadow(
          color: Colors.white.withOpacity(0.9),
          offset: const Offset(-6, -6),
          blurRadius: 16,
        ),
      ],
    ),
    child: child,
  );
}