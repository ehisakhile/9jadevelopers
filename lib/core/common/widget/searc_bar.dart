import 'package:colibri/core/config/colors.dart';

import '../../theme/app_theme.dart';
import '../../theme/images.dart';
import 'package:flutter/material.dart';
import '../../../extensions.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SearchBar extends StatefulWidget {
  final String hintText;
  final StringToVoidFunc? onTextChange;
  final FocusNode? focusNode;
  final TextEditingController? textEditingController;

  const SearchBar(this.onTextChange, this.hintText, this.focusNode,
      this.textEditingController);

  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  final icons = [
    1.toSizedBoxVertical,
    const Icon(
      Icons.close,
      size: 17,
      key: const ValueKey(1),
      color: AppColors.colorPrimary,
    )
  ];
  late Widget currentIcons;

  @override
  void initState() {
    super.initState();
    currentIcons = icons[0];
  }

  @override
  Widget build(BuildContext context) => TextField(
        focusNode: widget.focusNode,
        textInputAction: TextInputAction.search,
        controller: widget.textEditingController,
        style: AppTheme.button.copyWith(fontWeight: FontWeight.w500),
        onSubmitted: widget.onTextChange,
        onChanged: widget.onTextChange,
        decoration: InputDecoration(

            // contentPadding: const EdgeInsets.only(ri: 8),
            contentPadding: const EdgeInsets.all(11),
            // fillColor: Colors.black12,
            border: InputBorder.none,
            hintText: widget.hintText,
            hintStyle: context.subTitle2.copyWith(
              fontWeight: FontWeight.bold,
              color: Color(0xFF5B626B),
              fontFamily: 'CeraPro',
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 7.0, top: 12, bottom: 9),
              child: SvgPicture.asset(
                Images.search,
                height: 10,
                width: 10,
              ),
            ),
            suffix: AnimatedSwitcher(
              transitionBuilder: (c, animation) => ScaleTransition(
                scale: animation,
                child: c,
              ),
              child: currentIcons.onTapWidget(
                () {
                  FocusManager.instance.primaryFocus!.unfocus();
                },
              ),
              duration: const Duration(milliseconds: 200),
            ),
            labelStyle: AppTheme.caption.copyWith(fontWeight: FontWeight.bold)),
      ).toContainer(
        alignment: Alignment.center,
        height: 42,
        decoration: BoxDecoration(
            color: Colors.grey.withOpacity(.2),
            borderRadius: BorderRadius.circular(20)),
      );
}
