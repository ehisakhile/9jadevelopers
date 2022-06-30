import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Function of this class is to detect if there is bottom and top padding
/// for the device so we put it if not then we don't put anything
/// Put on top of any scaffold
class IosSafeWidget extends StatelessWidget {
  const IosSafeWidget({Key? key, required this.child}) : super(key: key);
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final pixels = window.viewPadding;
    double bottomPixels = 0;
    if (!Platform.isIOS) return Container(child: child);
    if (pixels.bottom < 85)
      bottomPixels = pixels.bottom - 40.h;
    else
      bottomPixels = pixels.bottom - 85.h;
    if (bottomPixels < 0) bottomPixels = 0;

    return Padding(
      padding: EdgeInsets.only(
        bottom: bottomPixels,
      ),
      child: child,
    );
  }
}
