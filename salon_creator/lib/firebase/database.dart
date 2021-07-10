import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:salon_creator/models/salon.dart';

final salonsRef = FirebaseFirestore.instance.collection('salons').withConverter(
      fromFirestore: (snapshot, _) => Salon.fromMap(
        snapshot.data(),
      ),
      toFirestore: (salon, _) => salon.toMap(),
    );

void addSalonsToDatabase(Salon salon) async {
  try {
    await salonsRef.add(salon);
  } on FirebaseException catch (e) {
    print(e.message);
  }
}
