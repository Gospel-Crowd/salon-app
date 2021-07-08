import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> sendMail({text, name, fullName, subject, phoneNumber}) async {
  User user = FirebaseAuth.instance.currentUser;
  HttpsCallable request = FirebaseFunctions.instance.httpsCallable('sendMail');
  try {
    final result = await request.call(
      {
        'mail': user.email,
        'name': name,
        'fullName': fullName,
        'subject': subject,
        'text': text,
        'phoneNumber': phoneNumber,
      },
    );
    print(result);
  } on FirebaseFunctionsException catch (e) {
    print("Firebase Functions Exception");
    print(e.code);
    print(e.message);
  } catch (e) {
    print('Caught Exception');
    print(e);
  }
}
