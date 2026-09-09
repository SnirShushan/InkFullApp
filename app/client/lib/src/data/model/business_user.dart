class BusinessUser {
  final String id;
  final String name;
  final String email;
  final String address;
  final String phone;
  final String udid;
  final String logintoken;
  final String profileimage;
  final String isNotify;
  final String islogin;
  final String liked;
  final String followers;
  final String userType;
  final String businessType;
  final String loginType;

  const BusinessUser({
    this.id = '',
    this.name = '',
    this.email = '',
    this.address = '',
    this.phone = '',
    this.udid = '',
    this.logintoken = '',
    this.profileimage = '',
    this.isNotify = '',
    this.islogin = '',
    this.liked = '',
    this.followers = '',
    this.userType = "1",
    this.businessType = "1",
    this.loginType = "1",
  });

  BusinessUser copy({
    String? id,
    String? name,
    String? email,
    String? address,
    String? phone,
    String? udid,
    String? logintoken,
    String? profileimage,
    String? isNotify,
    String? islogin,
    String? liked,
    String? followers,
    String? userType,
    String? businessType,
    String? loginType,
  }) =>
      BusinessUser(
        id: id ?? this.id,
        name: name ?? this.name,
        email: email ?? this.email,
        address: address ?? this.address,
        phone: phone ?? this.phone,
        udid: udid ?? this.udid,
        logintoken: logintoken ?? this.logintoken,
        profileimage: profileimage ?? this.profileimage,
        isNotify: isNotify ?? this.isNotify,
        islogin: islogin ?? this.islogin,
        liked: liked ?? this.liked,
        followers: followers ?? this.followers,
        userType: userType ?? this.userType,
        businessType: businessType ?? this.businessType,
        loginType: loginType ?? this.loginType,
      );

  static BusinessUser fromJson(Map<String, dynamic> json) => BusinessUser(
        id: json['id'].toString(),
        name: json['name'].toString(),
        email: json['email'].toString(),
        address: json['address'].toString(),
        phone: json['phone'].toString(),
        udid: json['udid'].toString(),
        logintoken: json['login_token'].toString(),
        profileimage: json['profile_image'].toString(),
        isNotify: json['is_notify'].toString(),
        userType: json['userType'].toString(),
        liked: json['liked'].toString(),
        followers: json['followers'].toString(),
        businessType: json['businessType'].toString(),
        loginType: json['loginType'].toString(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'address': address,
        'phone': phone,
        'login_token': logintoken,
        'profile_image': profileimage,
        'is_notify': isNotify,
        'userType': userType,
        'liked': liked,
        'followers': followers,
        'businessType': businessType,
        'loginType': loginType,
      };
}
