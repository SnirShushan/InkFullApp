<?php
$fields = ['udid','device_type','app_token','app_version'];
$fields[]="email";
// $fields[]="gmail_data";
    
$check = check_isset($fields);
if ($check) {
    $postdata=get_all_data_protected($_REQUEST);
    $row = get_user_by_email($postdata['email']);

    $limit = get_settings();
    $post_limit = $limit['post_limit'];

    if(count($row)>0)
    {
        $status = 1;
        // $msg = "login Success";
        $msg = "התחברת בהצלחה";
        $login_token =bin2hex(openssl_random_pseudo_bytes(64));
        $update_dt=date("Y-m-d H:i:s");
        $update_data=[
            'login_type'=>3,
            'device_type'=>$postdata['device_type'],
            'udid'=>$postdata['udid'],
            'login_token'=>$login_token,
            'app_version'=>$postdata['app_version'],
            'ip_login'=>get_client_ip(),
            'date_updated'=>$update_dt,
            'login_date' => $update_dt
        ];

        if($row['phone'] == ""){
            $update_data['is_register'] = 1;
        }
        else{
            $update_data['is_register'] = 0;
        }

        $result=update("tbl_customer", $update_data, ['id'=>$row['id']]);
        if($result){
            $profile=get_user_profile($row['id'],$row['id']);
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
            $data['profile'] = $profile;
            $data['styles_list'] = get_style_list();
        }
    }
    else{
        $status=1;
        $login_token =bin2hex(openssl_random_pseudo_bytes(64));
        $update_dt=date("Y-m-d H:i:s");
        $ins_data=[
            'register_type'=>3,
            'login_type'=>3,
            'device_type'=>$postdata['device_type'],
            'udid'=>$postdata['udid'],
            'login_token'=>$login_token,
            'app_version'=>$postdata['app_version'],
            'ip_registered'=>get_client_ip(),
            'register_date'=>$update_dt,
            'date_added'=>$update_dt,
            // 'name'=>$postdata['name'],
            'email'=>$postdata['email'],
            // 'gmail_data'=>$postdata['gmail_data'],
            'status'=>1,
            'is_register'=>1,
            'post_limit'=>$post_limit
        ];

            $result=insert("tbl_customer", $ins_data);
            if($result){
                $uid=get_last_id();
                $profile=get_user_profile($uid,$uid);
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
                $data['profile'] = $profile;
                $data['styles_list'] = get_style_list();
                $status=1;
                $msg="Success";
            }else{
                $status=0;
                // $msg="Error in registration.";
                $msg="שגיאה בהרשמה";
            }
    }

    if(count($data['profile'])>0){
        if($data['profile']['status']=="1")
        {
            $status=1;
            $msg="Success";
            $data['artist']=get_business_artist_list($data['profile']['id'],$data['profile']['id']);
            $data['studio']=get_business_studio_list($data['profile']['id'],$data['profile']['id']);
            $data['followers']=get_user_followers($data['profile']['id']);
        }else if($data['profile']['status']=="2"){
            $status="0";
            // $msg="You are blocked by admin.";
            $msg="המשתמש נחסם על ידי האדמין";
            $data['profile']=[];
        }else if($data['profile']['status']=="3"){
            $status="0";
            // $msg="Your account has been archived";
            $msg="החשבון הועבר לארכיון";
            $msg="החשבון נמחק";
            $data['profile']=[];
        }
        
    }
        

} else {
    $status = 0;
    $msg = $gbl_msg_invalid_args;
}