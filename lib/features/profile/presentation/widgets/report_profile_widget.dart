import '../../../../translations/locale_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class ReportProfileWidget extends StatefulWidget {
  const ReportProfileWidget(this.userId, {Key? key}) : super(key: key);
  final String userId;
  @override
  _ReportProfileWidgetState createState() => _ReportProfileWidgetState();
}

class _ReportProfileWidgetState extends State<ReportProfileWidget> {
  final Map<int, String> reportMap = {
    1: LocaleKeys.this_user_using_this_account_for_smap.tr(),
    2: LocaleKeys.this_user_pretended_to_be_someone.tr(),
    3: LocaleKeys.this_user_posting_inappropriate_content.tr(),
    4: LocaleKeys.this_is_a_fake_account.tr(),
    5: LocaleKeys.this_is_a_fraudulent_account.tr(),
    6: 'Other',
  };
  int? currentIndex = 1;
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
    return Container();
    // return Scaffold(
    //   body: BlocProvider(
    //     create: (context) => getIt<ProfileCubit>(),
    //     child: Builder(builder: (context) {
    //       return BlocConsumer<ProfileCubit, CommonUIState>(
    //         listener: (context, state) => state.maybeWhen(
    //           orElse: () => null,
    //           error: (s) => context.showSnackBar(message: s.toString()),
    //           success: (s) {
    //             Navigator.of(context).pop();
    //             context.showSnackBar(message: s.toString());
    //             return null;
    //           },
    //         ),
    //         builder: (context, state) => state.maybeWhen(
    //           orElse: () => SingleChildScrollView(
    //             child: Container(
    //               padding: EdgeInsets.only(
    //                 bottom: MediaQuery.of(context).viewInsets.bottom,
    //               ),
    //               child: [
    //                 ListTile(
    //                   leading: const BackButton(),
    //                   title: Padding(
    //                     padding: const EdgeInsets.all(8.0),
    //                     child: Text(
    //                       'Report Profile',
    //                       style: TextStyle(fontWeight: FontWeight.w500),
    //                     ),
    //                   ),
    //                   tileColor: AppColors.sfBgColor,
    //                 ),
    //                 14.toSizedBox,
    //                 SmartSelect<String?>.single(
    //                   modalFilter: true,
    //                   modalFilterBuilder: (ctx, cont) => TextField(
    //                     decoration: InputDecoration(
    //                       hintStyle: context.subTitle1
    //                           .copyWith(fontWeight: FontWeight.w500),
    //                       hintText: "Search Report Reason",
    //                       border: InputBorder.none,
    //                     ),
    //                   ),
    //                   choiceStyle: S2ChoiceStyle(
    //                     titleStyle: context.subTitle2.copyWith(
    //                       fontWeight: FontWeight.w500,
    //                     ),
    //                   ),
    //                   // title
    //                   modalConfig: S2ModalConfig(
    //                     title: LocaleKeys.report_post.tr(),
    //                     headerStyle: S2ModalHeaderStyle(
    //                       textStyle: context.subTitle1.copyWith(
    //                         fontWeight: FontWeight.w500,
    //                       ),
    //                     ),
    //                   ),
    //                   modalType: S2ModalType.fullPage,
    //                   selectedValue: reportMap[currentIndex!],
    //                   onChange: (s) {
    //                     setState(() {
    //                       currentIndex = int.tryParse(s.value!);
    //                     });
    //                   },

    //                   // Tile before choice
    //                   tileBuilder: (c, s) => ListTile(
    //                     trailing: const Icon(
    //                       Icons.arrow_forward_ios_outlined,
    //                       size: 14,
    //                     ),
    //                     onTap: () => s.showModal(),
    //                     title: 'Report Reason'
    //                         .toSubTitle2(fontWeight: FontWeight.w500),
    //                     subtitle: reportMap[currentIndex!]!
    //                         .toCaption(fontWeight: FontWeight.w500),
    //                   ),
    //                   choiceItems: reportMap.entries
    //                       .map(
    //                         (e) => S2Choice(
    //                           value: e.key.toString(),
    //                           title: e.value,
    //                         ),
    //                       )
    //                       .toList(),
    //                 ),
    //                 14.toSizedBox,
    //                 Padding(
    //                   padding: const EdgeInsets.all(8.0),
    //                   child: TextField(
    //                     controller: _controller,
    //                     maxLength: 300,
    //                     decoration: InputDecoration(
    //                       contentPadding: EdgeInsets.symmetric(
    //                         vertical: 12.toVertical as double,
    //                         horizontal: 6.toHorizontal as double,
    //                       ),
    //                       focusedErrorBorder: OutlineInputBorder(
    //                         borderSide: BorderSide(
    //                           width: 1,
    //                           color: Colors.red.withOpacity(.8),
    //                         ),
    //                       ),
    //                       errorBorder: OutlineInputBorder(
    //                         borderSide: BorderSide(
    //                           width: .8,
    //                           color: Colors.red.withOpacity(.8),
    //                         ),
    //                       ),
    //                       enabledBorder: const OutlineInputBorder(
    //                         borderSide: BorderSide(
    //                           width: 1,
    //                           color: AppColors.placeHolderColor,
    //                         ),
    //                       ),
    //                       focusedBorder: const OutlineInputBorder(
    //                         borderSide: BorderSide(
    //                           width: 1,
    //                           color: AppColors.colorPrimary,
    //                         ),
    //                       ),
    //                       border: const OutlineInputBorder(),
    //                       labelText: 'Comment',
    //                       labelStyle: AppTheme.caption.copyWith(
    //                           fontWeight: FontWeight.w500,
    //                           color: AppColors.placeHolderColor),
    //                       errorStyle: AppTheme.caption.copyWith(
    //                         color: Colors.red,
    //                         fontWeight: FontWeight.w500,
    //                       ),
    //                     ),
    //                   ),
    //                 ),
    //                 state.maybeWhen(
    //                   orElse: () => CustomButton(
    //                     text: 'Report Profile',
    //                     onTap: () async {
    //                       // send api requestt with report int and comment
    //                       print(
    //                           'Send Api Request with  , and ${_controller!.text}');

    //                       await BlocProvider.of<ProfileCubit>(context)
    //                           .reportProfile(
    //                         ReportProfileEntity(
    //                           userId: widget.userId,
    //                           reason: currentIndex,
    //                           comment: _controller!.text,
    //                         ),
    //                       );
    //                     },
    //                     color: AppColors.colorPrimary,
    //                   ).toPadding(16),
    //                   loading: () => LoadingBar(),
    //                 ),
    //               ].toColumn(
    //                 mainAxisSize: MainAxisSize.min,
    //               ),
    //             ),
    //           ),
    //         ),
    //       );
    //     }),
    //   ),
    // );
  }
}
