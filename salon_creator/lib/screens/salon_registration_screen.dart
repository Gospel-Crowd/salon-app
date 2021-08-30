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
  bool _noFieldsEmpty = false;
  bool _submitInProgress = false;

  final contentController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneNumberController = TextEditingController();

  void _updateScreenState() {
    setState(() {
      _noFieldsEmpty = !(contentController.text.isEmpty ||
          firstNameController.text.isEmpty ||
          lastNameController.text.isEmpty ||
          phoneNumberController.text.isEmpty ||
          phoneNumberController.text.length < 10);
    });
  }

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
      body: Stack(
        alignment: AlignmentDirectional.topCenter,
        children: [
          _submitInProgress ? LinearProgressIndicator() : Container(),
          SafeArea(
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: SingleChildScrollView(
                reverse: true,
                child: Padding(
                  padding: EdgeInsets.only(bottom: bottomSpace),
                  child: Container(
                    margin:
                        EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                    child: _buildForms(screenHeight, screenWidth),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForms(double screenHeight, double screenWidth) => Column(
        children: [
          SizedBox(height: 16),
          _buildDescriptionContainer(screenHeight),
          SizedBox(height: 32),
          _buildFullNameForm(screenWidth, screenHeight),
          Divider(height: 32),
          _buildPhoneNumberForm(screenWidth, screenHeight),
          Divider(height: 32),
          _buildContentForm(screenWidth, screenHeight),
          Divider(height: 32),
          _noFieldsEmpty
              ? Container()
              : Text(
                  "未記入項目があります",
                  style: Theme.of(context)
                      .textTheme
                      .bodyText2
                      .copyWith(color: Colors.grey),
                ),
          _buildSubmitButton(screenWidth, screenHeight),
        ],
      );

  Widget _buildSubmitButton(double screenWidth, double screenHeight) =>
      CustomButton(
        text: "送信",
        width: screenWidth * 0.4,
        height: screenHeight * 0.05,
        function: _noFieldsEmpty
            ? () async {
                showCustomDialog(
                  content: "内容にお間違えがなければ、\n送信ボタンを押してください\n確認メールを送信します",
                  leftFunction: _noFieldsEmpty ? () => _submitForm() : null,
                  leftButtonText: "送信",
                  rightFunction: () => Navigator.pop(context),
                  rightButtonText: "取り消し",
                  context: context,
                );
              }
            : null,
      );

  Future _submitForm() async {
    setState(() {
      _submitInProgress = true;
    });

    await sendSalonRegistrationThanksMail(
      text: contentController.text,
      fullName: "${lastNameController.text} ${firstNameController.text}",
      phoneNumber: phoneNumberController.text,
    );

    setState(() {
      _submitInProgress = false;
    });

    Navigator.of(context).pushReplacementNamed('/registration_success');
  }

  Widget _buildContentForm(double screenWidth, double screenHeight) {
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
          SizedBox(height: 12),
          _buildContentTextField(),
        ],
      ),
    );
  }

  Widget _buildContentTextField() {
    return Container(
      height: 216,
      child: TextField(
        onChanged: (changedText) => _updateScreenState(),
        controller: contentController,
        textAlignVertical: TextAlignVertical.center,
        keyboardType: TextInputType.multiline,
        maxLength: 300,
        maxLines: 100,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(16, 8, 16, 8),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black, width: 0.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black, width: 0.5),
          ),
          hintText: "申し込み理由、用途等",
        ),
      ),
    );
  }

  Widget _buildFullNameForm(double screenWidth, double screenHeight) {
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
          SizedBox(height: 12),
          Row(
            children: [
              _buildNameTextField(lastNameController, "苗字", screenWidth * 0.35),
              SizedBox(width: screenWidth * 0.02),
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

  Widget _buildPhoneNumberForm(double screenWidth, double screenHeight) {
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
          SizedBox(height: 12),
          Container(
            height: 32,
            child: TextField(
              onChanged: (changedText) => _updateScreenState(),
              controller: phoneNumberController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black, width: 0.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black, width: 0.5),
                ),
                hintText: "電話番号",
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameTextField(
    TextEditingController controller,
    String label,
    double width,
  ) {
    return Container(
      width: width,
      height: 32,
      child: TextField(
        onChanged: (changedText) => _updateScreenState(),
        controller: controller,
        keyboardType: TextInputType.name,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(16, 8, 16, 8),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black, width: 0.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black, width: 0.5),
          ),
          hintText: label,
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
