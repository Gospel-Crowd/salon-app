import 'package:salon_creator/models/file_info.dart';

class DiscoveryData {
  List<FileInfo> files;

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
            .map<FileInfo>((fileInfo) =>
                FileInfo.fromMap(fileInfo.cast<String, dynamic>()))
            .toList()
        : [];
  }
}
