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
    String s(dynamic v) => v == null ? "" : v.toString();
    id = s(json['id']);
    name = s(json['name']);
    email = s(json['email']);
    phone = s(json['phone']);
    cntCode = s(json['cnt_code']);
    lang = s(json['lang']);
    profileImage = s(json['profile_image']);
    loginToken = s(json['login_token']);
    styles = s(json['styles']);
    businessType = s(json['business_type']);
    userType = s(json['user_type']);
    loginType = s(json['login_type']);
    address = s(json['address']);
    addressLat = s(json['address_lat']);
    addressLng = s(json['address_lng']);
    addressPlaceId = s(json['address_place_id']);
    aboutText = s(json['about_text']);
    isRequestSent = s(json['is_request_sent']);
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
