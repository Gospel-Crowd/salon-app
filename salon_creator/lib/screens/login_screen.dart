import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:salon_creator/app.dart';
import 'package:salon_creator/common/color.dart';
import 'package:salon_creator/firebase/database.dart';
import 'package:salon_creator/firebase/sign_in.dart';
import 'package:salon_creator/models/creator_model.dart';
import 'package:salon_creator/models/member_model.dart';
import 'package:salon_creator/models/user_model.dart';
import 'package:salon_creator/models/user_profile_model.dart';
import 'package:salon_creator/models/user_setting_model.dart';
import 'package:salon_creator/screens/salon_creation_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _loginInProgress = false;
  DbHandler dbHandler = DbHandler();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: _loginInProgress
          ? LinearProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
              backgroundColor: Colors.grey,
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  child: Text(
                    "Gospel Crowd",
                    style: Theme.of(context).textTheme.headline1,
                  ),
                ),
                _buildLoginButtons(context),
              ],
            ),
    );
  }

  Widget _buildLoginButtons(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLoginButton(
            context: context,
            asset: 'assets/signin_button/google_logo.png',
            text: "Googleでログイン",
            method: () async {
              _tryLoginWith(
                context,
                signInWithGoogle(),
              );
            },
          ),
          SizedBox(
            height: 16,
          ),
          _buildLoginButton(
            context: context,
            asset: 'assets/signin_button/apple_logo.png',
            text: "Appleでログイン",
            method: () async {
              _tryLoginWith(
                context,
                signInWithApple(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton({
    BuildContext context,
    String asset,
    String text,
    Function method,
  }) {
    final mq = MediaQuery.of(context).size;
    final screenWidth = mq.width;
    final screenHeight = mq.height;

    return Center(
      child: Container(
        width: screenWidth < 600 ? screenWidth * 0.8 : screenWidth * 0.5,
        height: screenHeight * 0.06,
        child: ElevatedButton(
          style: Theme.of(context).elevatedButtonTheme.style.copyWith(
                backgroundColor: MaterialStateProperty.all(Colors.white),
                foregroundColor: MaterialStateProperty.all(Colors.black),
              ),
          onPressed: method,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLoginMethodLogo(asset),
              SizedBox(
                width: 16,
              ),
              Text(text),
            ],
          ),
        ),
      ),
    );
  }

  Container _buildLoginMethodLogo(String asset) {
    final iconSize = MediaQuery.of(context).size.width * 0.08;
    return Container(
      width: iconSize,
      height: iconSize,
      child: FittedBox(
        fit: BoxFit.cover,
        child: Image.asset(asset),
      ),
    );
  }

  void _navigateBasedOnRole(UserModel userModel) {
    if (userModel.role == RoleType.member) {
      Navigator.of(context).pushReplacementNamed('/salon_registration');
    } else if (userModel.role == RoleType.creator) {
      FirebaseFirestore.instance
          .collection('salons')
          .where('owner', isEqualTo: userModel.email)
          .get()
          .then(
        (QuerySnapshot snapshot) {
          if (snapshot.docs.isNotEmpty) {
            Navigator.of(context).pushReplacementNamed('/home');
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return SalonCreationScreen(
                    userModel: CreatorModel.fromMap(userModel.toMap()),
                  );
                },
              ),
            );
          }
        },
      );
    }
  }

  Future<UserModel> _addToDatabase() async {
    final User user = FirebaseAuth.instance.currentUser;

    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    var userModel = MemberModel(
      email: user.email,
      profile: UserProfileModel(name: user.displayName),
      settings: UserSettings(pushNotifications: true),
      created: DateTime.now().toUtc(),
      salons: [],
    );

    await dbHandler
        .setUser(userModel)
        .onError((error, stackTrace) => _buildLoginFailedDialog());

    return userModel;
  }

  Future _buildLoginFailedDialog() {
    return showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          content: Text("ログインに失敗しました\nもう一度お試しください"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("戻る"),
            ),
          ],
        );
      },
    );
  }

  void _tryLoginWith(BuildContext context, method) async {
    setState(() {
      _loginInProgress = true;
    });

    try {
      await method.whenComplete(() async {
        if (FirebaseAuth.instance.currentUser != null) {
          var userModel =
              await dbHandler.getUser(FirebaseAuth.instance.currentUser.email);

          if (userModel == null) {
            userModel = await _addToDatabase();
          }

          setState(() {
            userLoggedIn = true;
          });

          _navigateBasedOnRole(userModel);
        }
      });
    } on FirebaseAuthException catch (e) {
      print(e.message);
    } finally {
      setState(() {
        _loginInProgress = false;
      });
    }
  }
}
