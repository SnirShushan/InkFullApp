<?php
$fields = ['name','app_token','device_type','app_version','uid','login_token'];
$check = check_isset($fields);

if ($check) {
    $status = 1;
    $msg = "Success";
    $post = get_all_data_protected($_REQUEST);
    $row = validate_token($post['login_token'], $post['uid']);
    if ($row == false) {
        $status = 2;
        $msg = $gbl_msg_invalid_token;
    }
    else{
        if($post['name']!=""){
            $user_detail = check_is_unique_user_name(['id'=>$post['uid'],'name'=>$post['name']]);
            if(!$user_detail){
                // $msg = "Name Already Exists";
                $msg = "השם כבר קיים";
                $status = 0;
            }
        }
    }
    /* $row = get_user_by_phone($_REQUEST['phone']);
    if (count($row) > 0) {
        $is_exists = 1;
    }
    $data['is_exists'] = $is_exists; */
} else {
    $status = 0;
    $msg = $gbl_msg_invalid_args;
}