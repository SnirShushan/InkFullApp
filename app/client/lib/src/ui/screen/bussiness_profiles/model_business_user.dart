import 'package:ink/src/data/model/ArtistModel.dart';

class BusinessUserListModel {
  String? id;
  String? name;
  String? status;
  String? email;
  String? phone;
  String? cntCode;
  String? lang;
  String? profileImage;
  String? styles;
  List<String>? stylesHe;
  String? businessType;
  String? userType;
  String? loginType;
  String? address;
  String? addressLat;
  String? addressLng;
  String? addressPlaceId;
  String? aboutText;
  String? postLimit;
  String? isRegister;
  String? liked;
  String? followers;
  Posts? posts;
  List<Artist>? artist;
  List<BusinessImg>? businessImg;

  BusinessUserListModel(
      {this.id,
      this.name,
      this.status,
      this.email,
      this.phone,
      this.cntCode,
      this.lang,
      this.profileImage,
      this.styles,
      this.stylesHe,
      this.businessType,
      this.userType,
      this.loginType,
      this.address,
      this.addressLat,
      this.addressLng,
      this.addressPlaceId,
      this.aboutText,
      this.postLimit,
      this.isRegister,
      this.liked,
      this.followers,
      this.posts,
      this.artist,
      this.businessImg});

  BusinessUserListModel.fromJson(Map<String, dynamic> json) {
    id = json['id'].toString();
    name = json['name'].toString();
    status = json['status'].toString();
    email = json['email'].toString();
    phone = json['phone'].toString();
    cntCode = json['cnt_code'].toString();
    lang = json['lang'].toString();
    profileImage = json['profile_image'].toString();
    styles = json['styles'].toString();
    businessType = json['business_type'].toString();
    userType = json['user_type'].toString();
    loginType = json['login_type'].toString();
    address = json['address'].toString();
    addressLat = json['address_lat'].toString();
    addressLng = json['address_lng'].toString();
    addressPlaceId = json['address_place_id'].toString();
    aboutText = json['about_text'].toString();
    postLimit = json['post_limit'].toString();
    isRegister = json['is_register'].toString();
    liked = json['liked'].toString();
    followers = json['followers'].toString();
    posts = json['posts'] != null ? new Posts.fromJson(json['posts']) : null;
    if (json['artist'] != null &&
        json['artist'].toString() != "[]" &&
        json['artist'].toString() != "[[]]") {
      artist = <Artist>[];
      json['artist'].forEach((v) {
        artist!.add(Artist.fromJson(v));
      });
    }

    if (json['styles_he'] != null) {
      stylesHe = <String>[];
      json['styles_he'].forEach((v) {
        stylesHe!.add(v);
      });
    }
    if (json['business_img'] != null) {
      businessImg = <BusinessImg>[];
      json['business_img'].forEach((v) {
        businessImg!.add(new BusinessImg.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['status'] = this.status;
    data['email'] = this.email;
    data['phone'] = this.phone;
    data['cnt_code'] = this.cntCode;
    data['lang'] = this.lang;
    data['profile_image'] = this.profileImage;
    data['styles'] = this.styles;
    data['business_type'] = this.businessType;
    data['user_type'] = this.userType;
    data['login_type'] = this.loginType;
    data['address'] = this.address;
    data['address_lat'] = this.addressLat;
    data['address_lng'] = this.addressLng;
    data['address_place_id'] = this.addressPlaceId;
    data['about_text'] = this.aboutText;
    data['post_limit'] = this.postLimit;
    data['is_register'] = this.isRegister;
    data['liked'] = this.liked;
    data['followers'] = this.followers;
    if (this.posts != null) {
      data['posts'] = this.posts!.toJson();
    }
    if (this.stylesHe != null) {
      data['styles_he'] = this.stylesHe!.map((v) => v).toList();
    }
    if (this.artist != null) {
      data['artist'] = this.artist!.map((v) => v.toJson()).toList();
    }
    if (this.businessImg != null && businessImg!.isNotEmpty) {
      data['business_img'] = this.businessImg!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Posts {
  List<Tatto>? sketch;
  List<Tatto>? tatto;

  Posts({this.sketch, this.tatto});

  Posts.fromJson(Map<String, dynamic> json) {
    if (json['sketch'] != null) {
      sketch = <Tatto>[];
      json['sketch'].forEach((v) {
        sketch!.add(new Tatto.fromJson(v));
      });
    }
    if (json['tatto'] != null) {
      tatto = <Tatto>[];
      json['tatto'].forEach((v) {
        tatto!.add(new Tatto.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.sketch != null) {
      data['sketch'] = this.sketch!.map((v) => v.toJson()).toList();
    }
    if (this.tatto != null) {
      data['tatto'] = this.tatto!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Tatto {
  String? id;
  String? uid;
  String? imgType;
  String? styles;
  String? description;
  String? imageName;
  String? imageId;
  String? dateAdded;
  String? dateUpdated;
  String? artistUid;
  String? status;
  String? studioUid;
  Owner? owner;
  Owner? artist;
  String? liked;
  String? followers;
  String? postLiked;
  String? postLikes;

  Tatto(
      {this.id,
      this.uid,
      this.imgType,
      this.styles,
      this.description,
      this.imageName,
      this.imageId,
      this.dateAdded,
      this.dateUpdated,
      this.artistUid,
      this.status,
      this.studioUid,
      this.owner,
      this.artist,
      this.liked,
      this.followers,
      this.postLiked,
      this.postLikes});

  Tatto.fromJson(Map<String, dynamic> json) {
    id = json['id'].toString();
    uid = json['uid'].toString();
    imgType = json['img_type'].toString();
    styles = json['styles'].toString();
    description = json['description'].toString();
    imageName = json['image_name'].toString();
    imageId = json['image_id'].toString();
    dateAdded = json['date_added'].toString();
    dateUpdated = json['date_updated'].toString();
    artistUid = json['artist_uid'].toString();
    status = json['status'].toString();
    studioUid = json['studio_uid'].toString();
    // owner = (json['owner'] != null || json['owner'] == "[]")
    //     ? new Owner.fromJson(json['owner'])
    //     : null;
    // artist = (json['artist'] != null || json['artist'] == "[]")
    //     ? new Owner.fromJson(json['artist'])
    //     : null;
    liked = json['liked'];
    followers = json['followers'].toString();
    postLiked = json['post_liked'].toString();
    postLikes = json['post_likes'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['uid'] = this.uid;
    data['img_type'] = this.imgType;
    data['styles'] = this.styles;
    data['description'] = this.description;
    data['image_name'] = this.imageName;
    data['image_id'] = this.imageId;
    data['date_added'] = this.dateAdded;
    data['date_updated'] = this.dateUpdated;
    data['artist_uid'] = this.artistUid;
    data['status'] = this.status;
    data['studio_uid'] = this.studioUid;
    if (this.owner != null) {
      data['owner'] = this.owner!.toJson();
    }
    if (this.artist != null) {
      data['artist'] = this.artist!.toJson();
    }
    data['liked'] = this.liked;
    data['followers'] = this.followers;
    data['post_liked'] = this.postLiked;
    data['post_likes'] = this.postLikes;
    return data;
  }
}

class Owner {
  String? id;
  String? name;
  String? status;
  String? email;
  String? phone;
  String? cntCode;
  String? lang;
  String? profileImage;
  String? styles;
  String? businessType;
  String? userType;
  String? loginType;
  String? address;
  String? addressLat;
  String? addressLng;
  String? addressPlaceId;
  String? aboutText;
  String? postLimit;
  String? isRegister;

  Owner(
      {this.id,
      this.name,
      this.status,
      this.email,
      this.phone,
      this.cntCode,
      this.lang,
      this.profileImage,
      this.styles,
      this.businessType,
      this.userType,
      this.loginType,
      this.address,
      this.addressLat,
      this.addressLng,
      this.addressPlaceId,
      this.aboutText,
      this.postLimit,
      this.isRegister});

  Owner.fromJson(Map<String, dynamic> json) {
    id = json['id'].toString();
    name = json['name'].toString();
    status = json['status'].toString();
    email = json['email'].toString();
    phone = json['phone'].toString();
    cntCode = json['cnt_code'].toString();
    lang = json['lang'].toString();
    profileImage = json['profile_image'].toString();
    styles = json['styles'].toString();
    businessType = json['business_type'].toString();
    userType = json['user_type'].toString();
    loginType = json['login_type'].toString();
    address = json['address'].toString();
    addressLat = json['address_lat'].toString();
    addressLng = json['address_lng'].toString();
    addressPlaceId = json['address_place_id'].toString();
    aboutText = json['about_text'].toString();
    postLimit = json['post_limit'].toString();
    isRegister = json['is_register'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['status'] = this.status;
    data['email'] = this.email;
    data['phone'] = this.phone;
    data['cnt_code'] = this.cntCode;
    data['lang'] = this.lang;
    data['profile_image'] = this.profileImage;
    data['styles'] = this.styles;
    data['business_type'] = this.businessType;
    data['user_type'] = this.userType;
    data['login_type'] = this.loginType;
    data['address'] = this.address;
    data['address_lat'] = this.addressLat;
    data['address_lng'] = this.addressLng;
    data['address_place_id'] = this.addressPlaceId;
    data['about_text'] = this.aboutText;
    data['post_limit'] = this.postLimit;
    data['is_register'] = this.isRegister;
    return data;
  }
}

class BusinessImg {
  String? postId;
  String? imageUrl;
  String? isMultipleImages;
  BusinessImg({this.postId, this.imageUrl});

  BusinessImg.fromJson(Map<String, dynamic> json) {
    postId = json['post_id'].toString();
    imageUrl = json['image_url'].toString();
    isMultipleImages = json['is_multiple_image'].toString()??"0";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['post_id'] = this.postId;
    data['image_url'] = this.imageUrl;
    data['is_multiple_image'] = this.isMultipleImages;
    return data;
  }
}
