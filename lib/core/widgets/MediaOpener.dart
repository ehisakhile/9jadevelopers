import 'dart:io';
// import 'package:awsome_video_player/awsome_video_player.dart';
import 'package:auto_route/src/router/auto_router_x.dart';
import 'package:better_player/better_player.dart';
import 'package:colibri/core/common/media/media_data.dart';
import 'package:colibri/core/routes/routes.gr.dart';
import 'package:colibri/core/config/colors.dart';
import 'package:colibri/features/feed/presentation/widgets/create_post_card.dart';
import 'package:colibri/features/posts/presentation/widgets/video_play_button.dart';
import 'package:colibri/features/posts/presentation/widgets/video_sound_button.dart';
import 'package:colibri/features/posts/presentation/widgets/video_time_label_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_view/photo_view.dart';
import 'package:colibri/extensions.dart';

class MediaOpener extends StatefulWidget {
  final MediaData? data;
  const MediaOpener({Key? key, this.data}) : super(key: key);
  @override
  _MediaOpenerState createState() => _MediaOpenerState();
}

class _MediaOpenerState extends State<MediaOpener> {
  @override
  Widget build(BuildContext context) {
    switch (widget.data!.type) {
      case MediaTypeEnum.IMAGE:
        return OpenImage(
          path: widget.data!.path,
        );

      case MediaTypeEnum.VIDEO:
        return MyVideoPlayer(
          path: widget.data!.path,
        );

      case MediaTypeEnum.GIF:
        return OpenImage(
          path: widget.data!.path,
        );

      case MediaTypeEnum.EMOJI:
        return Container();

      default:
        return Container();
    }
  }
}

/// video player code...

class MyVideoPlayer extends StatefulWidget {
  final String? path;
  final bool withAppBar;
  final bool fullVideoControls;
  final bool? isComeHome;

  const MyVideoPlayer({
    Key? key,
    this.path,
    this.withAppBar = true,
    this.fullVideoControls = false,
    this.isComeHome,
  }) : super(key: key);
  @override
  MyVideoPlayerState createState() => MyVideoPlayerState();
}

class MyVideoPlayerState extends State<MyVideoPlayer> {
  late BetterPlayerController _betterPlayerController;
  bool isPlaying = false;
  Duration videoTimePlayed = Duration(seconds: 0);
  @override
  void initState() {
    super.initState();
    isPlaying = widget.fullVideoControls;

    playerControllerShow();
    _betterPlayerController.setVolume(0.0);
    _betterPlayerController.addEventsListener(betterPlayerEvenetListener);
  }

  void betterPlayerEvenetListener(BetterPlayerEvent event) {
    String? _newProgress =
        event.parameters?["progress"].toString().split(".")[0];

    if (_newProgress != 'null') {
      final format = DateFormat("HH:mm:ss");
      final progressFormat = format.parse(_newProgress!);
      videoTimePlayed = Duration(
        hours: progressFormat.hour,
        minutes: progressFormat.minute,
        seconds: progressFormat.second,
      );
    }
  }

  // This kicks of then playing video
  playerControllerShow() {
    BetterPlayerDataSource betterPlayerDataSource = BetterPlayerDataSource(
      widget.path!.contains("https")
          ? BetterPlayerDataSourceType.network
          : BetterPlayerDataSourceType.file,
      widget.path!,
    );

    _betterPlayerController = BetterPlayerController(
      BetterPlayerConfiguration(
        autoPlay: true,
        fit: BoxFit.fitHeight,
        aspectRatio: 19 / 16,
        deviceOrientationsOnFullScreen: [
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
          DeviceOrientation.portraitUp,
        ],
        controlsConfiguration: isPlaying
            ? const BetterPlayerControlsConfiguration()
            : const BetterPlayerControlsConfiguration(
                enableFullscreen: false,
                showControlsOnInitialize: false,
                showControls: false,
              ),
      ),
      betterPlayerDataSource: betterPlayerDataSource,
    );
  }

  void pause() {
    _betterPlayerController.pause();
  }

  @override
  Widget build(BuildContext context) {
    return widget.withAppBar ? withAppBarWidget() : withOutAppBarWidget();
  }

  Widget withAppBarWidget() {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.black, //change your color here
        ),
        title: "Video Player".toSubTitle1(
          (url) => context.router.root.push(WebViewScreenRoute(url: url)),
          color: AppColors.textColor,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: Colors.white,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: SafeArea(
        child: BetterPlayer(
          controller: _betterPlayerController,
        ),
      ),
    );
  }

  Widget withOutAppBarWidget() {
    return Stack(
      alignment: Alignment.center,
      children: [
        BetterPlayer(
          controller: _betterPlayerController,
        ),
        VideoPlayButton(_betterPlayerController)
            .toVisibility(!widget.fullVideoControls),
        // time
        Positioned(
          left: 10,
          bottom: 10,
          child: VideoTimeLabelWidget(_betterPlayerController),
        ),
        // sound
        Positioned(
          right: 10,
          bottom: 10,
          child: VideoSoundButton(_betterPlayerController),
        ),
      ],
    ); //
  }

  @override
  void dispose() {
    super.dispose();
    _betterPlayerController.dispose();
  }
}

class OpenImage extends StatelessWidget {
  final String? path;

  const OpenImage({Key? key, this.path}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.black, //change your color here
        ),
        title: "Gallery".toSubTitle1(
            (url) => context.router.root.push(WebViewScreenRoute(url: url)),
            color: AppColors.textColor,
            fontWeight: FontWeight.bold),
        backgroundColor: Colors.white,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: Container(
        child: PhotoView(
          imageProvider: path!.isValidUrl
              ? Image.network(path!, headers: {'accept': 'image/*'})
                  as ImageProvider<Object>?
              : FileImage(
                  File(path!),
                ),
        ),
      ),
    );
  }
}
