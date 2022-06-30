import 'package:auto_route/auto_route.dart';
import 'package:colibri/core/config/colors.dart';
import '../../../../core/common/buttons/custom_button.dart';
import '../../../../translations/locale_keys.g.dart';
import '../../../../core/common/uistate/common_ui_state.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/routes/routes.gr.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/widgets/loading_bar.dart';
import '../../../../extensions.dart';
import '../bloc/reset_password_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keyboard_actions/keyboard_actions.dart';

class ResetPasswordScreen extends StatefulWidget {
  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  ResetPasswordCubit? resetPasswordCubit;
  late final TextEditingController _forgotPasswordController;

  @override
  void initState() {
    super.initState();
    resetPasswordCubit = getIt<ResetPasswordCubit>();
    _forgotPasswordController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ResetPasswordCubit>(
      create: (c) => resetPasswordCubit!,
      child: BlocListener<ResetPasswordCubit, CommonUIState>(
          listener: (_, state) {
            state.maybeWhen(
                orElse: () {},
                success: (message) {
                  context.router.root.pop();
                  context.showSnackBar(message: message);
                },
                error: (e) {
                  context.showOkAlertDialog(desc: e!, title: "Alert");
                });
          },
          child: Scaffold(
            backgroundColor: Colors.white,
            body: BlocBuilder<ResetPasswordCubit, CommonUIState>(
              builder: (c, state) => state.when(
                  initial: buildHome,
                  success: (s) => buildHome(),
                  loading: () => LoadingBar(),
                  error: (e) => buildHome()),
            ),
          )),
    );
  }

  Widget buildHome() {
    return SingleChildScrollView(
      child: Container(
        constraints:
            BoxConstraints(maxHeight: MediaQuery.of(context).size.height),
        child: KeyboardActions(
          config: KeyboardActionsConfig(
            keyboardActionsPlatform: KeyboardActionsPlatform.IOS,
            actions: [
              KeyboardActionsItem(
                displayDoneButton: true,
                focusNode: resetPasswordCubit!.emailValidator.focusNode,
              ),
            ],
          ),
          child: SizedBox(
            height: context.getScreenHeight as double?,
            child: [
              [
                AppIcons.appLogo
                    .toContainer(alignment: Alignment.center)
                    .toExpanded(),
                LocaleKeys
                    .please_check_your_email_inbox_mail_we_sent_you_an_email
                    .tr()
                    .toCaption(fontWeight: FontWeight.w500)
                    .toContainer(alignment: Alignment.center),
              ].toColumn().toExpanded(),
              [
                20.toSizedBox,
                LocaleKeys.enter_your_email_address.tr().toTextField(
                      controller: _forgotPasswordController,
                      onChange: (s) => setState(() {}),
                      errorText: !_forgotPasswordController.text.isValidEmail &&
                              _forgotPasswordController.text.isNotEmpty
                          ? 'Please Enter a valid email address'
                          : null,
                      onSubmit: (value) {
                        resetPasswordCubit!
                            .resetPassword(_forgotPasswordController.text);
                      },
                    ),
                20.toSizedBox,
                CustomButton(
                  color: _forgotPasswordController.text.isValidEmail &&
                          _forgotPasswordController.text.isNotEmpty
                      ? AppColors.colorPrimary
                      : AppColors.colorPrimary.withOpacity(.5),
                  text: LocaleKeys.reset_the_password.tr(),
                  fullWidth: true,
                  onTap: () async {
                    if (_forgotPasswordController.text.isValidEmail &&
                        _forgotPasswordController.text.isNotEmpty)
                      await resetPasswordCubit!
                          .resetPassword(_forgotPasswordController.text);
                    FocusManager.instance.primaryFocus!.unfocus();
                  },
                ),
              ].toColumn().toExpanded(),
              [
                LocaleKeys.already_have_an_account.tr().toCaption(
                    fontWeight: FontWeight.w500, color: Colors.black54),
                "SIGN IN"
                    .toButton(color: AppColors.colorPrimary)
                    .toUnderLine()
                    .toFlatButton(
                        () => context.router.root.replace(LoginScreenRoute())),
              ]
                  .toColumn(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center)
                  .toExpanded()
            ]
                .toColumn(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center)
                .toHorizontalPadding(24),
          ),
        ),
      ),
    );
  }
}
