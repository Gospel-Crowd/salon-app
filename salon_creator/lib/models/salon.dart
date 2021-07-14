class Salon {
  String name;
  String media;
  String category;
  String description;
  String price;

  Salon({
    this.name,
    this.media,
    this.category,
    this.description,
    this.price,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': this.name,
      'category': this.category,
      'description': this.description,
      'price': this.price,
      'media': this.media,
    };
  }

  Salon.fromMap(Map<String, dynamic> map) {
    this.name = map[this.name];
    this.category = map[this.category];
    this.description = map[this.description];
    this.price = map[this.price];
    this.media = map[this.media];
  }
}
