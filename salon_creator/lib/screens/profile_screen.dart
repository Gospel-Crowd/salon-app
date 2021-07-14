import 'package:flutter/material.dart';
import 'package:salon_creator/common/color.dart';
import 'package:salon_creator/widgets/custom_button.dart';
import 'package:salon_creator/widgets/custom_label.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  TextEditingController descriptionController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;
    final screenWidth = mq.width;
    final screenHeight = mq.height;
    return Scaffold(
      appBar: AppBar(
        actions: [
          _buildSkipButton(),
        ],
        title: Text("プロフィール登録"),
      ),
      body: Container(
        margin: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.05,
        ),
        child: _buildProfileScreenInner(screenWidth, screenHeight),
      ),
    );
  }

  Widget _buildProfileScreenInner(double screenWidth, double screenHeight) {
    return Column(
      children: [
        SizedBox(
          height: 16,
        ),
        CustomLabel(
          title: "プロフィール画像",
        ),
        SizedBox(
          height: 16,
        ),
        CircleAvatar(
          backgroundColor: primaryColor,
          radius: 64,
        ),
        SizedBox(
          height: 16,
        ),
        Text('タップしてプロフィール画像を変更'),
        SizedBox(
          height: 8,
        ),
        Divider(),
        SizedBox(
          height: 16,
        ),
        _buildContentTextField(),
        Divider(
          height: 64,
        ),
        CustomButton(
          text: "完了",
          width: screenWidth * 0.4,
          height: screenHeight * 0.05,
        ),
      ],
    );
  }

  Widget _buildSkipButton() {
    return TextButton(
      onPressed: () {},
      child: Text(
        "スキップ",
        style: TextStyle(color: primaryColor),
      ),
    );
  }

  Widget _buildContentTextField() {
    return Column(
      children: [
        CustomLabel(
          title: '自己紹介文',
        ),
        SizedBox(
          height: 16,
        ),
        Container(
          height: 216,
          child: _buildTextField(),
        ),
      ],
    );
  }

  Widget _buildTextField() {
    return TextField(
      controller: descriptionController,
      textAlignVertical: TextAlignVertical.center,
      keyboardType: TextInputType.multiline,
      maxLines: 100,
      style: TextStyle(
        height: 1,
        fontSize: 16,
      ),
      decoration: InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(16, 8, 16, 8),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.black,
            width: 0.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.black,
            width: 0.5,
          ),
        ),
        hintText: "趣味、学びたいこと等",
      ),
    );
  }
}
