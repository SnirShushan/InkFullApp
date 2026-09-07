<?php
$fields = ['uid', 'login_token', 'device_type', 'app_version', 'app_token', 'is_read', 'notification_id'];
$check = check_isset($fields);
if ($check) {
    $post = get_all_data_protected($_REQUEST);
    $row = validate_token($post['login_token'], $post['uid']);

    if ($row == false) {
        $status = 2;
        $msg = $gbl_msg_invalid_token;
    } else {
        $sql_noti="SELECT * FROM tbl_notifications where id = '".$post['notification_id']."' AND me = '".$post['uid']."' limit 1";
        $result=$db->query($sql_noti);
        if($result->num_rows()>0){
            $update_data = [];
            $update_data["is_read"] = $post['is_read'];
            // $update_data['date_updated'] = date("Y-m-d H:i:s");
            $result = update('tbl_notifications', $update_data,['id'=>$post['notification_id'],'me'=>$post['uid']]);
            if($result){
                $status = 1;
                $msg = "Notification marked as read successfully";
                // $msg = "ההודעה סומנה כקריאה בהצלחה";
            }

        }else{
            $status = 0;
            $msg = "Notification not found";
            // $msg = "ההודעה לא נמצאה";
        }
    }
}else {
    $status = 0;
    $msg = $gbl_msg_invalid_args;
}