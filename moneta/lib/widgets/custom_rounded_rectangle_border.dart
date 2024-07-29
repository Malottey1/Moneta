import 'package:flutter/material.dart';

class CustomRoundedRectangleBorder extends ShapeBorder {
  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) => getOuterPath(rect, textDirection: textDirection);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..moveTo(rect.left, rect.top + 10)
      ..quadraticBezierTo(rect.left, rect.top, rect.left + 10, rect.top)
      ..lineTo(rect.right - 80, rect.top)
      ..quadraticBezierTo(rect.right, rect.top, rect.right, rect.top + 80)
      ..lineTo(rect.right, rect.bottom - 10)
      ..quadraticBezierTo(rect.right, rect.bottom, rect.right - 10, rect.bottom)
      ..lineTo(rect.left + 10, rect.bottom)
      ..quadraticBezierTo(rect.left, rect.bottom, rect.left, rect.bottom - 10)
      ..close();
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) => CustomRoundedRectangleBorder();
}