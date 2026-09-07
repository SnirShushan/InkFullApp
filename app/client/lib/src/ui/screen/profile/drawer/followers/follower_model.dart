class FollowerModel {
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
  String? cityname;
  String? addressLat;
  String? addressLng;
  String? addressPlaceId;
  String? aboutText;
  String? postLimit;
  String? isRegister;

  FollowerModel(
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
      this.cityname,
      this.address,
      this.addressLat,
      this.addressLng,
      this.addressPlaceId,
      this.aboutText,
      this.postLimit,
      this.isRegister});

  FollowerModel.fromJson(Map<String, dynamic> json) {
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
    cityname = json['city_name'].toString();
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
    data['city_name'] = this.cityname;
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
