import 'package:flutter/material.dart';

import '../../../../core/common/failure.dart';
import '../../../../core/common/usecase.dart';
import '../repo/profile_repo.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@injectable
class DeleteAccountUseCase extends UseCase<dynamic, DeleteAccountParam> {
  final ProfileRepo? profileRepo;

  DeleteAccountUseCase(this.profileRepo);
  @override
  Future<Either<Failure, dynamic>> call(DeleteAccountParam param) =>
      profileRepo!.deleteAccount(param.context, param.params);
}

class DeleteAccountParam {
  final BuildContext context;
  final String params;

  DeleteAccountParam(this.context, this.params);
}
