import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:salon_creator/common/color.dart';
import 'package:salon_creator/firebase/database.dart';
import 'package:salon_creator/models/salon.dart';
import 'package:salon_creator/widgets/custom_button.dart';
import 'package:salon_creator/widgets/custom_dialog.dart';
import 'package:salon_creator/widgets/custom_label.dart';
import 'package:salon_creator/widgets/custom_textfield.dart';
import 'package:uuid/uuid.dart';

class SalonCreationScreen extends StatefulWidget {
  const SalonCreationScreen({Key key}) : super(key: key);

  @override
  _SalonCreationScreenState createState() => _SalonCreationScreenState();
}

class _SalonCreationScreenState extends State<SalonCreationScreen> {
  bool isFilled = false;
  bool inProgress = false;
  final ImagePicker imagePicker = ImagePicker();
  int index = 0;
  List<XFile> _imageFiles = [];

  ScrollController _scrollController = ScrollController();
  TextEditingController categoriesController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController salonNameController = TextEditingController();
  XFile image;

  void _updateScreenContext() {
    var _hasProfileChanged = salonNameController.text.isNotEmpty &&
        categoriesController.text.isNotEmpty &&
        descriptionController.text.isNotEmpty &&
        priceController.text.isNotEmpty &&
        _imageFiles.isNotEmpty;
    print(salonNameController.text.isNotEmpty);

    print(priceController.text.isNotEmpty);
    print(descriptionController.text.isNotEmpty);
    print(categoriesController.text.isNotEmpty);
    print(_imageFiles.isNotEmpty);
    print(isFilled);

    setState(() {
      isFilled = _hasProfileChanged;
    });
  }

  _scrollToRight() {
    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;
    final screenWidth = mq.width;
    final screenHeight = mq.height;

    return Scaffold(
      appBar: inProgress ? null : _buildAppBar(context),
      body: inProgress
          ? _buildCreatingProgressScreen()
          : SafeArea(
              child: GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                },
                child: SingleChildScrollView(
                  child: Container(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 8,
                        ),
                        _buildMediaPreviewerDivider(),
                        SizedBox(
                          height: 8,
                        ),
                        _buildMediaPreviewer(
                            screenHeight, screenWidth, context),
                        _buildMediaPane(context),
                        _buildSalonDetailForms(screenWidth),
                        isFilled ? Container() : Text("空欄の部分があります"),
                        _buildSalonSaveButton(screenWidth, screenHeight),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Center _buildCreatingProgressScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "作成中です",
            style: TextStyle(
              color: primaryColor,
            ),
          ),
          SizedBox(
            height: 16,
          ),
          CircularProgressIndicator(),
        ],
      ),
    );
  }

  Widget _buildMediaPreviewerDivider() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("プレビュー用メディア"),
      ],
    );
  }

  Widget _buildSalonSaveButton(double screenWidth, double screenHeight) {
    return CustomButton(
      function: isFilled
          ? () async {
              setState(() {
                inProgress = true;
              });
              await saveSalonDetail().whenComplete(() {
                setState(() {
                  inProgress = false;
                });
                Navigator.of(context).pushReplacementNamed('/home');
              });
            }
          : null,
      text: "保存",
      width: screenWidth * 0.4,
      height: screenHeight * 0.05,
    );
  }

  Widget _buildMediaPane(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color.fromRGBO(195, 195, 195, 0.3),
      ),
      margin: EdgeInsets.only(top: 8),
      height: 48,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _buildMediaPaneAddButton(context),
            _imageFiles != null ? _buildMediaPaneIconList() : Container(),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaPaneIconList() {
    return Expanded(
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        controller: _scrollController,
        itemCount: _imageFiles.length,
        itemBuilder: (BuildContext context, i) {
          return Stack(
            alignment: Alignment.center,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: _buildMediaPaneIcon(i),
              ),
              index == i
                  ? Container(
                      width: 80,
                      height: 48,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: primaryColor,
                          width: 3,
                        ),
                      ),
                    )
                  : Container(
                      width: 80,
                      height: 48,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            index = i;
                          });
                        },
                      ),
                    ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMediaPaneIcon(int i) {
    return Stack(
      alignment: Alignment.topRight,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      children: [
        Image(
          fit: BoxFit.cover,
          width: 80,
          height: 45,
          image: FileImage(
            File(
              _imageFiles[i].path,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMediaPaneAddButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: primaryColor,
        border: Border.all(
          color: primaryColor,
          width: 2,
        ),
      ),
      child: IconButton(
        alignment: Alignment.center,
        icon: Icon(
          Icons.add_circle,
          size: 28,
          color: Colors.white,
        ),
        onPressed: () {
          showBottomSheet(context);
        },
      ),
    );
  }

  Widget _buildMediaPreviewer(
      double screenHeight, double screenWidth, BuildContext context) {
    return Container(
      color: Color.fromRGBO(195, 195, 195, 0.3),
      height: screenWidth * 0.563,
      width: screenWidth,
      child: _imageFiles.isEmpty
          ? TextButton(
              child: Icon(
                Icons.add_circle,
                size: 64,
                color: primaryColor,
              ),
              onPressed: () {
                showBottomSheet(context);
              },
            )
          : Stack(
              alignment: Alignment.topLeft,
              children: [
                Image(
                  height: screenWidth * 0.563,
                  width: screenWidth,
                  fit: BoxFit.cover,
                  image: FileImage(
                    File(
                      _imageFiles[index].path,
                    ),
                  ),
                ),
                _buildDeleteButton(context),
              ],
            ),
    );
  }

  Widget _buildDeleteButton(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      margin: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: primaryColor,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: () {
          _buildDeleteConfirmationDialog(context);
        },
        icon: Icon(
          Icons.close,
          color: Colors.white,
        ),
      ),
    );
  }

  void _buildDeleteConfirmationDialog(BuildContext context) {
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
          _imageFiles.removeAt(index);
          index -= 1;
        });
        Navigator.of(context).pop();
      },
      rightButtonText: "取り消し",
      rightFunction: () {
        Navigator.of(context).pop();
      },
    );
  }

  void showBottomSheet(BuildContext context) async {
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
                  await _storeMediaFiles(context);
                },
              ),
              Divider(
                height: 0,
              ),
              ListTile(
                title: Text("動画から選ぶ"),
              ),
              Divider(
                height: 0,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSalonDetailForms(double screenWidth) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.05,
      ),
      child: Column(
        children: [
          SizedBox(
            height: 16,
          ),
          _buildSalonNameForm(),
          Divider(
            height: 32,
          ),
          _buildCategoryForm(),
          Divider(
            height: 32,
          ),
          _buildContentForm(),
          _buildSalonPriceForm(),
          Divider(
            height: 40,
          )
        ],
      ),
    );
  }

  Widget _buildSalonNameForm() {
    return TextFieldWithLabel(
      onChanged: (_) => _updateScreenContext(),
      controller: salonNameController,
      title: "サロン名",
      hintText: "ゴスペルサロン",
    );
  }

  Widget _buildCategoryForm() {
    return TextFieldWithLabel(
      onChanged: (_) => _updateScreenContext(),
      controller: categoriesController,
      title: "カテゴリー",
      hintText: "ゴスペル、ピアノ、ギター等",
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return AppBar(
      actions: [
        TextButton(
          onPressed: () {
            final dbHandler = DbHandler();
            dbHandler.addSalon(
              Salon(
                owner: FirebaseAuth.instance.currentUser.email,
              ),
            );
            Navigator.of(context).pushReplacementNamed('/home');
          },
          child: Text("スキップ"),
        ),
      ],
      title: Text("サロン作成"),
    );
  }

  Widget _buildSalonPriceForm() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        TextFieldWithLabel(
          onChanged: (_) => _updateScreenContext(),
          controller: priceController,
          title: "月額料金",
          hintText: "1000",
          width: 100,
          keyboardType: TextInputType.number,
        ),
        SizedBox(
          width: 8,
        ),
        Text(
          "¥",
          style: TextStyle(fontSize: 24),
        ),
      ],
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
          hintText: "サロンの目的、発信内容等",
        ),
      ),
    );
  }

  Future saveSalonDetail() async {
    final dbHandle = DbHandler();
    Salon salon = Salon();
    salon.category = categoriesController.text;
    salon.description = descriptionController.text;
    salon.name = salonNameController.text;
    salon.owner = FirebaseAuth.instance.currentUser.email;
    salon.price = priceController.text;
    if (_imageFiles.isNotEmpty) {
      salon.media = await _uploadImageAndGetUrl();
    }
    await dbHandle.addSalon(salon);
  }

  Future<void> _storeMediaFiles(BuildContext context) async {
    try {
      Navigator.of(context).pop();
      final pickedFile =
          await imagePicker.pickImage(source: ImageSource.gallery);

      setState(() {
        _imageFiles.add(pickedFile);
        index = _imageFiles.length - 1;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToRight());
      _updateScreenContext();
    } catch (e) {
      print(e);
    }
  }

  Future _uploadImageAndGetUrl() async {
    var snapshot = FirebaseStorage.instance.ref().child('images');
    List donwloadUrl = [];
    for (int i = 0; i < _imageFiles.length; i++) {
      final url = await snapshot
          .child('${Uuid().v1()}.png')
          .putFile(File(_imageFiles[i].path));
      donwloadUrl.add(
        await url.ref.getDownloadURL(),
      );
    }

    return donwloadUrl;
  }
}
