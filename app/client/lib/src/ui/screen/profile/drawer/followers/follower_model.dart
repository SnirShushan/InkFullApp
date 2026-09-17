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
    String nz(dynamic v) {
      if (v == null) return '';
      final s = v.toString().trim();
      if (s.isEmpty || s == 'null' || s == 'undefined') return '';
      return s;
    }

    id = nz(json['id']);
    name = nz(json['name']);
    status = nz(json['status']);
    email = nz(json['email']);
    phone = nz(json['phone']);
    cntCode = nz(json['cnt_code']);
    lang = nz(json['lang']);
    profileImage = nz(json['profile_image']);
    styles = nz(json['styles']);
    businessType = nz(json['business_type']);
    userType = nz(json['user_type']);
    loginType = nz(json['login_type']);
    cityname = nz(json['city_name']);
    address = nz(json['address']);
    addressLat = nz(json['address_lat']);
    addressLng = nz(json['address_lng']);
    addressPlaceId = nz(json['address_place_id']);
    aboutText = nz(json['about_text']);
    postLimit = nz(json['post_limit']);
    isRegister = nz(json['is_register']);
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
