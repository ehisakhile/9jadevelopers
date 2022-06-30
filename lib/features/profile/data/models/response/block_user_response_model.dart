class BlockUserResponseModel {
  final int? code;
  final String? message;
  BlockUserResponseModel({
    this.code,
    this.message,
  });

  factory BlockUserResponseModel.fromMap(Map<String, dynamic> map) {
    return BlockUserResponseModel(
      code: map['code']?.toInt(),
      message: map['message'],
    );
  }
}
