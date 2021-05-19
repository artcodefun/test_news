class News {
  News(
      {required this.id,
      required this.title,
      required this.description,
      required this.image});

  int id;
  String title;
  String description;
  String image;

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "title": title,
      "description": description,
      "image": image
    };
  }

  News.fromMap(Map  map)
      : id = map["id"],
        title = map["title"],
        description = map["description"],
        image = map["image"];
}
