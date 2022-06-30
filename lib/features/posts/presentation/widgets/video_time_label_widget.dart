import 'package:better_player/better_player.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class VideoTimeLabelWidget extends StatefulWidget {
  final BetterPlayerController controller;

  const VideoTimeLabelWidget(this.controller, {Key? key}) : super(key: key);

  @override
  _VideoTimeLabelWidgetState createState() => _VideoTimeLabelWidgetState();
}

class _VideoTimeLabelWidgetState extends State<VideoTimeLabelWidget> {
  String progress = "00:00:00";
  String duration = "00:00:00";
  String timeLeft = '00:00';
  @override
  void initState() {
    super.initState();
    widget.controller.addEventsListener(betterPlayerEvenetListener);
  }

  void betterPlayerEvenetListener(BetterPlayerEvent event) {
    String? _newProgress =
        event.parameters?["progress"].toString().split(".")[0];
    String? _newDuration =
        event.parameters?["duration"].toString().split(".")[0];

    if (_newProgress != 'null' && _newDuration != 'null') {
      final format = DateFormat("HH:mm:ss");
      final progressFormat = format.parse(_newProgress!);
      final durationFormat = format.parse(_newDuration!);
      // todo bloc.timeVideoPlayed = durationFormat.toString()
      String difference =
          durationFormat.difference(progressFormat).toString().split('.')[0];
      if (difference[0] == '0') difference = difference.substring(2);
      setState(() {
        timeLeft = difference;
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(2),
      ),
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Text(
        timeLeft,
        style: TextStyle(
          fontSize: 10,
          color: Colors.white,
        ),
      ),
    );
  }
}
