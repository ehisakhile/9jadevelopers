import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';

class VideoSoundButton extends StatefulWidget {
  final BetterPlayerController controller;
  const VideoSoundButton(this.controller, {Key? key}) : super(key: key);

  @override
  _VideoSoundButtonState createState() => _VideoSoundButtonState();
}

class _VideoSoundButtonState extends State<VideoSoundButton> {
  bool isMute = true;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
        color: Colors.black12,
      ),
      child: GestureDetector(
        onTap: () => setState(() {
          isMute = !isMute;
          if (isMute) {
            widget.controller.setVolume(0.0);
          } else {
            widget.controller.setVolume(1.0);
          }
        }),
        child: Icon(
          isMute ? Icons.volume_off : Icons.volume_up,
          color: Colors.white60,
          size: 20,
        ),
      ),
    );
  }
}
