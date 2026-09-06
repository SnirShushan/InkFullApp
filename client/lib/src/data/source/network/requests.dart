import 'package:dio/dio.dart';

import '../../../utils/webService.dart';

class NetWorkRequest {
  //checkPhoneExist
  static checkPhoneExist(phone) => {
        "action": "CheckPhoneExists",
        "phone": phone,
        'app_token': WebService.appToken,
        'app_version': WebService.appVersion,
        'device_type': WebService.deviceType,
      };

  //sendLogToServer
  static sendLogToServer({phone, errMsg}) => {
        "action": "LoginFailDBLog",
        "cnt_code": WebService.countryCode,
        "phone": phone,
        'app_token': WebService.appToken,
        'app_version': WebService.appVersion,
        'device_type': WebService.deviceType,
        "error_text": errMsg
      };

  //OTP Fetch
  static fetchOTPReq(phone, otp, email) => {
        "action": "SendSms",
        "phone": phone,
        'otp': otp,
        'app_token': WebService.appToken,
        'app_version': WebService.appVersion,
        'device_type': WebService.deviceType,
        'email': email
      };

  //login
  static login(phone, udid) => {
        "action": "Login",
        "cnt_code": WebService.countryCode,
        "phone": phone,
        'udid': udid,
        'app_token': WebService.appToken,
        'app_version': WebService.appVersion,
        'device_type': WebService.deviceType,
        'login_type': 1,
      };

  //google sign in
  static googleSignIn(email, udid) => {
        "action": "LoginWithGmail",
        "email": email,
        'udid': udid,
        'app_token': WebService.appToken,
        'app_version': WebService.appVersion,
        'device_type': WebService.deviceType,
        'login_type': "3",
      };

  //login
  static StartupImageData(uid, loginToken) => {
        "action": "StartupImage",
        "uid": uid,
        'login_token': loginToken,
        'app_token': WebService.appToken,
        'app_version': WebService.appVersion,
        'device_type': WebService.deviceType,
        'login_type': 1,
      };

  //loginWithApple
  static loginWithApple(name, email, udid, socialId) => {
        "action": "Login",
        "name": name ?? '',
        "email": email,
        'udid': udid,
        'app_token': WebService.appToken,
        'app_version': WebService.appVersion,
        'device_type': WebService.deviceType,
        'apple_id': socialId,
        'login_type': 2,
      };

  //update styles
  static updateStyles(uid, loginToken, styles) => {
        "action": "UpdateStyles",
        "uid": uid,
        "login_token": loginToken,
        'styles': styles,
        'device_type': WebService.deviceType,
        'app_version': WebService.appVersion,
        'app_token': WebService.appToken,
      };

  //delete account
  static deleteAccount(uid, loginToken) => {
        "action": "DeleteAccount",
        "uid": uid,
        "login_token": loginToken,
        'device_type': WebService.deviceType,
        'app_version': WebService.appVersion,
        'app_token': WebService.appToken,
      };

  // //get Home Data
  // static getHomeTopStylesRequest(uid, loginToken) => {
  //       "action": "GetHomeDataSection1",
  //       "uid": uid,
  //       "login_token": loginToken,
  //       'device_type': WebService.deviceType,
  //       'app_version': WebService.appVersion,
  //       'app_token': WebService.appToken,
  //     };
  static getPostCountRequest(uid, loginToken) => {
        "action": "GetPostCount",
        "uid": uid,
        "login_token": loginToken,
        'device_type': WebService.deviceType,
        'app_version': WebService.appVersion,
        'app_token': WebService.appToken,
      };

  static getHomeRequest(uid, loginToken, start, limit) => {
        "action": "GetHomeData",
        "uid": uid,
        "login_token": loginToken,
        'device_type': WebService.deviceType,
        'app_version': WebService.appVersion,
        'app_token': WebService.appToken,
        'start': start,
        'limit': limit,
      };

  //get posts
  static getPostsReq(uid, loginToken, style, start, limit, following) => {
        // "action": "GetPosts",
        "action": "GetPostsNew",
        'uid': uid,
        'login_token': loginToken,
        'styles': style,
        'device_type': WebService.deviceType,
        'app_version': WebService.appVersion,
        'app_token': WebService.appToken,
        'start': start,
        'limit': limit,
        'following': following
      };

  //get posts
  static getInspirationPostsRequest(
          {uid,
          loginToken,
          style,
          start,
          limit,
          following,
          searchTxt,
          mostView,
          isRecommended,
          isNew}) =>
      {
        "action": "GetPostsNew",
        'uid': uid,
        'login_token': loginToken,
        'styles': style,
        'device_type': WebService.deviceType,
        'app_version': WebService.appVersion,
        'app_token': WebService.appToken,
        'start': start,
        'limit': limit,
        'following': following,
        'search_txt': searchTxt,
        'most_view': mostView,
        'is_recommended': isRecommended,
        'is_new': isNew,
      };

  // static getInspirationPostsRequest(
  //       {uid,
  //       loginToken,
  //       style,
  //       start,
  //       limit,
  //       following,
  //       searchTxt,
  //       mostView,
  //       isRecommended,
  //       isNew}) =>
  //   {
  //     "action": "GetPosts",
  //     'uid': uid,
  //     'login_token': loginToken,
  //     'styles': style,
  //     'device_type': WebService.deviceType,
  //     'app_version': WebService.appVersion,
  //     'app_token': WebService.appToken,
  //     'start': start,
  //     'limit': limit,
  //     'following': following,
  //     'search_txt': searchTxt,
  //     'most_view': mostView,
  //     'is_recommended': isRecommended,
  //     'is_new': isNew,
  //   };

  static getHomePostsReq(
          uid, loginToken, random, start, limit, postIds, style) =>
      {
        "action": "GetPostsNew",
        'uid': uid,
        'login_token': loginToken,
        'is_random': random,
        'post_ids': postIds,
        'device_type': WebService.deviceType,
        'app_version': WebService.appVersion,
        'app_token': WebService.appToken,
        'start': start,
        'styles': style,
        'limit': limit,
        'following': "0"
      };

  static getHomePostsNewReq(
          uid, loginToken, random, start, limit, postIds) =>
      {
        "action": "GetHomePostsNew",
        'uid': uid,
        'login_token': loginToken,
        'is_random': random,
        'post_ids': postIds,
        'device_type': WebService.deviceType,
        'app_version': WebService.appVersion,
        'app_token': WebService.appToken,
        'start': start,

        'limit': limit,
        'following': "0"
      };

  //get posts
  // static getFollowingPostsReq(uid, loginToken, style, isFollowing) => {
  //       "action": "GetPosts",
  //       'uid': uid,
  //       'login_token': loginToken,
  //       'styles': style,
  //       'following': isFollowing,
  //       'device_type': WebService.deviceType,
  //       'app_version': WebService.appVersion,
  //       'app_token': WebService.appToken,
  //     };

  //report post
  static reportPost(pid, comment, uid, loginToken) => {
        "action": "ReportPost",
        "pid": pid,
        "comment": comment,
        'uid': uid,
        'login_token': loginToken,
        'device_type': WebService.deviceType,
        'app_version': WebService.appVersion,
        'app_token': WebService.appToken,
      };

  //reportBusiness
  static reportBusiness(bid, comment, uid, loginToken) => {
        "action": "ReportUser",
        "user_id": bid,
        "comment": comment,
        'uid': uid,
        'login_token': loginToken,
        'device_type': WebService.deviceType,
        'app_version': WebService.appVersion,
        'app_token': WebService.appToken,
      };

  //get business
  static getBusinessReq(
          {uid,
          loginToken,
          isStyleEnabled,
          userStyles,
          // isNewEnabled
          isFilterLocation,
          isRecommended,
          lat,
          lng,
          radius,
          isPopularEnabled,
          searchTxt,
          isClosest,
          start,
          limit}) =>
      {
        // "action": "GetBusiness",
        "action": "GetBusiness",
        "uid": uid,
        "login_token": loginToken,
        "device_type": WebService.deviceType,
        "app_version": WebService.appVersion,
        "app_token": WebService.appToken,
        "styles": isStyleEnabled == "1" ? userStyles : "",
        "start": start,
        "limit": limit,
        // "new": isNewEnabled ?? "",
        "is_closest": isClosest, //1 or 2
        "is_recommended": isRecommended ?? "", //1 or 2
        "is_filter_location": isFilterLocation, //1 or 2
        "lat": lat,
        "lng": lng,
        "radius": radius ?? WebService.locationRadius,
        "popular": isPopularEnabled ?? "",
        "search_txt": searchTxt,
      };

  //get business details
  static getBusinessDetails(uid, bid, loginToken) => {
        "action": "GetBusinessDetail",
        "uid": uid,
        "bid": bid,
        "login_token": loginToken,
        'device_type': WebService.deviceType,
        'app_version': WebService.appVersion,
        'app_token': WebService.appToken,
      };

  //Get Sketch List (For business Detail)
  static getSketchListReq(uid, bid, loginToken, start, limit) => {
        "action": "GetSketchList",
        "uid": uid,
        "bid": bid,
        "login_token": loginToken,
        'device_type': WebService.deviceType,
        'app_version': WebService.appVersion,
        'app_token': WebService.appToken,
        "start": start,
        "limit": limit,
      };

  //Get Tattoo List (For business Detail)
  static getTattooListReq(uid, bid, loginToken, start, limit) => {
        "action": "GetTattooList",
        "uid": uid,
        "bid": bid,
        "login_token": loginToken,
        'device_type': WebService.deviceType,
        'app_version': WebService.appVersion,
        'app_token': WebService.appToken,
        "start": start,
        "limit": limit,
      };

  //add post
  static addPost(uid, loginToken, creatorId, imageType, styles, description,
          imageName, imageId, businessType) =>
      {
        "action": "AddPost",
        'uid': uid,
        'login_token': loginToken,
        'image_type': imageType, //0 = tattoo 1 = sketch
        'styles': styles,
        'description': description,
        'image_name': imageName,
        "image_id": imageId,
        "artist_uid": businessType == "2" ? uid : creatorId,
        "studio_uid": uid,
        'device_type': WebService.deviceType,
        'app_version': WebService.appVersion,
        'app_token': WebService.appToken,
      };

  //update post
  static updatePostReq(
          uid, loginToken, styles, description, artistId, studioId, postId,imageId,imageName) =>
      {
        "action": "UpdatePost",
        "uid": uid,
        "login_token": loginToken,
        "styles": styles != "" ? styles : null,
        "description": description != "" ? description : null,
        "artist_uid": artistId != "" ? artistId : null,
        "studio_uid": studioId != "" ? studioId : null,
        "device_type": WebService.deviceType,
        "app_version": WebService.appVersion,
        "app_token": WebService.appToken,
        "pid": postId,
        'image_name': imageName,
        "image_id": imageId,
      };


  //update post artist
  static updatePostMember(uid, loginToken, memberId, postId) => {
        "action": "UpdatePost",
        "uid": uid,
        "login_token": loginToken,
        "artist_uid": memberId,
        "device_type": WebService.deviceType,
        "app_version": WebService.appVersion,
        "app_token": WebService.appToken,
        "pid": postId
      };

  //get My Artist
  static getMyArtist(uid, loginToken) => {
        "action": "GetMyArtist",
        "uid": uid,
        "login_token": loginToken,
        "device_type": WebService.deviceType,
        "app_version": WebService.appVersion,
        "app_token": WebService.appToken,
      };

  //getMyStudios
  static getMyStudios(uid, loginToken) => {
        "action": "GetMyStudio",
        "uid": uid,
        "login_token": loginToken,
        "device_type": WebService.deviceType,
        "app_version": WebService.appVersion,
        "app_token": WebService.appToken,
      };

  //change user type
  static changeUserType(uid, loginToken, styles, signatureImage) async => {
        "action": "UpdateBusinessProfile",
        'uid': uid,
        'login_token': loginToken,
        'business_type': WebService.isArtist,
        'name': WebService.name,
        'address': WebService.address,
        'address_lat': WebService.lat,
        'address_lng': WebService.lang,
        'address_place_id': WebService.placeId,
        'city_name': WebService.cityName,
        'styles': styles,
        'about_text': WebService.aboutText,
        'device_type': WebService.deviceType,
        'app_version': WebService.appVersion,
        'app_token': WebService.appToken,
        'member_ids':
            WebService.memberList.isNotEmpty ? WebService.memberList : "",
        'signature_image': signatureImage.existsSync()
            ? await MultipartFile.fromFile(signatureImage.path,
                filename: signatureImage.uri.toString())
            : null,
      };

  //getBusinessList
  static getBusinessListReq(uid, loginToken, btype, search_txt) => {
        "action": "GetBusinessList",
        "uid": uid,
        "login_token": loginToken,
        "business_type": btype,
        "search_txt": search_txt,
        'device_type': WebService.deviceType,
        'app_version': WebService.appVersion,
        'app_token': WebService.appToken,
      };

  //request a tattoo
  static requestTattoo(
          uid,
          loginToken,
          name,
          phone,
          tattooSize,
          styles,
          frontData,
          backData,
          description,
          artistId,
          businessId,
          image1Id,
          image2Id,
          image3Id,
          image1Name,
          image2Name,
          image3Name,
          backDataImage,
          frontDataImage) async =>
      {
        "action": "RequestForTattoo",
        "uid": uid,
        "login_token": loginToken,
        "name": name,
        "phone": phone,
        "tattoo_size": tattooSize,
        "styles": styles,
        "front_data": frontData,
        "back_data": backData,
        "description": description,
        "artists_uid": artistId,
        "business_id": businessId,
        "image1_id": image1Id,
        "image2_id": image2Id,
        "image3_id": image3Id,
        "image1_name": image1Name,
        "image2_name": image2Name,
        "image3_name": image3Name,
        "back_data_image": backDataImage!.existsSync()
            ? await MultipartFile.fromFile(backDataImage.path,
                filename: backDataImage.uri.toString())
            : null,
        "front_data_image": frontDataImage!.existsSync()
            ? await MultipartFile.fromFile(frontDataImage.path,
                filename: frontDataImage.uri.toString())
            : null,
        'device_type': WebService.deviceType,
        'app_version': WebService.appVersion,
        'app_token': WebService.appToken,
      };

  //getPosts
  static getMyPostsReq(uid, loginToken, start, limit) => {
        "action": "GetPostsNew",
        'uid': uid,
        'login_token': loginToken,
        'device_type': WebService.deviceType,
        'app_version': WebService.appVersion,
        'app_token': WebService.appToken,
        "my": "1",
        "start": start,
        "limit": limit,
      };

  //getUsers
  static getUserRequest(uid, loginToken) => {
        "action": "GetUser",
        'uid': uid,
        'login_token': loginToken,
        'device_type': WebService.deviceType,
        'app_version': WebService.appVersion,
        'app_token': WebService.appToken,
      };

  //searchPosts
  static searchPosts(uid, loginToken, searchText, following) => {
        // "action": "GetPosts",
        "action": "GetPostsNew",
        'uid': uid,
        'login_token': loginToken,
        'device_type': WebService.deviceType,
        'app_version': WebService.appVersion,
        'app_token': WebService.appToken,
        "search_txt": searchText,
        "following": following
      };

  //removePost
  static removePostRequest(uid, loginToken, postId) => {
        "action": "RemovePost",
        'uid': uid,
        'login_token': loginToken,
        'device_type': WebService.deviceType,
        'app_version': WebService.appVersion,
        'app_token': WebService.appToken,
        'pid': postId
      };

  //getPostDetails
  static getPostDetails(uid, loginToken, pid) => {
        "action": "GetPostDetail",
        "uid": uid,
        "login_token": loginToken,
        "pid": pid,
        'device_type': WebService.deviceType,
        'app_version': WebService.appVersion,
        'app_token': WebService.appToken,
      };

  //follow user
  static followUser(fid, uid, likeStatus, loginToken) => {
        "action": "FollowUser",
        'fid': fid,
        'uid': uid,
        'action_status': likeStatus,
        'login_token': loginToken,
        'device_type': WebService.deviceType,
        'app_version': WebService.appVersion,
        'app_token': WebService.appToken,
      };

  //Registration Profile
  static registrationRequest(uid, loginToken, name, email, phone) => {
        "action": "UpdateProfile",
        "uid": uid,
        "login_token": loginToken,
        "device_type": WebService.deviceType,
        "app_version": WebService.appVersion,
        "app_token": WebService.appToken,
        "name": name,
        "email": email,
        "phone": phone,
        "cnt_code": WebService.countryCode,
      };

  //update profile
  static updateUserDetails(uid, loginToken, name, email, phone) => {
        "action": "UpdateProfile",
        "uid": uid,
        "login_token": loginToken,
        "device_type": WebService.deviceType,
        "app_version": WebService.appVersion,
        "app_token": WebService.appToken,
        "name": name,
        "email": email,
        "phone": phone,
        "cnt_code": WebService.countryCode,
      };

  //update profile
  static updateProfile(uid, loginToken, name, address, addressPlaceId, lat, lng,
          about, styles, firebaseId, email) =>
      {
        "action": "UpdateProfile",
        "uid": uid,
        "login_token": loginToken,
        "device_type": WebService.deviceType,
        "app_version": WebService.appVersion,
        "app_token": WebService.appToken,
        "name": name,
        "email": email,
        "address": address,
        "address_place_id": addressPlaceId,
        "address_lat": lat,
        "address_lng": lng,
        "about_text": about,
        "styles": styles,
        "firebase_id": firebaseId,
      };

  //update profile image
  static updateProfileImage(uid, loginToken, profileImage) async => {
        "action": "UpdateProfileImage",
        "uid": uid,
        "login_token": loginToken,
        "profile_image": profileImage.existsSync()
            ? await MultipartFile.fromFile(profileImage.path,
                filename: profileImage.uri.toString())
            : null,
        "device_type": WebService.deviceType,
        "app_version": WebService.appVersion,
        "app_token": WebService.appToken,
      };

  //update location and push
  static updateSettingsLocation(uid, loginToken, isLocationEnabled) => {
        "action": "UpdateProfile",
        "uid": uid,
        "login_token": loginToken,
        "device_type": WebService.deviceType,
        "app_version": WebService.appVersion,
        "app_token": WebService.appToken,
        "location_enable": isLocationEnabled
      };

  //update push enabled
  static updatePushEnabled(uid, loginToken, isPushEnabled) => {
        "action": "UpdateProfile",
        "uid": uid,
        "login_token": loginToken,
        "device_type": WebService.deviceType,
        "app_version": WebService.appVersion,
        "app_token": WebService.appToken,
        "push_enable": isPushEnabled
      };

  //updateArtistList
  static updateArtistList(uid, loginToken, artistId, actionStatus) => {
        "action": "RemoveArtistFromList",
        "uid": uid,
        "login_token": loginToken,
        "device_type": WebService.deviceType,
        "app_version": WebService.appVersion,
        "app_token": WebService.appToken,
        "artist_id": artistId,
        "action_status": actionStatus,
      };

  //updateStudioList
  static updateStudioList(uid, loginToken, studioId, actionStatus) => {
        "action": "RemoveStudioFromList",
        "uid": uid,
        "login_token": loginToken,
        "device_type": WebService.deviceType,
        "app_version": WebService.appVersion,
        "app_token": WebService.appToken,
        "studio_id": studioId,
        "action_status": actionStatus,
      };

  //contact us
  static contactUs(uid, loginToken, comment) => {
        "action": "ContactUs",
        "uid": uid,
        "login_token": loginToken,
        "device_type": WebService.deviceType,
        "app_version": WebService.appVersion,
        "app_token": WebService.appToken,
        "comment": comment,
      };

  //accept invitation
  static acceptInvitation(uid, isArtist, loginToken, artistId, actionStatus) =>
      {
        "action": isArtist ? "ResStudioReq" : "ResArtistReq",
        "uid": uid,
        "login_token": loginToken,
        (isArtist ? "studio_id" : "artist_id"): artistId,
        "action_status": actionStatus,
        "device_type": WebService.deviceType,
        "app_version": WebService.appVersion,
        "app_token": WebService.appToken
      };

  //Read Notification Req
  static readNotificationRequest(
          uid, isArtist, loginToken, notificationId, isRead) =>
      {
        "action": "ReadNotifications",
        "uid": uid,
        "login_token": loginToken,
        "notification_id": notificationId,
        "is_read": isRead,
        "device_type": WebService.deviceType,
        "app_version": WebService.appVersion,
        "app_token": WebService.appToken
      };

  //Read TattooRequest Req
  static readTattooRequests(
          uid, isArtist, loginToken, requestId, isRead, types) =>
      {
        "action": "ReadTattooRequest",
        "uid": uid,
        "login_token": loginToken,
        "request_id": requestId,
        "is_read": isRead,
        "type": types,
        "device_type": WebService.deviceType,
        "app_version": WebService.appVersion,
        "app_token": WebService.appToken
      };

  //getTattooRequestsList
  static getTattooRequestsList(uid, loginToken, userType) => {
        "action": "GetTattooRequest",
        "uid": uid,
        "login_token": loginToken,
        "device_type": WebService.deviceType,
        "app_version": WebService.appVersion,
        "app_token": WebService.appToken,
        "type": userType == "1" ? "sent" : "rcvd",
      };

  //getTattooRequestsList
  static getCheckSubscriptionList(uid, loginToken, isAddPost) => {
        "action": "CheckSubscription",
        "uid": uid,
        "is_add_post": isAddPost,
        "login_token": loginToken,
        "device_type": WebService.deviceType,
        "app_version": WebService.appVersion,
        "app_token": WebService.appToken,
      };

  //getTattooRequestsList
  static getCheckSubscriptionListName(uid, loginToken, isAddPost, nameCheck) =>
      {
        "action": "CheckSubscription",
        "uid": uid,
        "name": nameCheck,
        "is_add_post": isAddPost,
        "login_token": loginToken,
        "device_type": WebService.deviceType,
        "app_version": WebService.appVersion,
        "app_token": WebService.appToken,
      };

  //check subscription
  static checkSubscriptionListReq(uid, loginToken, isAddPost) => {
        "action": "CheckSubscription",
        "uid": uid,
        "is_add_post": isAddPost,
        "login_token": loginToken,
        "device_type": WebService.deviceType,
        "app_version": WebService.appVersion,
        "app_token": WebService.appToken,
      };

  //get followers list
  static getFollowers({uid, loginToken, start, limit, isFollowing}) => {
        "action": "getFollowersList",
        "uid": uid,
        "login_token": loginToken,
        "device_type": WebService.deviceType,
        "app_version": WebService.appVersion,
        "app_token": WebService.appToken,
        "start": start,
        "limit": limit,
        "is_following": isFollowing,
        //(1=list of user which are folowed by current user & 2 = list of user which are folow the current user )
      };

  static postUserToUpgradeReq({uid, loginToken}) => {
        "action": "UserInterestToUpgrade",
        "uid": uid,
        "login_token": loginToken,
        "device_type": WebService.deviceType,
        "app_version": WebService.appVersion,
        "app_token": WebService.appToken
        //(1=list of user which are folowed by current user & 2 = list of user which are folow the current user )
      };

  //Name Check Business Registration
  static nameCheckBusinessRegistrationRequest(
          {required String uid, loginToken, required String name}) =>
      {
        "action": "CheckNameExists",
        "uid": uid,
        "login_token": loginToken,
        "device_type": WebService.deviceType,
        "app_version": WebService.appVersion,
        "app_token": WebService.appToken,
        "name": name,
      };

  static testServerReq() => {"action": "CheckServerStatus"};

  static basicFreePlanReq({required String uid, loginToken}) => {
        "action": "FreePlanSubscription",
        "uid": uid,
        "login_token": loginToken,
        "device_type": WebService.deviceType,
        "app_version": WebService.appVersion,
        "app_token": WebService.appToken
      };
}
