import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:salon_creator/common/color.dart';
import 'package:salon_creator/firebase/database.dart';
import 'package:salon_creator/firebase/sign_in.dart';
import 'package:salon_creator/models/creator_model.dart';
import 'package:salon_creator/models/user_model.dart';
import 'package:salon_creator/screens/contact_us_screen.dart';
import 'package:salon_creator/screens/lesson_list_screen.dart';
import 'package:salon_creator/screens/member_list_screen.dart';
import 'package:salon_creator/screens/salon_creation_screen.dart';

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

        var creatorModel = CreatorModel.fromMap(snapshot.data.data());

        return DefaultTabController(
          length: 2,
          child: Scaffold(
            body: _buildHomePageInternal(context, creatorModel),
          ),
        );
      },
    );
  }

  Widget _buildHomePageInternal(BuildContext context, CreatorModel userModel) =>
      userModel.salonId == null
          ? Scaffold(
              appBar: AppBar(
                title: Text('ホーム'),
                iconTheme: IconThemeData(color: Colors.black),
              ),
              drawer: _buildDrawer(context, userModel),
              body: _buildSalonNotYetCreatedView(context, userModel),
            )
          : DefaultTabController(
              length: 2,
              child: Scaffold(
                appBar: AppBar(
                  bottom: TabBar(
                    tabs: [
                      Tab(text: 'レッスン'),
                      Tab(text: 'メンバー'),
                    ],
                  ),
                  title: Text('ホーム'),
                  iconTheme: IconThemeData(color: Colors.black),
                ),
                drawer: _buildDrawer(context, userModel),
                body: TabBarView(
                  children: [
                    LessonListScreen(),
                    MemberListScreen(),
                  ],
                ),
              ),
            );

  Widget _buildSalonNotYetCreatedView(
    BuildContext context,
    UserModel userModel,
  ) =>
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'サロンがまだありません\n下のボタンからサロンを作りましょう',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return SalonCreationScreen(userModel: userModel);
                    },
                  ),
                );
              },
              child: Text('サロンを作る'),
            ),
          ],
        ),
      );

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
