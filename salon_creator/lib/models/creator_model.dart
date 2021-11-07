import 'package:salon_creator/models/discovery_data.dart';
import 'package:salon_creator/models/user_model.dart';
import 'package:salon_creator/models/user_profile_model.dart';
import 'package:salon_creator/models/user_setting_model.dart';

class CreatorModel extends UserModel {
  String salonId;
  final DiscoveryData discoveryData;

  CreatorModel({
    String email,
    UserSettings settings,
    UserProfileModel profile,
    DateTime created,
    this.salonId,
    this.discoveryData,
  }) : super(
          email: email,
          settings: settings,
          profile: profile,
          created: created,
          role: RoleType.creator,
        );

  Map<String, dynamic> toMap() {
    var superMap = super.toMap();
    superMap['salonId'] = salonId;
    superMap['discoveryData'] = discoveryData.toMap();

    return superMap;
  }

  factory CreatorModel.fromMap(Map<String, dynamic> map) {
    var userModel = UserModel.fromMap(map);
    return CreatorModel(
      salonId: map['salonId'],
      email: userModel.email,
      settings: userModel.settings,
      profile: userModel.profile,
      created: userModel.created,
      discoveryData: map['discoveryData'] != null
            ? DiscoveryData.fromMap(
                map['discoveryData'].cast<String, dynamic>())
            : null,
    );
  }
}
