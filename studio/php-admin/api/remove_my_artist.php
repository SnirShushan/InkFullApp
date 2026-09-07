<?php
$fields = ['uid','login_token','app_token','device_type','app_version','artist_id','action_status'];
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
        $msg="success";
        $status=1;
        $dt=date("Y-m-d H:i:s");
        if(in_array($post['action_status'],['1','2']))
        {   
            $artist_ids = explode(',', $post['artist_id']);  // Explode artist_id into an array
            $push_arr = [];
            foreach ($artist_ids as $artist_id) {
                $artist_id = trim($artist_id);  // Remove any extra spaces
                $is_exists="0";
                $result=$db->query("SELECT id FROM tbl_artist_business_map WHERE uid='$artist_id' AND bid='".$post['uid']."' LIMIT 1");
                
                if($result && $result->num_rows() > 0) {
                    $is_exists="1";
                    $rows = $result->result_array();
                    $row = $rows[0];
                }

                if($post['action_status'] == "1") {
                    if($is_exists == "1") {
                        $status = 0;
                        $msg = "הבקשה כבר נשלחה";  // Request already sent
                    } else {
                        $ins_artist_data = [
                            'uid' => $artist_id,
                            'bid' => $post['uid'],
                            'req_status' => '0',
                            'date_added' => $dt
                        ];
                        insert('tbl_artist_business_map', $ins_artist_data);
                        $status = 1;

                        // Notification when request is sent
                        $ins_f = [
                            'noti_type' => "studio_request_sent",
                            'date_added' => $dt,
                            'uid' => $artist_id,
                            'pid' => 0,
                            'me' => $post['uid']
                        ];
                        insert("tbl_notifications", $ins_f);

                        // Notification when request is received
                        $ins_f = [
                            'noti_type' => "artist_request_rcvd",
                            'date_added' => $dt,
                            'uid' => $post['uid'],
                            'pid' => 0,
                            'me' => $artist_id
                        ];
                        insert("tbl_notifications", $ins_f);

                        $studio_user = get_user_profile($post['uid'], $post['uid']);
                        $artist_user = get_user_profile($artist_id, $artist_id);

                        if($artist_user['push_enable'] == '1') {
                            $title = $studio_user['name'] . " " . $gbl_msg_req_rcv_from_studio;
                            $push_data = [
                                'badge_count' => 1,
                                'description' => '',
                                'pid' => "0",
                                'screen' => "notification",
                                'is_request' => "0"
                            ];
                            $push = notification_new($title, $artist_user['udid'], $push_data,$artist_user['device_type']);
                            $push = json_decode($push, true);
                            $push_arr[] = $push;
                        }
                        $data['d'] = $studio_user;
                    }
                }

                if($post['action_status'] == "2") {
                    if($is_exists == "1") {
                        $status = 1;
                        $db->query("DELETE FROM tbl_artist_business_map WHERE uid='$artist_id' AND bid='".$post['uid']."'");
                        $db->query("DELETE FROM tbl_notifications WHERE status='0' AND me='".$artist_id."' and uid='".$post['uid']."' and noti_type='artist_request_rcvd' ORDER BY id DESC LIMIT 1");
                        $db->query("DELETE FROM tbl_notifications WHERE status='0' AND uid='".$artist_id."' and me='".$post['uid']."' and noti_type='studio_request_sent' ORDER BY id DESC LIMIT 1");
                        
                        /* $chek_sql = "SELECT id FROM tbl_notifications WHERE status='0' AND (uid='$artist_id' OR me='".$post['uid']."') AND (uid='".$post['uid']."' OR me='$artist_id') LIMIT 1";
                        $result_chk = $db->query($chek_sql);
                        if($result_chk && $result_chk->num_rows() > 0) {
                            $db->query("DELETE FROM tbl_notifications WHERE status='0' AND (uid='$artist_id' OR me='".$post['uid']."') AND (uid='".$post['uid']."' OR me='$artist_id') LIMIT 1");
                        } */
                    } else {
                        $status = 0;
                        $msg = "לא נמצא צוות";  // No team found
                    }
                }
            }

            // Fetch list of users with pending or accepted requests
            $users = [];
            $result = $db->query("SELECT uid, req_status, date_added FROM tbl_artist_business_map WHERE bid='".$post['uid']."' AND req_status IN('0','1') ORDER BY date_added DESC");
            if($result && $result->num_rows() > 0) {
                foreach($result->result_array() as $row) {
                    $profile = get_user_profile($row['uid']);
                    if(count($profile) > 0) {
                        $row['profile'] = $profile;
                        $users[] = $row;
                    }
                }
            }
            $data['push'] = $push_arr;
            $data['users'] = $users;
        } else {
            $status = 0;
            $msg = "Please send action";
        }
    }
} else {
    $status = 0;
    $msg = $gbl_msg_invalid_args;
}