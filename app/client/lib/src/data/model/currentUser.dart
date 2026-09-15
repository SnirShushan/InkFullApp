class AppUser {
  Profile? profile;
  List<StylesList>? stylesList;

  // List<Artist>? artist;
  String? followers;

  String? startup_image;

  AppUser({this.profile, this.stylesList, this.followers, this.startup_image});

  AppUser.fromJson(Map<String, dynamic> json) {
    profile =
        json['profile'] != null ? new Profile.fromJson(json['profile']) : null;
    if (json['styles_list'] != null) {
      stylesList = <StylesList>[];
      json['styles_list'].forEach((v) {
        stylesList!.add(StylesList.fromJson(v));
      });
    }
    // if (json['artist'] != null) {
    //   artist = <Artist>[];
    //   json['artist'].forEach((v) {
    //     artist!.add(new Artist.fromJson(v));
    //   });
    // }
    followers = json['followers'].toString() ?? "0";
    startup_image = json['startup_image'].toString() ?? "0";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.profile != null) {
      data['profile'] = this.profile!.toJson();
    }
    if (this.stylesList != null) {
      data['styles_list'] = this.stylesList!.map((v) => v.toJson()).toList();
    }
    // if (this.artist != null) {
    //   data['artist'] = this.artist!.map((v) => v.toJson()).toList();
    // }
    data['followers'] = this.followers;
    data['startup_image'] = this.startup_image;
    return data;
  }
}

class Profile {
  String? id;
  String? firebaseId;
  String? name;
  String? email;
  String? phone;
  String? cntCode;
  String? udId;
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
  String? locationEnable;
  String? pushEnable;
  String? isRegister;
  List<String>? stylesHe;

  Profile(
      {this.id,
      this.firebaseId,
      this.name,
      this.email,
      this.phone,
      this.cntCode,
      this.udId,
      this.lang,
      this.profileImage,
      this.loginToken,
      this.styles,
      this.businessType,
      this.userType,
      this.loginType,
      this.address,
      this.addressLat,
      this.isRegister,
      this.addressLng,
      this.addressPlaceId,
      this.aboutText,
      this.stylesHe,
      this.locationEnable,
      this.pushEnable});

  Profile.fromJson(Map<String, dynamic> json) {
    String nz(dynamic v) {
      if (v == null) return '';
      final s = v.toString();
      if (s == 'null' || s == 'undefined') return '';
      return s;
    }

    id = nz(json['id']);
    firebaseId = nz(json['firebase_id']);
    name = nz(json['name']);
    email = nz(json['email']);
    phone = nz(json['phone']);
    cntCode = nz(json['cnt_code']);
    udId = nz(json['udid']);
    lang = nz(json['lang']);
    profileImage = nz(json['profile_image']);
    loginToken = nz(json['login_token']);
    styles = nz(json['styles']);
    businessType = nz(json['business_type']);
    userType = nz(json['user_type']);
    loginType = nz(json['login_type']);
    address = nz(json['address']);
    addressLat = nz(json['address_lat']);
    addressLng = nz(json['address_lng']);
    addressPlaceId = nz(json['address_place_id']);
    aboutText = nz(json['about_text']);
    locationEnable = nz(json['location_enable']);
    pushEnable = nz(json['push_enable']);
    isRegister = nz(json['is_register']).isEmpty ? '0' : nz(json['is_register']);
    if (json['styles_he'] != null && json['styles_he'] is List) {
      stylesHe = <String>[];
      for (final v in json['styles_he'] as List) {
        stylesHe!.add(v.toString());
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['firebase_id'] = this.firebaseId;
    data['name'] = this.name;
    data['email'] = this.email;
    data['phone'] = this.phone;
    data['cnt_code'] = this.cntCode;
    data['udid'] = this.udId;
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
    data['location_enable'] = this.locationEnable;
    data['push_enable'] = this.pushEnable;
    data['is_register'] = this.isRegister;
    if (this.stylesHe != null) {
      data['styles_he'] = this.stylesHe!.map((v) => v).toList();
    }
    return data;
  }
}

class StylesList {
  String? id;
  String? name;
  String? nameEn;
  String? imageName;
  String? slug;

  StylesList({this.id, this.name, this.nameEn, this.imageName, this.slug});

  StylesList.fromJson(Map<String, dynamic> json) {
    String nz(dynamic v) {
      if (v == null) return '';
      final s = v.toString();
      if (s == 'null' || s == 'undefined') return '';
      return s;
    }

    id = nz(json['id']);
    name = nz(json['name']);
    nameEn = nz(json['name_en']);
    imageName = nz(json['image_name']);
    slug = nz(json['slug']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['name_en'] = this.nameEn;
    data['image_name'] = this.imageName;
    data['slug'] = this.slug;
    return data;
  }
}
