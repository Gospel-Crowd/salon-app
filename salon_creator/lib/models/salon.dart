class Salon {
  String owner;
  String name;
  List<String> media;
  String category;
  String description;
  String price;

  Salon({
    this.owner,
    this.name,
    this.media,
    this.category,
    this.description,
    this.price,
  });

  Map<String, dynamic> toMap() {
    return {
      'owner': this.owner,
      'name': this.name,
      'category': this.category,
      'description': this.description,
      'price': this.price,
      'media': List.castFrom(media),
    };
  }

  Salon.fromMap(Map<String, dynamic> map) {
    this.owner = map['owner'];
    this.name = map['name'];
    this.category = map['category'];
    this.description = map['description'];
    this.price = map['price'];
    this.media = map['media'];
  }
}
