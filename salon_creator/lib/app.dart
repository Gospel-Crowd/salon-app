import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:salon_creator/common/color.dart';
import 'package:salon_creator/constant/constants.dart' as constants;
import 'package:salon_creator/screens/home.dart';
import 'package:salon_creator/screens/login_page.dart';

class SalonCreatorApp extends StatelessWidget {
  const SalonCreatorApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: _buildThemeData(),
      routes: {
        '/home': (context) => HomePage(),
        '/login': (context) => LoginPage(),
      },
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (ctx, snapshot) {
          if (snapshot.hasData) {
            return _buildHomePage();
          }
          return LoginPage();
        },
      ),
    );
  }

  ThemeData _buildThemeData() {
    return ThemeData(
      fontFamily: 'NotoSansJP',
      primaryColor: primaryColor,
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all(primaryColor),
        ),
      ),
      dividerColor: Color.fromRGBO(193, 193, 193, 1),
      appBarTheme: AppBarTheme(
        shadowColor: Colors.transparent,
        color: Colors.white,
        foregroundColor: Colors.black,
        textTheme: TextTheme(
          headline6: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontFamily: 'NotoSansJP',
          ),
        ),
      ),
    );
  }

  Widget _buildHomePage() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection(constants.DBCollection.users)
          .doc(FirebaseAuth.instance.currentUser.email)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return LinearProgressIndicator();
        }

        if (snapshot.data.exists) {
          return HomePage();
        } else {
          return LoginPage();
        }
      },
    );
  }
}
