import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:salon_creator/common/color.dart';
import 'package:salon_creator/models/user_model.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({
    Key key,
    this.userModel,
  }) : super(key: key);

  final UserModel userModel;

  @override
  _ContactUsScreenState createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  TextEditingController questionController;
  bool _questionNotEmpty = false;
  String _selectedCategory = 'アプリ';
  bool _submitInProgress = false;
  bool _submitSuccess = false;

  @override
  void initState() {
    super.initState();
    questionController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('お問い合わせ'),
          iconTheme: IconThemeData(color: Colors.black),
        ),
        body: _buildBody(context),
      );

  Widget _buildBody(BuildContext context) => Padding(
        padding: const EdgeInsets.all(16),
        child: _submitInProgress
            ? Center(child: CircularProgressIndicator())
            : _submitSuccess
                ? _buildThankYouMessage(context)
                : Column(
                    children: [
                      SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'サロンやアプリに関するご要望、ご感想などがあればこちらのお問い合わせフォームでご記入ください。',
                          textAlign: TextAlign.center,
                        ),
                      ),
                      _buildCategorySelector(),
                      _buildQuestionInputDisplay(),
                      SizedBox(height: 16),
                      _buildSubmitButton(context),
                    ],
                  ),
      );

  Widget _buildThankYouMessage(BuildContext context) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Thank You!',
            style: Theme.of(context).textTheme.headline3,
          ),
          SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              'フィードバックありがとうございました\nこれは私たちのサービスを改善するのに役立ちます',
              textAlign: TextAlign.center,
            ),
          ),
        ],
      );

  Widget _buildSubmitButton(BuildContext context) => SizedBox(
        width: MediaQuery.of(context).size.width * 0.35,
        height: MediaQuery.of(context).size.width * 0.1,
        child: ElevatedButton(
          onPressed: _questionNotEmpty
              ? () async {
                  setState(() {
                    _submitInProgress = true;
                  });

                  await FirebaseFunctions.instance
                      .httpsCallable('sendFeedbackMailToGospelCrowd')
                      .call({
                    'mail': widget.userModel.email,
                    'name': widget.userModel.profile.name,
                    'category': _selectedCategory,
                    'content': questionController.text,
                  });

                  setState(() {
                    _submitInProgress = false;
                    _submitSuccess = true;
                  });
                }
              : null,
          child: Text('送信'),
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith((states) =>
                states.any((element) => element == MaterialState.disabled)
                    ? Colors.grey
                    : primaryColor),
          ),
        ),
      );

  void _updateScreenContext(String changedText) => setState(() {
        _questionNotEmpty = changedText.isNotEmpty;
      });

  Widget _buildCategorySelector() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16),
          Text(
            'カテゴリー',
            style: Theme.of(context).textTheme.headline3,
          ),
          SizedBox(height: 4),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              border: Border.all(width: 0.4),
            ),
            padding: const EdgeInsets.all(8),
            child: DropdownButton(
              isExpanded: true,
              underline: Container(height: 0),
              value: _selectedCategory,
              items: ['アプリ', 'サロン', 'ゴスペルクラウド', 'その他']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (_) {
                setState(() {
                  _selectedCategory = _;
                });
              },
            ),
          ),
        ],
      );

  Widget _buildQuestionInputDisplay() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16),
          Text(
            '内容',
            style: Theme.of(context).textTheme.headline3,
          ),
          SizedBox(height: 4),
          TextFormField(
            controller: questionController,
            onChanged: (_) => _updateScreenContext(_),
            maxLines: 10,
          ),
          SizedBox(height: 8),
        ],
      );
}
