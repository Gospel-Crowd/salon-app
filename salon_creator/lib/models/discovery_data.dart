import 'package:salon_creator/models/cloud_file.dart';

class DiscoveryData {
  List<CloudFile> files;

  DiscoveryData({
    this.files,
  });

  Map<String, dynamic> toMap() {
    return {
      'files': files.map((file) => file.toMap()).toList(),
    };
  }

  DiscoveryData.fromMap(Map<String, dynamic> map) {
    files = map['files'] != null
        ? map['files']
            .map<CloudFile>((fileInfo) =>
                CloudFile.fromMap(fileInfo.cast<String, dynamic>()))
            .toList()
        : [];
  }
}