class RequestImages {
  String? imageId;
  String? name;
  String? imageUrl;
  String? uid;

  RequestImages({this.imageId, this.name, this.imageUrl, this.uid});

  RequestImages.fromJson(Map<String, dynamic> json) {
    imageId = json['imageId'];
    name = json['name'];
    imageUrl = json['imageUrl'];
    uid = json['uid'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['imageId'] = this.imageId;
    data['name'] = this.name;
    data['imageUrl'] = this.imageUrl;
    data['uid'] = this.uid;
    return data;
  }
}
