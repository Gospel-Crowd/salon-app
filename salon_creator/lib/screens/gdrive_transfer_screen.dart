import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:salon_creator/firebase/database.dart';
import 'package:salon_creator/models/cloud_file.dart';
import 'package:salon_creator/models/transfer_details.dart';

class GdriveTransferScreen extends StatefulWidget {
  const GdriveTransferScreen({Key key, this.cloudFile}) : super(key: key);

  // TODO: rename this to GdriveFile, as this is a discovered file
  final CloudFile cloudFile;

  @override
  _GdriveTransferScreenState createState() => _GdriveTransferScreenState();
}

class _GdriveTransferScreenState extends State<GdriveTransferScreen> {
  bool operationInProgress = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection(DbHandler.transfersCollection)
          .doc(widget.cloudFile.id)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return LinearProgressIndicator();
        }

        var fileMetadata = snapshot.data.data();

        if (fileMetadata == null) {
          return LinearProgressIndicator();
        }

        return _buildGdriveTransferScreenInternal(fileMetadata);
      },
    );
  }

  Widget _buildGdriveTransferScreenInternal(Map<String, dynamic> fileMetadata) {
    num bytesTransferred =
        num.parse(fileMetadata['bytes_transferred'].toString());
    bool transferCompleted = fileMetadata['state'] == 'TransferCompleted';
    num transferProgress = transferCompleted
        ? 1.0
        : bytesTransferred / widget.cloudFile.sizeInBytes;

    //TODO: Show linear progress indicator while we fetch the thumbnail url
    return Scaffold(
      appBar: AppBar(
        title: Text('ファイルを転送'),
        iconTheme: IconThemeData(color: Colors.black),
        actions: [
          transferCompleted
              ? TextButton(
                  onPressed: () async {
                    Navigator.pop(context, await _buildTransferDetails());
                  },
                  child: Text('追加'))
              : Container(),
        ],
      ),
      body: _buildBodyInternal(transferCompleted, transferProgress, context),
    );
  }

  Future<TransferDetails> _buildTransferDetails() async {
    setState(() {
      operationInProgress = true;
    });

    StorageHandler storageHandler = StorageHandler();
    var fileId = widget.cloudFile.id;
    
    var transferDetails = TransferDetails(
      id: fileId,
      fileId: fileId,
      status: TransferStatus.Successful,
      thumbnailUrl: await storageHandler.getCloudFileThumbnailUrl(fileId),
    );

    setState(() {
      operationInProgress = false;
    });

    return transferDetails;
  }

  Widget _buildBodyInternal(
    bool transferCompleted,
    num transferProgress,
    BuildContext context,
  ) {
    return Stack(
      children: [
        !transferCompleted || operationInProgress
            ? LinearProgressIndicator()
            : Container(),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildTransferDescription(),
              SizedBox(height: 16),
              _buildTransferPercentage(transferProgress, context),
              SizedBox(height: 16),
              _buildTransferProgressBar(transferProgress),
              SizedBox(height: 16),
              _buildThumbnailImage(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTransferProgressBar(num transferProgress) {
    return LinearProgressIndicator(
      value: transferProgress,
      minHeight: 24,
    );
  }

  Widget _buildThumbnailImage() {
    return Row(
      children: [
        widget.cloudFile.thumbnailUrl != null
            ? Expanded(
                child: Image.network(
                  widget.cloudFile.thumbnailUrl,
                  errorBuilder: (context, exception, stackTrace) => Container(),
                  fit: BoxFit.fill,
                ),
              )
            : Container(),
      ],
    );
  }

  Widget _buildTransferPercentage(num transferProgress, BuildContext context) {
    return Text(
      (transferProgress * 100).toStringAsFixed(0) + ' % 転送完了',
      style: Theme.of(context).textTheme.headline3,
    );
  }

  Widget _buildTransferDescription() {
    return Text('【' +
        widget.cloudFile.name +
        '】をアプリのストレージに転送しています。完了するまでこの画面でお待ちください。');
  }
}
