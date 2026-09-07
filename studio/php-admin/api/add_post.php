<?php

$fields = ['uid', 'login_token', 'image_type', 'styles', 'description', 'image_name', 'image_id', 'artist_uid', 'studio_uid', 'device_type', 'app_version', 'app_token'];
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
        $dt = date("Y-m-d H:i:s");
        $ins_data = [];
        $ins_data['uid'] = $post['uid'];
        $ins_data['img_type'] = $post['image_type'];
        $ins_data['styles'] = $post['styles'];
        $ins_data['description'] = trim($post['description']);
        $ins_data['image_name'] = $post['image_name'];
        $ins_data['image_id'] = $post['image_id'];
        $ins_data['date_added'] = $dt;
        $ins_data['date_updated'] = $dt;
        $ins_data['artist_uid'] = $post['artist_uid'];
        $ins_data['studio_uid'] = $post['studio_uid'];
        $ins_data['status'] = '1';

        $result = insert('tbl_post', $ins_data);
        if ($result) {
            // $msg = "Post added Successfully";
            $msg = "התמונה הועלתה בהצלחה";
            $status = 1;
            $uids=[];
            $post_id = get_last_id();
            if ($post_id) {
                $user=get_user_profile($post['uid']);

                if($user['business_type']=="1")
                {
                    if($post['artist_uid']!=""){
                        if($post['artist_uid']!=$post['uid']){
                            $artist=get_user_profile($post['artist_uid'],$post['artist_uid']);
                            if(count($artist)>0){
                                if($artist['business_type']=='2'){
                                    $ins_f=[];
                                    $ins_f['noti_type']="post_mention";
                                    $ins_f['date_added']=$dt;
                                    $ins_f['uid']=$post['uid'];
                                    $ins_f['pid']=$post_id;
                                    $ins_f['me']=$post['artist_uid'];
                                    insert("tbl_notifications",$ins_f);
    
                                    if($artist['push_enable'] == '1'){
                                        $title=$user['name']." ".$gbl_msg_artist_post_mention;
                                        $push_data=[];
                                        $push_data['badge_count']=1;
                                        $push_data['description']='';
                                        $push_data['pid']=$post_id;
                                        // $push_data['owner']=$user;
                                        $push_data['screen']="post_mention";
                                        // $data['push']=notification($title, [$artist['udid']], $push_data);
                                        $data['push']=notification_new($title, $artist['udid'], $push_data,$artist['device_type']);
                                        $data['push'] = json_decode($data['push'],true);
                                    }
                                }
                            }
                        }// artist user and login user should not be same
                    }//if artist is there
                }//if studio


                
                /// send push notification to the followers that new post added and add entry to the notification table
                $sql_follow="select uid from tbl_follows where follow_uid='".$post['uid']."' AND uid!=follow_uid";
                $result_follow=$db->query($sql_follow);
                if($result_follow){
                    if($result_follow->num_rows()>0){
                        foreach($result_follow->result() as $f){
                            $ins_f=[];
                            $ins_f['noti_type']="new_post";
                            $ins_f['date_added']=$dt;
                            $ins_f['uid']=$post['uid'];
                            $ins_f['pid']=$post_id;
                            $ins_f['me']=$f->uid;
                            insert("tbl_notifications",$ins_f);
                            $uids[]=$f->uid;
                        }//foreach loop
                        $list_device=[];
                        
                        if(count($uids)>0){
                            
                            $list_uids=get_udid($uids);
                            /* foreach($list_uids as $sl){
                                if($sl['push_enable'] == '1')
                                {
                                    $list_device[]=$sl['udid'];
                                }
                            } */
                            
                            $title=$user['name']." ".$gbl_msg_aded_post;
                            $push_data=[];
                            $push_data['badge_count']=1;
                            $push_data['description']='';
                            $push_data['pid']=$post_id;
                            // $push_data['owner']=$user;
                            $push_data['screen']="new_post";
                            foreach($list_uids as $sl){
                                if($sl['push_enable'] == '1')
                                {
                                    // $data['follow_push']=notification($title, $list_device, $push_data);
                                    $data['follow_push']=notification_new($title, $sl['udid'], $push_data,$sl['device_type']);
                                    $data['follow_push'] = json_decode($data['follow_push'],true);
                                }
                            }
                            
                        }//if user has to sent 
                        
                        
                    }//if number of rows found
                }//find follower fo this business
            }
        }
        $data['d']=$post;
    }
} else {
    $status = 0;
    $msg = $gbl_msg_invalid_args;
}
