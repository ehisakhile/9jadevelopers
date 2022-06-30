import 'package:auto_route/src/router/auto_router_x.dart';
import 'package:colibri/core/config/colors.dart';
import '../../../../core/routes/routes.gr.dart';

import '../../../../core/common/widget/common_divider.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../feed/presentation/widgets/no_data_found_screen.dart';
import '../bloc/post_cubit.dart';
import '../../../search/domain/entity/people_entity.dart';
import '../../../search/presentation/widgets/people_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../../../../extensions.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class ShowLikeScreen extends HookWidget {
  final String postId;

  const ShowLikeScreen(this.postId);
  @override
  Widget build(BuildContext context) {
    final controller =
        useAnimationController(duration: const Duration(milliseconds: 1000))
          ..forward();
    final postCubit = useMemoized<PostCubit?>(
        () => getIt<PostCubit>()..showLikesPagination!.setPostID(postId))!;
    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder<int>(
          initialData: 0,
          stream: postCubit.showLikesPagination!.itemLength,
          builder: (context, snapshot) =>
              "People who liked (${snapshot.data})".toSubTitle1(
            (url) => context.router.root.push(WebViewScreenRoute(url: url)),
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: PagedListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 10),
        pagingController: postCubit.showLikesPagination!.pagingControllerMixin,
        builderDelegate: PagedChildBuilderDelegate<PeopleEntity>(
            noItemsFoundIndicatorBuilder: (_) => NoDataFoundScreen(
                  title: 'No likes yet!',
                  buttonVisibility: false,
                  message:
                      'This post appears to have no likes yet. To like this post, click on like button.',
                  icon: AppIcons.likeOption(
                      color: AppColors.colorPrimary, size: 40),
                  onTapButton: () {
                    // ExtendedNavigator.root.push(Routes.createPost);
                  },
                ),
            itemBuilder: (BuildContext context, item, int index) => PeopleItem(
                  peopleEntity: item,
                  onFollowTap: () {
                    postCubit.showLikesPagination!.followUnFollow(index);
                  },
                ).toSlideAnimation(controller)),
        separatorBuilder: (BuildContext context, int index) => commonDivider,
      ),
    );
  }
}
