import '../../../../core/extensions/context_exrensions.dart';
import '../../../../core/theme/images.dart';
import '../bloc/chat_cubit.dart';
import '../../../../translations/locale_keys.g.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';

class MessagesFloatingSearchBar extends StatelessWidget {
  const MessagesFloatingSearchBar(this.chatCubit, {Key? key}) : super(key: key);
  final ChatCubit? chatCubit;
  @override
  Widget build(BuildContext context) {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final floatingSearchBarController = FloatingSearchBarController();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: FloatingSearchBar(
        controller: floatingSearchBarController,
        hint: LocaleKeys.search_for_messages.tr(),
        hintStyle: context.subTitle2.copyWith(
          fontWeight: FontWeight.bold,
          color: Color(0xFF5B626B),
          fontFamily: 'CeraPro',
        ),
        backgroundColor: Colors.grey.shade200,
        borderRadius: BorderRadius.all(Radius.circular(20)),
        scrollPadding: const EdgeInsets.only(top: 16, bottom: 56),
        transitionDuration: const Duration(milliseconds: 400),
        transitionCurve: Curves.easeInOut,
        physics: const BouncingScrollPhysics(),
        axisAlignment: isPortrait ? 0.0 : -1.0,
        automaticallyImplyBackButton: false,
        openAxisAlignment: 0.0,
        width: isPortrait ? 600 : 500,
        elevation: 0.0,
        debounceDelay: const Duration(milliseconds: 500),
        actions: [],
        leadingActions: [
          Padding(
            padding: const EdgeInsets.only(
              left: 16.0,
              top: 12,
              bottom: 12,
              right: 16,
            ),
            child: SvgPicture.asset(
              Images.search,
              height: 20,
              width: 20,
            ),
          ),
        ],
        onQueryChanged: (query) {
          chatCubit!.chatPagination!.searchChat = true;
          chatCubit!.chatPagination!.queryText = query;
        },
        transition: CircularFloatingSearchBarTransition(),
        builder: (context, transition) {
          return const SizedBox();
        },
      ),
    );
  }
}
