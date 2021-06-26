import 'package:flutter/material.dart';
import 'package:salon_creator/authentication/sign_in.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                  onPressed: () async {
                    await signOut();
                    Navigator.of(context).pushNamed('/login');
                  },
                  child: Text("ログアウト"))
            ],
          ),
        ),
      ),
      body: Container(),
    );
  }
}
