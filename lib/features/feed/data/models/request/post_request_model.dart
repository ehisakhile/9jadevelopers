import 'dart:collection';

import 'dart:convert';

import 'package:colibri/features/feed/data/models/og_data.dart';

class PostRequestModel {
  final String? postText;
  final String? gifUrl;
  final String? threadId;
  final OgData? ogData;
  final List<Map<String, String>>? poll_data;
  final String? ogDataTitle;
  final String? ogDataDescription;
  final String? ogImage;
  final String? ogWebsite;
  final String? ogUrl;

  PostRequestModel({
    this.postText,
    this.gifUrl,
    this.threadId,
    this.ogData,
    this.poll_data,
    this.ogDataTitle,
    this.ogDataDescription,
    this.ogImage,
    this.ogWebsite,
    this.ogUrl,
  });

  HashMap<String, dynamic> toMap() {
    final ogDataMap = HashMap<String, dynamic>.from({
      "post_text": postText ?? "",
      "thread_id": threadId ?? "",
      "gif_src": gifUrl ?? "",
      "og_data": ogData?.toMap(),
      'poll_data': jsonEncode(poll_data),
    });
    return ogDataMap;
  }
}
