import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:salon_creator/common/color.dart';
import 'package:salon_creator/firebase/database.dart';
import 'package:salon_creator/models/creator_model.dart';
import 'package:salon_creator/models/cloud_file.dart';
import 'package:salon_creator/models/media_object.dart';
import 'package:salon_creator/models/salon.dart';
import 'package:salon_creator/screens/gdrive_picker_screen.dart';
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
  final double thumbnailHeight = 48;
  final double thumbnailWidth = 60;

  bool isFormFilled = false;
  bool operationInProgress = false;
  final ImagePicker imagePicker = ImagePicker();
  int _selectedImageIndex = 0;
  List<MediaObject> _mediaObjects = [];
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
        _mediaObjects.isNotEmpty;
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
                _buildMediaPreviewerTitle(),
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
          Text(
            "作成中です",
            style: Theme.of(context)
                .textTheme
                .headline2
                .apply(color: primaryColor),
          ),
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

  Widget _buildMediaPreviewerTitle() {
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
      height: thumbnailHeight,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _buildMediaPaneAddButton(context),
            _mediaObjects != null
                ? _buildMediaPaneThumbnailList()
                : Container(),
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
        itemCount: _mediaObjects.length,
        itemBuilder: (BuildContext context, i) {
          return Stack(
            alignment: Alignment.center,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 2),
                child: _buildMediaPaneThumbnail(i),
              ),
              _selectedImageIndex == i
                  ? Container(
                      width: thumbnailWidth,
                      height: thumbnailHeight,
                      decoration: BoxDecoration(
                        border: Border.all(color: primaryColor, width: 4),
                      ),
                    )
                  : Container(
                      width: thumbnailWidth,
                      height: thumbnailHeight,
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
    Widget imageWidget = Container();
    var mediaObject = _mediaObjects[i];
    if (mediaObject is ImageMediaObject) {
      imageWidget = Image(
        fit: BoxFit.cover,
        width: thumbnailWidth,
        height: thumbnailHeight,
        image: mediaObject.buildImage(),
      );
    } else if (mediaObject is VideoMediaObject) {
      imageWidget = Stack(
        alignment: AlignmentDirectional.center,
        children: [
          Image(
            fit: BoxFit.cover,
            width: thumbnailWidth,
            height: thumbnailHeight,
            image: mediaObject.buildThumbnail(),
          ),
          Icon(Icons.play_circle, size: 32, color: Colors.white),
        ],
      );
    }

    return Stack(
      alignment: Alignment.topRight,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      children: [
        imageWidget,
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
      child: _mediaObjects.isEmpty
          ? TextButton(
              child: Icon(Icons.add_circle, size: 64, color: primaryColor),
              onPressed: () {
                _showBottomSheet(context);
              },
            )
          : Stack(
              alignment: Alignment.topLeft,
              children: [
                _buildImageOrVideoPreview(screenHeight, screenWidth),
                _buildDeleteButton(context),
              ],
            ),
    );
  }

  Widget _buildImageOrVideoPreview(double screenHeight, double screenWidth) {
    var mediaObject = _mediaObjects[_selectedImageIndex];
    if (mediaObject is ImageMediaObject) {
      return Image(
        height: screenWidth * 0.563,
        width: screenWidth,
        fit: BoxFit.cover,
        image: mediaObject.buildImage(),
      );
    } else if (mediaObject is VideoMediaObject) {
      return Stack(
        alignment: AlignmentDirectional.center,
        children: [
          Image(
            height: screenWidth * 0.563,
            width: screenWidth,
            fit: BoxFit.cover,
            image: mediaObject.buildThumbnail(),
          ),
          Icon(Icons.play_circle, size: 80, color: Colors.white),
        ],
      );
    }

    return null;
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
          _mediaObjects.removeAt(_selectedImageIndex);
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
                onTap: () => _storeMediaFiles(context),
              ),
              Divider(height: 0),
              ListTile(
                title: Text("動画から選ぶ"),
              ),
              Divider(height: 0),
              _buildGdrivePickerTile(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGdrivePickerTile(BuildContext context) {
    return ListTile(
      title: Text("Google Drive から選ぶ"),
      onTap: () async {
        final gdriveFile = (await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return GdrivePicker(userModel: widget.userModel);
            },
          ),
        )) as CloudFile;
        if (gdriveFile != null) {
          setState(() {
            _mediaObjects.add(CloudVideoMediaObject(cloudFile: gdriveFile));
          });
        }
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
    Salon salon = Salon();

    salon.category = categoriesController.text;
    salon.description = descriptionController.text;
    salon.name = salonNameController.text;
    salon.owner = FirebaseAuth.instance.currentUser.email;
    salon.price = priceController.text;
    salon.media = [];
    if (_mediaObjects.isNotEmpty) {
      for (int i = 0; i < _mediaObjects.length; i++) {
        if (_mediaObjects[i] is LocalImageMediaObject) {
          salon.media.add(
            await (_mediaObjects[i] as LocalImageMediaObject)
                .uploadImageAndGetUrl(),
          );
        } else if (_mediaObjects[i] is CloudVideoMediaObject) {
          salon.media
              .add((_mediaObjects[i] as CloudVideoMediaObject).getFileId());
        }
      }
    }

    var salonId = await dbHandler.addSalon(salon);
    widget.userModel.salonId = salonId;

    await dbHandler.updateUser(widget.userModel);
  }

  Future<void> _storeMediaFiles(BuildContext context) async {
    try {
      final pickedFile =
          await imagePicker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _mediaObjects.add(LocalImageMediaObject(xFile: pickedFile));
          _selectedImageIndex = _mediaObjects.length - 1;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToRight());
        _updateScreenContext();
      }
    } catch (e) {
      print(e);
    }
  }
}
