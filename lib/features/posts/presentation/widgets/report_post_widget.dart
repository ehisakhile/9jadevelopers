import 'package:colibri/core/config/colors.dart';
import 'package:colibri/extensions.dart';
import 'package:flutter_awesome_select/flutter_awesome_select.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/common/buttons/custom_button.dart';
import '../../../../core/common/uistate/common_ui_state.dart';
import '../../../../core/theme/app_theme.dart';

import '../../../../core/widgets/loading_bar.dart';
import '../../../../translations/locale_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../feed/domain/entity/report_post_entity.dart';
import '../../../feed/presentation/bloc/feed_cubit.dart';

class ReportPostWidget extends StatefulWidget {
  const ReportPostWidget(this.postId, {Key? key}) : super(key: key);
  final String postId;

  @override
  _ReportPostWidgetState createState() => _ReportPostWidgetState();
}

class _ReportPostWidgetState extends State<ReportPostWidget> {
  final Map<int, String> reportMap = {
    1: LocaleKeys.this_is_spam.tr(),
    2: LocaleKeys.misleading_or_fraudulent.tr(),
    3: LocaleKeys.publication_of_private_information.tr(),
    4: LocaleKeys.threats_of_violence_or_physical_harm.tr(),
    5: LocaleKeys.i_am_not_interested_in_this_post.tr(),
    6: 'Other',
  };

  int currentIndex = 1;
  TextEditingController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(builder: (context) {
        return BlocConsumer<FeedCubit, CommonUIState>(
          listener: (context, state) => state.maybeWhen(
            orElse: () => null,
            error: (s) => context.showSnackBar(message: s.toString()),
            success: (s) {
              Navigator.pop(context);
              context.showSnackBar(message: s.toString());
              return null;
            },
          ),
          builder: (context, state) => state.maybeWhen(
            orElse: () => SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: [
                  ListTile(
                    leading: const BackButton(),
                    title: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Report Post',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    tileColor: AppColors.sfBgColor,
                  ),
                  14.toSizedBox,
                  SmartSelect<String?>.single(
                    modalFilter: true,
                    modalFilterBuilder: (ctx, cont) => TextField(
                      decoration: InputDecoration(
                        hintStyle: context.subTitle1
                            .copyWith(fontWeight: FontWeight.w500),
                        hintText: "Search Report Reason",
                        border: InputBorder.none,
                      ),
                    ),
                    choiceStyle: S2ChoiceStyle(
                      titleStyle: context.subTitle2.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    // title
                    modalConfig: S2ModalConfig(
                      title: LocaleKeys.report_post.tr(),
                      headerStyle: S2ModalHeaderStyle(
                        textStyle: context.subTitle1.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    modalType: S2ModalType.fullPage,
                    selectedValue: reportMap[currentIndex],
                    onChange: (s) {
                      setState(() {
                        currentIndex = int.parse(s.value!);
                      });
                    },

                    // Tile before choice
                    tileBuilder: (c, s) => ListTile(
                      trailing: const Icon(
                        Icons.arrow_forward_ios_outlined,
                        size: 14,
                      ),
                      onTap: () => s.showModal(),
                      title: 'Report Reason'
                          .toSubTitle2(fontWeight: FontWeight.w500),
                      subtitle: reportMap[currentIndex]!
                          .toCaption(fontWeight: FontWeight.w500),
                    ),
                    choiceItems: reportMap.entries
                        .map(
                          (e) => S2Choice(
                            value: e.key.toString(),
                            title: e.value,
                          ),
                        )
                        .toList(),
                  ),
                  14.toSizedBox,
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _controller,
                      maxLength: 300,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 12.toVertical as double,
                          horizontal: 6.toHorizontal as double,
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            width: 1,
                            color: Colors.red.withOpacity(.8),
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            width: .8,
                            color: Colors.red.withOpacity(.8),
                          ),
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                            width: 1,
                            color: AppColors.placeHolderColor,
                          ),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                            width: 1,
                            color: AppColors.colorPrimary,
                          ),
                        ),
                        border: const OutlineInputBorder(),
                        labelText: 'Comment',
                        labelStyle: AppTheme.caption.copyWith(
                            fontWeight: FontWeight.w500,
                            color: AppColors.placeHolderColor),
                        errorStyle: AppTheme.caption.copyWith(
                          color: Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  state.maybeWhen(
                    orElse: () => CustomButton(
                      text: 'Report Post',
                      onTap: () async {
                        print(
                            'Send Api Request with  , and ${_controller!.text}');

                        await BlocProvider.of<FeedCubit>(context).reportPost(
                          ReportPostEntity(
                            postId: widget.postId,
                            reason: currentIndex,
                            comment: _controller!.text,
                          ),
                        );
                      },
                      color: AppColors.colorPrimary,
                    ).toPadding(16),
                    loading: () => LoadingBar(),
                  ),
                ].toColumn(
                  mainAxisSize: MainAxisSize.min,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
