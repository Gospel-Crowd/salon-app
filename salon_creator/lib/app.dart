import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:salon_creator/common/color.dart';
import 'package:salon_creator/common/constants.dart' as constants;
import 'package:salon_creator/screens/home.dart';
import 'package:salon_creator/screens/login_screen.dart';
import 'package:salon_creator/screens/salon_create_application_screen.dart';
import 'package:salon_creator/screens/salon_create_screen.dart';
import 'package:salon_creator/screens/registration_success_screen.dart';

class SalonCreatorApp extends StatelessWidget {
  const SalonCreatorApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: _buildThemeData(),
      routes: {
        '/salon_creation': (context) => SalonCreationScreen(),
        '/home': (context) => HomePage(),
        '/login': (context) => LoginPage(),
        '/salon_registration': (context) => SalonRegistrationScreen(),
        '/screen': (context) => RegistrationSuccessScreen(),
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
        FirebaseAuth.instance.authStateChanges().listen(
          (User user) {
            if (user != null) {
              if (snapshot.data.exists &&
                  snapshot.data.get(FieldPath(['role'])) == 1) {
                return HomePage();
              } else if (snapshot.data.get(FieldPath(['role'])) == 0) {
                return SalonRegistrationScreen();
              }
            }
          },
        );
        return LoginPage();
      },
    );
  }
}
