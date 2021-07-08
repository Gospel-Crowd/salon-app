import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:salon_creator/authentication/sign_in.dart';
import 'package:salon_creator/constant/constants.dart' as constants;
import 'package:salon_creator/models/file_info.dart';
import 'package:salon_creator/models/user_model.dart';

class DrivePicker extends StatefulWidget {
  const DrivePicker({Key key}) : super(key: key);

  @override
  _DrivePickerState createState() => _DrivePickerState();
}

class _DrivePickerState extends State<DrivePicker> {
  void _driveConnect() async {
    // Call function to discover drive files. This will sync drive files to the db in the backend

    await http.post(
      Uri.https(
        'us-central1-gospel-crowd-salon-app-test.cloudfunctions.net',
        '/driveDiscovery',
      ),
      body: json.encode({
        'accessToken': userAccessToken,
        'userMailId': currentSignedInUser.email,
      }),
      headers: {
        "content-type": "application/json",
        "accept": "application/json",
      },
    );
  }

  @override
  void initState() {
    _driveConnect();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('DRIVE PICKER'),
      ),
      // Fetch from db to display drive files
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection(constants.DBCollection.users)
            .doc(currentSignedInUser.email)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return LinearProgressIndicator();
          }

          var user = UserModel.fromSnapshot(snapshot.data);

          return user.discoveryData != null
              ? _buildFileList(user.discoveryData.files)
              : LinearProgressIndicator();
        },
      ),
    );
  }

  ListView _buildFileList(List<FileInfo> files) {
    List<Widget> fileList = [];

    for (var file in files) {
      fileList.add(Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: _buildFileItem(file),
      ));
    }

    return ListView(children: fileList);
  }

  Widget _buildFileItem(FileInfo file) {
    return file.thumbnailUrl != null
        ? Image.network(file.thumbnailUrl)
        : ListTile(
            subtitle: OutlinedButton(
              child: Text(file.name),
              onPressed: () async {
                await http.post(
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
              },
            ),
          );
  }
}
