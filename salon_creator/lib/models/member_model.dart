import 'package:salon_creator/models/user_model.dart';
import 'package:salon_creator/models/user_profile_model.dart';
import 'package:salon_creator/models/user_setting_model.dart';

class MemberModel extends UserModel {
  List<String> salons;

  MemberModel({
    String email,
    UserSettings settings,
    UserProfileModel profile,
    DateTime created,
    this.salons,
  }) : super(
          email: email,
          settings: settings,
          profile: profile,
          created: created,
          role: RoleType.member,
        );

  Map<String, dynamic> toMap() {
    var superMap = super.toMap();
    superMap['salons'] = salons.asMap();

    return superMap;
  }

  factory MemberModel.fromMap(Map<String, dynamic> map) {
    var userModel = UserModel.fromMap(map);
    return MemberModel(
      salons: map['salons'] != null
          ? map['salons'].cast<String>() as List<String>
          : [],
      email: userModel.email,
      settings: userModel.settings,
      profile: userModel.profile,
      created: userModel.created,
    );
  }
}
