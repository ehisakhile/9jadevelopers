import 'package:equatable/equatable.dart';

class ReportPostEntity extends Equatable {
  final String postId;
  final int? reason;
  final String comment;

  const ReportPostEntity({
    required this.postId,
    required this.reason,
    required this.comment,
  });

  @override
  List<Object?> get props => [
        this.postId,
        this.reason,
        this.comment,
      ];

  Map<String, dynamic> toJson() {
    return {
      'post_id': postId,
      'reason': reason,
      'comment': comment,
    };
  }
}
