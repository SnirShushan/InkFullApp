import 'package:ink/src/data/model/ArtistModel.dart';

class MPostDetails {
  String? id;
  String? uid;
  String? imgType;
  String? styles;
  String? description;
  dynamic  imageName;
  String? imageId;
  String? dateAdded;
  String? dateUpdated;
  String? artistUid;
  String? status;
  String? studioUid;
  Owner? owner;
  Artist? artist;
  String? liked;
  // String? followers;
  // String? postLiked;
  // String? postLikes;
  List<String>? tagList;
  String? tagStr;
  List<String>? tagListEn;
  String? tagStrEn;
  String? isMultipleImages;
  List<RelatedPosts>? relatedPosts;

  MPostDetails(
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
      this.isMultipleImages,
      // this.followers,
      // this.postLiked,
      // this.postLikes,
      this.tagList,
      this.tagStr,
      this.tagListEn,
      this.tagStrEn,
      this.relatedPosts});

  MPostDetails.fromJson(Map<String, dynamic> json) {
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
    isMultipleImages = json['is_multiple_image'].toString()??"0";
    owner = json['owner'] == null || json['owner'].toString() == "[]"
        ? null
        : Owner.fromJson(json['owner']);

    artist = json['artist'] == null || json['artist'].toString() == "[]"
        ? null
        : Artist.fromJson(json['artist']);

    liked = json['liked'].toString();
    // followers = json['followers'].toString();
    // postLiked = json['post_liked'].toString();
    // postLikes = json['post_likes'].toString();
    tagList = json['tag_list'].cast<String>();
    tagStr = json['tag_str'].toString();
    tagListEn = json['tag_list_en'].cast<String>();
    tagStrEn = json['tag_str_en'].toString();
    if (json['related_posts'] != null) {
      relatedPosts = <RelatedPosts>[];
      json['related_posts'].forEach((v) {
        relatedPosts!.add(RelatedPosts.fromJson(v));
      });
    }
  }
  // Add this method to get images as List<String>
  List<String> getImageUrls() {
    if (imageName == null) return [];

    if (imageName is String) {
      return [imageName as String];
    } else if (imageName is List) {
      // Handle List<dynamic> or List<String>
      return imageName.map((item) => item.toString()).toList().cast<String>();
    }

    return [];
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
    data['is_multiple_image'] = this.isMultipleImages;
    if (this.owner != null) {
      data['owner'] = this.owner!.toJson();
    }
    if (this.artist != null) {
      data['artist'] = this.artist!.toJson();
    }
    data['liked'] = this.liked;
    // data['followers'] = this.followers;
    // data['post_liked'] = this.postLiked;
    // data['post_likes'] = this.postLikes;
    data['tag_list'] = this.tagList;
    data['tag_str'] = this.tagStr;
    data['tag_list_en'] = this.tagListEn;
    data['tag_str_en'] = this.tagStrEn;
    if (this.relatedPosts != null) {
      data['related_posts'] =
          this.relatedPosts!.map((v) => v.toJson()).toList();
    }
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

class RelatedPosts {
  String? id;
  String? uid;
  String? imgType;
  // String? styles;
  // String? description;
  String? imageName;
  String? imageId;
  String? isMultipleImages;

  RelatedPosts(
      {this.id,
      this.uid,
      this.imgType,
      // this.styles,
      // this.description,
      this.imageName,
      this.isMultipleImages,
      this.imageId});

  RelatedPosts.fromJson(Map<String, dynamic> json) {
    id = json['id'].toString();
    uid = json['uid'].toString();
    imgType = json['img_type'].toString();
    // styles = json['styles'].toString();
    // description = json['description'].toString();
    imageName = json['image_name'].toString();
    isMultipleImages = json['is_multiple_image'].toString()??"0";
    imageId = json['image_id'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['uid'] = this.uid;
    data['img_type'] = this.imgType;
    // data['styles'] = this.styles;
    // data['description'] = this.description;
    data['image_name'] = this.imageName;
    data['image_id'] = this.imageId;
    data['is_multiple_image'] = this.isMultipleImages;
    return data;
  }
}

/*
import 'ArtistModel.dart';

class MPostDetails {
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
  Artist? artist;
  String? liked;
  String? followers;
  String? postLiked;
  String? postLikes;
  List<String>? tagList;
  String? tagStr;
  List<String>? tagListEn;
  String? tagStrEn;

  MPostDetails(
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
      this.postLikes,
      this.tagList,
      this.tagStr,
      this.tagListEn,
      this.tagStrEn});

  MPostDetails.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    uid = json['uid'];
    imgType = json['img_type'];
    styles = json['styles'];
    description = json['description'];
    imageName = json['image_name'];
    imageId = json['image_id'];
    dateAdded = json['date_added'];
    dateUpdated = json['date_updated'];
    artistUid = json['artist_uid'];
    status = json['status'];
    studioUid = json['studio_uid'];
    owner = json['owner'] != null ? new Owner.fromJson(json['owner']) : null;
    artist = json['artist'] == null || json['artist'].toString() == "[]"
        ? null
        : new Artist.fromJson(json['artist']);

    liked = json['liked'];
    followers = json['followers'];
    postLiked = json['post_liked'].toString();
    postLikes = json['post_likes'].toString();
    if (json['tag_list'] != null) {
      tagList = [];
      json['tag_list'].forEach((v) {
        tagList!.add(v);
      });
    }
    tagStr = json['tag_str'];
    if (json['tag_list_en'] != null) {
      tagListEn = [];
      json['tag_list_en'].forEach((v) {
        tagListEn!.add(v);
      });
    }
    tagStrEn = json['tag_str_en'];
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
    // if (this.artist != null) {
    //   data['artist'] = this.artist!.map((v) => v.toJson()).toList();
    // }
    data['liked'] = this.liked;
    data['followers'] = this.followers;
    data['post_liked'] = this.postLiked;
    data['post_likes'] = this.postLikes;
    if (this.tagList != null) {
      data['tag_list'] = this.tagList!.map((v) => v).toList();
    }
    data['tag_str'] = this.tagStr;
    if (this.tagListEn != null) {
      data['tag_list_en'] = this.tagListEn!.map((v) => v).toList();
    }
    data['tag_str_en'] = this.tagStrEn;
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
      this.aboutText});

  Owner.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    status = json['status'];
    email = json['email'];
    phone = json['phone'];
    cntCode = json['cnt_code'];
    lang = json['lang'];
    profileImage = json['profile_image'];
    styles = json['styles'];
    businessType = json['business_type'];
    userType = json['user_type'];
    loginType = json['login_type'];
    address = json['address'];
    addressLat = json['address_lat'];
    addressLng = json['address_lng'];
    addressPlaceId = json['address_place_id'];
    aboutText = json['about_text'];
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
    return data;
  }
}
*/
