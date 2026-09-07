<?php
$fields = ['uid','login_token','app_token','device_type','app_version','studio_id','action_status'];
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
            $is_exists="0";
            $result=$db->query("select id from tbl_artist_business_map where uid='".$post['uid']."' AND bid='".$post['studio_id']."' LIMIT 1");
            //$data['q']=$db->last_query();
            if($result)
            {
                if($result->num_rows()>0){
                    $is_exists="1";
                    $rows=$result->result_array();
                    $row=$rows[0];
                }
            }

            if($post['action_status']=="1")
            {
                if($is_exists=="1")
                {
                    $status=0;
                    // $msg="Already in list";
                    // $msg="כבר נמצא ברשימה";
                    $msg="הבקשה כבר נשלחה";
                }else{
                    $ins_artist_data=[];
                    $ins_artist_data['uid'] = $post['uid'];
                    $ins_artist_data['bid'] = $post['studio_id'];
                    $ins_artist_data['req_status'] = '0';
                    $ins_artist_data['date_added'] = $dt;
                    
                    insert('tbl_artist_business_map', $ins_artist_data);
                    $status=1;

                        /* $ins_f=[];
                        $ins_f['noti_type']="artist_request_rcvd";
                        $ins_f['date_added']=$dt;
                        $ins_f['uid']=$post['uid'];
                        $ins_f['pid']=0;
                        $ins_f['me']=$post['studio_id'];
                        insert("tbl_notifications",$ins_f); */
                        
                        $ins_f=[];
                        $ins_f['noti_type']="artist_request_sent";
                        $ins_f['date_added']=$dt;
                        $ins_f['uid']=$post['studio_id'];
                        $ins_f['pid']=0;
                        $ins_f['me']=$post['uid'];
                        insert("tbl_notifications",$ins_f);

                        /* $ins_f=[];
                        $ins_f['noti_type']="studio_request_sent";
                        $ins_f['date_added']=$dt;
                        $ins_f['uid']=$post['studio_id'];
                        $ins_f['pid']=0;
                        $ins_f['me']=$post['uid'];
                        insert("tbl_notifications",$ins_f); */
                        
                        $ins_f=[];
                        $ins_f['noti_type']="studio_request_rcvd";
                        $ins_f['date_added']=$dt;
                        $ins_f['uid']=$post['uid'];
                        $ins_f['pid']=0;
                        $ins_f['me']=$post['studio_id'];
                        insert("tbl_notifications",$ins_f);

                        $studio_user=get_user_profile($post['studio_id'],$post['studio_id']);
                        $artist_user=get_user_profile($post['uid'],$post['uid']);

                        if($artist_user['push_enable'] == '1')
                        {
                            $title=$artist_user['name']." ".$gbl_msg_req_rcv_from_artist;
                            $push_data=[];
                            $push_data['badge_count']=1;
                            $push_data['description']='';
                            $push_data['pid']="0";
                            // $push_data['owner']=$artist_user;
                            $push_data['screen']="notification";
                            $push_data['is_request']="0";
                            // $data['push']=notification($title, [$studio_user['udid']], $push_data);
                            $data['push']=notification_new($title, $studio_user['udid'], $push_data,$studio_user['device_type']);
                            $data['push'] = json_decode($data['push'],true);
                        }
                        $data['d']=$studio_user;

                }
            }


            if($post['action_status']=="2")
            {
                if($is_exists=="1")
                {
                    $status=1;
                    $db->query("delete from tbl_artist_business_map where uid='".$post['uid']."' AND bid='".$post['studio_id']."'");

                    $chek_sql="select id from tbl_notifications where status='0' AND (uid='".$post['studio_id']."' OR me='".$post['uid']."') AND (uid='".$post['uid']."' OR me='".$post['studio_id']."')  LIMIT 1";
                    $result_chk=$db->query($chek_sql);
                    if($result_chk){
                        if($result_chk->num_rows()>0){
                                $chek_sql1="delete from tbl_notifications where status='0' AND (uid='".$post['studio_id']."' OR me='".$post['uid']."') AND (uid='".$post['uid']."' OR me='".$post['studio_id']."')  LIMIT 1";
                                $db->query($chek_sql1);
                        }
                    }

                    // $db->query("delete from tbl_artist_business_map where uid='".$post['uid']."' AND bid='".$post['studio_id']."'");
                }else{
                   $status=0;
                //    $msg="No artist found on your list";
                   $msg="לא נמצא צוות";
                }
            }

            $users=[];
            $result=$db->query("select uid,req_status,date_added from tbl_artist_business_map where uid='".$post['uid']."' AND req_status IN('0','1') ORDER BY date_added DESC");
            //$data['f']=$db->last_query();
            if($result){
                if($result->num_rows()>0){
                    foreach($result->result_array() as $row){
                        $profile=get_user_profile($row['uid']);
                        if(count($profile)>0){
                            $row['profile']=$profile;
                            $users[]=$row;
                        }
                        
                    }
                }
            }
            $data['users']=$users;

        }else{
            $status=0;
            $msg="Please send action";
        }
        
        
    }
} else {
    $status = 0;
    $msg = $gbl_msg_invalid_args;
}