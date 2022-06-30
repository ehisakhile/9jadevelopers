import 'package:flutter/material.dart';

class MyBorderShape extends ShapeBorder {
  MyBorderShape();

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  final double holeSize = 80;

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return Path.combine(
      PathOperation.difference,
      Path()
        ..addRRect(
          RRect.fromRectAndRadius(
            rect,
            Radius.circular(0),
          ),
        )
        ..close(),
      Path()
        ..addOval(
          Rect.fromCenter(
            center: rect.center.translate(0, -rect.height / 1.4),
            height: holeSize,
            width: holeSize,
          ),
        )
        ..close(),
    );
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) => this;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    throw UnimplementedError();
  }
}
