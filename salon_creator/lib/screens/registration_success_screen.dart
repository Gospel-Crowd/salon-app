import 'package:flutter/material.dart';
import 'package:salon_creator/widgets/custom_button.dart';

class RegistrationSuccessScreen extends StatelessWidget {
  const RegistrationSuccessScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;
    final screenWidth = mq.width;
    final screenHeight = mq.height;
    return Scaffold(
      appBar: AppBar(
        title: Text("お申し込み完了"),
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: screenWidth * 0.07,
          ),
          alignment: Alignment.center,
          child: Column(
            children: [
              _buildRegistrationSuccessfulText(),
              _buildBackToLoginScreenButton(screenWidth, screenHeight, context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRegistrationSuccessfulText() {
    return Expanded(
      child: Center(
        child: Text(
          "ご申請ありがとうございます\n確認のメールの送付が完了しました\nご登録に差し当たり、数日以内に\n担当のものよりご連絡を差し上げますので\nご対応の程よろしくお願い致します",
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildBackToLoginScreenButton(
      double screenWidth, double screenHeight, BuildContext context) {
    return CustomButton(
      text: "ログイン画面",
      width: screenWidth * 0.4,
      height: screenHeight * 0.05,
      function: () {
        Navigator.of(context).pushNamed('/login');
      },
    );
  }
}
