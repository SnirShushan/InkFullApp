class HomeModel {
  List<Business>? business;
  String? isFilter;
  List<TattosInStyle>? tattosInStyle;
  List<NewUserList>? newUserList;
  String? isNewNotification;

  HomeModel(
      {this.business,
      this.isFilter,
      this.tattosInStyle,
      this.newUserList,
      this.isNewNotification});

  HomeModel.fromJson(Map<String, dynamic> json) {
    if (json['business'] != null) {
      business = <Business>[];
      json['business'].forEach((v) {
        business!.add(new Business.fromJson(v));
      });
    }
    isFilter = json['is_filter'];
    if (json['tattos_in_style'] != null) {
      tattosInStyle = <TattosInStyle>[];
      json['tattos_in_style'].forEach((v) {
        tattosInStyle!.add(new TattosInStyle.fromJson(v));
      });
    }
    if (json['new_user_list'] != null) {
      newUserList = <NewUserList>[];
      json['new_user_list'].forEach((v) {
        newUserList!.add(new NewUserList.fromJson(v));
      });
    }
    isNewNotification = json['is_new_notification'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.business != null) {
      data['business'] = this.business!.map((v) => v.toJson()).toList();
    }
    data['is_filter'] = this.isFilter;
    if (this.tattosInStyle != null) {
      data['tattos_in_style'] =
          this.tattosInStyle!.map((v) => v.toJson()).toList();
    }
    if (this.newUserList != null) {
      data['new_user_list'] = this.newUserList!.map((v) => v.toJson()).toList();
    }
    data['is_new_notification'] = this.isNewNotification;
    return data;
  }
}

class Business {
  String? id;
  String? name;
  String? status;
  // String? email;
  // String? phone;
  // String? cntCode;
  // String? lang;
  String? profileImage;
  String? styles;
  String? businessType;
  String? userType;
  String? loginType;
  String? address;
  // String? addressLat;
  // String? addressLng;
  // String? addressPlaceId;
  // String? aboutText;
  // String? postLimit;
  // String? isRegister;
  // String? liked;
  // String? followers;
  List<String>? stylesHe;

  List<BusinessImageModel>? businessimg;

  Business({
    this.id,
    this.name,
    this.status,
    // this.email,
    // this.phone,
    // this.cntCode,
    // this.lang,
    this.profileImage,
    this.styles,
    this.businessType,
    this.userType,
    this.stylesHe,
    this.loginType,
    this.address,
    // this.addressLat,
    // this.addressLng,
    // this.addressPlaceId,
    // this.aboutText,
    // this.postLimit,
    // this.isRegister,
    this.businessimg,

  });

  Business.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    status = json['status'];
    // email = json['email'];
    // phone = json['phone'];
    // cntCode = json['cnt_code'];
    // lang = json['lang'];
    profileImage = json['profile_image'];
    styles = json['styles'];
    businessType = json['business_type'];
    userType = json['user_type'];
    loginType = json['login_type'];
    address = json['address'];
    // addressLat = json['address_lat'];
    // addressLng = json['address_lng'];
    // addressPlaceId = json['address_place_id'];
    // aboutText = json['about_text'];
    // postLimit = json['post_limit'];
    // isRegister = json['is_register'];

    if (json['styles_he'] != null && json['styles_he'].toString() != "[]") {
      stylesHe = <String>[];
      json['styles_he'].forEach((v) {
        stylesHe!.add(v);
      });
    }
    if (json['business_img'] != null) {
      businessimg = <BusinessImageModel>[];
      json['business_img'].forEach((v) {
        businessimg!.add(BusinessImageModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['status'] = this.status;
    // data['email'] = this.email;
    // data['phone'] = this.phone;
    // data['cnt_code'] = this.cntCode;
    // data['lang'] = this.lang;
    data['profile_image'] = this.profileImage;
    data['styles'] = this.styles;
    data['business_type'] = this.businessType;
    data['user_type'] = this.userType;
    data['login_type'] = this.loginType;
    data['address'] = this.address;
    // data['address_lat'] = this.addressLat;
    // data['address_lng'] = this.addressLng;
    // data['address_place_id'] = this.addressPlaceId;
    // data['about_text'] = this.aboutText;
    // data['post_limit'] = this.postLimit;
    // data['is_register'] = this.isRegister;

    if (this.stylesHe != null) {
      data['styles_he'] = this.stylesHe!.map((v) => v).toList();
    }
    if (this.businessimg != null) {
      data['business_img'] = this.businessimg!.map((v) => v.toJson()).toList();
    }

    return data;
  }
}



class TattosInStyle {
  String? id;
  String? uid;
  // String? styles;
  String? imageName;
  // String? imageId;
  String? isMultipleImages;

  TattosInStyle(
      {this.id,
      this.uid,
      // this.styles,
      this.imageName,
        this.isMultipleImages,
      // this.imageId,
      });

  TattosInStyle.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    uid = json['uid'];
    // styles = json['styles'];
    imageName = json['image_name'];
    isMultipleImages = json['is_multiple_image'].toString()??"0";
    // imageId = json['image_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['uid'] = this.uid;
    // data['styles'] = this.styles;
    data['image_name'] = this.imageName;
    data['is_multiple_image'] = this.isMultipleImages;
    // data['image_id'] = this.imageId;
    return data;
  }
}

class NewUserList {
  String? id;
  String? name;
  String? status;
  // String? email;
  // String? phone;
  // String? cntCode;
  // String? lang;
  String? profileImage;
  // String? styles;
  // String? businessType;
  // String? userType;
  // String? loginType;
  // String? address;
  // String? addressLat;
  // String? addressLng;
  // String? addressPlaceId;
  // String? aboutText;
  // String? postLimit;
  // String? isRegister;

  NewUserList(
      {this.id,
      this.name,
      this.status,
      // this.email,
      // this.phone,
      // this.cntCode,
      // this.lang,
      this.profileImage,
      // this.styles,
      // this.businessType,
      // this.userType,
      // this.loginType,
      // this.address,
      // this.addressLat,
      // this.addressLng,
      // this.addressPlaceId,
      // this.aboutText,
      // this.postLimit,
      // this.isRegister
      });

  NewUserList.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    status = json['status'];
    // email = json['email'];
    // phone = json['phone'];
    // cntCode = json['cnt_code'];
    // lang = json['lang'];
    profileImage = json['profile_image'];
    // styles = json['styles'];
    // businessType = json['business_type'];
    // userType = json['user_type'];
    // loginType = json['login_type'];
    // address = json['address'];
    // addressLat = json['address_lat'];
    // addressLng = json['address_lng'];
    // addressPlaceId = json['address_place_id'];
    // aboutText = json['about_text'];
    // postLimit = json['post_limit'];
    // isRegister = json['is_register'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['status'] = this.status;
    // data['email'] = this.email;
    // data['phone'] = this.phone;
    // data['cnt_code'] = this.cntCode;
    // data['lang'] = this.lang;
    data['profile_image'] = this.profileImage;
    // data['styles'] = this.styles;
    // data['business_type'] = this.businessType;
    // data['user_type'] = this.userType;
    // data['login_type'] = this.loginType;
    // data['address'] = this.address;
    // data['address_lat'] = this.addressLat;
    // data['address_lng'] = this.addressLng;
    // data['address_place_id'] = this.addressPlaceId;
    // data['about_text'] = this.aboutText;
    // data['post_limit'] = this.postLimit;
    // data['is_register'] = this.isRegister;
    return data;
  }
}

class BusinessImageModel {
  String? postId;
  String? imageUrl;
  String? isMultipleImages;

  BusinessImageModel({this.postId, this.imageUrl, this.isMultipleImages});

  BusinessImageModel.fromJson(Map<String, dynamic> json) {
    postId = json['post_id'].toString()??"";
    imageUrl = json['image_url'].toString()??"";
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
