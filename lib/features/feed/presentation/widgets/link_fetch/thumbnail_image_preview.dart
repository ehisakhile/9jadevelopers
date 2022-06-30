import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'default_circular_progress.dart';

class ThumbnailImagePreview extends StatelessWidget {
  final String _image;

  ThumbnailImagePreview(this._image);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(10),
        topRight: Radius.circular(10),
      ),
      child: CachedNetworkImage(
        imageUrl: _image,
        width: MediaQuery.of(context).size.width,
        fit: BoxFit.fill,
        errorWidget: (context, url, error) => Icon(
          Icons.error,
          color: Theme.of(context).colorScheme.secondary,
        ),
        progressIndicatorBuilder: (_, __, ___) => DefaultCircularProgress(),
      ),
    );
  }
}
