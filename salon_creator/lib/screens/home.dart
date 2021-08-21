import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:salon_creator/common/color.dart';
import 'package:salon_creator/firebase/database.dart';
import 'package:salon_creator/firebase/sign_in.dart';
import 'package:salon_creator/models/user_model.dart';
import 'package:salon_creator/screens/contact_us_screen.dart';
import 'package:salon_creator/screens/lesson_list_screen.dart';
import 'package:salon_creator/screens/member_list_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection(DbHandler.usersCollection)
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
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text('ホーム'),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      drawer: _buildDrawer(context, userModel),
      body: SafeArea(
        child: Column(
          children: [
            _buildScreenSelection(screenWidth),
            selectedIndex == 0 ? LessonListScreen() : MemberListScreen(),
          ],
        ),
      ),
    );
  }

  Widget _buildScreenSelection(double screenWidth) {
    return Container(
      margin: EdgeInsets.only(
        top: screenWidth * 0.02,
        bottom: screenWidth * 0.02,
        left: screenWidth * 0.02,
        right: screenWidth * 0.02,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLessonListScreen(),
          const SizedBox(
            width: 8,
          ),
          _buildMemberListScreen(),
        ],
      ),
    );
  }

  Widget _buildMemberListScreen() {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedIndex = 1;
          });
        },
        child: Container(
          alignment: Alignment.center,
          height: 40,
          decoration: BoxDecoration(
            color: selectedIndex == 1
                ? primaryColor
                : Color.fromRGBO(240, 240, 240, 1),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Text(
            "メンバー",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: selectedIndex == 1 ? Colors.white : null,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLessonListScreen() {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedIndex = 0;
          });
        },
        child: Container(
          alignment: Alignment.center,
          height: 40,
          decoration: BoxDecoration(
            color: selectedIndex == 0
                ? primaryColor
                : Color.fromRGBO(240, 240, 240, 1),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Text(
            "レッスン",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: selectedIndex == 0 ? Colors.white : null,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, UserModel userModel) {
    List<Widget> drawerMenuItems = [
      _buildProfileImageDisplay(context, userModel),
    ];
    drawerMenuItems.addAll(ListTile.divideTiles(
      context: context,
      tiles: [
        _buildProfileTile(context),
        ListTile(title: Text('サロン設定')),
        _buildContactUsTile(context, userModel),
        _buildTermsTile(context),
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

  Widget _buildContactUsTile(BuildContext context, UserModel userModel) {
    return ListTile(
      title: Text('お問い合わせ'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return ContactUsScreen(userModel: userModel);
            },
          ),
        );
      },
    );
  }

  Widget _buildTermsTile(BuildContext context) {
    return ListTile(
      title: Text('利用規約'),
      onTap: () {
        Navigator.of(context).pushNamed('/terms');
      },
    );
  }

  Widget _buildProfileTile(BuildContext context) {
    return ListTile(
      title: Text('プロフィール'),
      onTap: () {
        Navigator.of(context).pushNamed('/user/profile/get');
      },
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
            FittedBox(
              fit: BoxFit.scaleDown,
              child: CircleAvatar(
                radius: MediaQuery.of(context).size.width * 0.15,
                foregroundImage: userModel.profile.imageUrl != null
                    ? NetworkImage(userModel.profile.imageUrl)
                    : AssetImage(
                        'assets/default_profile_image.png',
                      ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              userModel.profile.name,
              style: Theme.of(context).textTheme.headline3.copyWith(
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
      child: Text("ログアウト"),
    );
  }
}
