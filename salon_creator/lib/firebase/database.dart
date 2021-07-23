import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:salon_creator/models/salon.dart';
import 'package:salon_creator/models/user_model.dart';
import 'package:salon_creator/models/user_setting_model.dart';
import 'package:salon_creator/common/constants.dart' as constants;

class DbHandler {
  var salonsRef;

  DbHandler() {
    this.salonsRef =
        FirebaseFirestore.instance.collection('salons').withConverter(
              fromFirestore: (snapshot, _) => Salon.fromMap(
                snapshot.data(),
              ),
              toFirestore: (salon, _) => salon.toMap(),
            );
  }

  Future addUserToDatabase() async {
    final db = FirebaseFirestore.instance;
    final User user = FirebaseAuth.instance.currentUser;

    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    final UserModel currentSignedInUser = UserModel(
      email: user.email,
      name: user.displayName,
      role: RoleType.member,
      settings: UserSettings(pushNotifications: true),
      created: DateTime.now().toUtc(),
    );

    await db
        .collection(constants.DBCollection.users)
        .doc(currentSignedInUser.email)
        .set(currentSignedInUser.toMap());
  }

  addSalon(Salon salon) async {
    try {
      await salonsRef.add(salon);
    } on FirebaseException catch (e) {
      print(e.message);
    }
  }

  getSalon(User user) async {
    final snap = await FirebaseFirestore.instance
        .collection('salons')
        .where(['owner'], isEqualTo: user.email).get();
    return snap.docs.first;
  }
}
