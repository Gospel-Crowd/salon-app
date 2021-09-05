// ignore: unused_import
import 'dart:ffi';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:salon_creator/common/color.dart';
import 'package:salon_creator/firebase/database.dart';
import 'package:salon_creator/models/lesson.dart';
import 'package:salon_creator/models/resource.dart';
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
  bool _isPublished = false;
  bool _isFormFilled = false;
  bool _operationInProgress = false;
  List<File> _resources = [];
  List<String> _resourcesList = [];
  TextEditingController _categoriesController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _lessonNameController = TextEditingController();
  XFile _imageFile;
  XFile _mediaFile;
  XFile _thumbnailFile;

  Future<XFile> _pickImage() async {
    final ImagePicker imagePicker = ImagePicker();
    XFile imageFile;
    try {
      final pickedFile =
          await imagePicker.pickImage(source: ImageSource.gallery);
      imageFile = pickedFile;
    } catch (e) {
      print(e);
    }
    return imageFile;
  }

  void _updateScreenContext() {
    var _hasProfileChanged = _mediaFile != null ||
        _thumbnailFile != null ||
        _categoriesController.text.isNotEmpty ||
        _descriptionController.text.isNotEmpty ||
        _resourcesList.isNotEmpty ||
        _lessonNameController.text.isNotEmpty;
    setState(() {
      _isFormFilled = _hasProfileChanged;
    });
  }

  void _changeSwitch(bool e) => setState(() => _isPublished = e);

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
                  final _imageFile = await _pickImage();
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

  void _pickFile() async {
    FilePickerResult result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null) {
      for (int i = 0; i < result.count; i++) {
        setState(() {
          _resourcesList.add(result.names[i]);
          _resources.add(File(result.paths[i]));
        });
      }
    } else {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _operationInProgress ? null : _buildAppBar(context),
      body: _operationInProgress
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
                _isFormFilled ? Container() : Text("空欄の部分があります"),
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
          Text("作成中です", style: Theme.of(context).textTheme.headline3),
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

  Widget _buildLessonSaveButton(double screenWidth, double screenHeight) {
    return CustomButton(
      function: _isFormFilled
          ? () async {
              setState(() {
                _operationInProgress = true;
              });
              await _saveLessonDetail().whenComplete(() {
                setState(() {
                  _operationInProgress = false;
                });
                Navigator.of(context).pushReplacementNamed('/home');
              });
            }
          : null,
      text: _isPublished ? "保存" : "下書きを保存",
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
          child: _thumbnailFile == null
              ? TextButton(
                  child: Icon(
                    Icons.add_circle,
                    size: 64,
                  ),
                  onPressed: () async {
                    _imageFile = await _pickImage();
                    setState(() {
                      _thumbnailFile = _imageFile;
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
                          _thumbnailFile.path,
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
              Switch(value: _isPublished, onChanged: _changeSwitch),
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
                _pickFile();
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
        itemCount: _resourcesList.length,
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
            _resourcesList[index],
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
      controller: _lessonNameController,
      title: "レッスン名",
      hintText: "ゴスペルピアノ",
    );
  }

  Widget _buildCategoryForm() {
    return TextFieldWithLabel(
      maxLines: 1,
      onChanged: (_) => _updateScreenContext(),
      controller: _categoriesController,
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
        controller: _descriptionController,
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
          _resourcesList.removeAt(index);
        });

        Navigator.pop(context);
      },
      rightButtonText: "取り消し",
      rightFunction: () {
        Navigator.of(context).pop();
      },
    );
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
          _thumbnailFile = null;
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
    lesson.resources = _resources.isNotEmpty ? [] : null;
    lesson.salonId = "XytREh97Xs9pJvnI13JS";
    lesson.name = _lessonNameController.text.isNotEmpty
        ? _lessonNameController.text
        : null;
    lesson.category = _categoriesController.text.isNotEmpty
        ? _categoriesController.text
        : null;
    lesson.description = _descriptionController.text.isNotEmpty
        ? _descriptionController.text
        : null;
    lesson.isPublish = _isPublished;
    lesson.mediaUrl = _mediaFile != null
        ? await storageHandler.uploadImageAndGetUrl(File(_mediaFile.path))
        : null;

    lesson.thumbnailUrl = _thumbnailFile != null
        ? await storageHandler.uploadImageAndGetUrl(File(_thumbnailFile.path))
        : null;

    if (_resourcesList != null) {
      for (int i = 0; i < _resourcesList.length; i++) {
        lesson.resources.add(
          Resource(
            displayName: _resourcesList[i],
            url: await storageHandler.uploadResourceAndGetUrl(
              File(_resources[i].path),
            ),
          ).toMap(),
        );
      }
    }
    await dbHandler.addLesson(lesson, "XytREh97Xs9pJvnI13JS");
  }
}
