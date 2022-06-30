class UpdateSettingsRequestModel {
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? aboutYou;
  final String? website;
  final String? gender;
  final String? username;
  final String? countryId;

  UpdateSettingsRequestModel(
      {this.firstName,
      this.lastName,
      this.email,
      this.aboutYou,
      this.website,
      this.gender,
      this.username,
      this.countryId});

  Map<String, dynamic> toJson() => {
        // "id": id == null ? null : id,
        "first_name": firstName == null ? null : firstName,
        "last_name": lastName == null ? null : lastName,
        "username": username == null ? null : username,
        "email": email == null ? null : email,
        // "is_verified": isVerified == null ? null : isVerified,
        "website": website == null ? null : website,
        "about": aboutYou == null ? null : aboutYou,
        "gender": gender == null ? null : gender,
        "country_id": countryId == null ? null : countryId,
      };
}
