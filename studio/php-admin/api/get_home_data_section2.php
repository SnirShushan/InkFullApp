<?php
$fields = ['uid','login_token','app_token','device_type','app_version'];
$check = check_isset($fields);
$job_list = [];
if ($check) {
    $post = get_all_data_protected($_REQUEST);
    $row = validate_token($post['login_token'], $post['uid']);
    if ($row == false) {
        $status = 2;
        $msg = $gbl_msg_invalid_token;
    }
    else{
        $user_data = get_user_profile($post['uid']);
        $status=1;
        $msg="success";
        $start = "0";
        $limit = "6";
        $user_styles = $user_data['styles'];
        $radius = "40";
        $lat = $user_data['address_lat'];
        $lng = $user_data['address_lng'];
        $b_post_limit = 5; // need integer value for compare do not put string limit
        $order_by = 'order by date_added DESC';
        $is_home = true;
        include_once("get_business.php");
        
    }
} else {
    $status = 0;
    $msg = $gbl_msg_invalid_args;
}