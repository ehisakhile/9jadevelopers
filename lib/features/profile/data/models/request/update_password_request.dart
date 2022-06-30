class UpdatePasswordRequest {
  final String oldPassword;
  final String newPassword;

  UpdatePasswordRequest({required this.oldPassword, required this.newPassword});
  Map<String, dynamic> toJson() => {
        // "id": id == null ? null : id,
        "old_password": oldPassword,
        "new_password": newPassword
      };
}
