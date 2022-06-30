import 'package:cached_network_image/cached_network_image.dart';
import '../../extensions/context_exrensions.dart';
import '../../extensions/widget_extensions.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

class ImageSlider extends StatelessWidget {
  const ImageSlider(this.url, {Key? key}) : super(key: key);
  final String url;
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: context.getScreenHeight * .7,
      ),
      child: CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.scaleDown,
        progressIndicatorBuilder: (_, __, progress) {
          Vx.teal100;
          return const CircularProgressIndicator().toPadding(8).toCenter();
        },
      ),
    );
  }
}
