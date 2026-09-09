class Artist {
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
  String? isRequestSent;
  bool? isSelected = false;

  Artist(
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
      this.isRequestSent,
      this.isSelected = false});

  Artist.fromJson(Map<String, dynamic> json) {
    id = json['id'].toString();
    name = json['name'].toString();
    email = json['email'].toString();
    phone = json['phone'].toString();
    cntCode = json['cnt_code'];
    lang = json['lang'].toString();
    profileImage = json['profile_image'].toString();
    loginToken = json['login_token'].toString();
    styles = json['styles'].toString();
    businessType = json['business_type'].toString();
    userType = json['user_type'].toString();
    loginType = json['login_type'].toString();
    address = json['address'].toString();
    addressLat = json['address_lat'].toString();
    addressLng = json['address_lng'].toString();
    addressPlaceId = json['address_place_id'].toString();
    aboutText = json['about_text'].toString();
    isRequestSent = json['is_request_sent'].toString();
    isSelected = false;
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
    data['is_request_sent'] = this.isRequestSent;
    return data;
  }
}
