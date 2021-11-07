// TODO: this should be renamed to GdriveFile
// and CloudFile should represent any file copied into Storage from a cloud provider
class CloudFile {
  final String name;
  final String id;
  final String thumbnailUrl;
  final num sizeInBytes;
  final FileSource source;

  CloudFile({
    this.name,
    this.id,
    this.thumbnailUrl,
    this.sizeInBytes,
    this.source,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'id': id,
      'thumbnailUrl': thumbnailUrl,
      'sizeInBytes': sizeInBytes,
      'source': source,
    };
  }

  CloudFile.fromMap(Map<String, dynamic> map)
      : assert(map['name'] != null),
        assert(map['id'] != null),
        name = map['name'],
        id = map['id'],
        thumbnailUrl = map['thumbnailUrl'],
        sizeInBytes = num.parse(map['sizeInBytes']),
        source = FileSource.values.firstWhere(
          (element) => element.toString().split('.')[1] == map['source'],
          orElse: () => FileSource.Unknown,
        );
}

enum FileSource {
  GoogleDrive,
  DropBox,
  Unknown,
}
