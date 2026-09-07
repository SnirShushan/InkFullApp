<?php
$fields = ['udid', 'device_type', 'login_type', 'app_token', 'app_version'];
$check = check_isset($fields);
if ($check) {
    $postdata = get_all_data_protected($_REQUEST);
    
    $limit = get_settings();
    $post_limit = $limit['post_limit'];

    if ($postdata['login_type'] == 1) {
        $row = get_user_by_phone($postdata['phone']);
        if (count($row) > 0) {

            $status = 1;
            // $msg = "login Success";
            $msg = "התחברת בהצלחה";
            $login_token = bin2hex(openssl_random_pseudo_bytes(64));
            $update_dt = date("Y-m-d H:i:s");
            $update_data = [
                'device_type' => $postdata['device_type'],
                'udid' => $postdata['udid'],
                'login_token' => $login_token,
                'app_version' => $postdata['app_version'],
                'ip_login' => get_client_ip(),
                'login_date' => $update_dt
            ];
            if($row['email'] == ""){
                $update_data['is_register'] = 1;
            }
            else{
                $update_data['is_register'] = 0;
            }
            $result = update("tbl_customer", $update_data, ['id' => $row['id']]);
            if ($result) {
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
                $data['startup_image'] = $startup_image;
                // $user=get_business_detail($row['id'],$row['id']);
                // if(count($user)>0){
                //     $data['business']=$user;
                // }
            }
        } else {
            $status = 1;
            // $msg = "login Success";
            $msg = "התחברת בהצלחה";
            $ins_data = [];
            $ins_data['phone'] = $postdata['phone'];
            $ins_data['cnt_code'] = $postdata['cnt_code'];
            $ins_data['device_type'] = $postdata['device_type'];
            $ins_data['login_type'] = $postdata['login_type'];
            $ins_data['app_version'] = $postdata['app_version'];
            $ins_data['register_date'] = date("Y-m-d H:i:s");
            $ins_data['date_added'] = date("Y-m-d H:i:s");
            $ins_data['date_updated'] = date("Y-m-d H:i:s");
            $ins_data['post_limit'] = $post_limit;
            $ins_data['is_register'] = '1';
            insert('tbl_customer', $ins_data);
            $ins_id = get_last_id();
            if ($ins_id) {
                $login_token = bin2hex(openssl_random_pseudo_bytes(64));
                $update_dt = date("Y-m-d H:i:s");
                $update_data = [
                    'device_type' => $postdata['device_type'],
                    'udid' => $postdata['udid'],
                    'login_token' => $login_token,
                    'app_version' => $postdata['app_version'],
                    'ip_login' => get_client_ip(),
                    'login_date' => $update_dt
                ];
                $result = update("tbl_customer", $update_data, ['id' => $ins_id]);
                if ($result) {
                    $profile=get_user_profile($ins_id,$ins_id);
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
                    $data['startup_image'] = $startup_image;
                    // $user=get_business_detail($ins_id,$ins_id);
                    // if(count($user)>0){
                    //     $data['business']=$user;
                    // }
                }
            }
        }
    }

    //login with apple
    if ($postdata['login_type'] == 2) {
        $row = get_user_by_email($postdata['email']);
        if (count($row) > 0) {

            $status = 1;
            // $msg = "login Success";
            $msg = "התחברת בהצלחה";
            $login_token = bin2hex(openssl_random_pseudo_bytes(64));
            $update_dt = date("Y-m-d H:i:s");
            $update_data = [
                'device_type' => $postdata['device_type'],
                'udid' => $postdata['udid'],
                'login_token' => $login_token,
                'app_version' => $postdata['app_version'],
                'ip_login' => get_client_ip(),
                'login_date' => $update_dt
            ];

            if($row['phone'] == ""){
                $update_data['is_register'] = 1;
            }
            else{
                $update_data['is_register'] = 0;
            }

            if(isset($postdata['apple_id'])){
                if($postdata['apple_id']!="")
                    $update_data['apple_id']=$postdata['apple_id'];
            }
            $result = update("tbl_customer", $update_data, ['id' => $row['id']]);
            if ($result) {
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
                $data['startup_image'] = $startup_image;
                // $user=get_business_detail($row['id'],$row['id']);
                // if(count($user)>0){
                //     $data['business']=$user;
                // }
            }
        } else {
            $status = 1;
            // $msg = "login Success";
            $msg = "התחברת בהצלחה";
            $ins_data = [];
            $ins_data['phone'] = "";
            $ins_data['cnt_code'] = "";
            $ins_data['name'] = $postdata['name'];
            $ins_data['email'] = $postdata['email'];
            $ins_data['device_type'] = $postdata['device_type'];
            $ins_data['login_type'] = $postdata['login_type'];
            $ins_data['register_type'] = "2";
            $ins_data['app_version'] = $postdata['app_version'];
            $ins_data['register_date'] = date("Y-m-d H:i:s");
            $ins_data['date_added'] = date("Y-m-d H:i:s");
            $ins_data['date_updated'] = date("Y-m-d H:i:s");
            $ins_data['post_limit'] = $post_limit;
            $ins_data['is_register'] = '1';

            if(isset($postdata['apple_id'])){
                if($postdata['apple_id']!="")
                    $ins_data['apple_id']=$postdata['apple_id'];
            }
            insert('tbl_customer', $ins_data);
            $ins_id = get_last_id();
            if ($ins_id) {
                $login_token = bin2hex(openssl_random_pseudo_bytes(64));
                $update_dt = date("Y-m-d H:i:s");
                $update_data = [
                    'device_type' => $postdata['device_type'],
                    'udid' => $postdata['udid'],
                    'login_token' => $login_token,
                    'app_version' => $postdata['app_version'],
                    'ip_login' => get_client_ip(),
                    'login_date' => $update_dt
                ];
                $result = update("tbl_customer", $update_data, ['id' => $ins_id]);
                if ($result) {
                    $profile=get_user_profile($ins_id,$ins_id);
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
                    $data['startup_image'] = $startup_image;
                    // $user=get_business_detail($ins_id,$ins_id);
                    // if(count($user)>0){
                    //     $data['business']=$user;
                    // }
                }
            }
        }
    }// if login with phone

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
