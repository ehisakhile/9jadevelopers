import 'dart:io';

import '../common/media/media_data.dart';
import '../../features/feed/presentation/widgets/create_post_card.dart';
import 'package:flutter/material.dart';
import '../../extensions.dart';

class ThumbnailWidget extends StatefulWidget {
  final MediaData? data;
  final VoidCallback? onCloseTap;
  final double? height;
  final double? width;
  const ThumbnailWidget(
      {Key? key, this.data, this.onCloseTap, this.height, this.width})
      : super(key: key);
  @override
  _ThumbnailWidgetState createState() => _ThumbnailWidgetState();
}

class _ThumbnailWidgetState extends State<ThumbnailWidget> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.file(
            File(widget.data!.thumbnail!),
            height: widget.data!.type == MediaTypeEnum.IMAGE
                ? widget.height ?? 120
                : widget.height ?? 200.toHeight as double?,
            width: widget.data!.type == MediaTypeEnum.IMAGE
                ? widget.width ?? context.getScreenWidth * .40
                : widget.width ?? context.getScreenWidth as double?,
            fit: widget.data!.type == MediaTypeEnum.IMAGE
                ? BoxFit.cover
                : BoxFit.fill,
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: const Icon(
            Icons.close,
            size: 18,
            color: Colors.red,
          )
              .toContainer(
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.red, width: 1),
                      shape: BoxShape.circle,
                      color: Colors.white))
              .onTapWidget(() {
            widget.onCloseTap!.call();
          }),
        ),
      ],
    ).toContainer();
  }
}

class GiphyWidget extends StatefulWidget {
  final int? itemIndex;
  final int? length;

  final String? path;
  final VoidCallback? fun;
  final bool enableClose;
  final double? height;
  final double? width;
  const GiphyWidget(
      {Key? key,
      this.path,
      this.fun,
      this.enableClose = true,
      this.itemIndex,
      this.height,
      this.width,
      this.length})
      : super(key: key);
  @override
  _GiphyWidgetState createState() => _GiphyWidgetState();
}

class _GiphyWidgetState extends State<GiphyWidget> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
            borderRadius:
                boarderRadiusCheck(widget.itemIndex ?? 0, widget.length ?? 0),
            child: Image.network(
              widget.path!,
              headers: {'accept': 'image/*'},
              height: widget.height,
              width: widget.width,
            )),
        Visibility(
          visible: widget.enableClose,
          child: Positioned(
            top: 0,
            right: 0,
            child: const Icon(
              Icons.close,
              size: 18,
              color: Colors.red,
            )
                .toContainer(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red, width: 1),
                shape: BoxShape.circle,
                color: Colors.white,
              ),
            )
                .onTapWidget(() {
              widget.fun!.call();
            }),
          ),
        ),
      ],
    ).toContainer().toHorizontalPadding(12);
  }

  boarderRadiusCheck(int itemIndex, int length) {
    if (length == 1) {
      return BorderRadius.circular(40);
    } else if (length == 2) {
      if (itemIndex == 0) {
        return const BorderRadius.only(
            topLeft: Radius.circular(40), bottomLeft: Radius.circular(40));
      } else {
        return const BorderRadius.only(
            topRight: Radius.circular(40), bottomRight: Radius.circular(40));
      }
    } else if (length == 3) {
      if (itemIndex == 0) {
        return const BorderRadius.only(
            topLeft: Radius.circular(40), bottomLeft: Radius.circular(40));
      } else if (itemIndex == 1) {
        return const BorderRadius.only(topRight: Radius.circular(40));
      } else {
        return const BorderRadius.only(bottomRight: Radius.circular(40));
      }
    } else if (length == 4) {
      if (itemIndex == 0) {
        return const BorderRadius.only(topLeft: Radius.circular(40));
      } else if (itemIndex == 1) {
        return const BorderRadius.only(bottomLeft: Radius.circular(40));
      } else if (itemIndex == 2) {
        return const BorderRadius.only(topRight: Radius.circular(40));
      } else {
        return const BorderRadius.only(bottomRight: Radius.circular(40));
      }
    } else {
      return BorderRadius.circular(40);
    }
  }
}
