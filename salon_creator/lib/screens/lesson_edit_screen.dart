import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
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
import 'package:salon_creator/widgets/lesson_card.dart';
import 'package:salon_creator/widgets/custom_progress_indicator.dart';

class LessonEditScreen extends StatefulWidget {
  const LessonEditScreen({
    this.lessonInfo,
    Key key,
  }) : super(key: key);
  final LessonInfo lessonInfo;

  @override
  _LessonEditScreenState createState() => _LessonEditScreenState();
}

class _LessonEditScreenState extends State<LessonEditScreen> {
  final dbHandler = DbHandler();
  String path = "";
  bool _isPublished = false;
  bool _isFormFilled = false;
  bool _operationInProgress = false;
  bool _switchToNewThumbnail = false;
  bool _switchToNewMedia = false;
  String _storageThumbnailUrl;
  String _storageMediaUrl;
  List<Resource> _oldResourcesList = [];
  List<Resource> _newResourcesList = [];
  List<Resource> _currentResource = [];
  TextEditingController _categoriesController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _lessonNameController = TextEditingController();
  XFile _imageFile;
  XFile _mediaFile;
  XFile _thumbnailFile;
  Lesson _newLessonDetail;
  LessonInfo arguments;

  Future<XFile> _pickImage() async {
    final ImagePicker imagePicker = ImagePicker();
    XFile imageFile;
    try {
      final pickedFile =
          await imagePicker.pickImage(source: ImageSource.gallery);
      imageFile = pickedFile;
    } catch (e) {
      Exception(e);
    }
    return imageFile;
  }

  void _updateScreenContext() {
    var _hasProfileChanged = _mediaFile != null ||
        _thumbnailFile != null ||
        _categoriesController.text.isNotEmpty ||
        _descriptionController.text.isNotEmpty ||
        _newResourcesList.isNotEmpty ||
        _lessonNameController.text.isNotEmpty ||
        _isPublished != _isPublished;
    setState(() {
      _isFormFilled = _hasProfileChanged;
    });
  }

  _showBottomSheet() async {
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
                    _newLessonDetail.mediaUrl = _imageFile.path;
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
          _currentResource.add(Resource(
            displayName: result.files[i].name,
            url: File(result.paths[i]).path,
          ));
        });
      }
    } else {
      return;
    }
  }

  Future<void> getCurrentLessonDetails(LessonInfo lessonInfo) async {
    final data = await FirebaseFirestore.instance
        .collection(DbHandler.salonsCollection)
        .doc(widget.lessonInfo.salonId)
        .collection(DbHandler.lessonsCollection)
        .doc(widget.lessonInfo.lessonId)
        .get()
        .whenComplete(() => null);
    _newLessonDetail = Lesson.fromMap(data.data());
  }

  void _changeSwitch(bool e) => setState(() => _newLessonDetail.isPublish = e);

  Widget build(BuildContext context) {
    CollectionReference lesson = FirebaseFirestore.instance
        .collection(DbHandler.salonsCollection)
        .doc(widget.lessonInfo.salonId)
        .collection(DbHandler.lessonsCollection);
    return FutureBuilder<DocumentSnapshot>(
      future: lesson.doc(widget.lessonInfo.lessonId).get(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text("Something went wrong");
        }
        if (snapshot.hasData && !snapshot.data.exists) {
          return Text("Document does not exist");
        }
        if (snapshot.hasData) {
          if (_newLessonDetail == null) {
            _newLessonDetail = Lesson.fromMap(snapshot.data.data());
            _currentResource = [..._newLessonDetail.resources];
          }

          if (_newLessonDetail.mediaUrl != null && _storageMediaUrl == null) {
            _storageMediaUrl = _newLessonDetail.mediaUrl;
          }

          if (_newLessonDetail.thumbnailUrl != null &&
              _storageThumbnailUrl == null) {
            _storageThumbnailUrl = _newLessonDetail.thumbnailUrl;
          }

          return Scaffold(
            appBar: _operationInProgress ? null : _buildAppBar(context),
            body: _operationInProgress
                ? CustomProgressIndicator(title: "作成中です")
                : _buildLessonCreationInner(context),
          );
        }
        return Scaffold(
          body: CustomProgressIndicator(title: "読み込み中"),
        );
      },
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
                _buildSalonDetailForms(screenWidth, _newLessonDetail),
                _isFormFilled ? Container() : Text("空欄の部分があります"),
                SizedBox(height: 4),
                _buildLessonSaveButton(screenWidth, screenHeight),
                SizedBox(height: 24),
              ],
            ),
          ),
        ),
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
              await _updateLessonDetail().whenComplete(() {
                setState(() {
                  _operationInProgress = false;
                });
                Navigator.of(context).pushReplacementNamed('/home');
              });
            }
          : null,
      text: _newLessonDetail.isPublish ? "公開する" : "下書きを保存",
      width: screenWidth * 0.4,
      height: screenHeight * 0.06,
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
          child: _newLessonDetail.thumbnailUrl == null
              ? TextButton(
                  child: Icon(
                    Icons.add_circle,
                    size: 64,
                  ),
                  onPressed: () async {
                    _imageFile = await _pickImage();
                    setState(() {
                      _newLessonDetail.thumbnailUrl = _imageFile.path;
                      _switchToNewThumbnail = true;
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
                      image: _switchToNewThumbnail
                          ? FileImage(File(_newLessonDetail.thumbnailUrl))
                          : NetworkImage(_newLessonDetail.thumbnailUrl),
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
          child: _newLessonDetail.mediaUrl == null
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
                      image: _switchToNewMedia
                          ? FileImage(File(_newLessonDetail.mediaUrl))
                          : NetworkImage(_newLessonDetail.mediaUrl),
                    ),
                    _buildDeleteButton(_buildDeleteMediaFileConfirmationDialog),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildSalonDetailForms(double screenWidth, Lesson lesson) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.05,
      ),
      child: Column(
        children: [
          SizedBox(height: 16),
          _buildSalonNameForm(lesson.name != null ? lesson.name : ""),
          Divider(height: 32),
          _buildCategoryForm(lesson.category != null ? lesson.category : ""),
          Divider(height: 32),
          _buildContentForm(
              lesson.description != null ? lesson.description : ""),
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
              Switch(
                  value: _newLessonDetail.isPublish, onChanged: _changeSwitch),
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
        itemCount: _currentResource.length,
        itemBuilder: (BuildContext context, index) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildResourceFileRow(context, _currentResource[index], index),
            ],
          );
        },
      ),
    );
  }

  Widget _buildResourceFileRow(
      BuildContext context, Resource resource, int index) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            resource.displayName,
            style: Theme.of(context)
                .textTheme
                .headline4
                .copyWith(color: primaryColor),
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

  Widget _buildSalonNameForm(String hint) {
    return TextFieldWithLabel(
      maxLines: 1,
      onChanged: (_) => _updateScreenContext(),
      controller: _lessonNameController,
      title: "レッスン名",
      hintText: hint,
    );
  }

  Widget _buildCategoryForm(String hint) {
    return TextFieldWithLabel(
      maxLines: 1,
      onChanged: (_) => _updateScreenContext(),
      controller: _categoriesController,
      title: "カテゴリー",
      hintText: hint,
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return AppBar(
      iconTheme: IconThemeData(
        color: primaryColor, //change your color here
      ),
      title: Text("レッスン作成"),
    );
  }

  Widget _buildContentForm(String hint) {
    return Column(
      children: [
        CustomLabel(
          title: "説明文",
        ),
        SizedBox(
          height: 12,
        ),
        _buildDescriptionTextField(hint),
      ],
    );
  }

  Widget _buildDescriptionTextField(String hint) {
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
          hintText: hint,
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
          _currentResource.removeAt(index);
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
          _newLessonDetail.thumbnailUrl = null;
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
          _newLessonDetail.mediaUrl = null;
          _switchToNewMedia = true;
        });
        Navigator.of(context).pop();
      },
      rightButtonText: "取り消し",
      rightFunction: () {
        Navigator.of(context).pop();
      },
    );
  }

  Future _updateLessonDetail() async {
    final dbHandler = DbHandler();
    final storageHandler = StorageHandler();
    Lesson lesson = Lesson();
    if (_newLessonDetail.thumbnailUrl != _storageThumbnailUrl) {
      storageHandler.deleteImage(_storageThumbnailUrl);
      if (_newLessonDetail.mediaUrl != null) {
        lesson.mediaUrl = await storageHandler
            .uploadImageAndGetUrl(File(_newLessonDetail.mediaUrl));
      }
    } else {
      lesson.thumbnailUrl = _newLessonDetail.mediaUrl;
    }
    if (_storageThumbnailUrl != _newLessonDetail.thumbnailUrl) {
      storageHandler.deleteImage(_storageThumbnailUrl);
      if (_newLessonDetail.thumbnailUrl != null) {
        lesson.thumbnailUrl = await storageHandler
            .uploadImageAndGetUrl(File(_newLessonDetail.thumbnailUrl));
      } else {
        lesson.thumbnailUrl = _newLessonDetail.thumbnailUrl;
      }
    } else {
      lesson.mediaUrl = _newLessonDetail.mediaUrl;
    }

    lesson.resources = <Resource>[];
    lesson.salonId = widget.lessonInfo.salonId;
    lesson.name = _lessonNameController.text.isNotEmpty
        ? _lessonNameController.text
        : _newLessonDetail.name.isNotEmpty
            ? _newLessonDetail.name
            : null;
    lesson.category = _categoriesController.text.isNotEmpty
        ? _categoriesController.text
        : _newLessonDetail.category.isNotEmpty
            ? _newLessonDetail.category
            : null;
    lesson.description = _descriptionController.text.isNotEmpty
        ? _descriptionController.text
        : _newLessonDetail.description.isNotEmpty
            ? _newLessonDetail.description
            : null;
    lesson.isPublish = _newLessonDetail.isPublish;

    if (_newResourcesList != null) {
      // lesson.resources.addAll(
      //   _newLessonDetail.resources.map(
      //     (e) => Resource(displayName: e.displayName, url: e.url),
      //   ),
      // );
      for (int i = 0; i < _currentResource.length; i++) {
        final url = _currentResource[i].url;
        final displayName = _currentResource[i].displayName;
        if (!url.startsWith("https://firebasestorage.googleapis.com")) {
          final downloadedUrl =
              await storageHandler.uploadResourceAndGetUrl(File(url));
          assert(downloadedUrl.isNotEmpty);
          lesson.resources.add(Resource(
            displayName: displayName,
            url: downloadedUrl,
          ));
        } else {
          lesson.resources.add(_currentResource[i]);
        }
      }
    }
    _switchToNewMedia = false;
    _switchToNewThumbnail = false;
    await dbHandler.updateLesson(
        lesson, widget.lessonInfo.salonId, widget.lessonInfo.lessonId);
  }
}
