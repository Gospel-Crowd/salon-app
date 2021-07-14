import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:salon_creator/models/salon.dart';

final salonsRef = FirebaseFirestore.instance.collection('salons').withConverter(
      fromFirestore: (snapshot, _) => Salon.fromMap(
        snapshot.data(),
      ),
      toFirestore: (salon, _) => salon.toMap(),
    );

class DbHandler {
  DbHandler();
  addSalon(Salon salon) async {
    try {
      await salonsRef.add(salon);
    } on FirebaseException catch (e) {
      print(e.message);
    }
  }

  getSalon(User user) async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('salons')
          .where(['owner'], isEqualTo: user.email).get();
      print(snap.docs.first);
      return snap.docs.first;
    } on FirebaseException catch (e) {
      print(e.message);
    }
  }
}
