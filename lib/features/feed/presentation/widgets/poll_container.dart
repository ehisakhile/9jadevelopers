import '../../../../core/common/uistate/common_ui_state.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/loading_bar.dart';
import '../../data/models/feeds_response.dart';
import '../../domain/entity/post_entity.dart';
import 'poll_item.dart';
import '../../../posts/domain/usecases/vote_poll_use_case.dart';
import '../../../posts/presentation/bloc/post_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PollContainer extends StatefulWidget {
  PollContainer(this.postEntity, {Key? key}) : super(key: key);
  final PostEntity postEntity;

  @override
  State<PollContainer> createState() => _PollContainerState();
}

class _PollContainerState extends State<PollContainer> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<PostCubit>(),
      child: BlocBuilder<PostCubit, CommonUIState>(
        builder: (context, state) {
          return state.maybeWhen(
            orElse: () {
              final postCubit = BlocProvider.of<PostCubit>(context);
              return SizedBox(
                height: widget.postEntity.poll != null
                    ? _mapLengthToHeight()
                    : null,
                width: double.infinity,
                child: widget.postEntity.poll != null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: _mapPollOptionsToList(
                          postCubit: postCubit,
                          success: false,
                        ),
                      )
                    : Container(),
              );
            },
            success: (poll) {
              print(poll);
              return SizedBox(
                height: _mapLengthToHeight(),
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: _mapPollOptionsToList(success: true, poll: poll),
                ),
              );
            },
            loading: () => Padding(
              padding: const EdgeInsets.all(8.0),
              child: LoadingBar(),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _mapPollOptionsToList({
    PostCubit? postCubit,
    required bool? success,
    Poll? poll,
  }) {
    List<Widget> _widgetList = [];
    List<Option> _options =
        success! ? poll!.options! : widget.postEntity.poll!.options!;
    for (int i = 0; i < _options.length; i++) {
      _widgetList.add(
        GestureDetector(
          onTap: () async {
            if (widget.postEntity.poll!.hasVoted == 0 && !success) {
              await postCubit!.votePoll(
                PollParam(
                  pollId: i,
                  postId: int.parse(widget.postEntity.postId),
                ),
              );
            }
          },
          child: PollItem(
            text: success
                ? poll!.options![i].option
                : widget.postEntity.poll!.options![i].option,
            percentage: success
                ? poll!.options![i].percentage
                : widget.postEntity.poll!.hasVoted == 0
                    ? null
                    : (widget.postEntity.poll!.options![i].percentage),
          ),
        ),
      );
    }
    return _widgetList;
  }

  double _mapLengthToHeight() {
    switch (widget.postEntity.poll!.options!.length) {
      case 2:
        return 100;

      case 3:
        return 150;
      case 4:
        return 180;
      default:
        return 180;
    }
  }
}
