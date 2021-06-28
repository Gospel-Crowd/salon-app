class UserSettings {
  final bool pushNotifications;

  UserSettings({
    this.pushNotifications,
  });

  Map<String, dynamic> toMap() {
    return {
      'pushNotifications': pushNotifications,
    };
  }

  UserSettings.fromMap(Map<String, dynamic> map)
      : assert(map['pushNotifications'] != null),
        pushNotifications = map['pushNotifications'];
}
