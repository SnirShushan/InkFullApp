<?php
$fields = ['uid', 'login_token', 'app_token', 'device_type', 'app_version', 'fid', 'action_status'];
$check = check_isset($fields);
$job_list = [];
if ($check) {
    $post = get_all_data_protected($_REQUEST);
    $row = validate_token($post['login_token'], $post['uid']);
    if ($row == false) {
        $status = 2;
        $msg = $gbl_msg_invalid_token;
    } else {
        $status = 1;
        if ($post['action_status'] == "1") {
            $msg = "לעקוב בהצלחה";
            try {
                $is_exists = "0";
                if ($post['uid'] != $post['fid']) {
                    $result = $db->query("select id from tbl_follows where uid='" . $post['uid'] . "' AND follow_uid='" . $post['fid'] . "' LIMIT 1");
                    //$data['q']=$db->last_query();
                    if ($result) {
                        if ($result->num_rows() > 0) {
                            $is_exists = "1";
                        }
                    }
                    if ($is_exists == "0") {
                        $ins_data = [];
                        $ins_data['uid'] = $post['uid'];
                        $ins_data['follow_uid'] = $post['fid'];
                        $ins_data['date_added'] = date("Y-m-d H:i:s");
                        insert('tbl_follows', $ins_data);
                    }
                }
            } catch (Exception  $e) {
                $status = 0;
                $msg = "שגיאה לעקוב";
            }
        } else {
            try {
                $result = $db->query("DELETE FROM tbl_follows WHERE uid='" . $post['uid'] . "' AND follow_uid='" . $post['fid'] . "'");
                $msg = "בטל את המעקב בהצלחה";
            }catch (Exception  $e) {
                $status = 0;
                $msg = "שגיאה לבטל את המעקב אחר המשתמש";
            }
            //$data['q']=$db->last_query();
        }
        $data['followers']=get_user_followers($post['fid']);
    }
} else {
    $status = 0;
    $msg = $gbl_msg_invalid_args;
}
