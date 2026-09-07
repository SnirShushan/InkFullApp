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
        // $msg="Success";
        $msg = "פנייה נשלחה בהצלחה";
        $user_detail = get_user_profile($row['id']);
        $subject = "משתמש מעוניין בשידרוג";
        if($user_detail['is_email_send_plan_upgrade'] == "2"){
            $data['mail_data'] = sending_email_admin($row['id'],$subject);
            $db->update("tbl_customer", ['is_email_send_plan_upgrade'=>'1'], ['id'=>$post['uid']]);
        }
        // $data['mail_data'] = sending_email_admin($row['id'],$subject);
    }
} else {
    $status = 0;
    $msg = $gbl_msg_invalid_args;
}