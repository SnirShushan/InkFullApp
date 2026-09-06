class CollectionModel {
  String? fid;
  String? fname;
  String? uid;
  String? imageUrl;

  CollectionModel({this.fid, this.fname, this.uid, this.imageUrl});

  CollectionModel.fromJson(Map<dynamic, dynamic> json) {
    fid = json['fid'].toString();
    fname = json['fname'].toString();
    uid = json['uid'].toString();
    imageUrl = json['image_url'].toString();
  }

  Map<dynamic, dynamic> toJson() {
    final Map<dynamic, dynamic> data = new Map<dynamic, dynamic>();
    data['fid'] = this.fid;
    data['fname'] = this.fname;
    data['uid'] = this.uid;
    data['image_url'] = this.imageUrl;
    return data;
  }
}
