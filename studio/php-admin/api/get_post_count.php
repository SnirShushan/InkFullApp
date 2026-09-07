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
        $status=1;
        $msg="success";
        $stylespost_params = [];
        $user_data = get_user_profile($post['uid']);
        $user_styles = $user_data['styles'];
        if($user_styles!=""){
            $stylespost_params['is_recommended']=$user_styles;
        }
        $plist=new_posts_count($stylespost_params);
        $data['total_post_count'] = $plist;
    }
} else {
    $status = 0;
    $msg = $gbl_msg_invalid_args;
}