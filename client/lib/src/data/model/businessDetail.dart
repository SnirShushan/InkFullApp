import 'package:ink/src/data/model/post_model.dart';

import 'ArtistModel.dart';

class BusinessDetail {
  Detail? detail;

  BusinessDetail({this.detail});

  BusinessDetail.fromJson(Map<String, dynamic> json) {
    detail =
        json['detail'] != null ? new Detail.fromJson(json['detail']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.detail != null) {
      data['detail'] = this.detail!.toJson();
    }
    return data;
  }
}

class Detail {
  String? id;
  String? name;
  String? email;
  String? phone;
  String? cntCode;
  String? lang;
  String? profileImage;
  String? loginToken;
  String? styles;
  String? businessType;
  String? userType;
  String? loginType;
  String? address;
  String? addressLat;
  String? addressLng;
  String? addressPlaceId;
  String? aboutText;
  String? liked;
  String? followers;
  // Posts? posts;
  List<Artist>? artist;

  Detail(
      {this.id,
      this.name,
      this.email,
      this.phone,
      this.cntCode,
      this.lang,
      this.profileImage,
      this.loginToken,
      this.styles,
      this.businessType,
      this.userType,
      this.loginType,
      this.address,
      this.addressLat,
      this.addressLng,
      this.addressPlaceId,
      this.aboutText,
      this.liked,
      this.followers,
      // this.posts,
      this.artist});

  Detail.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
    cntCode = json['cnt_code'];
    lang = json['lang'];
    profileImage = json['profile_image'];
    loginToken = json['login_token'];
    styles = json['styles'];
    businessType = json['business_type'];
    userType = json['user_type'];
    loginType = json['login_type'];
    address = json['address'];
    addressLat = json['address_lat'];
    addressLng = json['address_lng'];
    addressPlaceId = json['address_place_id'];
    aboutText = json['about_text'];
    liked = json['liked'];
    followers = json['followers'];
    // posts = json['posts'] != null ? new Posts.fromJson(json['posts']) : null;
    if (json['artist'] != null) {
      artist = <Artist>[];
      json['artist'].forEach((v) {
        artist!.add(new Artist.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['email'] = this.email;
    data['phone'] = this.phone;
    data['cnt_code'] = this.cntCode;
    data['lang'] = this.lang;
    data['profile_image'] = this.profileImage;
    data['login_token'] = this.loginToken;
    data['styles'] = this.styles;
    data['business_type'] = this.businessType;
    data['user_type'] = this.userType;
    data['login_type'] = this.loginType;
    data['address'] = this.address;
    data['address_lat'] = this.addressLat;
    data['address_lng'] = this.addressLng;
    data['address_place_id'] = this.addressPlaceId;
    data['about_text'] = this.aboutText;
    data['liked'] = this.liked;
    data['followers'] = this.followers;
    // if (this.posts != null) {
    //   data['posts'] = this.posts!.toJson();
    // }
    if (this.artist != null) {
      data['artist'] = this.artist!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

// class Posts {
//   List<PostModel>? l0;
//   List<PostModel>? l1;
//
//   Posts({this.l0, this.l1});
//
//   Posts.fromJson(Map<String, dynamic> json) {
//     if (json['0'] != null) {
//       l0 = <PostModel>[];
//       json['0'].forEach((v) {
//         l0!.add(new PostModel.fromJson(v));
//       });
//     }
//     if (json['1'] != null) {
//       l1 = <PostModel>[];
//       json['1'].forEach((v) {
//         l1!.add(new PostModel.fromJson(v));
//       });
//     }
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     if (this.l0 != null) {
//       data['0'] = this.l0!.map((v) => v.toJson()).toList();
//     }
//     if (this.l1 != null) {
//       data['1'] = this.l1!.map((v) => v.toJson()).toList();
//     }
//     return data;
//   }
// }
