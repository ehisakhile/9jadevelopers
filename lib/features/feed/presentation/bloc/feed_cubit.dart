// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: invalid_use_of_protected_member

import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:colibri/core/common/failure.dart';
import 'package:colibri/core/common/pagination/pagination_helper.dart';
import 'package:colibri/core/common/uistate/common_ui_state.dart';
import 'package:colibri/core/config/strings.dart';
import 'package:colibri/features/feed/domain/entity/post_entity.dart';
import 'package:colibri/features/feed/domain/entity/report_post_entity.dart';
import 'package:colibri/features/feed/domain/usecase/create_post_use_case.dart';
import 'package:colibri/features/feed/domain/usecase/get_drawer_data_use_case.dart';
import 'package:colibri/features/feed/domain/usecase/get_feed_posts_use_case.dart';
import 'package:colibri/features/feed/domain/usecase/like_unlike_use_case.dart';
import 'package:colibri/features/feed/domain/usecase/report_post_use_case.dart';
import 'package:colibri/features/feed/domain/usecase/repost_use_case.dart';
import 'package:colibri/features/feed/domain/usecase/upload_media_use_case.dart';
import 'package:colibri/features/feed/presentation/widgets/all_home_screens.dart';
import 'package:colibri/features/feed/presentation/widgets/feed_widgets.dart';
import 'package:colibri/features/posts/domain/usecases/add_remove_bookmark_use_case.dart';
import 'package:colibri/features/posts/domain/usecases/delete_media_use_case.dart';
import 'package:colibri/features/posts/domain/usecases/delete_post_use_case.dart';
import 'package:colibri/features/posts/domain/usecases/log_out_use_case.dart';
import 'package:colibri/features/posts/presentation/bloc/like_unlike_mixin.dart';
import 'package:colibri/features/profile/domain/entity/profile_entity.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:colibri/extensions.dart';

part 'feed_state.dart';

@injectable
class FeedCubit extends PostPaginatonCubit<PostEntity, CommonUIState>
    with PostInteractionMixin {
  final currentPageController =
      BehaviorSubject<ScreenType>.seeded(const ScreenType.home());
  Function(ScreenType) get changeCurrentPage => currentPageController.sink.add;
  Stream<ScreenType> get currentPage => currentPageController.stream;

  final videoPlayState = BehaviorSubject<bool>.seeded(false);
  Function(bool) get changeVideoPlayState => videoPlayState.sink.add;
  Stream<bool> get isVideoPlaying => videoPlayState.stream;

  final _feedListController = BehaviorSubject<List<PostEntity>>();

  Function(List<PostEntity>) get changeFeedsList =>
      _feedListController.sink.add;

  Stream<List<PostEntity>> get feedsList => _feedListController.stream;

  final _drawerEntityController = BehaviorSubject<ProfileEntity>();

  Function(ProfileEntity) get changeDrawerEntity =>
      _drawerEntityController.sink.add;

  Stream<ProfileEntity> get drawerEntity => _drawerEntityController.stream;

  // Stream<bool> get enablePublishButton=>

  // use cases
  final GetFeedPostUseCase? getFeedPostUseCase;

  final GetDrawerDataUseCase? getDrawerUseCase;

  final UploadMediaUseCase? uploadMediaUseCase;

  final DeleteMediaUseCase? deleteMediaUseCase;

  final CreatePostUseCase? createPostUseCase;

  final LikeUnlikeUseCase? likeUnlikeUseCase;

  final RepostUseCase? repostUseCase;

  final AddOrRemoveBookmarkUseCase? addOrRemoveUseCase;

  final DeletePostUseCase? deletePostUseCase;

  final ReportPostUseCase? reportPostUseCase;

  final LogOutUseCase? logOutUseCase;

  FeedCubit(
    this.getFeedPostUseCase,
    this.getDrawerUseCase,
    this.uploadMediaUseCase,
    this.createPostUseCase,
    this.likeUnlikeUseCase,
    this.deleteMediaUseCase,
    this.repostUseCase,
    this.addOrRemoveUseCase,
    this.deletePostUseCase,
    this.logOutUseCase,
    this.reportPostUseCase,
  ) : super(const CommonUIState.initial());

  @override
  Future<Either<Failure, List<PostEntity>>?> getItems(int pageKey) async {
    return await getFeedPostUseCase!(pageKey.toString());
  }

  @override
  int getNextKey(PostEntity item) {
    return item.offSetId ?? 0;
  }

  @override
  bool isLastPage(List<PostEntity> item) {
    // check if response has an advertisement object
    // if yes then item length will always be [ApiConstants.pageSize+1]
    return item.isLastPage;
  }

  @override
  PostEntity getLastItemWithoutAd(List<PostEntity> item) {
    // if there is an ad object as last we will give
    // second last item for calculating offset value
    return item.getItemWithoutAd;
  }

  @override
  Future likeUnlikePost(int index) async {
    PostEntity item = pagingController.itemList![index];
    pagingController.itemList![index] = item.copyWith(
        isLiked: !item.isLiked!,
        likeCount: (item.isLiked! ? item.likeCount!.dec : item.likeCount!.inc)
            .toString());
    pagingController.notifyListeners();
    var either = await likeUnlikeUseCase!(item.postId);
    either.fold((l) {
      PostEntity oldItem = pagingController.itemList![index];
      pagingController.itemList![index] = oldItem.copyWith(
          isLiked: !oldItem.isLiked!,
          likeCount: (oldItem.isLiked!
                  ? oldItem.likeCount!.dec
                  : oldItem.likeCount!.inc)
              .toString());
      pagingController.notifyListeners();
      emit(CommonUIState.error(l.errorMessage));
      emit(const CommonUIState.initial());
    }, (r) {});
  }

  @override
  Future<void> deletePost(int index) async {
    var either = await deletePostUseCase!(
        pagingController.itemList![index].postId.toString());
    either.fold((l) {
      emit(const CommonUIState.initial());
      emit(CommonUIState.error(l.errorMessage));
    }, (r) {
      emit(const CommonUIState.initial());
      emit(const CommonUIState.success("Deleted Successfully"));
      pagingController.itemList!.removeAt(index);
      pagingController.notifyListeners();
    });
  }

  @override
  Future<void> repost(int index) async {
    final PostEntity item = pagingController.itemList![index];
    final List<PostEntity> allItems = pagingController.itemList!
        .where((element) => element.postId == item.postId)
        .toList();

    /// case of removing reposted item
    /// if items is already reposteed
    if (item.showRepostedText == true && item.isReposted!) {
      /// if the reposted items is not owned by the other person
      /// current user is reposted this particular item
      /// or owner of the post is not the logged in current user but current user reposted the post
      if (!item.isOtherUser || item.isReposted!) {
        /// Firstly removed the item from the list
        ///
        /// find the reposted post item with having name of current user in reposted text
        final PostEntity? firstWhere = pagingController.itemList!.firstWhere(
            (element) => element.postId == item.postId,
            orElse: null);
        if (firstWhere != null) {
          /// remove post item
          final removedIndex = pagingController.itemList!.indexOf(firstWhere);
          pagingController
            ..itemList!.removeAt(removedIndex)
            ..notifyListeners();

          /// also removed from global list
          allItems.removeAt(removedIndex);

          /// updated all items with new values
          allItems.asMap().forEach((index, value) {
            pagingController.itemList![index] = value.copyWith(
                isReposted: false, repostCount: value.repostCount!.dec);
          });
        } else {
          pagingController
            ..itemList!.removeAt(index)
            ..notifyListeners();

          /// get all items of that particular item (we have more more than one post of same id) so that we can update reposted count on each post

          /// assigning & updated resposted count and isResposted to false
          allItems.asMap().forEach((index, value) {
            pagingController
              ..itemList![index] = value.copyWith(
                  repostCount: value.repostCount!.dec.toString(),
                  isReposted: false)
              ..notifyListeners();
          });
        }
      }

      /// owner of post is other user
      /// we don't remove the post from current index
      /// and add the same post as reposted post on the top of the list
      else {
        final PostEntity? firstWhere = pagingController.itemList!.firstWhere(
            (element) => element.postId == item.postId,
            orElse: null);
        if (firstWhere != null) {
          increaseRepostCount(allItems);
          // var index=pagingController.itemList.indexOf(firstWhere);
          /// at last we're adding reposted post on the top of the list
          pagingController
            ..itemList!.insert(
                0,
                firstWhere.copyWith(
                    isReposted: true,
                    repostCount: item.repostCount!.inc.toString(),
                    showRepostedText: true,
                    reposterFullname: "You",
                    isOtherUser: false))
            ..notifyListeners();
        } else {
          /// getting all post items with reposted or without reposted
          /// so that we can increase the repost count on each item
          List<PostEntity> list = pagingController.itemList!
              .where((element) => element.postId == item.postId)
              .toList();

          /// all items with same post ids
          list.asMap().forEach((index, value) {
            /// updating the items with incremented reposted value
            pagingController.itemList![index] = item.copyWith(
                repostCount: item.repostCount!.inc.toString(),
                isReposted: true,
                reposterFullname:
                    pagingController.itemList![index].reposterFullname,
                showRepostedText:
                    pagingController.itemList![index].showRepostedText);
          });
        }
      }
    } else {
      // pagingController
      //   ..itemList[index] = item.copyWith(
      //       isReposted: true, repostCount: item.repostCount.inc.toString());
      if (!item.isOtherUser && item.isReposted!) {
        /// Firstly removed the item from the list
        ///
        /// find the reposted post item with having name of current user in reposted text
        final PostEntity? firstWhere = pagingController.itemList!.firstWhere(
            (element) => element.postId == item.postId,
            orElse: null);
        if (firstWhere != null) {
          /// remove post item
          final removedIndex = pagingController.itemList!.indexOf(firstWhere);
          pagingController
            ..itemList!.removeAt(removedIndex)
            ..notifyListeners();

          /// also removed from global list
          allItems.removeAt(removedIndex);

          /// updated all items with new values
          allItems.asMap().forEach((index, value) {
            pagingController.itemList![index] = value.copyWith(
                isReposted: false, repostCount: value.repostCount!.dec);
          });
        } else {
          pagingController
            ..itemList!.removeAt(index)
            ..notifyListeners();

          /// get all items of that particular item (we have more more than one post of same id) so that we can update reposted count on each post

          /// assigning & updated resposted count and isResposted to false
          allItems.asMap().forEach((index, value) {
            pagingController
              ..itemList![index] = value.copyWith(
                  repostCount: value.repostCount!.dec.toString(),
                  isReposted: false)
              ..notifyListeners();
          });
        }
        // if(firstWhere!=null){
        //   var index=pagingController.itemList.indexOf(firstWhere);
        //   pagingController.itemList[index]=firstWhere.copyWith(isReposted: !item.isReposted,
        //       repostCount: item.repostCount.dec.toString());
        // }
      } else {
        allItems.asMap().forEach((index, value) {
          pagingController
            ..itemList![index] = value.copyWith(
                repostCount: value.repostCount!.inc.toString(),
                isReposted: true)
            ..notifyListeners();
        });
        pagingController
          ..itemList!.insert(
              0,
              item.copyWith(
                  showRepostedText: true,
                  reposterFullname: "You",
                  isOtherUser: false,
                  repostCount: item.repostCount!.inc.toString(),
                  isReposted: true))
          ..notifyListeners();
      }
    }
    pagingController.notifyListeners();
    await repostUseCase!(item.postId);
  }

  @override
  Future<void> close() {
    currentPageController.close();
    _feedListController.close();
    _drawerEntityController.close();
    return super.close();
  }

  Future<void> getUserData() async {
    var response = await getDrawerUseCase!(unit);
    response.fold((l) => left(l), (data) => changeDrawerEntity(data));
  }

  @override
  Future<void> addOrRemoveBookmark(int index) async {
    PostEntity item = pagingController.itemList![index];
    pagingController.itemList![index] = item.copyWith(
      isSaved: !item.isSaved!,
    );
    pagingController.notifyListeners();
    var either = await addOrRemoveUseCase!(item.postId);
    either.fold((l) {
      PostEntity oldItem = pagingController.itemList![index];
      pagingController.itemList![index] = oldItem.copyWith(
        isSaved: !oldItem.isSaved!,
      );
      pagingController.notifyListeners();
      emit(CommonUIState.error(l.errorMessage));
      emit(const CommonUIState.initial());
    }, (r) {
      var message = pagingController.itemList![index].isSaved!
          ? Strings.bookmarkAdded
          : Strings.removeBookmark;
      emit(CommonUIState.success(message));
      emit(const CommonUIState.initial());
    });
  }

  @override
  Future onOptionItemSelected(
      BuildContext context, PostOptionsEnum postOptionsEnum, int index) async {
    switch (postOptionsEnum) {
      case PostOptionsEnum.REPORT:
        break;
      case PostOptionsEnum.SHOW_LIKES:
        break;
      case PostOptionsEnum.BOOKMARK:
        await addOrRemoveBookmark(index);
        break;
      case PostOptionsEnum.DELETE:
        context.router.root.pop();
        await deletePost(index);
        break;
      case PostOptionsEnum.BLOCK:
        break;
    }
  }

  saveNotificationToken() async {
    // await saveNotificationPushUseCase(unit);
  }

  Future<void> reportPost(ReportPostEntity model) async {
    emit(const CommonUIState.loading());
    final either = await reportPostUseCase!(model);
    either.fold(
      (l) => emit(CommonUIState.error(l.errorMessage)),
      (r) {
        final Response response = r;
        if (response.statusCode == 200)
          emit(CommonUIState.success('Report Sent Successfuly'));
        else
          CommonUIState.error('Report Not Sent Please Try Again Later');
      },
    );
  }

  void logout() async {
    emit(const CommonUIState.loading());
    final either = await logOutUseCase!(unit);
    either.fold(
      (l) => emit(CommonUIState.error(l.errorMessage)),
      (r) => emit(const CommonUIState.success(FEED_SUCCESS.LOGOUT_SUCCESSFULL)),
    );
  }

  void increaseRepostCount(List<PostEntity> allItems) {
    allItems.asMap().forEach((index, value) {
      pagingController
        ..itemList![index] = value.copyWith(
            repostCount: value.repostCount!.inc.toString(), isReposted: true);
    });
  }

  void changeVideoState(bool state) {
    if (state != isVideoPlaying) changeVideoPlayState(state);
  }
}

enum FEED_SUCCESS { LOGOUT_SUCCESSFULL }
