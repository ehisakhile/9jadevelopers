import 'package:better_player/better_player.dart';
import 'package:colibri/core/config/colors.dart';

import 'package:colibri/core/widgets/circle_painter.dart';
import 'package:colibri/extensions.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class VideoPlayButton extends StatefulWidget {
  final BetterPlayerController controller;
  const VideoPlayButton(this.controller, {Key? key}) : super(key: key);

  @override
  _VideoPlayButtonState createState() => _VideoPlayButtonState();
}

class _VideoPlayButtonState extends State<VideoPlayButton> {
  bool isIconShown = true;
  @override
  void initState() {
    super.initState();
    widget.controller.addEventsListener(betterPlayerEvenetListener);
    widget.controller.setVolume(0.0);
  }

  void betterPlayerEvenetListener(BetterPlayerEvent event) {
    if (event.betterPlayerEventType == BetterPlayerEventType.play ||
        event.betterPlayerEventType == BetterPlayerEventType.progress) {
      setState(() {
        isIconShown = false;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    widget.controller.removeEventsListener(betterPlayerEvenetListener);
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: CirclePainter(),
      child: Container(
        height: 40.toHeight as double?,
        width: 40.toHeight as double?,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.colorPrimary,
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 2.0),
          child: const Icon(
            FontAwesomeIcons.play,
            color: Colors.white,
            size: 17,
          ),
        ),
      ),
    ).toVisibility(isIconShown);
  }
}
