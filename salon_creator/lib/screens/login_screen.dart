import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:salon_creator/authentication/sign_in.dart';
import 'package:salon_creator/common/color.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 32,
                    ),
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
          const SizedBox(
            height: 16,
          ),
          _buildLoginButton(
            context: context,
            asset: 'assets/signinbutton/apple-logo.png',
            text: "Appleでログイン",
            method: () async {
              _tryLoginWith(
                context,
                signInWithApple(),
              );
            },
          )
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
          style: TextButton.styleFrom(
            backgroundColor: Colors.white,
            primary: Colors.black,
          ),
          onPressed: method,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                asset,
                width: 32,
                height: 32,
              ),
              const SizedBox(
                width: 16,
              ),
              Text(
                text,
                style: TextStyle(fontSize: screenWidth < 600 ? 16 : 22),
              ),
            ],
          ),
        ),
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

  void _addToDatabase(bool signInSuccessful, User _auth) {
    if (signInSuccessful) {
      if (_auth != null) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(_auth.email)
            .get()
            .then(
              (DocumentSnapshot snapshot) => {
                addUserToDatabase().onError(
                  (error, stackTrace) => showDialog(
                    context: context,
                    builder: (_) {
                      return AlertDialog(
                        content: Text("ログインに失敗しました\nもう一度お試しください"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              "戻る",
                              style: TextStyle(
                                color: primaryColor,
                              ),
                            ),
                          )
                        ],
                      );
                    },
                  ),
                ),
              },
            );
      }
    }
  }

  void _tryLoginWith(BuildContext context, method) async {
    final User _auth = FirebaseAuth.instance.currentUser;
    setState(() {
      _loginInProgress = true;
    });
    bool signInSuccessful = false;
    try {
      await method.whenComplete(() {
        _addToDatabase(signInSuccessful, _auth);
        setState(
          () {
            _loginInProgress = false;
            signInSuccessful = true;
          },
        );
      });
    } on FirebaseAuthException catch (e) {
      print(e.message);
    }

    _navigateBasedOnRole();
  }
}
