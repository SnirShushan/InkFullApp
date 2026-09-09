// class PostModel {
//   String? id;
//   String? uid;
//   String? imgType;
//   String? styles;
//   String? description;
//   String? imageName;
//   String? imageId;
//   String? dateAdded;
//   String? dateUpdated;
//   String? artistUid;
//   String? status;
//   String? studioUid;
//   // Owner? owner;
//   // List<Artist>? artist;
//   String? liked;
//   String? followers;
//   String? postLiked;
//   String? postLikes;
//   String? q;
//   List<String>? tagList;
//   String? tagStr;
//
//   PostModel(
//       {this.id,
//       this.uid,
//       this.imgType,
//       this.styles,
//       this.description,
//       this.imageName,
//       this.imageId,
//       this.dateAdded,
//       this.dateUpdated,
//       this.artistUid,
//       this.status,
//       this.studioUid,
//       // this.owner,
//       // this.artist,
//       this.liked,
//       this.followers,
//       this.postLiked,
//       this.postLikes,
//       this.tagList,
//       this.tagStr});
//
//   PostModel.fromJson(Map<String, dynamic> json) {
//     id = json['id'].toString() ?? "";
//     uid = json['uid'].toString() ?? "";
//     imgType = json['img_type'].toString() ?? "";
//     styles = json['styles'].toString() ?? "";
//     description = json['description'].toString() ?? "";
//     imageName = json['image_name'].toString() ?? "";
//     imageId = json['image_id'].toString() ?? "";
//     dateAdded = json['date_added'].toString() ?? "";
//     dateUpdated = json['date_updated'].toString() ?? "";
//     artistUid = json['artist_uid'].toString() ?? "";
//     status = json['status'].toString() ?? "";
//     studioUid = json['studio_uid'] ?? "";
//     // owner = json.containsKey("owner")
//     //     ? json['owner'].toString() == "[]"
//     //         ? null
//     //         : Owner.fromJson(json['owner'])
//     //     : null;
//     // if (json['artist'] != null) {
//     //   artist = <Artist>[];
//     //   // json['artist'].forEach((v) {
//     //   artist!.add(new Artist.fromJson(json['artist'][0]));
//     //   // }
//     //   // );
//     // }
//     liked = json['liked'].toString() ?? "";
//     followers = json['followers'].toString() ?? "";
//     postLiked = json['post_liked'].toString() ?? "";
//     postLikes = json['post_likes'].toString() ?? "";
//     // tagList = json['tag_list'] != "" ? json['tag_list'].cast<String>() : "";
//     // tagStr = json['tag_str'] ?? "";
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     data['uid'] = this.uid;
//     data['img_type'] = this.imgType;
//     data['styles'] = this.styles;
//     data['description'] = this.description;
//     data['image_name'] = this.imageName;
//     data['image_id'] = this.imageId;
//     data['date_added'] = this.dateAdded;
//     data['date_updated'] = this.dateUpdated;
//     data['artist_uid'] = this.artistUid;
//     data['status'] = this.status;
//     data['studio_uid'] = this.studioUid;
//     // if (this.owner != null) {
//     //   data['owner'] = this.owner!.toJson();
//     // }
//     // if (this.artist != null) {
//     //   data['artist'] = this.artist!;
//     // }
//     data['liked'] = this.liked;
//     data['followers'] = this.followers;
//     data['post_liked'] = this.postLiked;
//     data['post_likes'] = this.postLikes;
//     data['tag_list'] = this.tagList;
//     data['tag_str'] = this.tagStr;
//     return data;
//   }
// }
// //
// // class Owner {
// //   String? id;
// //   String? name;
// //   String? email;
// //   String? phone;
// //   String? cntCode;
// //   String? lang;
// //   String? profileImage;
// //   String? loginToken;
// //   String? styles;
// //   String? businessType;
// //   String? userType;
// //   String? loginType;
// //   String? address;
// //   String? addressLat;
// //   String? addressLng;
// //   String? addressPlaceId;
// //   String? aboutText;
// //
// //   Owner(
// //       {this.id,
// //       this.name,
// //       this.email,
// //       this.phone,
// //       this.cntCode,
// //       this.lang,
// //       this.profileImage,
// //       this.loginToken,
// //       this.styles,
// //       this.businessType,
// //       this.userType,
// //       this.loginType,
// //       this.address,
// //       this.addressLat,
// //       this.addressLng,
// //       this.addressPlaceId,
// //       this.aboutText});
// //
// //   Owner.fromJson(Map<String, dynamic> json) {
// //     id = json['id'].toString();
// //     name = json['name'].toString();
// //     email = json['email'].toString();
// //     phone = json['phone'].toString();
// //     cntCode = json['cnt_code'].toString();
// //     lang = json['lang'].toString();
// //     profileImage = json['profile_image'].toString();
// //     loginToken = json['login_token'].toString();
// //     styles = json['styles'].toString();
// //     businessType = json['business_type'].toString();
// //     userType = json['user_type'].toString();
// //     loginType = json['login_type'].toString();
// //     address = json['address'].toString();
// //     addressLat = json['address_lat'].toString();
// //     addressLng = json['address_lng'].toString();
// //     addressPlaceId = json['address_place_id'].toString();
// //     aboutText = json['about_text'].toString();
// //   }
// //
// //   Map<String, dynamic> toJson() {
// //     final Map<String, dynamic> data = new Map<String, dynamic>();
// //     data['id'] = this.id;
// //     data['name'] = this.name;
// //     data['email'] = this.email;
// //     data['phone'] = this.phone;
// //     data['cnt_code'] = this.cntCode;
// //     data['lang'] = this.lang;
// //     data['profile_image'] = this.profileImage;
// //     data['login_token'] = this.loginToken;
// //     data['styles'] = this.styles;
// //     data['business_type'] = this.businessType;
// //     data['user_type'] = this.userType;
// //     data['login_type'] = this.loginType;
// //     data['address'] = this.address;
// //     data['address_lat'] = this.addressLat;
// //     data['address_lng'] = this.addressLng;
// //     data['address_place_id'] = this.addressPlaceId;
// //     data['about_text'] = this.aboutText;
// //     return data;
// //   }
// // }
