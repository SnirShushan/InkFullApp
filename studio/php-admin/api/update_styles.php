<?php

$fields = ['uid', 'login_token', 'styles', 'device_type', 'app_version', 'app_token'];
$check = check_isset($fields);
$email = '';
$name = '';
global $signature_image_path;
if ($check) {
    $post = get_all_data_protected($_REQUEST);
    $row = validate_token($post['login_token'], $post['uid']);

    if ($row == false) {
        $status = 2;
        $msg = $gbl_msg_invalid_token;
    } else {

        $update_dt = date("Y-m-d H:i:s");

        $sql = "UPDATE tbl_customer set styles='" . $post['styles'] . "' ,date_updated='" . $update_dt . "' WHERE id='" . $row['id'] . "' LIMIT 1";
        $result = $db->query($sql) or (log_error($sql));
        if ($result) {
            // $msg = "Styles Update Successfully";
            $msg = "סגנון עודכן בהצלחה";
            $data['profile'] = get_user_profile($post['uid'],$post['uid']);
            $status = 1;
        }
    }
} else {
    $status = 0;
    $msg = $gbl_msg_invalid_args;
}
