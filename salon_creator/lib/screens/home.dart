import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:salon_creator/common/color.dart';
import 'package:salon_creator/common/constants.dart' as constants;
import 'package:salon_creator/firebase/sign_in.dart';
import 'package:salon_creator/models/user_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection(constants.DBCollection.users)
          .doc(FirebaseAuth.instance.currentUser.email)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return LinearProgressIndicator();
        }

        var userModel = UserModel.fromMap(snapshot.data.data());

        return _buildHomePageInternal(context, userModel);
      },
    );
  }

  Widget _buildHomePageInternal(BuildContext context, UserModel userModel) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ホーム'),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      drawer: _buildDrawer(context, userModel),
      body: Container(),
    );
  }

  Widget _buildDrawer(BuildContext context, UserModel userModel) {
    var drawerListItemTextStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
    );

    List<Widget> drawerMenuItems = [
      _buildProfileImageDisplay(context, userModel),
    ];
    drawerMenuItems.addAll(ListTile.divideTiles(
      context: context,
      tiles: [
        ListTile(title: Text('プロフィール', style: drawerListItemTextStyle)),
        ListTile(title: Text('サロン設定', style: drawerListItemTextStyle)),
        ListTile(title: Text('お問い合わせ', style: drawerListItemTextStyle)),
        ListTile(title: Text('利用規約', style: drawerListItemTextStyle)),
        ListTile(title: Text('設定', style: drawerListItemTextStyle)),
      ],
    ).toList());

    return Drawer(
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(children: drawerMenuItems),
            _buildLogoutButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImageDisplay(BuildContext context, UserModel userModel) {
    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        Container(
          height: MediaQuery.of(context).size.height * 0.27,
          color: primaryColor,
        ),
        Column(
          children: [
            CircleAvatar(
              radius: MediaQuery.of(context).size.width * 0.15,
              backgroundImage: AssetImage(
                'assets/default_profile_image.png',
              ),
            ),
            SizedBox(height: 16),
            Text(
              userModel.name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return TextButton(
      onPressed: () async {
        await signOut();
        Navigator.of(context).pushNamed('/login');
      },
      child: Text(
        "ログアウト",
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }
}
