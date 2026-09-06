class RequestArtist {
  String? uid;
  String? reqStatus;
  String? dateAdded;
  Profile? profile;

  RequestArtist({this.uid, this.reqStatus, this.dateAdded, this.profile});

  RequestArtist.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    reqStatus = json['req_status'];
    dateAdded = json['date_added'];
    profile =
        json['profile'] != null ? new Profile.fromJson(json['profile']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['uid'] = this.uid;
    data['req_status'] = this.reqStatus;
    data['date_added'] = this.dateAdded;
    if (this.profile != null) {
      data['profile'] = this.profile!.toJson();
    }
    return data;
  }
}

class Profile {
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

  Profile(
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
      this.aboutText});

  Profile.fromJson(Map<String, dynamic> json) {
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
    return data;
  }
}
