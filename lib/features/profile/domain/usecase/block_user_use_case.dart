import '../../../../core/common/failure.dart';
import '../../../../core/common/usecase.dart';
import '../../data/models/response/block_user_response_model.dart';
import '../repo/profile_repo.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@injectable
class BlockUserUseCase extends UseCase<BlockUserResponseModel, int> {
  final ProfileRepo profileRepo;
  BlockUserUseCase(this.profileRepo);

  @override
  Future<Either<Failure, BlockUserResponseModel>> call(int userId) =>
      profileRepo.blockUser(userId);
}
