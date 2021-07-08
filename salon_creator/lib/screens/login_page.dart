import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:salon_creator/authentication/sign_in.dart';

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
      body: _loginInProgress == true
          ? LinearProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
              backgroundColor: Colors.grey,
            )
          : Stack(
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
    double screenWidth,
    double screenHeight,
    BuildContext context,
  ) {
    return Center(
      child: Container(
        width: screenWidth < 600 ? screenWidth * 0.6 : screenWidth * 0.5,
        height: screenHeight * 0.07,
        child: TextButton(
          style: TextButton.styleFrom(
            backgroundColor: Colors.white,
            primary: Colors.black,
          ),
          onPressed: () {
            _tryLoginWithGoogle(context);
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
                style: TextStyle(fontSize: screenWidth < 600 ? 16 : 22),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _tryLoginWithGoogle(BuildContext context) async {
    setState(() {
      _loginInProgress = true;
    });

    bool signInSucessful = false;

    await signInWithGoogle().whenComplete(
      () => setState(
        () {
          signInSucessful = true;
        },
      ),
    );

    if (signInSucessful) {
      if (FirebaseAuth.instance.currentUser != null) {
        addUserToDatabase();
        Navigator.of(context).pushNamed('/home');
      } else {
        showDialog(
          context: context,
          builder: (_) {
            return AlertDialog(
              content: Text("ログインに失敗しました\nもう一度お試しください"),
              actions: [],
            );
          },
        );
      }
    }
  }

  Widget _buildBackgroundImage() {
    return Container(
      decoration: new BoxDecoration(
        image: new DecorationImage(
          image: new AssetImage("assets/background.jpg"),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
