import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';

class VideoSlider extends StatefulWidget {
  const VideoSlider(this.url, this.startDuration, {Key? key}) : super(key: key);
  final String url;
  final Duration startDuration;

  @override
  State<VideoSlider> createState() => _VideoSliderState();
}

class _VideoSliderState extends State<VideoSlider> {
  late BetterPlayerController _controller;

  @override
  void initState() {
    super.initState();
    final BetterPlayerDataSource _betterPlayerDataSource =
        BetterPlayerDataSource(BetterPlayerDataSourceType.network, widget.url);
    _controller = BetterPlayerController(
      BetterPlayerConfiguration(
        fit: BoxFit.fitHeight,
        startAt: widget.startDuration,
        autoPlay: true,
      ),
      betterPlayerDataSource: _betterPlayerDataSource,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: BetterPlayer(controller: _controller),
        ),
      ],
    );
  }
}
