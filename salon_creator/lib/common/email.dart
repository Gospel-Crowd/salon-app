import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> sendFeedbackMail({
  name,
  category,
  content,
}) async {
  await FirebaseFunctions.instance
      .httpsCallable('sendFeedbackMailToGospelCrowd')
      .call({
    'mail': FirebaseAuth.instance.currentUser.email,
    'name': name,
    'category': category,
    'content': content,
  });
}

Future<void> sendSalonRegistrationThanksMail({
  fullName,
  phoneNumber,
  text,
}) async {
  await FirebaseFunctions.instance
      .httpsCallable('sendSalonRegistrationThanksMail')
      .call({
    'mail': FirebaseAuth.instance.currentUser.email,
    'fullName': fullName,
    'text': text,
    'phoneNumber': phoneNumber,
  });
}
