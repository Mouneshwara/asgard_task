class ProductModel {
  String? imageUrl;
  List<double>? coordinates;
  String? id;
  String? title;
  String? body;
  String? userId;

  ProductModel(
      {this.imageUrl,
      this.coordinates,
      this.id,
      this.title,
      this.body,
      this.userId});

  ProductModel.fromJson(Map<String, dynamic> json) {
    imageUrl = json['imageUrl'];
    coordinates = json['coordinates'].cast<double>();
    id = json['id'];
    title = json['title'];
    body = json['body'];
    userId = json['userId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['imageUrl'] = this.imageUrl;
    data['coordinates'] = this.coordinates;
    data['id'] = this.id;
    data['title'] = this.title;
    data['body'] = this.body;
    data['userId'] = this.userId;
    return data;
  }
}
