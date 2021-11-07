import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:salon_creator/firebase/database.dart';
import 'package:salon_creator/models/cloud_file.dart';

abstract class MediaObject {}

abstract class ImageMediaObject extends MediaObject {
  ImageProvider buildImage();
}

abstract class VideoMediaObject extends MediaObject {
  ImageProvider buildThumbnail();
  String getThumbnailUrl();
}

class LocalImageMediaObject implements ImageMediaObject {
  final XFile xFile;

  LocalImageMediaObject({this.xFile});

  @override
  ImageProvider buildImage() {
    return FileImage(File(xFile.path));
  }

  Future<String> uploadImageAndGetUrl() async {
    final storageHandler = StorageHandler();
    return await storageHandler.uploadImageAndGetUrl(File(xFile.path));
  }
}

class CloudVideoMediaObject implements VideoMediaObject {
  final CloudFile cloudFile;

  CloudVideoMediaObject({this.cloudFile});

  @override
  ImageProvider<Object> buildThumbnail() {
    return NetworkImage(cloudFile.thumbnailUrl);
  }

  @override
  String getThumbnailUrl() {
    return cloudFile.thumbnailUrl;
  }

  String getFileId() {
    return cloudFile.id;
  }
}
