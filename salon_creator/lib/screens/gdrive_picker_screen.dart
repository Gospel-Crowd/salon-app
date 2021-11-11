import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:salon_creator/firebase/database.dart';
import 'package:salon_creator/firebase/sign_in.dart';
import 'package:salon_creator/models/creator_model.dart';
import 'package:salon_creator/models/cloud_file.dart';
import 'package:salon_creator/models/transfer_details.dart';
import 'package:salon_creator/models/user_model.dart';
import 'package:salon_creator/screens/gdrive_transfer_screen.dart';

class GdrivePicker extends StatefulWidget {
  const GdrivePicker({Key key, this.userModel}) : super(key: key);

  final UserModel userModel;

  @override
  _GdrivePickerState createState() => _GdrivePickerState();
}

class _GdrivePickerState extends State<GdrivePicker> {
  void _driveConnect() async {
    // Call function to discover drive files. This will sync drive files to the db in the backend

    await http.post(
      Uri.https(
        'us-central1-gospel-crowd-salon-app-test.cloudfunctions.net',
        '/driveDiscovery',
      ),
      body: json.encode({
        'accessToken': userAccessToken,
        'userMailId': widget.userModel.email,
      }),
      headers: {
        "content-type": "application/json",
        "accept": "application/json",
      },
    );
  }

  @override
  void initState() {
    super.initState();

    _driveConnect();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Google Drive から選ぶ'),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection(DbHandler.usersCollection)
            .doc(FirebaseAuth.instance.currentUser.email)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return LinearProgressIndicator();
          }

          var user = CreatorModel.fromMap(snapshot.data.data());

          return user.discoveryData != null
              ? _buildFileList(user.discoveryData.files)
              : LinearProgressIndicator();
        },
      ),
    );
  }

  Widget _buildFileList(List<CloudFile> files) {
    List<Widget> fileList = [];

    for (var file in files) {
      var fileItem = _buildFileItem(file);
      if (fileItem != null) {
        fileList.add(fileItem);
      }
    }

    return GridView(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      shrinkWrap: true,
      gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: (MediaQuery.of(context).size.width) /
            (MediaQuery.of(context).size.height / 2.9),
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
      ),
      children: fileList,
    );
  }

  Widget _buildFileItem(CloudFile file) {
    return ListTile(
      subtitle: OutlinedButton(
        child: file.thumbnailUrl != null
            ? Image.network(
                file.thumbnailUrl,
                errorBuilder: (context, exception, stackTrace) => Container(),
              )
            : Text(file.name),
        onPressed: () async {
          _triggerDriveTransfer(file);

          final transferDetails = (await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return GdriveTransferScreen(cloudFile: file);
              },
            ),
          )) as TransferDetails;

          if (transferDetails != null) {
            _popScreen(file, transferDetails);
          }
        },
      ),
    );
  }

  void _popScreen(CloudFile file, TransferDetails transferDetails) {
    Navigator.pop(
      context,
      CloudFile(
        id: file.id,
        name: file.name,
        thumbnailUrl: transferDetails.thumbnailUrl,
        sizeInBytes: file.sizeInBytes,
        source: file.source,
      ),
    );
  }

  void _triggerDriveTransfer(CloudFile file) {
    http.post(
      Uri.https(
        'us-central1-gospel-crowd-salon-app-test.cloudfunctions.net',
        '/driveTransfer',
      ),
      body: json.encode({
        'accessToken': userAccessToken,
        'userMailId': currentSignedInUser.email,
        'fileId': file.id,
      }),
      headers: {
        "content-type": "application/json",
        "accept": "application/json",
      },
    );
  }
}
