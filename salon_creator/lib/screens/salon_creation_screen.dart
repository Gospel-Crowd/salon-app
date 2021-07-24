import 'package:flutter/material.dart';

class SalonCreationScreen extends StatefulWidget {
  const SalonCreationScreen({Key key}) : super(key: key);

  @override
  _SalonCreationScreenState createState() => _SalonCreationScreenState();
}

class _SalonCreationScreenState extends State<SalonCreationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/home');
            },
            child: Text("スキップ"),
          ),
        ],
        title: Text("サロン作成"),
      ),
    );
  }
}