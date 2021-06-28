import 'package:salon_creator/models/user_setting_model.dart';

class UserModel {
  final String email;
  final String name;
  final RoleType role;
  final UserSettings settings;
  final DateTime created;

  UserModel({
    this.email,
    this.name,
    this.role,
    this.settings,
    this.created,
  });

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'role': role.index,
      'setting': settings.toMap(),
      'created': created,
    };
  }

  bool isCreator() {
    return (role == RoleType.creator);
  }

  UserModel.fromMap(Map<String, dynamic> map)
      : assert(map['email'] != null),
        assert(map['name'] != null),
        assert(map['role'] != null),
        email = map['email'],
        name = map['name'],
        role = RoleType.values[map['role']],
        settings = UserSettings.fromMap(map['setting'].cast<String, dynamic>()),
        created = map['created'].toDate();
}

enum RoleType {
  member, // 0
  creator, // 1
}
