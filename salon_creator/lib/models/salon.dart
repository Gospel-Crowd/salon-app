class Salon {
  String salonName;
  String media;
  String category;
  String description;
  String price;

  Salon({
    this.salonName,
    this.media,
    this.category,
    this.description,
    this.price,
  });

  Map<String, dynamic> toMap() {
    return {
      'salonName': this.salonName,
      'category': this.category,
      'description': this.description,
      'price': this.price,
      'media': this.media,
    };
  }

  Salon.fromMap(Map<String, dynamic> map) {
    this.salonName = map[this.salonName];
    this.category = map[this.category];
    this.description = map[this.description];
    this.price = map[this.price];
    this.media = map[this.media];
  }
}
