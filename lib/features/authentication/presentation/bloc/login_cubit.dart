import 'dart:collection';

import 'package:bloc/bloc.dart';
import 'sign_up_cubit.dart';
import '../../../../core/common/stream_validators.dart';
import '../../../../core/common/uistate/common_ui_state.dart';
import '../../../../core/common/validators.dart';
import '../../../../core/datasource/local_data_source.dart';
import '../../domain/usecase/login_use_case.dart';
import '../../domain/usecase/social_login_use_case.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';

part 'login_state.dart';

@injectable
class LoginCubit extends Cubit<CommonUIState> {
  FieldValidators passwordValidator =
      FieldValidators(null, null, obsecureTextBool: true);
  late FieldValidators emailValidators;
  Stream<bool> get validForm => Rx.combineLatest2<String?, String?, bool>(
          emailValidators.stream, passwordValidator.stream, (a, b) {
        return a != null && b != null && a.isNotEmpty && b.isNotEmpty;
      }).asBroadcastStream();

  final errorTextStream = BoolStreamValidator();

  // use cases
  final LocalDataSource? localDataSource;
  final LoginUseCase? loginUseCase;
  final SocialLoginUseCase? socialLoginUseCase;

  // UI STATE
  bool isPasswordVisible = false;
  // constructor
  LoginCubit(this.localDataSource, this.loginUseCase, this.socialLoginUseCase)
      : super(const CommonUIState.initial()) {
    emailValidators =
        FieldValidators(validateEmail, passwordValidator.focusNode);
  }
  void changePasswordVisibility() {
    emit(const CommonUIState.initial());
    isPasswordVisible = !isPasswordVisible;
    emit(const CommonUIState.success(''));
  }

  void loginUser(String email, String password) async {
    // empty case

    emit(const CommonUIState.loading());
    final response = await loginUseCase!(
      HashMap<String, dynamic>.from(
        {"email": email.trim(), "password": password.trim()},
      ),
    );
    response.fold(
      (l) => emit(
        CommonUIState.error(l.errorMessage),
      ),
      (r) => emit(
        CommonUIState.success(SuccessState.LOGIN_SUCCESS),
      ),
    );
  }

  void facebookLogin() async {
    var response = await socialLoginUseCase!(SocialLogin.FB);
    emit(response.fold((l) => CommonUIState.error(l.errorMessage),
        (r) => CommonUIState.success(r)));
  }

  void googleLogin() async {
    var response = await socialLoginUseCase!(SocialLogin.GOOGLE);
    emit(response.fold((l) => CommonUIState.error(l.errorMessage),
        (r) => CommonUIState.success(r)));
  }

  void twitterLogin() async {
    var response = await socialLoginUseCase!(SocialLogin.TWITTER);
    emit(response.fold((l) => CommonUIState.error(l.errorMessage),
        (r) => CommonUIState.success(r)));
  }

  @override
  // ignore: missing_return
  Future<Function> close() {
    emailValidators.onDispose();
    passwordValidator.onDispose();
    errorTextStream.dispose();
    super.close();
    return Future.value(() {});
  }
}
