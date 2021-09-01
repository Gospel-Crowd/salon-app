class Lesson {
  String salonId;
  String name;
  String thumbnail;
  String media;
  String category;
  String description;
  bool publish;
  List<String> resources;

  Lesson({
    this.salonId,
    this.name,
    this.thumbnail,
    this.media,
    this.category,
    this.description,
    this.publish,
    this.resources,
  });

  Map<String, dynamic> toMap() {
    return {
      'salonId': this.salonId,
      'name': this.name,
      'thumbnail': this.thumbnail,
      'media': this.media,
      'category': this.category,
      'description': this.description,
      'publish': this.publish,
      'resources': List.castFrom(this.resources),
    };
  }

  Lesson.fromMap(Map<String, dynamic> map) {
    this.salonId = map['salonId'];
    this.name = map['name'];
    this.thumbnail = map['thumbnail'];
    this.media = map['media'];
    this.category = map['category'];
    this.description = map['description'];
    this.publish = map['publish'];
    this.resources = map['resources'].cast<String>() as List<String>;
  }
}
