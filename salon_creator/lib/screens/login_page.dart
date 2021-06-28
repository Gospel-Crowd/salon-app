import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:salon_creator/authentication/sign_in.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;
    final screenWidth = mq.width;

    return Scaffold(
      body: Stack(
        children: [
          _buildBackgroundImage(),
          _buildLoginButtons(screenWidth, context),
        ],
      ),
    );
  }

  Widget _buildLoginButtons(double screenWidth, BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Container(
              width: screenWidth / 1.3,
              child: TextButton(
                style: TextButton.styleFrom(primary: Colors.transparent),
                onPressed: () async {
                  await signInWithGoogle();
                  if (FirebaseAuth.instance.currentUser != null) {
                    addUserToDatabase();
                    Navigator.of(context).pushNamed('/home');
                  }
                },
                child: Image.asset(
                  'assets/signinbutton/btn_google_signin_light_normal_web@2x.png',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundImage() {
    return Container(
      decoration: new BoxDecoration(
        image: new DecorationImage(
          image: new AssetImage("assets/background.jpg"),
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}
