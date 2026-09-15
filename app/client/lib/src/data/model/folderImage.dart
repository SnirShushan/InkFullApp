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

  static String _nz(dynamic v) {
    if (v == null) return '';
    final s = v.toString();
    if (s == 'null' || s == 'undefined') return '';
    return s;
  }

  static FolderImage fromJson(Map<String, dynamic> json) => FolderImage(
      imageId: _nz(json['imageId'] ?? json['image_id']),
      pId: _nz(json['pid'] ?? json['pId']),
      fid: _nz(json['fid'] ?? json['folderId']),
      imageUrl: _nz(json['imageUrl'] ?? json['image_url'] ?? json['url']),
      firebaseId: _nz(json['firebase_id'] ?? json['firebaseId'] ?? json['uid']));
}
