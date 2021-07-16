import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:salon_creator/models/salon.dart';

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
