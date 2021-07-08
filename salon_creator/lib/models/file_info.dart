class FileInfo {
  final String name;
  final String id;
  final String thumbnailUrl;

  FileInfo({
    this.name,
    this.id,
    this.thumbnailUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'fileName': name,
      'fileId': id,
      'thumbnailUrl': thumbnailUrl,
    };
  }

  FileInfo.fromMap(Map<String, dynamic> map)
      : assert(map['fileName'] != null),
        assert(map['fileId'] != null),
        name = map['fileName'],
        id = map['fileId'],
        thumbnailUrl = map['thumbnailUrl'];
}
