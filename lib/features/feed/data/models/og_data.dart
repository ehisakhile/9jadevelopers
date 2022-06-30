import 'dart:convert';

import 'package:flutter/material.dart';

class OgData {
  final String? title;
  final String? description;
  final String? image;
  final String? type;
  final String? url;

  OgData({
    this.title,
    this.description,
    this.image,
    this.type,
    this.url,
  });

  OgData copyWith({
    String? title,
    String? description,
    String? image,
    String? type,
    String? url,
  }) {
    return OgData(
      title: title ?? this.title,
      description: description ?? this.description,
      image: image ?? this.image,
      type: type ?? this.type,
      url: url ?? this.url,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'image': image,
      'type': type,
      'url': url,
    };
  }

  factory OgData.fromMap(Map<String, dynamic> map) {
    final _title = map['title'] ?? map['og:title'];
    final _description = map['description'] ?? map['og:description'];
    final _image = map['image'] ?? map['og:image'];
    final _url = map['url'] ?? map['og:url'];
    return OgData(
      title: _title,
      description: _description,
      image: _image,
      type: map['type'],
      url: _url,
    );
  }
}
