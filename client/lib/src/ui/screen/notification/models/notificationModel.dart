class NotificationModelNew {
  String? id;
  String? notiType;
  String? dateAdded;
  String? uid;
  String? pid;
  String? status;
  String? me;
  String? isread;
  String? notiDate;
  String? dateUpdated;
  String? postimages;
  String? custid;
  String? custname;
  String? custprofileImage;

  // NotiUser? notiUser;

  NotificationModelNew(
      {this.id,
      this.notiType,
      this.dateAdded,
      this.uid,
      this.pid,
      this.custid,
      this.custname,
      this.status,
      this.custprofileImage,
      this.me,
      this.postimages,
      this.isread,
      this.dateUpdated,
      this.notiDate,
      // this.notiUser
      });

  NotificationModelNew.fromJson(Map<String, dynamic> json) {
    id = json['id'].toString();
    notiType = json['noti_type'].toString();
    dateAdded = json['date_added'].toString();
    uid = json['uid'].toString();
    pid = json['pid'].toString();
    custid = json['cust_id'].toString();
    custname = json['cust_name'].toString();
    custprofileImage = json['cust_profile_image'].toString();
    status = json['status'].toString();
    me = json['me'].toString();
    notiDate = json['noti_date'].toString();
    dateUpdated = json['date_updated'] != "" ? json['date_updated'] : "";
    isread = json['is_read'] != "" ? json['is_read'] : "1";
    // notiUser = json['noti_user'] != null
    //     ? json['noti_user'].toString() != "[]"
    //         ? NotiUser.fromJson(json['noti_user'])
    //         : null
    //     : null;

    postimages =
        json.containsKey("post_image") ? json['post_image'].toString() : "";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['noti_type'] = this.notiType;
    data['date_added'] = this.dateAdded;
    data['uid'] = this.uid;
    data['pid'] = this.pid;
    data['cust_id'] = this.custid;
    data['cust_name'] = this.custname;
    data['cust_profile_image'] = this.custprofileImage;
    data['status'] = this.status;
    data['me'] = this.me;
    data['date_updated'] = this.dateUpdated;
    data['isread'] = this.isread;
    data['post_image'] = this.postimages;
    data['noti_date'] = this.notiDate;
    // if (this.notiUser != null && this.notiUser != []) {
    //   data['noti_user'] = this.notiUser!.toJson();
    // }

    return data;
  }
}

// class NotiUser {
//   String? id;
//   String? name;
//   // String? status;
//   // String? email;
//   // String? phone;
//   // String? cntCode;
//   // String? lang;
//   String? profileImage;
//   // String? styles;
//   // String? businessType;
//   // String? userType;
//   // String? loginType;
//   // String? address;
//   // String? addressLat;
//   // String? addressLng;
//   // String? addressPlaceId;
//   // String? aboutText;
//
//   NotiUser(
//       {this.id,
//       this.name,
//       // this.status,
//       // this.email,
//       // this.phone,
//       // this.cntCode,
//       // this.lang,
//       this.profileImage,
//       // this.styles,
//       // this.businessType,
//       // this.userType,
//       // this.loginType,
//       // this.address,
//       // this.addressLat,
//       // this.addressLng,
//       // this.addressPlaceId,
//       // this.aboutText
//       });
//
//   NotiUser.fromJson(Map<String, dynamic> json) {
//     id = json['id'].toString();
//     name = json['name'].toString();
//     // status = json['status'].toString();
//     // email = json['email'].toString();
//     // phone = json['phone'].toString();
//     // cntCode = json['cnt_code'].toString();
//     // lang = json['lang'].toString();
//     profileImage = json['profile_image'].toString();
//     // styles = json['styles'].toString();
//     // businessType = json['business_type'].toString();
//     // userType = json['user_type'].toString();
//     // loginType = json['login_type'].toString();
//     // address = json['address'].toString();
//     // addressLat = json['address_lat'].toString();
//     // addressLng = json['address_lng'].toString();
//     // addressPlaceId = json['address_place_id'].toString();
//     // aboutText = json['about_text'].toString();
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     data['name'] = this.name;
//     // data['status'] = this.status;
//     // data['email'] = this.email;
//     // data['phone'] = this.phone;
//     // data['cnt_code'] = this.cntCode;
//     // data['lang'] = this.lang;
//     data['profile_image'] = this.profileImage;
//     // data['styles'] = this.styles;
//     // data['business_type'] = this.businessType;
//     // data['user_type'] = this.userType;
//     // data['login_type'] = this.loginType;
//     // data['address'] = this.address;
//     // data['address_lat'] = this.addressLat;
//     // data['address_lng'] = this.addressLng;
//     // data['address_place_id'] = this.addressPlaceId;
//     // data['about_text'] = this.aboutText;
//     return data;
//   }
// }
