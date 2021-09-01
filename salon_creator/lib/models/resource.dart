class Resource {
  String displayName;
  String url;

  Resource({this.displayName, this.url});

  Map<String, dynamic> toMap() {
    return {
      'displayName': this.displayName,
      'url': this.url,
    };
  }
}
