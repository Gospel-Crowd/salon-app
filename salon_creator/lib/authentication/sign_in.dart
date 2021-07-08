import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:salon_creator/common/constants.dart' as constants;
import 'package:salon_creator/models/user_model.dart';
import 'package:salon_creator/models/user_setting_model.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

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

String generateNonce([int length = 32]) {
  final charset =
      '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
  final random = Random.secure();
  return List.generate(length, (_) => charset[random.nextInt(charset.length)])
      .join();
}

String sha256ofString(String input) {
  final bytes = utf8.encode(input);
  final digest = sha256.convert(bytes);
  return digest.toString();
}

Future<UserCredential> signInWithApple() async {
  final rawNonce = generateNonce();
  final nonce = sha256ofString(rawNonce);

  final appleCredential = await SignInWithApple.getAppleIDCredential(
    scopes: [
      AppleIDAuthorizationScopes.email,
      AppleIDAuthorizationScopes.fullName,
    ],
    nonce: nonce,
  );

  final oauthCredential = OAuthProvider("apple.com").credential(
    idToken: appleCredential.identityToken,
    rawNonce: rawNonce,
  );

  return await FirebaseAuth.instance.signInWithCredential(oauthCredential);
}

Future addUserToDatabase() async {
  final User user = FirebaseAuth.instance.currentUser;

  assert(!user.isAnonymous);
  assert(await user.getIdToken() != null);

  currentSignedInUser = UserModel(
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

Future signOut() async {
  final User user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    await FirebaseAuth.instance.signOut();
  }
}
