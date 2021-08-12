import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> sendMail({text, name, fullName, subject, phoneNumber}) async {
  await FirebaseFunctions.instance.httpsCallable('sendMail').call({
    'mail': FirebaseAuth.instance.currentUser.email,
    'name': name,
    'fullName': fullName,
    'subject': subject,
    'text': text,
    'phoneNumber': phoneNumber,
  });
}
