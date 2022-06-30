import 'package:flutter/material.dart';

class MediaPageBuilder extends PageRouteBuilder {
  final Widget page;
  MediaPageBuilder(this.page)
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondAnimation,
          ) =>
              page,
          transitionsBuilder: (BuildContext context,
              Animation<double> animation,
              Animation<double> secondAnimation,
              Widget child) {
            return Align(
              alignment: Alignment.center,
              child: SizeTransition(
                sizeFactor: CurvedAnimation(
                  parent: animation,
                  curve: Curves.linear,
                ),
                axis: Axis.horizontal,
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 400),
        );
}
