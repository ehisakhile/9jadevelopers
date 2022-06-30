import '../post_repo.dart';

import '../../../../core/common/failure.dart';
import '../../../../core/common/usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@injectable
class VotePollUseCase extends UseCase<dynamic, PollParam> {
  final PostRepo postRepo;

  VotePollUseCase(this.postRepo);
  @override
  Future<Either<Failure, dynamic>> call(PollParam params) {
    return postRepo.votePolls(params);
  }
}

class PollParam {
  final int postId;
  final int pollId;

  PollParam({
    required this.postId,
    required this.pollId,
  });
}
