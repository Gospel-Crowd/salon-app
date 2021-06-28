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
    return Scaffold(
      body: Stack(
        children: [
          _buildBackgroundImage(),
          _buildLoginButtons(context),
        ],
      ),
    );
  }

  Widget _buildLoginButtons(BuildContext context) {
    final mq = MediaQuery.of(context).size;
    final screenWidth = mq.width;
    final screenHeight = mq.height;
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildGoogleLoginButton(screenWidth, screenHeight, context),
        ],
      ),
    );
  }

  Widget _buildGoogleLoginButton(
      double screenWidth, double screenHeight, BuildContext context) {
    return Center(
      child: Container(
        width: screenWidth * 0.6,
        height: screenHeight * 0.06,
        child: TextButton(
          style: TextButton.styleFrom(
            backgroundColor: Colors.white,
            primary: Colors.black,
          ),
          onPressed: () async {
            await signInWithGoogle();
            if (FirebaseAuth.instance.currentUser != null) {
              addUserToDatabase();
              Navigator.of(context).pushNamed('/home');
            }
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/signinbutton/google_logo.png'),
              const SizedBox(
                width: 16,
              ),
              Text(
                "Googleでログイン",
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
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
