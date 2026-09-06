// class HomeModelBackup {
//   List<Business>? business;
//   String? isFilter;
//   List<TattosInStyle>? tattosInStyle;
//   List<NewUserList>? newUserList;
//   String? isNewNotification;
//
//   HomeModelBackup(
//       {this.business,
//         this.isFilter,
//         this.tattosInStyle,
//         this.newUserList,
//         this.isNewNotification});
//
//   HomeModelBackup.fromJson(Map<String, dynamic> json) {
//     if (json['business'] != null) {
//       business = <Business>[];
//       json['business'].forEach((v) {
//         business!.add(new Business.fromJson(v));
//       });
//     }
//     isFilter = json['is_filter'];
//     if (json['tattos_in_style'] != null) {
//       tattosInStyle = <TattosInStyle>[];
//       json['tattos_in_style'].forEach((v) {
//         tattosInStyle!.add(new TattosInStyle.fromJson(v));
//       });
//     }
//     if (json['new_user_list'] != null) {
//       newUserList = <NewUserList>[];
//       json['new_user_list'].forEach((v) {
//         newUserList!.add(new NewUserList.fromJson(v));
//       });
//     }
//     isNewNotification = json['is_new_notification'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     if (this.business != null) {
//       data['business'] = this.business!.map((v) => v.toJson()).toList();
//     }
//     data['is_filter'] = this.isFilter;
//     if (this.tattosInStyle != null) {
//       data['tattos_in_style'] =
//           this.tattosInStyle!.map((v) => v.toJson()).toList();
//     }
//     if (this.newUserList != null) {
//       data['new_user_list'] = this.newUserList!.map((v) => v.toJson()).toList();
//     }
//     data['is_new_notification'] = this.isNewNotification;
//     return data;
//   }
// }
//
// class Business {
//   String? id;
//   String? name;
//   String? status;
//   String? email;
//   String? phone;
//   String? cntCode;
//   String? lang;
//   String? profileImage;
//   String? styles;
//   String? businessType;
//   String? userType;
//   String? loginType;
//   String? address;
//   String? addressLat;
//   String? addressLng;
//   String? addressPlaceId;
//   String? aboutText;
//   String? postLimit;
//   String? isRegister;
//   // String? liked;
//   // String? followers;
//   List<String>? stylesHe;
//   // Posts? posts;
//   // List<Artist>? artist;
//   List<BusinessImageModel>? businessimg;
//
//   Business({
//     this.id,
//     this.name,
//     this.status,
//     this.email,
//     this.phone,
//     this.cntCode,
//     this.lang,
//     this.profileImage,
//     this.styles,
//     this.businessType,
//     this.userType,
//     this.stylesHe,
//     this.loginType,
//     this.address,
//     this.addressLat,
//     this.addressLng,
//     this.addressPlaceId,
//     this.aboutText,
//     this.postLimit,
//     this.isRegister,
//     // this.liked,
//     this.businessimg,
//     // this.followers,
//     // this.posts,
//     // this.artist
//   });
//
//   Business.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     name = json['name'];
//     status = json['status'];
//     email = json['email'];
//     phone = json['phone'];
//     cntCode = json['cnt_code'];
//     lang = json['lang'];
//     profileImage = json['profile_image'];
//     styles = json['styles'];
//     businessType = json['business_type'];
//     userType = json['user_type'];
//     loginType = json['login_type'];
//     address = json['address'];
//     addressLat = json['address_lat'];
//     addressLng = json['address_lng'];
//     addressPlaceId = json['address_place_id'];
//     aboutText = json['about_text'];
//     postLimit = json['post_limit'];
//     isRegister = json['is_register'];
//     // liked = json['liked'].toString();
//     // followers = json['followers'].toString();
//     // posts = json['posts'] == null || json['posts'].toString() == "[]"
//     //     ? null
//     //     : Posts.fromJson(json['posts']);
//
//     // if (json['artist'] != null) {
//     //   artist = <Artist>[];
//     //   json['artist'].forEach((v) {
//     //     artist!.add(Artist.fromJson(v));
//     //   });
//     // }
//
//     if (json['styles_he'] != null && json['styles_he'].toString() != "[]") {
//       stylesHe = <String>[];
//       json['styles_he'].forEach((v) {
//         stylesHe!.add(v);
//       });
//     }
//     if (json['business_img'] != null) {
//       businessimg = <BusinessImageModel>[];
//       json['business_img'].forEach((v) {
//         businessimg!.add(BusinessImageModel.fromJson(v));
//       });
//     }
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     data['name'] = this.name;
//     data['status'] = this.status;
//     data['email'] = this.email;
//     data['phone'] = this.phone;
//     data['cnt_code'] = this.cntCode;
//     data['lang'] = this.lang;
//     data['profile_image'] = this.profileImage;
//     data['styles'] = this.styles;
//     data['business_type'] = this.businessType;
//     data['user_type'] = this.userType;
//     data['login_type'] = this.loginType;
//     data['address'] = this.address;
//     data['address_lat'] = this.addressLat;
//     data['address_lng'] = this.addressLng;
//     data['address_place_id'] = this.addressPlaceId;
//     data['about_text'] = this.aboutText;
//     data['post_limit'] = this.postLimit;
//     data['is_register'] = this.isRegister;
//     // data['liked'] = this.liked;
//     // if (this.posts != null) {
//     //   data['posts'] = this.posts!.toJson();
//     // }
//     // if (this.artist != null) {
//     //   data['artist'] = this.artist!.map((v) => v.toJson()).toList();
//     // }
//
//     if (this.stylesHe != null) {
//       data['styles_he'] = this.stylesHe!.map((v) => v).toList();
//     }
//     if (this.businessimg != null) {
//       data['business_img'] = this.businessimg!.map((v) => v.toJson()).toList();
//     }
//
//     return data;
//   }
// }
// /*
// class Posts {
//   List<Sketch>? sketch;
//   List<Tatto>? tatto;
//
//   Posts({this.sketch, this.tatto});
//
//   Posts.fromJson(Map<String, dynamic> json) {
//     if (json['sketch'] != null) {
//       sketch = <Sketch>[];
//       json['sketch'].forEach((v) {
//         sketch!.add(new Sketch.fromJson(v));
//       });
//     }
//     if (json['tatto'] != null) {
//       tatto = <Tatto>[];
//       json['tatto'].forEach((v) {
//         tatto!.add(new Tatto.fromJson(v));
//       });
//     }
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     if (this.sketch != null) {
//       data['sketch'] = this.sketch!.map((v) => v.toJson()).toList();
//     }
//     if (this.tatto != null) {
//       data['tatto'] = this.tatto!.map((v) => v.toJson()).toList();
//     }
//     return data;
//   }
// }
//
// class Sketch {
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
//   Owner? owner;
//   Owner? artist;
//   String? liked;
//   String? followers;
//   String? postLiked;
//   int? postLikes;
//
//   Sketch(
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
//       this.owner,
//       this.artist,
//       this.liked,
//       this.followers,
//       this.postLiked,
//       this.postLikes});
//
//   Sketch.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     uid = json['uid'];
//     imgType = json['img_type'];
//     styles = json['styles'];
//     description = json['description'];
//     imageName = json['image_name'];
//     imageId = json['image_id'];
//     dateAdded = json['date_added'];
//     dateUpdated = json['date_updated'];
//     artistUid = json['artist_uid'];
//     status = json['status'];
//     studioUid = json['studio_uid'];
//     owner = json['owner'] != null ? new Owner.fromJson(json['owner']) : null;
//     artist = json['artist'] != null ? new Owner.fromJson(json['artist']) : null;
//     liked = json['liked'];
//     followers = json['followers'];
//     postLiked = json['post_liked'];
//     postLikes = json['post_likes'];
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
//     if (this.owner != null) {
//       data['owner'] = this.owner!.toJson();
//     }
//     if (this.artist != null) {
//       data['artist'] = this.artist!.toJson();
//     }
//     data['liked'] = this.liked;
//     data['followers'] = this.followers;
//     data['post_liked'] = this.postLiked;
//     data['post_likes'] = this.postLikes;
//     return data;
//   }
// }
//
// class Tatto {
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
//   Owner? owner;
//   Owner? artist;
//   String? liked;
//   String? followers;
//   String? postLiked;
//   int? postLikes;
//
//   Tatto(
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
//       this.owner,
//       this.artist,
//       this.liked,
//       this.followers,
//       this.postLiked,
//       this.postLikes});
//
//   Tatto.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     uid = json['uid'];
//     imgType = json['img_type'];
//     styles = json['styles'];
//     description = json['description'];
//     imageName = json['image_name'];
//     imageId = json['image_id'];
//     dateAdded = json['date_added'];
//     dateUpdated = json['date_updated'];
//     artistUid = json['artist_uid'];
//     status = json['status'];
//     studioUid = json['studio_uid'];
//     owner = json['owner'] != null ? new Owner.fromJson(json['owner']) : null;
//     artist = json['artist'] != null ? new Owner.fromJson(json['artist']) : null;
//     liked = json['liked'];
//     followers = json['followers'];
//     postLiked = json['post_liked'];
//     postLikes = json['post_likes'];
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
//     if (this.owner != null) {
//       data['owner'] = this.owner!.toJson();
//     }
//     if (this.artist != null) {
//       data['artist'] = this.artist!.toJson();
//     }
//     data['liked'] = this.liked;
//     data['followers'] = this.followers;
//     data['post_liked'] = this.postLiked;
//     data['post_likes'] = this.postLikes;
//     return data;
//   }
// }
// */
//
// class Owner {
//   String? id;
//   String? name;
//   String? status;
//   String? email;
//   String? phone;
//   String? cntCode;
//   String? lang;
//   String? profileImage;
//   String? styles;
//   String? businessType;
//   String? userType;
//   String? loginType;
//   String? address;
//   String? addressLat;
//   String? addressLng;
//   String? addressPlaceId;
//   String? aboutText;
//   String? postLimit;
//   String? isRegister;
//
//   Owner(
//       {this.id,
//         this.name,
//         this.status,
//         this.email,
//         this.phone,
//         this.cntCode,
//         this.lang,
//         this.profileImage,
//         this.styles,
//         this.businessType,
//         this.userType,
//         this.loginType,
//         this.address,
//         this.addressLat,
//         this.addressLng,
//         this.addressPlaceId,
//         this.aboutText,
//         this.postLimit,
//         this.isRegister});
//
//   Owner.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     name = json['name'];
//     status = json['status'];
//     email = json['email'];
//     phone = json['phone'];
//     cntCode = json['cnt_code'];
//     lang = json['lang'];
//     profileImage = json['profile_image'];
//     styles = json['styles'];
//     businessType = json['business_type'];
//     userType = json['user_type'];
//     loginType = json['login_type'];
//     address = json['address'];
//     addressLat = json['address_lat'];
//     addressLng = json['address_lng'];
//     addressPlaceId = json['address_place_id'];
//     aboutText = json['about_text'];
//     postLimit = json['post_limit'];
//     isRegister = json['is_register'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     data['name'] = this.name;
//     data['status'] = this.status;
//     data['email'] = this.email;
//     data['phone'] = this.phone;
//     data['cnt_code'] = this.cntCode;
//     data['lang'] = this.lang;
//     data['profile_image'] = this.profileImage;
//     data['styles'] = this.styles;
//     data['business_type'] = this.businessType;
//     data['user_type'] = this.userType;
//     data['login_type'] = this.loginType;
//     data['address'] = this.address;
//     data['address_lat'] = this.addressLat;
//     data['address_lng'] = this.addressLng;
//     data['address_place_id'] = this.addressPlaceId;
//     data['about_text'] = this.aboutText;
//     data['post_limit'] = this.postLimit;
//     data['is_register'] = this.isRegister;
//     return data;
//   }
// }
//
// class TattosInStyle {
//   String? id;
//   String? uid;
//   // String? imgType;
//   String? styles;
//   // String? description;
//   String? imageName;
//   String? imageId;
//   // String? dateAdded;
//   // String? dateUpdated;
//   // String? artistUid;
//   // String? status;
//   // String? studioUid;
//   // String? custId;
//
//   TattosInStyle(
//       {this.id,
//         this.uid,
//         // this.imgType,
//         this.styles,
//         // this.description,
//         this.imageName,
//         this.imageId,
//         // this.dateAdded,
//         // this.dateUpdated,
//         // this.artistUid,
//         // this.status,
//         // this.studioUid,
//         // this.custId
//       });
//
//   TattosInStyle.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     uid = json['uid'];
//     // imgType = json['img_type'];
//     styles = json['styles'];
//     // description = json['description'];
//     imageName = json['image_name'];
//     imageId = json['image_id'];
//     // dateAdded = json['date_added'];
//     // dateUpdated = json['date_updated'];
//     // artistUid = json['artist_uid'];
//     // status = json['status'];
//     // studioUid = json['studio_uid'];
//     // custId = json['cust_id'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     data['uid'] = this.uid;
//     // data['img_type'] = this.imgType;
//     data['styles'] = this.styles;
//     // data['description'] = this.description;
//     data['image_name'] = this.imageName;
//     data['image_id'] = this.imageId;
//     // data['date_added'] = this.dateAdded;
//     // data['date_updated'] = this.dateUpdated;
//     // data['artist_uid'] = this.artistUid;
//     // data['status'] = this.status;
//     // data['studio_uid'] = this.studioUid;
//     // data['cust_id'] = this.custId;
//     return data;
//   }
// }
//
// class NewUserList {
//   String? id;
//   String? name;
//   String? status;
//   String? email;
//   String? phone;
//   String? cntCode;
//   String? lang;
//   String? profileImage;
//   String? styles;
//   String? businessType;
//   String? userType;
//   String? loginType;
//   String? address;
//   String? addressLat;
//   String? addressLng;
//   String? addressPlaceId;
//   String? aboutText;
//   String? postLimit;
//   String? isRegister;
//
//   NewUserList(
//       {this.id,
//         this.name,
//         this.status,
//         this.email,
//         this.phone,
//         this.cntCode,
//         this.lang,
//         this.profileImage,
//         this.styles,
//         this.businessType,
//         this.userType,
//         this.loginType,
//         this.address,
//         this.addressLat,
//         this.addressLng,
//         this.addressPlaceId,
//         this.aboutText,
//         this.postLimit,
//         this.isRegister});
//
//   NewUserList.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     name = json['name'];
//     status = json['status'];
//     email = json['email'];
//     phone = json['phone'];
//     cntCode = json['cnt_code'];
//     lang = json['lang'];
//     profileImage = json['profile_image'];
//     styles = json['styles'];
//     businessType = json['business_type'];
//     userType = json['user_type'];
//     loginType = json['login_type'];
//     address = json['address'];
//     addressLat = json['address_lat'];
//     addressLng = json['address_lng'];
//     addressPlaceId = json['address_place_id'];
//     aboutText = json['about_text'];
//     postLimit = json['post_limit'];
//     isRegister = json['is_register'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     data['name'] = this.name;
//     data['status'] = this.status;
//     data['email'] = this.email;
//     data['phone'] = this.phone;
//     data['cnt_code'] = this.cntCode;
//     data['lang'] = this.lang;
//     data['profile_image'] = this.profileImage;
//     data['styles'] = this.styles;
//     data['business_type'] = this.businessType;
//     data['user_type'] = this.userType;
//     data['login_type'] = this.loginType;
//     data['address'] = this.address;
//     data['address_lat'] = this.addressLat;
//     data['address_lng'] = this.addressLng;
//     data['address_place_id'] = this.addressPlaceId;
//     data['about_text'] = this.aboutText;
//     data['post_limit'] = this.postLimit;
//     data['is_register'] = this.isRegister;
//     return data;
//   }
// }
//
// class BusinessImageModel {
//   String? postId;
//   String? imageUrl;
//
//   BusinessImageModel({this.postId, this.imageUrl});
//
//   BusinessImageModel.fromJson(Map<String, dynamic> json) {
//     postId = json['post_id'].toString()??"";
//     imageUrl = json['image_url'].toString()??"";
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['post_id'] = this.postId;
//     data['image_url'] = this.imageUrl;
//     return data;
//   }
// }
