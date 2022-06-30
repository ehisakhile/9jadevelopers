import '../../../features/feed/presentation/widgets/create_post_card.dart';

part 'media_data.g.dart';

class MediaData {
  final MediaTypeEnum? type;
  final String? path;
  final String? thumbnail;
  final String? id;
  MediaData({
    this.type,
    this.path,
    this.thumbnail,
    this.id,
  });
}
