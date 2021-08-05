import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:salon_creator/common/color.dart';
import 'package:salon_creator/firebase/database.dart';
import 'package:salon_creator/screens/home.dart';
import 'package:salon_creator/screens/login_screen.dart';
import 'package:salon_creator/screens/registration_success_screen.dart';
import 'package:salon_creator/screens/salon_creation_screen.dart';
import 'package:salon_creator/screens/salon_registration_screen.dart';
import 'package:salon_creator/screens/terms_screen.dart';
import 'package:salon_creator/screens/user_profile_edit_screen.dart';
import 'package:salon_creator/screens/user_profile_screen.dart';

class SalonCreatorApp extends StatelessWidget {
  const SalonCreatorApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: _buildThemeData(),
      routes: {
        '/home': (context) => HomePage(),
        '/login': (context) => LoginScreen(),
        '/registration_success': (context) => RegistrationSuccessScreen(),
        '/salon_creation': (context) => SalonCreationScreen(),
        '/salon_registration': (context) => SalonRegistrationScreen(),
        '/terms': (context) => TermsScreen(),
        '/user/profile/get': (context) => UserProfileScreen(),
        '/user/profile/update': (context) => UserProfileEditScreen(),
      },
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (ctx, snapshot) {
          final User user = snapshot.data;
          if (snapshot.hasData &&
              FirebaseFirestore.instance
                      .collection(DbHandler.usersCollection)
                      .doc(user.email) ==
                  null) {
            return _buildHomePage();
          }
          return LoginScreen();
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
          .collection(DbHandler.usersCollection)
          .doc(FirebaseAuth.instance.currentUser.email)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return LinearProgressIndicator();
        }

        if (snapshot.data.exists &&
            snapshot.data.get(FieldPath(['role'])) == 1) {
          return HomePage();
        } else if (snapshot.data.get(FieldPath(['role'])) == 0) {
          return SalonRegistrationScreen();
        }

        return LoginScreen();
      },
    );
  }
}
