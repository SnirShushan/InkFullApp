<?php
$fields = ['cnt_code','phone','app_token','device_type','app_version','error_text'];
$check = check_isset($fields);

if ($check) {
    $postdata = get_all_data_protected($_REQUEST);
    $dt = date("Y-m-d H:i:s");

    $ins = [];
    $ins['cnt_code'] = $postdata['cnt_code'];
    $ins['phone'] = $postdata['phone'];
    $ins['error_text'] = $postdata['error_text'];
    $ins['device_type'] = $postdata['device_type'];
    $ins['date_added'] = $dt;
    $sub_result = insert("tbl_login_error_db",$ins);
    if($sub_result){
        $status = 1;
        $msg = "Success";

    }else{
        $status = 0;
        // $msg = "Error on adding";
        $msg = "תקלה בהוספה";
    }

} else {
    $status = 0;
    $msg = $gbl_msg_invalid_args;
}