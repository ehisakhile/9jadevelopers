import 'package:colibri/core/config/colors.dart';

import '../../../../core/common/widget/common_divider.dart';
import '../../../../core/constants/appconstants.dart';
import '../../../../extensions.dart';
import '../../../posts/presentation/bloc/createpost_cubit.dart';
import '../../../search/domain/entity/hashtag_entity.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class HashTagSuggestionList extends StatefulWidget {
  const HashTagSuggestionList({
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
  State<HashTagSuggestionList> createState() => _HashTagSuggestionListState();
}

class _HashTagSuggestionListState extends State<HashTagSuggestionList> {
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
      builder: (context, esnapshot) {
        if (widget.createPostCubit!.postTextValidator.textController.text
            .trim()
            .isEmpty) {}
        String inputData =
            widget.createPostCubit!.postTextValidator.textController.text;
        String lastLatter = "";

        print("in the #");

        bool isTagShow = false;
        int lastIndexInt = -1;
        if (inputData.length != 0) {
          lastIndexInt = inputData.length - 1;
          lastLatter = inputData.split("#").last;
          AC.searchCubitHash!.hashTagPagination!.queryText = lastLatter;
          if (inputData.length != 0) {
            if (inputData[lastIndexInt] == "#") {
              doSearch("#", lastLatter);
              print("2");
            }
            RegExp alphanumeric = RegExp(r'^[a-zA-Z0-9]+$');

            if (alphanumeric.hasMatch(inputData[lastIndexInt])) {
              print("1");
              isTagShow = true;
            }
          }
        }

        words = inputData.split(' ');
        str = words.length > 0 && words[words.length - 1].startsWith('#')
            ? words[words.length - 1]
            : '';
        if (str.isEmpty) {
          words = inputData.split("\n");
          List<String> splitedString = words[words.length - 1].split(' ');

          str = words.length > 0 &&
                  splitedString[splitedString.length - 1].startsWith('#')
              ? splitedString[splitedString.length - 1]
              : '';
        }

        if (inputData.endsWith('#')) {
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
          startIndexOfTag = inputData.indexOf('#');
        }
        print(startIndexOfTag);
        return str.length > 1 && isTagShow
            ? Container(
                height: widget.height ?? 200,
                width: widget.width ?? 200,
                margin: widget.isComment ? null : EdgeInsets.only(top: 85),
                decoration: BoxDecoration(color: Colors.white, boxShadow: [
                  BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      blurRadius: 5,
                      spreadRadius: 0.1)
                ]),
                alignment: Alignment.center,
                child: PagedListView.separated(
                  pagingController:
                      AC.searchCubitHash!.hashTagPagination!.pagingController,
                  builderDelegate: PagedChildBuilderDelegate<HashTagEntity>(
                    itemBuilder: (c, item, index) {
                      print(item);
                      return Padding(
                        padding: EdgeInsets.only(top: index == 0 ? 7 : 0),
                        child: getHastTagItem1(
                          item,
                          (s) {
                            FocusScope.of(context).requestFocus(widget
                                .createPostCubit!.postTextValidator.focusNode);

                            widget.createPostCubit!.postTextValidator
                                    .textController.text =
                                inputData.replaceRange(
                                    startIndexOfTag, inputData.length, "$s ");

                            // makes cursor at the last word
                            widget.createPostCubit!.postTextValidator
                                    .textController.selection =
                                TextSelection.fromPosition(TextPosition(
                                    offset: widget
                                        .createPostCubit!
                                        .postTextValidator
                                        .textController
                                        .text
                                        .length));

                            isTagShow = false;
                            setState(() {});
                          },
                        ),
                      );
                    },
                  ),
                  separatorBuilder: (BuildContext context, int index) =>
                      commonDivider,
                ),
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

  Widget getHastTagItem1(HashTagEntity entity, StringToVoidFunc onTap) {
    return Row(
      children: [
        10.toSizedBox,
        Icon(
          FontAwesomeIcons.hashtag,
          color: AppColors.colorPrimary,
          size: 15,
        )
            .toPadding(12)
            .toContainer(
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.colorPrimary,
                  width: .3,
                ),
              ),
            )
            .toCenter(),
        Container(
          height: 30,
          padding: EdgeInsets.only(left: 7, top: 7, right: 7),
          alignment: Alignment.centerLeft,
          color: Colors.white,
          child: entity.name!
              .toSubTitle2(fontWeight: FontWeight.w500)
              .onTapWidget(() {
            onTap.call(entity.name);
          }),
        )
      ],
    );
  }
}
