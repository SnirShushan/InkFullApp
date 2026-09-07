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
            $artist_id=$post['uid'];
            $studio_id=$post['studio_id'];
            $is_exists="0";
            $result=$db->query("select id from tbl_artist_business_map where uid='".$artist_id."' AND bid='".$studio_id."' LIMIT 1");
            //$data['q']=$db->last_query();
            if($result)
            {
                if($result->num_rows()>0){
                    $is_exists="1";
                    $rows=$result->result_array();
                    $row=$rows[0];
                    $updatedata=['req_status'=>$post['action_status'],"date_updated"=>$dt];
                    $result = $db->update("tbl_artist_business_map", $updatedata, ['id'=>$row['id']]);
                    $msg="Success";

                    // $db->query("update tbl_notifications set status='".$post['action_status']."',date_updated='$dt' where uid='".$studio_id."' AND me='".$artist_id."' AND status='0' AND noti_type='studio_request_rcvd' ");
                    $db->query("update tbl_notifications set status='".$post['action_status']."',date_updated='$dt' where uid='".$artist_id."' AND me='".$studio_id."' AND status='0' AND noti_type='studio_request_sent' ");

                    if($post['action_status'] == "1"){
                        // $db->query("update tbl_notifications set status='".$post['action_status']."',date_updated='$dt' where uid='".$studio_id."' AND me='".$artist_id."' AND status='0' AND noti_type='artist_request_rcvd' ");
                        $db->query("update tbl_notifications set status='".$post['action_status']."' where uid='".$studio_id."' AND me='".$artist_id."' AND status='0' AND noti_type='artist_request_rcvd' ");
                    }
                    if($post['action_status'] == "2"){
                        $db->query("delete from tbl_notifications where status='0' and me='".$artist_id."' and uid='".$studio_id."' and noti_type='artist_request_rcvd' LIMIT 1");
                        $db->query("delete from tbl_artist_business_map where uid='".$artist_id."' AND bid='".$studio_id."' LIMIT 1");
                    }

                    $studio=get_user_profile($studio_id,$studio_id);
                    $artist=get_user_profile($artist_id,$artist_id);

                    if($studio['push_enable'] == '1')
                    {
                        $title = "";
                        if($post['action_status'] == "1"){
                            $title=$artist['name']." ".$gbl_msg_artist_apprv_req;
                        }
                        else{
                            $title=$artist['name']." ".$gbl_msg_artist_denied_req;
                        }
                        $push_data=[];
                        $push_data['badge_count']=1;
                        $push_data['description']='';
                        $push_data['pid']="0";
                        $push_data['screen']="notification";
                        $push_data['is_request']="0";
                        // $push_data['owner']=$artist;
                        // $data['push']=notification($title, [$studio['udid']], $push_data);
                        $data['push']=notification_new($title, $studio['udid'], $push_data,$studio['device_type']);
                        $data['push'] = json_decode($data['push'],true);
                    }
                }
            }

            if($is_exists=="0"){
                $status=0;
                $msg="Request not found";
            }


            

        }else{
            $status=0;
            $msg="Please send action";
        }
        
        
    }
} else {
    $status = 0;
    $msg = $gbl_msg_invalid_args;
}