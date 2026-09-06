class PostInspirationModel {
  String? id;
  String? uid;

  String? styles;
  String? imageName;
  String? imageId;
  String? isMultipleImages;
  PostInspirationModel({
    this.id,
    this.uid,
    this.styles,
    this.imageName,
    this.imageId,
    this.isMultipleImages
  });

  PostInspirationModel.fromJson(Map<String, dynamic> json) {
    id = json['id'].toString() ?? "";
    uid = json['uid'].toString() ?? "";

    styles = json['style_name'].toString() ?? "";

    imageName = json['image_name'].toString() ?? "";
    imageId = json['image_id'].toString() ?? "";
    isMultipleImages = json['is_multiple_image'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['uid'] = this.uid;

    data['style_name_hw'] = this.styles;

    data['image_name'] = this.imageName;
    data['image_id'] = this.imageId;
    data['is_multiple_image'] = this.isMultipleImages;

    return data;
  }
}

