class Lesson {
  String salonId;
  String name;
  String thumbnailUrl;
  String mediaUrl;
  String category;
  String description;
  bool isPublish;
  List<Map<String, dynamic>> resources;

  Lesson({
    this.salonId,
    this.name,
    this.thumbnailUrl,
    this.mediaUrl,
    this.category,
    this.description,
    this.isPublish,
    this.resources,
  });

  Map<String, dynamic> toMap() {
    return {
      'salonId': this.salonId,
      'name': this.name,
      'thumbnailUrl': this.thumbnailUrl,
      'mediaUrl': this.mediaUrl,
      'category': this.category,
      'description': this.description,
      'isPublish': this.isPublish,
      'resources': this.resources,
    };
  }

  Lesson.fromMap(Map<String, dynamic> map) {
    this.salonId = map['salonId'];
    this.name = map['name'];
    this.thumbnailUrl = map['thumbnailUrl'];
    this.mediaUrl = map['mediaUrl'];
    this.category = map['category'];
    this.description = map['description'];
    this.isPublish = map['isPublish'];
    this.resources =
        map['resources'].cast<String>() as List<Map<String, dynamic>>;
  }
}
