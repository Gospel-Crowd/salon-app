import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:salon_creator/common/color.dart';
import 'package:salon_creator/firebase/database.dart';
import 'package:salon_creator/models/creator_model.dart';
import 'package:salon_creator/models/salon.dart';
import 'package:salon_creator/widgets/custom_button.dart';
import 'package:salon_creator/widgets/custom_dialog.dart';
import 'package:salon_creator/widgets/custom_label.dart';
import 'package:salon_creator/widgets/custom_textfield.dart';

class SalonCreationScreen extends StatefulWidget {
  const SalonCreationScreen({Key key, this.userModel}) : super(key: key);

  final CreatorModel userModel;

  @override
  _SalonCreationScreenState createState() => _SalonCreationScreenState();
}

class _SalonCreationScreenState extends State<SalonCreationScreen> {
  bool isFormFilled = false;
  bool operationInProgress = false;
  final ImagePicker imagePicker = ImagePicker();
  int _selectedImageIndex = 0;
  List<XFile> _imageFiles = [];
  XFile image;
  TextEditingController categoriesController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController salonNameController = TextEditingController();
  ScrollController _scrollController = ScrollController();

  void _updateScreenContext() {
    var _hasProfileChanged = salonNameController.text.isNotEmpty ||
        categoriesController.text.isNotEmpty ||
        descriptionController.text.isNotEmpty ||
        priceController.text.isNotEmpty ||
        _imageFiles.isNotEmpty;
    setState(() {
      isFormFilled = _hasProfileChanged;
    });
  }

  _scrollToRight() {
    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: operationInProgress ? null : _buildAppBar(context),
      body: operationInProgress
          ? _buildCreateInProgressScreen()
          : _buildSalonCreationInner(context),
    );
  }

  Widget _buildSalonCreationInner(BuildContext context) {
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
                _buildMediaPreviewerDivider(),
                SizedBox(height: 8),
                _buildMediaPreviewer(screenHeight, screenWidth, context),
                _buildMediaPane(context),
                _buildSalonDetailForms(screenWidth),
                isFormFilled ? Container() : Text("空欄の部分があります"),
                _buildSalonSaveButton(screenWidth, screenHeight),
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
          Text("作成中です", style: Theme.of(context).textTheme.headline2),
          SizedBox(height: 16),
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
      function: isFormFilled
          ? () async {
              setState(() {
                operationInProgress = true;
              });
              await _saveSalonDetail().whenComplete(() {
                setState(() {
                  operationInProgress = false;
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
            _imageFiles != null ? _buildMediaPaneThumbnailList() : Container(),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaPaneThumbnailList() {
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
                child: _buildMediaPaneThumbnail(i),
              ),
              _selectedImageIndex == i
                  ? Container(
                      width: 80,
                      height: 48,
                      decoration: BoxDecoration(
                        border: Border.all(color: primaryColor, width: 3),
                      ),
                    )
                  : Container(
                      width: 80,
                      height: 48,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedImageIndex = i;
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

  Widget _buildMediaPaneThumbnail(int i) {
    return Stack(
      alignment: Alignment.topRight,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      children: [
        Image(
          fit: BoxFit.cover,
          width: 80,
          height: 45,
          image: FileImage(
            File(_imageFiles[i].path),
          ),
        ),
      ],
    );
  }

  Widget _buildMediaPaneAddButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: primaryColor,
        border: Border.all(color: primaryColor, width: 2),
      ),
      child: IconButton(
        alignment: Alignment.center,
        icon: Icon(Icons.add_circle, size: 28, color: Colors.white),
        onPressed: () {
          _showBottomSheet(context);
        },
      ),
    );
  }

  Widget _buildMediaPreviewer(
    double screenHeight,
    double screenWidth,
    BuildContext context,
  ) {
    return Container(
      color: Color.fromRGBO(195, 195, 195, 0.3),
      height: screenWidth * 0.563,
      width: screenWidth,
      child: _imageFiles.isEmpty
          ? TextButton(
              child: Icon(Icons.add_circle, size: 64, color: primaryColor),
              onPressed: () {
                _showBottomSheet(context);
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
                    File(_imageFiles[_selectedImageIndex].path),
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
      decoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle),
      child: IconButton(
        onPressed: () {
          _buildDeleteConfirmationDialog(context);
        },
        icon: Icon(Icons.close, color: Colors.white),
      ),
    );
  }

  Future<void> _buildDeleteConfirmationDialog(BuildContext context) async {
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
          _imageFiles.removeAt(_selectedImageIndex);
          _selectedImageIndex -= 1;
        });
        Navigator.of(context).pop();
      },
      rightButtonText: "取り消し",
      rightFunction: () {
        Navigator.of(context).pop();
      },
    );
  }

  void _showBottomSheet(BuildContext context) async {
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
      maxLines: 1,
      onChanged: (_) => _updateScreenContext(),
      controller: salonNameController,
      title: "サロン名",
      hintText: "ゴスペルサロン",
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
          maxLines: 1,
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

  Future _saveSalonDetail() async {
    final dbHandler = DbHandler();
    final storageHandler = StorageHandler();
    Salon salon = Salon();

    salon.category = categoriesController.text;
    salon.description = descriptionController.text;
    salon.name = salonNameController.text;
    salon.owner = FirebaseAuth.instance.currentUser.email;
    salon.price = priceController.text;
    salon.media = [];
    if (_imageFiles.isNotEmpty) {
      for (int i = 0; i < _imageFiles.length; i++) {
        salon.media.add(
          await storageHandler.uploadImageAndGetUrl(
            File(_imageFiles[i].path),
          ),
        );
      }
    }

    var salonId = await dbHandler.addSalon(salon);
    widget.userModel.salonId = salonId;

    await dbHandler.updateUser(widget.userModel);
  }

  Future<void> _storeMediaFiles(BuildContext context) async {
    try {
      Navigator.of(context).pop();
      final pickedFile =
          await imagePicker.pickImage(source: ImageSource.gallery);

      setState(() {
        _imageFiles.add(pickedFile);
        _selectedImageIndex = _imageFiles.length - 1;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToRight());
      _updateScreenContext();
    } catch (e) {
      print(e);
    }
  }
}
