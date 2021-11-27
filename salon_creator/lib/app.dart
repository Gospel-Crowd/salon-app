import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:salon_creator/common/color.dart';
import 'package:salon_creator/firebase/database.dart';
import 'package:salon_creator/screens/contact_us_screen.dart';
import 'package:salon_creator/screens/home_screen.dart';
import 'package:salon_creator/screens/lesson_creation_screen.dart';
import 'package:salon_creator/screens/lesson_edit_screen.dart';
import 'package:salon_creator/screens/login_screen.dart';
import 'package:salon_creator/screens/registration_success_screen.dart';
import 'package:salon_creator/screens/salon_creation_screen.dart';
import 'package:salon_creator/screens/salon_registration_screen.dart';
import 'package:salon_creator/screens/terms_screen.dart';
import 'package:salon_creator/screens/user_profile_edit_screen.dart';
import 'package:salon_creator/screens/user_profile_screen.dart';
import 'package:salon_creator/widgets/lesson_card.dart';

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
        '/lesson/create': (context) => LessonCreationScreen(),
        '/lesson/edit': (context) => LessonEditScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/lesson/edit') {
          final lessonInfo = settings.arguments as LessonInfo;
          return MaterialPageRoute(
              builder: (_) => LessonEditScreen(lessonInfo: lessonInfo));
        }
        return null;
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
    var textTheme = _buildTextTheme(defaultThemeData);

    return defaultThemeData.copyWith(
      primaryColor: primaryColor,
      iconTheme: IconThemeData(color: primaryColor),
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
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.disabled)) {
              return null;
            }
            return primaryColor;
          }),
        ),
      ),
      dividerColor: Color.fromRGBO(193, 193, 193, 1),
      appBarTheme: _buildAppBarTheme(defaultThemeData),
      tabBarTheme: _buildTabTheme(defaultThemeData, textTheme),
    );
  }

  AppBarTheme _buildAppBarTheme(ThemeData defaultThemeData) {
    return defaultThemeData.appBarTheme.copyWith(
      shadowColor: Colors.transparent,
      color: Colors.white,
      foregroundColor: Colors.black,
      textTheme: defaultThemeData.textTheme.apply(
        displayColor: Colors.black,
      ),
    );
  }

  TabBarTheme _buildTabTheme(ThemeData defaultThemeData, TextTheme textTheme) {
    return defaultThemeData.tabBarTheme.copyWith(
      labelColor: primaryColor,
      unselectedLabelColor: primaryColor,
      labelStyle: textTheme.headline4,
      unselectedLabelStyle: textTheme.headline4,
    );
  }

  TextTheme _buildTextTheme(ThemeData defaultThemeData) =>
      defaultThemeData.textTheme
          .copyWith(
            headline1: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
            ),
            headline2: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
            headline3: TextStyle(
              color: primaryColor,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
            headline4: TextStyle(
              fontSize: 16,
            ),
            button: TextStyle(
              fontSize: 18,
            ),
            headline5: TextStyle(
              color: primaryColor,
              fontSize: 10,
            ),
          )
          .apply(
            fontFamily: 'NotoSansJP',
            fontSizeDelta: 2,
          );

  Widget _buildHomePage() => StreamBuilder<DocumentSnapshot>(
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
