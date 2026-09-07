<?php
$fields = ['app_token','device_type','app_version','uid','login_token','address','lat','lng','radius','place_id','is_notify'];
$check = check_isset($fields);
$lat = '';
$lng = '';
$radius = '';
if ($check) {
    $post = get_all_data_protected($_REQUEST);
    $row = validate_token($post['login_token'], $post['uid']);
    if ($row == false) {
        $status = 2;
        $msg = $gbl_msg_invalid_token;
    }
    else{
        $update_dt = date("Y-m-d H:i:s");
        if(empty($post['lat']) || empty($post['lng']) || empty($post['radius'])){
            // $msg = "Please Provide valid location";
            $msg = "אנא בחר מיקום תקין";
        }
        else{
            $sql = "UPDATE tbl_customer set address='".$post['address']."', lat='".$post['lat']."', lng='".$post['lng']."', radius='".$post['radius']."', place_id='".$post['place_id']."', is_notify='".$post['is_notify']."', date_updated='".$update_dt."' WHERE id='".$row['id']."' LIMIT 1";
            $result = $db->query($sql) or (log_error($sql));
            
            if($result){
                // $msg = "Settings Update Successfully";
                $msg = "הגדרות עודכנו בהצלחה";
                $data['profile'] = get_user($post['uid']);
                $status = 1;
            }
        }   
    }
} else {
    $status = 0;
    $msg = $gbl_msg_invalid_args;
}
