import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:salon_creator/models/creator_model.dart';
import 'package:salon_creator/models/lesson.dart';
import 'package:salon_creator/models/salon.dart';
import 'package:salon_creator/models/user_model.dart';
import 'package:uuid/uuid.dart';

class DbHandler {
  static final String usersCollection = 'users';
  static final String salonsCollection = 'salons';
  static final String lessonsCollection = 'lessons';

  var userCollectionRef;
  var salonCollectionRef;
  var lessonCollectionRef;

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

    return dbObject.data() != null ? UserModel.fromMap(dbObject.data()) : null;
  }

  Future<String> addSalon(Salon salon) => FirebaseFirestore.instance
      .collection(salonsCollection)
      .add(salon.toMap())
      .then((value) => value.id);

  Future getSalon(CreatorModel creator) async => await salonCollectionRef
      .where(['salonId'], isEqualTo: creator.salonId)
      .get()
      .docs
      .first;

  Future addLesson(Lesson lesson, String salonId) async =>
      await salonCollectionRef
          .doc(salonId)
          .collection("lessons")
          .doc()
          .set(lesson.toMap());
}

class StorageHandler {
  static final String imageFilePath = "images";
  static final String resourcesPath = "resources";

  var imageFileRef;

  StorageHandler() {
    imageFileRef = FirebaseStorage.instance.ref().child(imageFilePath);
  }

  Future<String> uploadResourceAndGetUrl(File file) async {
    if (file != null) {
      var snapshot =
          await FirebaseStorage.instance.ref().child('resources').putFile(file);

      return snapshot.ref.getDownloadURL();
    }
    return null;
  }

  Future<String> uploadImageAndGetUrl(File file) async {
    if (file != null) {
      var snapshot = await FirebaseStorage.instance
          .ref()
          .child('images')
          .child('${Uuid().v1()}.png')
          .putFile(file);

      return snapshot.ref.getDownloadURL();
    }
    return null;
  }
}
