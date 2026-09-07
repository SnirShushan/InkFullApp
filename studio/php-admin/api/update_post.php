<?php

$fields = ['uid', 'login_token', 'pid', 'device_type', 'app_version', 'app_token'];
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
        $update_data = [];
        $update_data['date_updated'] = $dt;
        if(isset($post['image_type']))
        {
            if($post['image_type']!="")
            {
                $update_data['img_type'] = $post['image_type'];
            }
        }

        if(isset($post['image_name']))
        {
            if($post['image_name']!="")
            {
                $update_data['image_name'] = $post['image_name'];
            }
        }

        if(isset($post['image_id']))
        {
            if($post['image_id']!="")
            {
                $update_data['image_id'] = $post['image_id'];
            }
        }
        
        if(isset($post['styles']))
            $update_data['styles'] = $post['styles'];
        if(isset($post['description']))
            $update_data['description'] = trim($post['description']);
        
        
        if(isset($post['artist_uid'])){
            if($post['artist_uid']!="")
            {
                
                $post_detail=get_post_detail($post['pid'],$post['uid']);
                if($post_detail['artist_uid']!=$post['artist_uid']){
                                    $artist=get_user_profile($post['artist_uid'],$post['artist_uid']);
                                    $user=get_user_profile($post['uid']);
                                    $ins_f=[];
                                    $ins_f['noti_type']="post_mention";
                                    $ins_f['date_added']=$dt;
                                    $ins_f['uid']=$post['uid'];
                                    $ins_f['pid']=$post['pid'];
                                    $ins_f['me']=$post['artist_uid'];
                                    insert("tbl_notifications",$ins_f);
    
                                    if($artist['push_enable'] == '1')
                                    {
                                        $title=$user['name'].$gbl_msg_aded_post;
                                        $push_data=[];
                                        $push_data['badge_count']=1;
                                        $push_data['description']='';
                                        $push_data['pid']=$post['pid'];
                                        // $push_data['owner']=$user;
                                        $push_data['screen']="post_mention";
                                        // $data['push']=notification($title, [$artist['udid']], $push_data);
                                        $data['push']=notification_new($title, $artist['udid'], $push_data,$artist['device_type']);
                                        $data['push'] = json_decode($data['push'],true);
                                    }
                }
                $update_data['artist_uid'] = $post['artist_uid'];
                
            }
            else if($post['artist_uid'] == "")
            {
                $update_data['artist_uid'] = $post['artist_uid'];
            }
            

        }

        if(isset($post['studio_uid']))
            $update_data['studio_uid'] = $post['studio_uid'];
        
            
        $result = update('tbl_post', $update_data,['id'=>$post['pid']]);
        $data['d']=$post;
        $data['d1']=$db->last_query();
        if ($result) {
            // $msg = "Post updated Successfully";
            $msg = "הפוסט עודכן בהצלחה";
            $status = 1;
        }
    }
} else {
    $status = 0;
    $msg = $gbl_msg_invalid_args;
}
