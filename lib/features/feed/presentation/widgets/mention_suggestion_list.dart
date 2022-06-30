import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/common/widget/common_divider.dart';
import '../../../../core/constants/appconstants.dart';
import '../../../../extensions.dart';
import '../../../posts/presentation/bloc/createpost_cubit.dart';
import '../../../search/domain/entity/people_entity.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class MentionSuggestionList extends StatefulWidget {
  const MentionSuggestionList({
    Key? key,
    required this.createPostCubit,
    required this.isComment,
    this.height,
    this.width,
  }) : super(key: key);
  final CreatePostCubit? createPostCubit;
  final bool isComment;
  final double? height;
  final double? width;
  @override
  State<MentionSuggestionList> createState() => _MentionSuggestionListState();
}

class _MentionSuggestionListState extends State<MentionSuggestionList> {
  List<String> words = [];
  String str = '';
  bool detected = false;
  int startIndexOfTag = 0;
  int endIndexOfTag = 0;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: widget.createPostCubit!.postTextValidator.stream,
      initialData: 0,
      builder: (context, snapshot) {
        if (widget.createPostCubit!.postTextValidator.textController.text
            .trim()
            .isEmpty) {
          startIndexOfTag = 0;
        }

        String inputData =
            widget.createPostCubit!.postTextValidator.textController.text;

        String lastLatter = "";

        bool isTagShow = false;
        int lastIndexInt = -1;
        if (inputData.length != 0) {
          lastIndexInt = inputData.length - 1;

          lastLatter = inputData.split("@").last;
          AC.searchCubitA!.peoplePagination!.queryText = lastLatter;
          if (inputData.length != 0) {
            if (inputData[lastIndexInt] == "@") {
              doSearch("@", lastLatter);
              print("2");
            }
            RegExp alphanumeric = RegExp(r'^[a-zA-Z0-9]+$');

            if (alphanumeric.hasMatch(inputData[lastIndexInt]))
              isTagShow = true;
          }
        }
        words = inputData.split(' ');
        str = words.length > 0 && words[words.length - 1].startsWith('@')
            ? words[words.length - 1]
            : '';
        if (str.isEmpty) {
          words = inputData.split("\n");
          List<String> splitedString = words[words.length - 1].split(' ');

          str = words.length > 0 &&
                  splitedString[splitedString.length - 1].startsWith('@')
              ? splitedString[splitedString.length - 1]
              : '';
        }

        if (inputData.endsWith('@')) {
          detected = true;
          startIndexOfTag = inputData.length - 1;
        }

        if ((detected == true && inputData.endsWith(' ')) ||
            startIndexOfTag == 1) {
          detected = false;
          endIndexOfTag = inputData.length;
        }

        if (inputData.length < endIndexOfTag) {
          detected = true;
          isTagShow = true;
          endIndexOfTag = inputData.length;
          startIndexOfTag = inputData.indexOf('@');
        }

        return str.length > 1 && isTagShow
            ? Container(
                height: widget.height ?? 200,
                width: widget.width ?? 200,
                margin:
                    widget.isComment ? null : const EdgeInsets.only(top: 85),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      blurRadius: 5,
                      spreadRadius: 0.1,
                    )
                  ],
                ),
                alignment: Alignment.center,
                child: PagedListView.separated(
                    key: const PageStorageKey("People"),
                    pagingController:
                        AC.searchCubitA!.peoplePagination!.pagingController,
                    padding: const EdgeInsets.only(top: 10),
                    builderDelegate: PagedChildBuilderDelegate<PeopleEntity>(
                      itemBuilder: (c, item, index) {
                        return getPeopleItem1(
                          item,
                          (s) {
                            FocusScope.of(context).requestFocus(widget
                                .createPostCubit!.postTextValidator.focusNode);

                            String replacedString = inputData.replaceRange(
                                startIndexOfTag, inputData.length, "@$s ");

                            widget.createPostCubit!.postTextValidator
                                .textController.text = replacedString;

                            widget
                                .createPostCubit!
                                .postTextValidator
                                .textController
                                .selection = TextSelection.fromPosition(
                              TextPosition(
                                offset: widget
                                    .createPostCubit!
                                    .postTextValidator
                                    .textController
                                    .text
                                    .length,
                              ),
                            );

                            isTagShow = false;
                            setState(() {});
                          },
                        );
                      },
                    ),
                    separatorBuilder: (BuildContext context, int index) =>
                        commonDivider),
              )
            : Container();
      },
    );
  }

  void doSearch(String tag, String lastLatter) {
    if (tag == "#") {
      AC.searchCubitHash!.hashTagPagination!.changeSearch(lastLatter);
    } else if (tag == "@") {
      AC.searchCubitA!.peoplePagination!.changeSearch(lastLatter);
    }
  }

  Widget getPeopleItem1(PeopleEntity entity, StringToVoidFunc onTap) {
    return Row(
      children: [
        10.toSizedBox,
        SizedBox(
          height: 30,
          width: 30,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: CachedNetworkImage(
              placeholder: (c, i) => const CircularProgressIndicator(),
              imageUrl: entity.profileUrl!,
            ),
          ),
        ),
        10.toSizedBox,
        Flexible(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              child: entity.fullName!
                  .toSubTitle2(
                      fontWeight: FontWeight.w400,
                      fontFamily1: "CeraPro",
                      fontSize: 16,
                      maxLines: 1)
                  .onTapWidget(() {
                onTap.call(entity.userName);
              }),
            ),
            Container(
              child: entity.userName!
                  .toSubTitle2(
                      fontWeight: FontWeight.w400,
                      fontFamily1: "CeraPro",
                      fontSize: 13,
                      maxLines: 1)
                  .onTapWidget(() {
                onTap.call(entity.userName);
              }),
            ),
          ],
        ))
      ],
    );
  }
}
