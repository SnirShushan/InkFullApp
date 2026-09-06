class UserArtistModel {
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
  String? cityName;
  String? aboutText;
  String? postLimit;
  String? isRegister;
  String? isEmailSendPlanUpgrade;
  String? isEmailSend;

  UserArtistModel(
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
      this.cityName,
      this.aboutText,
      this.postLimit,
      this.isRegister,
      this.isEmailSendPlanUpgrade,
      this.isEmailSend});

  UserArtistModel.fromJson(Map<String, dynamic> json) {
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
    cityName = json['city_name'];
    aboutText = json['about_text'];
    postLimit = json['post_limit'];
    isRegister = json['is_register'];
    isEmailSendPlanUpgrade = json['is_email_send_plan_upgrade'];
    isEmailSend = json['is_email_send'];
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
    data['city_name'] = this.cityName;
    data['about_text'] = this.aboutText;
    data['post_limit'] = this.postLimit;
    data['is_register'] = this.isRegister;
    data['is_email_send_plan_upgrade'] = this.isEmailSendPlanUpgrade;
    data['is_email_send'] = this.isEmailSend;
    return data;
  }
}
