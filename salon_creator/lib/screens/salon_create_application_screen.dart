import 'package:flutter/material.dart';
import 'package:salon_creator/common/email.dart';
import 'package:salon_creator/widgets/custom_button.dart';
import 'package:salon_creator/widgets/custom_dialog.dart';
import 'package:salon_creator/widgets/custom_label.dart';

class SalonRegistrationScreen extends StatefulWidget {
  const SalonRegistrationScreen({Key key}) : super(key: key);

  @override
  _SalonRegistrationScreenState createState() =>
      _SalonRegistrationScreenState();
}

class _SalonRegistrationScreenState extends State<SalonRegistrationScreen> {
  final contentController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneNumberController = TextEditingController();

  bool _noFieldsEmpty() => !(contentController.text.isEmpty ||
      firstNameController.text.isEmpty ||
      lastNameController.text.isEmpty ||
      phoneNumberController.text.isEmpty);

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;
    final screenWidth = mq.width;
    final screenHeight = mq.height;
    final bottomSpace = MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text("登録申請"),
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: SingleChildScrollView(
            reverse: true,
            child: Padding(
              padding: EdgeInsets.only(bottom: bottomSpace),
              child: Container(
                margin: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.05,
                ),
                child: _buildForms(screenHeight, screenWidth),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForms(double screenHeight, double screenWidth) {
    return Column(
      children: [
        const SizedBox(height: 16),
        _buildDescriptionContainer(screenHeight),
        const SizedBox(height: 32),
        _buildFullNameForm(screenWidth, screenHeight),
        const Divider(height: 32),
        _buildPhoneNumberForm(screenWidth, screenHeight),
        const Divider(
          height: 32,
        ),
        _buildContentForm(screenWidth, screenHeight),
        const Divider(
          height: 32,
        ),
        _noFieldsEmpty()
            ? Container()
            : Text(
                "未記入項目があります",
                style: TextStyle(color: Colors.grey),
              ),
        _buildSubmitButton(screenWidth, screenHeight),
      ],
    );
  }

  Widget _buildSubmitButton(double screenWidth, double screenHeight) {
    return CustomButton(
      text: "送信",
      width: screenWidth * 0.4,
      height: screenHeight * 0.05,
      function: _noFieldsEmpty()
          ? () async {
              showCustomDialog(
                content: "内容にお間違えがなければ、\n送信ボタンを押してください\n確認メールを送信します",
                leftFunction: _noFieldsEmpty()
                    ? () {
                        sendMail(
                          text: contentController.text,
                          name: lastNameController.text,
                          fullName:
                              "${lastNameController.text} ${firstNameController.text}",
                          subject: "ご登録申請ありがとうございます",
                          phoneNumber: phoneNumberController.text,
                        ).whenComplete(
                          () => Navigator.of(context)
                              .pushReplacementNamed('/screen'),
                        );
                      }
                    : null,
                leftButtonText: "送信",
                rightFunction: () {
                  Navigator.pop(context);
                },
                rightButtonText: "取り消し",
                context: context,
              );
            }
          : null,
    );
  }

  Widget _buildContentForm(
    double screenWidth,
    double screenHeight,
  ) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomLabel(
            title: "お申し込みフォーム",
            color: Colors.black,
            width: screenWidth * 0.03,
            height: screenHeight * 0.03,
          ),
          const SizedBox(
            height: 12,
          ),
          _buildContentTextField(),
        ],
      ),
    );
  }

  Widget _buildContentTextField() {
    return Container(
      height: 216,
      child: TextField(
        controller: contentController,
        textAlignVertical: TextAlignVertical.center,
        keyboardType: TextInputType.multiline,
        maxLength: 300,
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
          hintText: "申し込み理由、用途等",
        ),
      ),
    );
  }

  Widget _buildFullNameForm(
    double screenWidth,
    double screenHeight,
  ) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomLabel(
            title: "名前",
            color: Colors.black,
            width: screenWidth * 0.03,
            height: screenHeight * 0.03,
          ),
          const SizedBox(
            height: 12,
          ),
          Row(
            children: [
              _buildNameTextField(
                lastNameController,
                "苗字",
                screenWidth * 0.35,
              ),
              SizedBox(
                width: screenWidth * 0.02,
              ),
              _buildNameTextField(
                firstNameController,
                "名前",
                screenWidth * 0.35,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneNumberForm(
    double screenWidth,
    double screenHeight,
  ) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomLabel(
            title: "電話番号",
            color: Colors.black,
            width: screenWidth * 0.03,
            height: screenHeight * 0.03,
          ),
          const SizedBox(
            height: 12,
          ),
          _buildPhoneNumberTextField(),
        ],
      ),
    );
  }

  Widget _buildPhoneNumberTextField() {
    return Container(
      height: 32,
      child: TextField(
        controller: phoneNumberController,
        keyboardType: TextInputType.phone,
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
          hintText: "電話番号",
        ),
      ),
    );
  }

  Widget _buildNameTextField(
    TextEditingController controller,
    String lable,
    double width,
  ) {
    return Container(
      width: width,
      height: 32,
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.name,
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
          hintText: lable,
        ),
      ),
    );
  }

  Widget _buildDescriptionContainer(double screenHeight) {
    return Container(
      alignment: Alignment.center,
      width: screenHeight * 0.35,
      child: Text(
        "ご入力頂いた内容とお電話の応答内容を元に\n審査します。スムーズな審査のために、\n以下のフォームにてご利用目的や、\nサロンの内容を詳細にご記述願います。",
        textAlign: TextAlign.center,
      ),
    );
  }
}
