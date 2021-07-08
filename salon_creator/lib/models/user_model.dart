import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:salon_creator/models/discovery_data.dart';
import 'package:salon_creator/models/user_setting_model.dart';

class UserModel {
  final String email;
  final String name;
  final RoleType role;
  final UserSettings settings;
  final DateTime created;
  final DiscoveryData discoveryData;

  UserModel({
    this.email,
    this.name,
    this.role,
    this.settings,
    this.created,
    this.discoveryData,
  });

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'role': role.index,
      'setting': settings.toMap(),
      'created': created,
      'discoveryData': discoveryData,
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
        settings = map['setting'] != null
            ? UserSettings.fromMap(map['setting'].cast<String, dynamic>())
            : null,
        created = map['created'].toDate(),
        discoveryData = map['discoveryData'] != null
            ? DiscoveryData.fromMap(
                map['discoveryData'].cast<String, dynamic>())
            : null;

  UserModel.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data());
}

enum RoleType {
  member, // 0
  creator, // 1
}
