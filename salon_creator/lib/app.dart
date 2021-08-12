import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:salon_creator/common/color.dart';
import 'package:salon_creator/firebase/database.dart';
import 'package:salon_creator/models/user_model.dart';
import 'package:salon_creator/screens/contact_us_screen.dart';
import 'package:salon_creator/screens/home.dart';
import 'package:salon_creator/screens/login_screen.dart';
import 'package:salon_creator/screens/registration_success_screen.dart';
import 'package:salon_creator/screens/salon_creation_screen.dart';
import 'package:salon_creator/screens/salon_registration_screen.dart';
import 'package:salon_creator/screens/terms_screen.dart';
import 'package:salon_creator/screens/user_profile_edit_screen.dart';
import 'package:salon_creator/screens/user_profile_screen.dart';

bool userLoggedIn = false;

class SalonCreatorApp extends StatelessWidget {
  const SalonCreatorApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: _buildThemeData(context),
      routes: {
        '/contact_us': (context) => ContactUsScreen(),
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

  ThemeData _buildThemeData(BuildContext context) {
    var defaultThemeData = Theme.of(context);

    return defaultThemeData.copyWith(
      primaryColor: primaryColor,
      textTheme: _buildTextTheme(defaultThemeData),
      inputDecorationTheme: defaultThemeData.inputDecorationTheme.copyWith(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          borderSide: BorderSide(),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all(primaryColor),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(primaryColor),
          foregroundColor: MaterialStateProperty.all(Colors.white),
        ),
      ),
      dividerColor: Color.fromRGBO(193, 193, 193, 1),
      appBarTheme: defaultThemeData.appBarTheme.copyWith(
        shadowColor: Colors.transparent,
        color: Colors.white,
        foregroundColor: Colors.black,
        textTheme: defaultThemeData.textTheme.apply(
          displayColor: Colors.black,
        ),
      ),
    );
  }

  TextTheme _buildTextTheme(ThemeData defaultThemeData) =>
      defaultThemeData.textTheme
          .copyWith(
            headline1: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
            headline3: TextStyle(
              color: primaryColor,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
            button: TextStyle(
              fontSize: 18,
            ),
          )
          .apply(
            fontFamily: 'NotoSansJP',
            fontSizeDelta: 2,
          );

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
