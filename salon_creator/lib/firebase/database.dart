import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:salon_creator/models/salon.dart';
import 'package:salon_creator/models/user_model.dart';
import 'package:uuid/uuid.dart';

class DbHandler {
  static final String usersCollection = 'users';
  static final String salonsCollection = 'salons';

  var userCollectionRef;
  var salonCollectionRef;

  DbHandler() {
    userCollectionRef = FirebaseFirestore.instance.collection(usersCollection);
    salonCollectionRef =
        FirebaseFirestore.instance.collection(salonsCollection);
  }

  Future updateUser(UserModel userModel) async =>
      await userCollectionRef.doc(userModel.email).update(userModel.toMap());

  Future addUser(UserModel userModel) async =>
      await userCollectionRef.doc(userModel.email).set(userModel.toMap());

  Future<UserModel> getUser(String email) async {
    var dbObject = await userCollectionRef.doc(email).get();

    return dbObject != null ? UserModel.fromMap(dbObject.data()) : null;
  }

  Future addSalon(Salon salon) async => await FirebaseFirestore.instance
      .collection("salons")
      .doc()
      .set(salon.toMap());

  Future getSalon(User user) async => await salonCollectionRef
      .where(['owner'], isEqualTo: user.email)
      .get()
      .docs
      .first;
}

class StorageHandler {
  static final String imageFilePath = "images";

  var imageFileRef;

  StorageHandler() {
    imageFileRef = FirebaseStorage.instance.ref().child(imageFilePath);
  }

  Future<String> uploadImageAndGetUrl(File file) async {
    var snapshot = await FirebaseStorage.instance
        .ref()
        .child('images')
        .child('${Uuid().v1()}.png')
        .putFile(file);

    return snapshot.ref.getDownloadURL();
  }
}
