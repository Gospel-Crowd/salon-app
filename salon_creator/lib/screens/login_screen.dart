import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:salon_creator/app.dart';
import 'package:salon_creator/common/color.dart';
import 'package:salon_creator/firebase/database.dart';
import 'package:salon_creator/firebase/sign_in.dart';
import 'package:salon_creator/models/user_model.dart';
import 'package:salon_creator/models/user_profile_model.dart';
import 'package:salon_creator/models/user_setting_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _loginInProgress = false;
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

  void _navigateBasedOnRole() {
    final _auth = FirebaseAuth.instance.currentUser;
    FirebaseFirestore.instance.collection('users').doc(_auth.email).get().then(
      (DocumentSnapshot snapshot) {
        if (snapshot.get(FieldPath(['role'])) == 0) {
          Navigator.of(context).pushReplacementNamed('/salon_registration');
        } else if (snapshot.get(FieldPath(['role'])) == 1) {
          FirebaseFirestore.instance
              .collection('salons')
              .where('owner', isEqualTo: _auth.email)
              .get()
              .then(
            (QuerySnapshot snapshot) {
              print(snapshot.docs.isNotEmpty);
              print(snapshot.docs.isEmpty);
              if (snapshot.docs.isNotEmpty) {
                Navigator.of(context).pushReplacementNamed('/home');
              } else {
                Navigator.of(context).pushReplacementNamed('/salon_creation');
              }
            },
          );
        }
      },
    );
  }

  Future<void> _addToDatabase() async {
    DbHandler dbHandler = DbHandler();
    final User user = FirebaseAuth.instance.currentUser;

    //エラー可能性
    if (user != null) {
      if (await dbHandler.getUser(user.email) != null) {
        return;
      }
      assert(!user.isAnonymous);
      assert(await user.getIdToken() != null);

      dbHandler
          .addUser(UserModel(
            email: user.email,
            profile: UserProfileModel(name: user.displayName),
            role: RoleType.member,
            settings: UserSettings(pushNotifications: true),
            created: DateTime.now().toUtc(),
          ))
          .onError((error, stackTrace) => _buildLoginFailedDialog());
    }
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
        await _addToDatabase();
        setState(
          () {
            _loginInProgress = false;
            userLoggedIn = true;
          },
        );
      });
    } on FirebaseAuthException catch (e) {
      print(e.message);
    }
    _navigateBasedOnRole();
  }
}
