import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:salon_creator/common/color.dart';
import 'package:salon_creator/firebase/database.dart';
import 'package:salon_creator/models/user_model.dart';
import 'package:salon_creator/screens/user_profile_edit_screen.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({Key key}) : super(key: key);

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
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

        return _buildUserProfileScreenInternal(context, userModel);
      },
    );
  }

  Widget _buildUserProfileScreenInternal(
    BuildContext context,
    UserModel userModel,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: Text('プロフィール'),
        iconTheme: IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return UserProfileEditScreen(userModel: userModel);
                  },
                ),
              );
            },
            icon: Icon(Icons.edit),
          ),
        ],
      ),
      body: _buildBody(context, userModel),
    );
  }

  Widget _buildBody(BuildContext context, UserModel userModel) {
    List<Widget> profileItems = [
      SizedBox(height: 16),
      _buildProfileImageDisplay(context, userModel),
      SizedBox(height: 16),
      Text(
        userModel.profile.name,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
      ),
    ];
    profileItems.addAll(ListTile.divideTiles(
      context: context,
      tiles: [
        _buildNameDisplay(userModel),
        _buildEmailDisplay(userModel),
        _buildAboutMeDisplay(userModel),
      ],
    ).toList());

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        children: profileItems,
      ),
    );
  }

  Widget _buildAboutMeDisplay(UserModel userModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8),
        Text(
          'プロフィール',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: primaryColor,
          ),
        ),
        SizedBox(height: 4),
        Text(
          userModel.profile.aboutMeText ?? 'Write something about yourself!',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
        ),
        SizedBox(height: 8),
      ],
    );
  }

  Widget _buildEmailDisplay(UserModel userModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8),
        Text(
          'メールアドレス',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: primaryColor,
          ),
        ),
        SizedBox(height: 4),
        Text(
          userModel.email,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
        ),
        SizedBox(height: 8),
      ],
    );
  }

  Widget _buildNameDisplay(UserModel userModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8),
        Text(
          '名前',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: primaryColor,
          ),
        ),
        SizedBox(height: 4),
        Text(
          userModel.profile.name,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
        ),
        SizedBox(height: 8),
      ],
    );
  }

  Widget _buildProfileImageDisplay(BuildContext context, UserModel userModel) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: CircleAvatar(
        radius: MediaQuery.of(context).size.width * 0.25,
        foregroundImage: userModel.profile.imageUrl != null
            ? NetworkImage(userModel.profile.imageUrl)
            : AssetImage(
                'assets/default_profile_image.png',
              ),
      ),
    );
  }
}
