<?php
$fields = ['uid','login_token','app_token','device_type','app_version','is_following'];
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
        $status=1;
        $followers=[];
        $params = [];
        if(isset($post['start']))
        {
            if($post['start']!=""){
                $params['start']=$post['start'];
            }
        }

        if(isset($post['limit']))
        {
            if($post['limit']!=""){
                $params['limit']=$post['limit'];
            }
        }
        
        if(isset($post['is_following']))
        {
            if($post['is_following'] != ""){
                $params['is_following'] = $post['is_following'];
            }
        }

        $data['followers'] = get_user_followers($post['uid'],$params);
        $followers = get_follower_list($post['uid'], $params);
        $data['followers_list']=$followers;
    }
}
