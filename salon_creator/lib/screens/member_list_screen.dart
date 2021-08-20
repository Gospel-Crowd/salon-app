import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:salon_creator/common/color.dart';
import 'package:salon_creator/firebase/database.dart';
import 'package:salon_creator/models/user_model.dart';

class MemberListScreen extends StatefulWidget {
  const MemberListScreen({Key key}) : super(key: key);

  @override
  _MemberListScreenState createState() => _MemberListScreenState();
}

class _MemberListScreenState extends State<MemberListScreen> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection(DbHandler.usersCollection)
          .where("salons",
              arrayContains: FirebaseAuth.instance.currentUser.email)
          .snapshots(),
      builder: (BuildContext context, snapshot) {
        if (!snapshot.hasData) {
          return LinearProgressIndicator();
        }
        if (snapshot.hasData) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
            child: Column(
              children: [
                _buildNumberOfMemberText(snapshot),
                Divider(
                  color: Color.fromRGBO(218, 218, 218, 1),
                  thickness: 1,
                  height: screenWidth * 0.05,
                ),
                _buildMemberAvatarGrid(snapshot),
              ],
            ),
          );
        }
        return Container();
      },
    );
  }

  Widget _buildMemberAvatarGrid(
      AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
    List<Widget> userList = [];
    //snapshot.data.
    snapshot.data.docs.map((e) {
      var userModel = UserModel.fromMap(e.data());

      userList.add(
        GestureDetector(
          onTap: () {},
          child: Container(
            child: Column(
              children: [
                _buildMemberIcon(e),
                SizedBox(height: 4),
                Text(
                  userModel.profile.name,
                  style: Theme.of(context).textTheme.headline5,
                ),
                Divider(
                  color: Color.fromRGBO(200, 200, 200, 1),
                  height: 16,
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
    return Expanded(
      child: GridView(
        shrinkWrap: true,
        gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: (MediaQuery.of(context).size.width) /
              (MediaQuery.of(context).size.height / 1.9),
        ),
        children: userList,
      ),
    );
  }

  Widget _buildMemberIcon(QueryDocumentSnapshot<Map<String, dynamic>> e) {
    return CircleAvatar(
      foregroundImage: e.data()['profile']['imageUrl'] != null
          ? NetworkImage(e.data()['profile']['imageUrl'])
          : AssetImage(
              'assets/default_profile_image.png',
            ),
      backgroundColor: Colors.black,
      radius: 32,
    );
  }

  Widget _buildNumberOfMemberText(
      AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
    return Row(
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(minHeight: 24.0, maxWidth: 250),
          child: Container(
            width: 120,
            height: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "メンバー: ",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  "${snapshot.data.size}人",
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
