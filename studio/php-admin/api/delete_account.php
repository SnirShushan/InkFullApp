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
        $dt = date("Y-m-d H:i:s");
        $upd_data = [];
        $upd_data['status'] = '3';
        $upd_data['is_delete'] = '1';
        $upd_data['delete_source'] = '1';
        $upd_data['date_updated'] = $dt;
        $result = $db->update("tbl_customer", $upd_data, ['id'=>$post['uid']]);
        // $msg="Account Deleted";
        $msg="החשבון נמחק";
    }
} else {
    $status = 0;
    $msg = $gbl_msg_invalid_args;
}