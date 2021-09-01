// ignore: unused_import
import 'dart:ffi';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:salon_creator/common/color.dart';
import 'package:salon_creator/common/image_picker.dart';
import 'package:salon_creator/firebase/database.dart';
import 'package:salon_creator/models/lesson.dart';
import 'package:salon_creator/widgets/custom_button.dart';
import 'package:salon_creator/widgets/custom_dialog.dart';
import 'package:salon_creator/widgets/custom_label.dart';
import 'package:salon_creator/widgets/custom_textfield.dart';

class LessonCreationScreen extends StatefulWidget {
  const LessonCreationScreen({Key key}) : super(key: key);

  @override
  _LessonCreationScreenState createState() => _LessonCreationScreenState();
}

class _LessonCreationScreenState extends State<LessonCreationScreen> {
  bool _publish = false;
  bool isFormFilled = false;
  bool operationInProgress = false;
  List<File> resources = [];
  List<String> resourcesList = [];
  TextEditingController categoriesController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController lessonNameController = TextEditingController();
  XFile _imageFile;
  XFile _mediaFile;
  XFile thumbnailFile;
  XFile image;

  void _updateScreenContext() {
    var _hasProfileChanged = _mediaFile != null ||
        thumbnailFile != null ||
        categoriesController.text.isNotEmpty ||
        descriptionController.text.isNotEmpty ||
        resourcesList.isNotEmpty ||
        lessonNameController.text.isNotEmpty;
    setState(() {
      isFormFilled = _hasProfileChanged;
    });
  }

  void _changeSwtich(bool e) => setState(() => _publish = e);

  void _showBottomSheet() async {
    return await showModalBottomSheet(
      context: context,
      builder: (_) {
        return Container(
          height: 200,
          child: Column(
            children: [
              ListTile(
                title: Text("写真を選ぶ"),
                onTap: () async {
                  final _imageFile = await imagePicker();
                  setState(() {
                    _mediaFile = _imageFile;
                  });
                  Navigator.pop(context);
                },
              ),
              Divider(height: 0),
              ListTile(
                title: Text("動画から選ぶ"),
              ),
              Divider(height: 0),
            ],
          ),
        );
      },
    );
  }

  void _filePicker() async {
    FilePickerResult result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null) {
      for (int i = 0; i < result.count; i++) {
        setState(() {
          resourcesList.add(result.names[i]);
          resources.add(File(result.paths[i]));
          print(resources[i]);
        });
      }
    } else {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: operationInProgress ? null : _buildAppBar(context),
      body: operationInProgress
          ? _buildCreateInProgressScreen()
          : _buildLessonCreationInner(context),
    );
  }

  Widget _buildLessonCreationInner(BuildContext context) {
    final mq = MediaQuery.of(context).size;
    final screenWidth = mq.width;
    final screenHeight = mq.height;
    return SafeArea(
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          child: Container(
            child: Column(
              children: [
                SizedBox(height: 8),
                _buildMediaPreviewerDivider("サムネイル"),
                SizedBox(height: 8),
                _buildThumbnailFileContainer(),
                SizedBox(height: 8),
                _buildMediaPreviewerDivider("動画・写真"),
                SizedBox(height: 8),
                _buildMediaFileContainer(),
                _buildSalonDetailForms(screenWidth),
                isFormFilled ? Container() : Text("空欄の部分があります"),
                _buildLessonSaveButton(screenWidth, screenHeight),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCreateInProgressScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "作成中です",
            style: TextStyle(
              color: primaryColor,
              fontSize: 24,
            ),
          ),
          SizedBox(
            height: 16,
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.3,
            height: MediaQuery.of(context).size.width * 0.3,
            child: CircularProgressIndicator(
              color: primaryColor,
              strokeWidth: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaPreviewerDivider(String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(text),
      ],
    );
  }

  delete(index) {
    setState(() {
      resourcesList.removeAt(index);
    });
    Navigator.pop(context);
  }

  Widget _buildLessonSaveButton(double screenWidth, double screenHeight) {
    return CustomButton(
      function: isFormFilled
          ? () async {
              setState(() {
                operationInProgress = true;
              });
              await _saveLessonDetail().whenComplete(() {
                setState(() {
                  operationInProgress = false;
                });
                Navigator.of(context).pushReplacementNamed('/home');
              });
            }
          : null,
      text: _publish ? "保存" : "下書きを保存",
      width: screenWidth * 0.4,
      height: screenHeight * 0.05,
    );
  }

  Widget _buildThumbnailFileContainer() {
    final mq = MediaQuery.of(context).size;
    final screenWidth = mq.width;
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: screenWidth, minHeight: 50),
      child: Container(
        color: Color.fromRGBO(195, 195, 195, 0.3),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: thumbnailFile == null
              ? TextButton(
                  child: Icon(
                    Icons.add_circle,
                    size: 64,
                    color: primaryColor,
                  ),
                  onPressed: () async {
                    _imageFile = await imagePicker();
                    setState(() {
                      thumbnailFile = _imageFile;
                    });
                  },
                )
              : Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Image(
                      height: screenWidth * 0.563,
                      width: screenWidth,
                      fit: BoxFit.cover,
                      image: FileImage(
                        File(
                          thumbnailFile.path,
                        ),
                      ),
                    ),
                    _buildDeleteButton(_buildDeleteThumbnailConfirmationDialog),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildMediaFileContainer() {
    final mq = MediaQuery.of(context).size;
    final screenWidth = mq.width;
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: screenWidth, minHeight: 50),
      child: Container(
        color: Color.fromRGBO(195, 195, 195, 0.3),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: _mediaFile == null
              ? TextButton(
                  child: Icon(
                    Icons.add_circle,
                    size: 64,
                    color: primaryColor,
                  ),
                  onPressed: _showBottomSheet,
                )
              : Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Image(
                      height: screenWidth * 0.563,
                      width: screenWidth,
                      fit: BoxFit.cover,
                      image: FileImage(
                        File(
                          _mediaFile.path,
                        ),
                      ),
                    ),
                    _buildDeleteButton(_buildDeleteMediaFileConfirmationDialog),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildSalonDetailForms(double screenWidth) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.05,
      ),
      child: Column(
        children: [
          SizedBox(height: 16),
          _buildSalonNameForm(),
          Divider(height: 32),
          _buildCategoryForm(),
          Divider(height: 32),
          _buildContentForm(),
          Divider(height: 32),
          _buildResourceFileUploadForm(),
          Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                "公開",
                style: Theme.of(context).textTheme.headline3,
              ),
              Switch(value: _publish, onChanged: _changeSwtich),
            ],
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildResourceFileUploadForm() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomLabel(title: "リソース"),
            ElevatedButton(
              onPressed: () {
                _filePicker();
              },
              child: Text("リソース"),
            ),
          ],
        ),
        _buildResourceFileList(),
      ],
    );
  }

  Widget _buildResourceFileList() {
    return Container(
      height: 200,
      child: ListView.builder(
        itemCount: resourcesList.length,
        itemBuilder: (BuildContext context, index) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildResourceFileRow(index, context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildResourceFileRow(int index, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            resourcesList[index],
            style: Theme.of(context).textTheme.headline4,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        IconButton(
          onPressed: () {
            _buildDeleteResourceConfirmationDialog(index);
          },
          icon: Icon(Icons.delete),
        ),
      ],
    );
  }

  Widget _buildSalonNameForm() {
    return TextFieldWithLabel(
      maxLines: 1,
      onChanged: (_) => _updateScreenContext(),
      controller: lessonNameController,
      title: "レッスン名",
      hintText: "ゴスペルピアノ",
    );
  }

  Widget _buildCategoryForm() {
    return TextFieldWithLabel(
      maxLines: 1,
      onChanged: (_) => _updateScreenContext(),
      controller: categoriesController,
      title: "カテゴリー",
      hintText: "ゴスペル、ピアノ、ギター等",
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text("レッスン作成"),
    );
  }

  Widget _buildContentForm() {
    return Column(
      children: [
        CustomLabel(
          title: "説明文",
        ),
        SizedBox(
          height: 12,
        ),
        _buildDescriptionTextField(),
      ],
    );
  }

  Widget _buildDescriptionTextField() {
    return Container(
      height: 216,
      child: TextField(
        onChanged: (_) => _updateScreenContext(),
        controller: descriptionController,
        textAlignVertical: TextAlignVertical.center,
        keyboardType: TextInputType.multiline,
        maxLength: 300,
        maxLines: 100,
        style: TextStyle(
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
          hintText: "レッスン内容",
        ),
      ),
    );
  }

  Widget _buildDeleteButton(VoidCallback function) {
    return Container(
      width: 40,
      height: 40,
      margin: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: primaryColor,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: function,
        icon: Icon(
          Icons.close,
          color: Colors.white,
        ),
      ),
    );
  }

  _buildDeleteResourceConfirmationDialog(index) {
    return showCustomDialog(
      context: context,
      title: Text(
        "本当に削除しますか?",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 18,
        ),
      ),
      content: "選択されているファイルが削除されます",
      leftButtonText: "削除する",
      leftFunction: () {
        setState(() {
          resourcesList.removeAt(index);
        });

        Navigator.pop(context);
      },
      rightButtonText: "取り消し",
      rightFunction: () {
        Navigator.of(context).pop();
      },
    );
  }

  removeFile() {
    setState(() {
      thumbnailFile = null;
    });
  }

  _buildDeleteThumbnailConfirmationDialog() async {
    return showCustomDialog(
      context: context,
      title: Text(
        "本当に削除しますか?",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 18,
        ),
      ),
      content: "サムネイルを削除しますか？",
      leftButtonText: "削除する",
      leftFunction: () {
        setState(() {
          thumbnailFile = null;
        });
        Navigator.of(context).pop();
      },
      rightButtonText: "取り消し",
      rightFunction: () {
        Navigator.of(context).pop();
      },
    );
  }

  _buildDeleteMediaFileConfirmationDialog() async {
    return showCustomDialog(
      context: context,
      title: Text(
        "本当に削除しますか?",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 18,
        ),
      ),
      content: "選択されている画像・動画が削除されます",
      leftButtonText: "削除する",
      leftFunction: () {
        setState(() {
          _mediaFile = null;
        });

        Navigator.of(context).pop();
      },
      rightButtonText: "取り消し",
      rightFunction: () {
        Navigator.of(context).pop();
      },
    );
  }

  Future _saveLessonDetail() async {
    final dbHandler = DbHandler();
    final storageHandler = StorageHandler();
    Lesson lesson = Lesson();
    lesson.resources = [];
    lesson.salonId = "XytREh97Xs9pJvnI13JS";
    lesson.name = lessonNameController?.text;
    lesson.category = categoriesController?.text;
    lesson.description = descriptionController?.text;
    lesson.publish = _publish;
    lesson.media = _mediaFile != null
        ? await storageHandler.uploadImageAndGetUrl(File(_mediaFile.path))
        : "";

    lesson.thumbnail = thumbnailFile != null
        ? await storageHandler.uploadImageAndGetUrl(File(thumbnailFile.path))
        : "";
    lesson.resources = [];

    if (resourcesList != null) {
      for (int i = 0; i < resourcesList.length; i++) {
        lesson.resources.add(
          await storageHandler.uploadResourceAndGetUrl(
            File(resources[i].path),
          ),
        );
        print(resourcesList[i]);
      }
    }
    await dbHandler.addLesson(lesson, "XytREh97Xs9pJvnI13JS");
  }
}
