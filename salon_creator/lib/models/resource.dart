class Resource {
  String displayName;
  String url;

  Resource({this.displayName, this.url});

  Resource.fromMap(Map<String, dynamic> map) {
    this.displayName = map['displayName'];
    this.url = map['url'];
  }

  Map<String, dynamic> toMap() {
    return {
      'displayName': this.displayName,
      'url': this.url,
    };
  }
}
