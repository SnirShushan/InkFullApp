import 'package:ink/src/data/model/image_model.dart';

class TattooRequest {
  bool? isContactRequest;
  String? id;
  String? isContactRequestStr;
  String? name;
  String? phone;
  String? email;
  String? tattooSize;
  String? image1Id;
  String? image2Id;
  String? image3Id;
  String? image1Name;
  String? image2Name;
  String? image3Name;
  String? styles;
  String? frontSide;
  String? backSide;
  String? frontData;
  String? backData;
  String? backDataImage;
  String? frontDataImage;
  String? description;
  String? artistsUid;
  String? businessId;
  String? uid;
  String? dateAdded;
  String? cntCode;
  String? dateUpdated;
  String? isread;
  List<RequestImages>? requestImages;
  ArtistRow? artistRow;
  ArtistRow? businessRow;
  ArtistRow? senderRow;

  TattooRequest(
      {this.isContactRequest,
      this.id,
      this.isContactRequestStr,
      this.name,
      this.phone,
      this.email,
      this.tattooSize,
      this.image1Id,
      this.image2Id,
      this.image3Id,
      this.image1Name,
      this.image2Name,
      this.image3Name,
      this.styles,
      this.frontSide,
      this.backSide,
      this.frontData,
      this.backData,
      this.backDataImage,
      this.frontDataImage,
      this.description,
      this.artistsUid,
      this.businessId,
      this.uid,
      this.dateAdded,
      this.dateUpdated,
      this.cntCode,
      this.requestImages,
      this.artistRow,
      this.isread,
      this.businessRow,
      this.senderRow});

  TattooRequest.fromJson(Map<String, dynamic> json) {
    if (json.containsKey("is_contact_request")) {
      isContactRequest =
          json['is_contact_request'].toString() == "2" ? true : false;
    }
    isContactRequestStr = json['is_contact_request'].toString();
    id = json['id'];
    name = json['name'];
    phone = json['phone']??"";
    email = json['email']??"";
    tattooSize = json['tattoo_size']??"";
    image1Id = json['image1_id']??"";
    image2Id = json['image2_id']??"";
    image3Id = json['image3_id']??"";
    image1Name = json['image1_name']??"";
    image2Name = json['image2_name']??"";
    image3Name = json['image3_name']??"";
    styles = json['styles'];
    frontSide = json['front_side'];
    backSide = json['back_side'];
    frontData = json['front_data'];
    backData = json['back_data'];
    backDataImage = json['back_data_image'];
    frontDataImage = json['front_data_image'];
    description = json['description'];
    artistsUid = json['artists_uid'];
    businessId = json['business_id'];
    uid = json['uid'];
    dateAdded = json['date_added'];
    dateUpdated = json['date_updated'];
    isread = json['is_read'] != "" ? json['is_read'] : "1";
    cntCode = json['cnt_code'] != "" ? json['cnt_code'] : "";
    if (json['request_images'] != null &&
        json['request_images'] != "" &&
        json['request_images'].toString() != "[]") {
      requestImages = <RequestImages>[];
      json['request_images'].forEach((v) {
        requestImages!.add(new RequestImages.fromJson(v));
      });
    }
    artistRow =
        (json['artist_row'] != null && json['artist_row'].toString() != "[]")
            ? new ArtistRow.fromJson(json['artist_row'] as Map<String, dynamic>)
            : null;
    businessRow = (json['business_row'] != null &&
            json['business_row'].toString() != "[]")
        ? ArtistRow.fromJson(json['business_row'] as Map<String, dynamic>)
        : null;
    senderRow =
        (json['sender_row'] != null && json['sender_row'].toString() != "[]")
            ? new ArtistRow.fromJson(json['sender_row'] as Map<String, dynamic>)
            : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['is_contact_request'] = this.isContactRequest;
    data['id'] = this.id;
    data['name'] = this.name;
    data['phone'] = this.phone;
    data['email'] = this.email;
    data['tattoo_size'] = this.tattooSize;
    data['image1_id'] = this.image1Id;
    data['image2_id'] = this.image2Id;
    data['image3_id'] = this.image3Id;
    data['image1_name'] = this.image1Name;
    data['image2_name'] = this.image2Name;
    data['image3_name'] = this.image3Name;
    data['styles'] = this.styles;
    data['front_side'] = this.frontSide;
    data['back_side'] = this.backSide;
    data['front_data'] = this.frontData;
    data['back_data'] = this.backData;
    data['back_data_image'] = this.backDataImage;
    data['front_data_image'] = this.frontDataImage;
    data['description'] = this.description;
    data['artists_uid'] = this.artistsUid;
    data['business_id'] = this.businessId;
    data['uid'] = this.uid;
    data['date_added'] = this.dateAdded;
    data['date_updated'] = this.dateUpdated;
    data['cnt_code'] = this.cntCode;
    data['is_read'] = this.isread;
    data['is_contact_request'] = this.isContactRequestStr;
    if (this.requestImages != null) {
      data['request_images'] =
          this.requestImages!.map((v) => v.toJson()).toList();
    }
    if (this.artistRow != null || this.artistRow != "[]") {
      data['artist_row'] = this.artistRow!.toJson();
    }
    if (this.businessRow != null) {
      data['business_row'] = this.businessRow!.toJson();
    }
    if (this.senderRow != null) {
      data['sender_row'] = this.senderRow!.toJson();
    }
    return data;
  }
}

class ArtistRow {
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
  String? aboutText;

  ArtistRow(
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
      this.aboutText});

  ArtistRow.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    status = json['status'];
    email = json['email'];
    phone = json['phone'];
    cntCode = json['cnt_code'] != "" ? json['cnt_code'] : "";
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
    aboutText = json['about_text'];
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
    data['about_text'] = this.aboutText;
    return data;
  }
}
