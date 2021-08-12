import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:salon_creator/common/color.dart';
import 'package:salon_creator/firebase/database.dart';
import 'package:salon_creator/models/user_model.dart';
import 'package:uuid/uuid.dart';

class UserProfileEditScreen extends StatefulWidget {
  const UserProfileEditScreen({
    Key key,
    this.userModel,
  }) : super(key: key);

  final UserModel userModel;

  @override
  _UserProfileEditScreenState createState() => _UserProfileEditScreenState();
}

class _UserProfileEditScreenState extends State<UserProfileEditScreen> {
  final ImagePicker imagePicker = ImagePicker();
  TextEditingController nameController;
  TextEditingController aboutMeController;
  DbHandler dbHandler = DbHandler();

  bool _opInProgress = false;
  bool _profileUpdated = false;
  XFile _imageFile;

  void _updateScreenContext(UserModel userModel) {
    var _hasProfileChanged = userModel.profile.name != nameController.text ||
        userModel.profile.aboutMeText != aboutMeController.text ||
        _imageFile != null;

    setState(() {
      _profileUpdated = _hasProfileChanged;
    });
  }

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.userModel.profile.name);
    aboutMeController =
        TextEditingController(text: widget.userModel.profile.aboutMeText);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection(DbHandler.usersCollection)
          .doc(FirebaseAuth.instance.currentUser.email)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return LinearProgressIndicator();
        }

        var userModel = UserModel.fromMap(snapshot.data.data());

        return _buildUserProfileEditScreenInternal(userModel);
      },
    );
  }

  Future<bool> _onBackButtonPressed() async {
    return !_profileUpdated
        ? true
        : await showDialog(
              context: context,
              builder: (context) => new AlertDialog(
                title: new Text('変更内容を取り消しますか？'),
                content: new Text('変更内容は全て失われます'),
                actions: <Widget>[
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text('キャンセル'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text('削除'),
                  ),
                ],
              ),
            ) ??
            false;
  }

  Widget _buildUserProfileEditScreenInternal(UserModel userModel) {
    List<Widget> profileItems = [];
    profileItems.addAll(ListTile.divideTiles(
      context: context,
      tiles: [
        _buildProfileImageEditDisplay(userModel),
        _buildNameEditDisplay(userModel),
        _buildAboutMeEditDisplay(userModel),
      ],
    ).toList());

    if (_opInProgress) {
      profileItems.insert(0, LinearProgressIndicator());
    }

    return WillPopScope(
      child: Scaffold(
        appBar: _buildAppBar(userModel),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView(
            children: profileItems,
          ),
        ),
      ),
      onWillPop: _onBackButtonPressed,
    );
  }

  Widget _buildAppBar(UserModel userModel) {
    return AppBar(
      title: Text('プロフィールの編集'),
      iconTheme: IconThemeData(color: Colors.black),
      actions: [
        TextButton(
          onPressed: _profileUpdated
              ? () async {
                  await _saveProfile(userModel);
                  Navigator.pop(context);
                }
              : null,
          child: Text('終了'),
          style: Theme.of(context).textButtonTheme.style.copyWith(
                foregroundColor: MaterialStateProperty.resolveWith((states) =>
                    states.any((element) => element == MaterialState.disabled)
                        ? Colors.grey
                        : primaryColor),
              ),
        ),
      ],
    );
  }

  Future<void> _saveProfile(UserModel userModel) async {
    setState(() {
      _opInProgress = true;
    });

    userModel.profile.name = nameController.text;
    userModel.profile.aboutMeText = aboutMeController.text;
    if (_imageFile != null) {
      userModel.profile.imageUrl = await _uploadImageAndGetUrl(_imageFile);
    }

    await dbHandler.updateUser(userModel);

    setState(() {
      _opInProgress = false;
    });
  }

  Future<String> _uploadImageAndGetUrl(XFile imageFile) async {
    var snapshot = await FirebaseStorage.instance
        .ref()
        .child('images')
        .child('${Uuid().v1()}.png')
        .putFile(File(imageFile.path));

    return snapshot.ref.getDownloadURL();
  }

  Widget _buildNameEditDisplay(UserModel userModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16),
        Text(
          '名前',
          style: Theme.of(context).textTheme.headline3,
        ),
        SizedBox(height: 4),
        _buildNameFormField(userModel),
        SizedBox(height: 24),
      ],
    );
  }

  TextFormField _buildNameFormField(UserModel userModel) {
    return TextFormField(
      controller: nameController,
      onChanged: (_) => _updateScreenContext(userModel),
    );
  }

  Widget _buildAboutMeEditDisplay(UserModel userModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16),
        Text(
          'プロフィール',
          style: Theme.of(context).textTheme.headline3,
        ),
        SizedBox(height: 4),
        _buildAboutMeFormField(userModel),
        SizedBox(height: 8),
      ],
    );
  }

  TextFormField _buildAboutMeFormField(UserModel userModel) {
    return TextFormField(
      controller: aboutMeController,
      onChanged: (_) => _updateScreenContext(userModel),
      maxLines: 10,
    );
  }

  Widget _buildProfileImageEditDisplay(UserModel userModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8),
        Text(
          'プロフィール写真',
          style: Theme.of(context).textTheme.headline3,
        ),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildProfileImageEditDisplayInternal(userModel),
          ],
        ),
        SizedBox(height: 24),
      ],
    );
  }

  Widget _buildProfileImageEditDisplayInternal(UserModel userModel) {
    return Stack(
      alignment: AlignmentDirectional.bottomCenter,
      children: [
        ClipOval(
          child: ColorFiltered(
            colorFilter: const ColorFilter.mode(
              Colors.black38,
              BlendMode.overlay,
            ),
            child: CircleAvatar(
              radius: MediaQuery.of(context).size.width * 0.25,
              foregroundImage: _imageFile != null
                  ? FileImage(File(_imageFile.path))
                  : widget.userModel.profile.imageUrl != null
                      ? NetworkImage(widget.userModel.profile.imageUrl)
                      : AssetImage('assets/default_profile_image.png'),
            ),
          ),
        ),
        _buildUploadImageButton(userModel),
      ],
    );
  }

  Widget _buildUploadImageButton(UserModel userModel) {
    return IconButton(
      onPressed: () async {
        try {
          final pickedFile = await imagePicker.pickImage(
            source: ImageSource.gallery,
          );
          setState(() {
            _imageFile = pickedFile;
          });
          _updateScreenContext(userModel);
        } catch (e) {
          print(e);
        }
      },
      icon: Icon(Icons.camera_alt, color: Colors.white),
      iconSize: 40,
    );
  }
}
