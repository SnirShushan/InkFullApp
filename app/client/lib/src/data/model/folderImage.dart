class FolderImage {
  final String imageId;
  final String pId;
  final String fid;
  final String imageUrl;
  final String firebaseId;

  FolderImage({
    required this.imageId,
    required this.pId,
    required this.fid,
    required this.imageUrl,
    required this.firebaseId,
  });

  Map<String, dynamic> toJson() => {
        'imageId': imageId,
        'pid': pId,
        'fid': fid,
        'imageUrl': imageUrl,
        'firebase_id': firebaseId,
      };

  static FolderImage fromJson(Map<String, dynamic> json) => FolderImage(
      imageId: json['imageId'].toString(),
      pId: json['pid'].toString(),
      fid: json['fid'].toString(),
      imageUrl: json['imageUrl'].toString(),
      firebaseId: json['firebase_id'].toString());
}
