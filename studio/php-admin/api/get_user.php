<?php
$fields = ['uid','login_token','app_token','device_type','app_version'];
$check = check_isset($fields);
$job_list = [];
if ($check) {
    $list=[];
    $post = get_all_data_protected($_REQUEST);
    $row = validate_token($post['login_token'], $post['uid']);
    if ($row == false) {
        $status = 2;
        $msg = $gbl_msg_invalid_token;
    }
    else{
        $msg="success";
        $status=1;
        // $data['profile']=get_user_profile($post['uid'],$post['uid']);
        $profile=get_user_profile($post['uid'],$post['uid']);
        
        $profile['styles_he'] = [];
        if($profile['styles'] != '')
        {
            $user_styles=explode(",",$profile['styles']);
            foreach($user_styles as $user_style)
            {
                $style_detail = get_style_detail(trim($user_style));
                $profile['styles_he'][] .= $style_detail['name'];
            }
        }
        $data['profile']=$profile;
        $data['styles_list'] = get_style_list();
        $data['artist']=get_business_artist_list($data['profile']['id'],$data['profile']['id']);
        $data['studio']=get_business_studio_list($data['profile']['id'],$data['profile']['id']);
        $data['followers']=get_user_followers($data['profile']['id']);
        $data['followers_list']=get_follower_list($data['profile']['id'],['limit'=>6]);
    }
} else {
    $status = 0;
    $msg = $gbl_msg_invalid_args;
}
