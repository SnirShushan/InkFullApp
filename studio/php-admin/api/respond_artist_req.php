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
            $is_exists="0";
            $result=$db->query("select id from tbl_artist_business_map where uid='".$post['artist_id']."' AND bid='".$post['uid']."' LIMIT 1");
            //$data['q']=$db->last_query();
            if($result)
            {
                if($result->num_rows()>0){
                    $is_exists="1";
                    $rows=$result->result_array();
                    $row=$rows[0];
                }
            }
            if($is_exists=="1"){
                $updatedata=[];
                $updatedata['req_status']=$post['action_status'];
                $updatedata['date_updated'] = date("Y-m-d H:i:s");
                $result = $db->update("tbl_artist_business_map", $updatedata, ['id'=>$row['id']]);


                $updatedata=[];
                $updatedata['status']=$post['action_status'];
                $updatedata['date_updated'] = date("Y-m-d H:i:s");
                // $result = $db->update("tbl_notifications", $updatedata, ['status'=>"0",'me'=>$post['uid'],"uid"=>$post['artist_id'],"noti_type"=>"artist_request_rcvd"]);
                $result = $db->update("tbl_notifications", $updatedata, ['status'=>"0",'me'=>$post['artist_id'],"uid"=>$post['uid'],"noti_type"=>"artist_request_sent"]);
                // $result = $db->delete("tbl_notifications", $updatedata, ['status'=>"0",'me'=>$post['uid'],"uid"=>$post['artist_id'],"noti_type"=>"studio_request_rcvd"]);
                
                if($post['action_status'] == "1"){
                    // $db->query("update tbl_notifications set status='".$post['action_status']."',date_updated='$dt' where uid='".$post['artist_id']."' AND me='".$post['uid']."' AND status='0' AND noti_type='studio_request_rcvd' ");
                    $db->query("update tbl_notifications set status='".$post['action_status']."' where uid='".$post['artist_id']."' AND me='".$post['uid']."' AND status='0' AND noti_type='studio_request_rcvd' ");
                }
                if($post['action_status'] == '2'){
                    $db->query("delete from tbl_notifications where status='0' and me='".$post['uid']."' and uid='".$post['artist_id']."' and noti_type='studio_request_rcvd' LIMIT 1");
                    $db->query("delete from tbl_artist_business_map where uid='".$post['artist_id']."' AND bid='".$post['uid']."' LIMIT 1");
                }

                $studio=get_user_profile($post['uid'],$post['uid']);
                $artist=get_user_profile($post['artist_id'],$post['artist_id']);

                if($artist['push_enable'] == '1')
                {
                    $title = "";
                    if($post['action_status'] == "1"){
                        $title=$studio['name']." ".$gbl_msg_studio_apprv_req;
                    }
                    else{
                        $title=$studio['name']." ".$gbl_msg_studio_denied_req;
                    }
                    $push_data=[];
                    $push_data['badge_count']=1;
                    $push_data['description']='';
                    $push_data['pid']="0";
                    $push_data['screen']="notification";
                    $push_data['is_request']="0";
                    // $push_data['owner']=$studio;
                    // $data['push']=notification($title, [$artist['udid']], $push_data);
                    $data['push']=notification_new($title, $artist['udid'], $push_data,$artist['device_type']);
                    $data['push'] = json_decode($data['push'],true);
                }

            }else{
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