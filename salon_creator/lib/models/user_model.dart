import 'package:salon_creator/models/user_profile_model.dart';
import 'package:salon_creator/models/user_setting_model.dart';

class UserModel {
  final String email;
  final RoleType role;
  final UserSettings settings;
  final UserProfileModel profile;
  DateTime created;

  UserModel({
    this.email,
    this.role,
    this.settings,
    this.profile,
    this.created,
  });

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'role': role.index,
      'setting': settings.toMap(),
      'created': created,
      'profile': profile.toMap(),
    };
  }

  bool isCreator() {
    return (role == RoleType.creator);
  }

//Cast occurs error
  UserModel.fromMap(Map<String, dynamic> map)
      : email = map['email'],
        role = RoleType.values[map['role']],
        settings = UserSettings.fromMap(map['setting'].cast<String, dynamic>()),
        created = map['created'] is DateTime
            ? map['created']
            : map['created'].toDate(),
        profile =
            UserProfileModel.fromMap(map['profile'].cast<String, dynamic>());
}

enum RoleType {
  member, // 0
  creator, // 1
}
