import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:colibri/core/config/api_constants.dart';
import 'package:colibri/features/feed/data/models/og_data.dart';
import 'package:flutter/cupertino.dart';

import '../../../../core/common/media/media_data.dart';
import '../../../../core/common/stream_validators.dart';
import '../../../../core/common/uistate/common_ui_state.dart';
import '../../../feed/data/models/request/post_request_model.dart';
import '../../../feed/domain/usecase/create_post_use_case.dart';
import '../../../feed/domain/usecase/get_drawer_data_use_case.dart';
import '../../../feed/domain/usecase/upload_media_use_case.dart';
import '../../../feed/presentation/widgets/create_post_card.dart';
import '../../domain/entiity/media_entity.dart';
import '../../domain/usecases/delete_media_use_case.dart';
import '../../../profile/domain/entity/profile_entity.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import '../../../../extensions.dart';
import 'package:http/http.dart' as http;
import 'package:collection/collection.dart';

part 'createpost_state.dart';

@injectable
class CreatePostCubit extends Cubit<CommonUIState> {
  final postTextValidator = FieldValidators(null, null)
    ..textController.text = "";

  static final RegExp REGEX_EMOJI = RegExp(
      r'(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])');

  final mediaItems = <MediaData>[];

  final imageController =
      BehaviorSubject<List<MediaData>>.seeded(<MediaData>[]);
  Function(List<MediaData>) get changeImages => imageController.sink.add;
  Stream<List<MediaData>> get images => imageController.stream;

  Stream<bool> get imageButton => Rx.combineLatest([images], (values) {
        if ((values[0]! as List<MediaData>).isEmpty) return true;
        List<MediaData> data = values[0] as List<MediaData>;
        return data.any((element) => element.type == MediaTypeEnum.IMAGE);
      });

  Stream<bool> get pollButton => Rx.combineLatest(
        [images],
        (values) => (values[0]! as List<MediaData>).isEmpty,
      );

  Stream<bool> get videoButton => Rx.combineLatest(
        [images],
        (values) => (values[0]! as List<MediaData>).isEmpty,
      );

  Stream<bool> get gifButton => Rx.combineLatest([images], (values) {
        if ((values[0]! as List<MediaData>).isEmpty) return true;
        var data = values[0] as List<MediaData>;
        return data.any((element) => element.type == MediaTypeEnum.GIF);
      });

  final enablePublishController = BehaviorSubject<bool>.seeded(false);
  Function(bool) get changePublishButton => enablePublishController.sink.add;
  Stream<bool> get enablePublishButton => enablePublishController.stream;

  final _drawerEntityController = BehaviorSubject<ProfileEntity>();
  Function(ProfileEntity) get changeDrawerEntity =>
      _drawerEntityController.sink.add;
  Stream<ProfileEntity> get drawerEntity => _drawerEntityController.stream;

  final UploadMediaUseCase uploadMediaUseCase;
  final CreatePostUseCase? createPostUseCase;
  final DeleteMediaUseCase? deleteMediaUseCase;
  final GetDrawerDataUseCase? getDrawerDataUseCase;
  OgData? ogDataMap;

  CreatePostCubit(this.uploadMediaUseCase, this.createPostUseCase,
      this.deleteMediaUseCase, this.getDrawerDataUseCase)
      : super(const CommonUIState.initial()) {
    Rx.merge([postTextValidator.stream, postTextValidator.stream, images])
        .listen((event) {
      if (event is String && REGEX_EMOJI.hasMatch(event))
        changePublishButton(true);
      else if (event is String)
        changePublishButton(event.isNotEmpty || mediaItems.isNotEmpty);
      else if (event is List<MediaData>)
        changePublishButton(
            event.isNotEmpty || postTextValidator.text.isNotEmpty);
    });
  }

  addImage(String? image) async {
    emit(const CommonUIState.loading());
    mediaItems.removeWhere((element) => element.type != MediaTypeEnum.IMAGE);

    var mediaData =
        MediaData(type: MediaTypeEnum.IMAGE, thumbnail: image, path: image);

    var either = await uploadMediaUseCase(mediaData);
    either.fold(
      (l) => null,
      (r) => {mediaItems.add(mediaData.copyWith(id: r.mediaId))},
    );
    emit(const CommonUIState.success(""));
    changeImages(mediaItems);
  }

  addGif(String? image) {
    mediaItems.clear();
    mediaItems
        .add(MediaData(type: MediaTypeEnum.GIF, thumbnail: image, path: image));
    changeImages(mediaItems);
  }

  addVideo(String image) async {
    final thumb = await File(image).getThumbnail;
    mediaItems.clear();

    var mediaData = MediaData(
      type: MediaTypeEnum.VIDEO,
      path: image,
      thumbnail: thumb.path,
    );
    emit(const CommonUIState.loading());
    final either = await uploadMediaUseCase(mediaData);
    either.fold(
      (l) => emit(CommonUIState.error(l.errorMessage)),
      (r) {
        mediaItems.add(mediaData.copyWith(id: r.mediaId));
        changeImages(mediaItems);
        emit(const CommonUIState.success(''));
      },
    );
  }

  removedFile(int index) async {
    var item = mediaItems[index];
    if (item.type == MediaTypeEnum.GIF || item.type == MediaTypeEnum.EMOJI) {
      mediaItems.removeAt(index);
      changeImages(mediaItems);
      return;
    }
    changeImages(mediaItems);
    mediaItems.removeAt(index);
    var either = await deleteMediaUseCase!(MediaEntity.fromMediaData(item));
    either.fold((l) {
      emit(CommonUIState.error(l.errorMessage));
      mediaItems.insert(index, item);
    }, (r) {});
  }

  Future<void> getUserData() async {
    emit(const CommonUIState.loading());
    var response = await getDrawerDataUseCase!(unit);
    response.fold((l) {
      emit(CommonUIState.error(l.errorMessage));
    }, (data) {
      emit(CommonUIState.success(data));
      changeDrawerEntity(data);
    });
  }

  Future<void> createPost({
    String? threadId,
    List<Map<String, dynamic>>? pollData,
    bool isPoll = false,
  }) async {
    changePublishButton(false);
    emit(const CommonUIState.loading());
    PostRequestModel model;

    if (!isPoll) {
      MediaData? gifData = mediaItems
          .firstWhereOrNull((element) => element.type == MediaTypeEnum.GIF);
      model = PostRequestModel(
        postText: postTextValidator.text,
        threadId: threadId,
        gifUrl: gifData?.path,
        ogData: ogDataMap,
      );
    } else {
      model = PostRequestModel(
        postText: postTextValidator.text,
        threadId: threadId,
        poll_data: pollData as List<Map<String, String>>?,
      );
    }
    print(model);

    var either = await createPostUseCase!(model);
    either.fold((l) {
      changePublishButton(true);
      emit(CommonUIState.error(l.errorMessage));
    }, (r) {
      emit(
        CommonUIState.success(
            threadId != null ? "Reply posted" : "Post published"),
      );
      clearAllPostData();
    });
  }

  clearAllPostData() {
    postTextValidator.textController.clear();
    mediaItems.clear();
    postTextValidator.onChange("");
    changeImages(mediaItems);
  }

  Future<void> ogDataPassingApi(
    Map<String, dynamic> requestBody,
  ) async {
    String uri = ApiConstants.baseUrl + ApiConstants.publishPost;

    emit(const CommonUIState.loading());

    try {
      http.Response response = await http.post(
        Uri.parse(uri),
        body: requestBody,
      );
      if (response.statusCode == 200) {
        clearAllPostData();
        emit(const CommonUIState.success('Post published'));
      } else {
        changePublishButton(true);
        emit(CommonUIState.error('Post not published'));
      }
    } catch (e) {
      print("OG data api $e");
      return null;
    }
  }
}
