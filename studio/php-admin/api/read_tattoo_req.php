<?php
$fields = ['uid', 'login_token', 'device_type', 'app_version', 'app_token', 'is_read', 'request_id','type'];
$check = check_isset($fields);
if ($check) {
    $post = get_all_data_protected($_REQUEST);
    $row = validate_token($post['login_token'], $post['uid']);

    if ($row == false) {
        $status = 2;
        $msg = $gbl_msg_invalid_token;
    } else {
        $type=$post['type'];
        $where = [];
        $where['id'] = $post['request_id'];
        $uid_where = '';
        if($type=="sent"){
            $uid_where = "AND uid = '".$post['uid']."'";
            $where['uid'] = $post['uid'];
        }else{
            $uid_where = "AND business_id = '".$post['uid']."'";
            $where['business_id'] = $post['uid'];
        }
        $sql_req="SELECT * FROM tbl_request where id = '".$post['request_id']."' " . $uid_where ."  limit 1";
        $result=$db->query($sql_req);
        if($result->num_rows()>0){
            $update_data = [];
            $update_data["is_read"] = $post['is_read'];
            $update_data['date_updated'] = date("Y-m-d H:i:s");
                        
            $result = update('tbl_request', $update_data,$where);
            if($result){
                $status = 1;
                $msg = "Tattoo request marked as read successfully";
                // $msg = "בקשת הקעקוע סומנה כקריאה בהצלחה";
            }

        }else{
            $status = 0;
            $msg = "Tattoo Request not found";
            // $msg = "בקשת הקעקוע לא נמצאה";
        }
    }
}else {
    $status = 0;
    $msg = $gbl_msg_invalid_args;
}