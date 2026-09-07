<?php
include __DIR__ . "/db_conn.php";
include __DIR__ . "/function.php";
// include "include/header.php";
error_reporting(E_ERROR | E_PARSE);
$status = 0;
$msg = "";
$data = [];
$db_env = $_ENV['db_env'];
$output_type = 1;
$gbl_lang = "1";
$base_url = $_ENV['SITE_URL'] . "api/";
$site_url = $_ENV['SITE_URL'];

// $gbl_msg_invalid_token = "Your session has been expired. Please try again after login";
$gbl_msg_invalid_token = "יש להתחבר מחדש";
$gbl_msg_invalid_args = "Invalid Arguments.";
$gbl_msg_invalid_args = "יש להתחבר מחדש";
$action = "";
$app_token = "";
$device_type = "";
$android_app_version = "";
$ios_app_version = "";

$setting = get_settings();
$app_token = $setting['app_token'];
$android_app_version = explode(",", $setting['android_app_version']);
$ios_app_version = explode(",", $setting['ios_app_version']);
$startup_image = $setting['startup_image'];
if (isset($_REQUEST['action']))
    $action = $_REQUEST['action'];
else
    $action = "-";

if (isset($_REQUEST['app_token'])) {
    if ($app_token != $_REQUEST['app_token']) {
        // $msg = "Invalide App Token";
        $msg = "יש להתחבר מחדש";
        $action = "|";
    }
}
if($action!="CheckPhoneExists" && $action != "SendSms")
{
    if (isset($_REQUEST['device_type'])) {
        $device_type = $_REQUEST['device_type'];
        if ($device_type == 'a') {
            if (!in_array($_REQUEST['app_version'], $android_app_version)) {
            // if (empty($_REQUEST['app_version'])) {
                $action = "#";
            }
        }
        if ($device_type == 'i') {
            if (!in_array($_REQUEST['app_version'], $ios_app_version)) {
            // if (empty($_REQUEST['app_version'])) {
                $action = "#";
            }
        }
    }
}

$gbl_msg_aded_post="נוספה תמונה חדשה";
$gbl_msg_req_rcv_from_artist="בקשה שהתקבלה מ";
$gbl_msg_studio_req_sent="קיבל את הפניה שלך";
$gbl_msg_studio_apprv_req="סטודיו אישר את בקשתך";
$gbl_msg_studio_denied_req="סטודיו דחה את בקשתך";
$gbl_msg_req_rcv_from_studio="בקשה שהתקבלה מ";
// $gbl_msg_artist_apprv_req="סטודיו אישר את בקשתך";
$gbl_msg_artist_apprv_req="האמן אישר את בקשתך";
$gbl_msg_artist_denied_req="האמן דחה את בקשתך";
$gbl_msg_artist_post_mention="הזכיר אותך בפוסט";
$profile_image_path = "../assets/uploads/profile_images/";
$signature_image_path = "../assets/uploads/signature_images/";
$body_image_path = "../assets/uploads/body_images/";
$startup_image_path = "../assets/uploads/";

switch ($action) {
    case "CheckPhoneExists":
        include "is_phone_exists.php";
        break;
    case "Login":
        //include "login.php";
        $status=0;
        $msg="Please update app";
        break;
    case "LoginWithGmail":
        include "login_with_gmail.php";
        break;
    case "Register":
        include "register.php";
        break;
    case "UpdateProfile":
        include "update_profile.php";
        break;
    case "UpdatePost":
        include "update_post.php";
        break;
    case "UpdateAddress":
        include "update_address.php";
        break;
    case "UpdateProfileImage":
        include "update_profile_image.php";
        break;
    case "RemoveProfileImage":
        include "remove_profile_image.php";
        break;
    case "ContactUs":
        include "contact_us.php";
        break;
    case "RemovePost":
        include "remove_post.php";
        break;
    case "GetHomeData":
        include "get_home_data.php";
        break;
    case "GetPostCount":
        include "get_post_count.php";
        break;
    case "GetHomeNewData":
        include "get_home_new_data.php";
        break;
    case "GetHomeDataSection1":
        include "get_home_data_section1.php";
        break;
    case "GetHomeDataSection2":
        include "get_home_data_section2.php";
        break;
    case "GetHomeDataSection3":
        include "get_home_data_section3.php";
        break;
    case "GetMyArtist":
        include "get_my_artist.php";
        break;
    case "GetMyStudio":
        include "get_my_studio.php";
        break;
    case "ResArtistReq":
        include "respond_artist_req.php";
        break;
    case "ResStudioReq":
        include "respond_studio_req.php";
        break;
    case "RemoveArtistFromList":
        include "remove_my_artist.php";
        break;
    case "RemoveStudioFromList":
        include "remove_my_studio.php";
        break;
    case "UpdateBusinessProfile":
        include "update_business_profile.php";
        break;
    case "RequestForTattoo":
        include "request_for_tattoo.php";
        break;
    case "GetTattooRequest":
        include "get_tattoo_req_list.php";
        break;
    case "ReadTattooRequest":
        include "read_tattoo_req.php";
        break;
    case "GetBusinessList":
        include "get_business_list_by_type.php";
        break;
    case "GetBusiness":
        include "get_business.php";
        break;
    case "GetBusinessNew":
        include "get_business_new.php";
        break;
    case "GetUser":
        include "get_user.php";
        break;
    case "GetBusinessDetail":
        include "get_business_detail.php";
        break;
    case "GetSketchList":
        include "get_business_sketch_list.php";
        break;
    case "GetTattooList":
        include "get_business_tattoo_list.php";
        break;
    case "UpdateStyles":
        include "update_styles.php";
        break;
    case "AddPost":
        include "add_post.php";
        break;
    case "ReportUser":
        include "report_user.php";
        break;
    case "ReportPost":
        include "report_post.php";
        break;
    case "GetNotifications":
        include "get_notifications.php";
        break;
    case "GetNotificationsNew":
        include "get_notifications_new.php";
        break;
    case "ReadNotifications":
        include "read_notifications.php";
        break;
    case "GetPosts":
        include "get_posts.php";
        break;
    case "GetPostsNew":
        include "get_posts_new.php";
        break;
    case "GetPostDetail":
        include "get_post_detail.php";
        break;
    case "LikePost":
        include "like_post.php";
        break;
    case "FollowUser":
        include "follow_user.php";
        break;
    case "DeleteAccount":
        include "delete_account.php";
        break;
    case "GetPages":
        include "get_pages.php";
        break;
    case "StartupImage":
        include "startup_image.php";
        break;
    case "AndroidSubscription":
        include "android_Subscription.php";
        break;
    case "GetSubscriptionPackageName":
        include "get_subscription_package_name.php";
        break;
    case "SubscriptionIpnCall":
        include "android_sub_ipn.php";
        break;
    case "CheckSubscription":
        include "check_subscription.php";
        break;
    case "IosSubscriptionIpnCall":
        include "ios_sub_ipn.php";
        break;
    case "SuccessPurchaseIphone":
        include "success_purchase_iphone.php";
        break;
    case "getFollowersList":
        include "get_followers_list.php";
        break;
    case "LoginFailDBLog":
        include "login_fail_db_log.php";
        break;
    case "UserInterestToUpgrade":
        include "user_interest_to_upgrade.php";
        break;
    case "SendSms":
        include "send_otp.php";
        break;
    case "ViewDbLog":
        include "view_db_log.php";
        break;
    case "ViewAppLog":
        include "view_app_log_LJbkcPhi8cExXLb.php";
        break;
    case "PushTest":
        include "push.php";
        break;
    case "|":
        $status = 0;
        // $msg = "Invalide App Token";
        $msg = "יש להתחבר מחדש";
        break;
    case "#":
        $status = 0;
        $msg = "Please update app to latest version.";
        break;
    case "test":
        include "test.php";
        break;
    case "test1":
        include "test1.php";
        break;
    case "CheckNameExists":
        include "is_name_exists.php";
        break;
    default:
        $msg = "Please provide valid action parameter.";
}

if ($output_type == 1) {
    header('Content-Type: application/json');
    $arr['status'] = $status;
    $arr['msg'] = $msg;
    $arr['data'] = $data;
    $arr['style_img_url'] = $_ENV['SITE_URL'] . "assets/images/styles/";
    $arr['profile_img_url'] = $_ENV['SITE_URL'] . "assets/uploads/profile_images/";
    $arr['body_img_url'] = $_ENV['SITE_URL'] . "assets/uploads/body_images/";
    $arr['startup_img_url'] = $_ENV['SITE_URL'] . "assets/uploads/";
    $arr['default_img_url'] = $_ENV['SITE_URL'] . "assets/img/defult.png";
    
    $tips=[
        'user_type'=>"1 = public user, 2 = Business",
        'business_type'=>"1 = studio, 2 = Artist",
        'login_type'=>"1 = phone otp,2=apple",
        'status'=>"0 = Not Approved, 1 = Approved, 2 = Blocked, 3 = Archive/Deleted",
        'is_premium'=>"0 = Basic Plan, 1 = Premium Plan",
        'subscritpion_status'=>"0 = Subscription Expired, 1 = Subscription Active",
        'is_filter'=>"1=True, 2=False"
    ];
    $arr['tips']=$tips;
    //echo json_encode($arr,JSON_UNESCAPED_SLASHES);
    echo json_encode($arr);
    if ($_ENV['enable_app_log'] == "1"){
        register_app_log($action, ['status' => $status, 'msg' => $msg]);
        register_app_log_new($action, ['status' => $status, 'msg' => $msg]);
    }
}
