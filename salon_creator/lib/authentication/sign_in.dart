import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:salon_creator/models/user_model.dart';
import 'package:salon_creator/constant/constants.dart' as constants;

UserModel currentSignedInUser = UserModel();
final db = FirebaseFirestore.instance;

Future<UserCredential> signInWithGoogle() async {
  final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();
  final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
  final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );

  return await FirebaseAuth.instance.signInWithCredential(credential);
}

Future addUserToDatabase() async {
  final _auth = FirebaseAuth.instance;
  final User user = _auth.currentUser;

  assert(!user.isAnonymous);
  assert(await user.getIdToken() != null);

  currentSignedInUser = UserModel(
    email: user.email,
    name: user.displayName,
    role: RoleType.member,
    setting: null,
    created: DateTime.now().toUtc(),
  );

  await db
      .collection(constants.DBCollection.users)
      .doc(user.email)
      .set(currentSignedInUser.toMap());
}

Future signOut() async {
  final _auth = FirebaseAuth.instance;
  final User user = _auth.currentUser;

  if (user != null) {
    await FirebaseAuth.instance.signOut();
  }
}
