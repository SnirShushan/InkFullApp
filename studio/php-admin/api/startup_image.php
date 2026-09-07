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
        $msg = "Success";
        $data['startup_image'] = $startup_image;
    }
} else {
    $status = 0;
    $msg = $gbl_msg_invalid_args;
}