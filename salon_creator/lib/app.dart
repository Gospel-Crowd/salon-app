import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:salon_creator/constant/constants.dart' as constants;
import 'package:salon_creator/screens/home.dart';
import 'package:salon_creator/screens/login_page.dart';

class SalonCreatorApp extends StatelessWidget {
  const SalonCreatorApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/home': (context) => HomePage(),
        '/login': (context) => LoginPage(),
      },
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (ctx, snapshot) {
          if (snapshot.hasData) {
            return _buildHomePage(snapshot);
          }
          return LoginPage();
        },
      ),
    );
  }

  Widget _buildHomePage(AsyncSnapshot<User> snapshot) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection(constants.DBCollection.users)
          .doc(snapshot.data.email)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return LinearProgressIndicator();
        }
        FirebaseAuth.instance.authStateChanges().listen(
          (User user) {
            if (user != null) {
              if (snapshot.data.exists) {
                return HomePage();
              }
            }
          },
        );
        return LoginPage();
      },
    );
  }
}
