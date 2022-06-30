import 'package:equatable/equatable.dart';

class ReportProfileEntity extends Equatable {
  final String userId;
  final int? reason;
  final String comment;

  ReportProfileEntity({
    required this.userId,
    required this.reason,
    required this.comment,
  });

  @override
  List<Object?> get props => [
        this.userId,
        this.reason,
        this.comment,
      ];

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'reason': reason,
      'comment': comment,
    };
  }
}
