<?php
$fields = ['udid','device_type','app_token','device_type','app_version'];
$fields[]="phone";
$fields[]="cnt_code";
    
$check = check_isset($fields);
if ($check) {
    $postdata=get_all_data_protected($_REQUEST);
    $row = get_user_by_phone($postdata['phone']);
        
    if(count($row)>0)
    {
        $status=0;
        $msg="User already exists with given details";
    }
        

    if (count($row) <= 0) {
        $allow=1;
        $status = 1;
        $msg = "Register Success";
        $login_token =bin2hex(openssl_random_pseudo_bytes(64));
        $update_dt=date("Y-m-d H:i:s");
        $ins_data=[
            'register_type'=>1,
            'device_type'=>$postdata['device_type'],
            'udid'=>$postdata['udid'],
            'login_token'=>$login_token,
            'app_version'=>$postdata['app_version'],
            'ip_registered'=>get_client_ip(),
            'register_date'=>$update_dt,
            'date_added'=>$update_dt,
            'name'=>$postdata['name'],
            'status'=>1,
        ];

        

        if(isset($postdata['email']))
        {
            $row_email = get_user_by_email($postdata['email']);
            $ins_data['email']=$postdata['email'];
            if(count($row_email)>0){
                $allow="0";
                $msg="Email already exists.";
            }
        }

        if(isset($postdata['phone']))
        {
            $row_phone = get_user_by_phone($postdata['phone']);
            $ins_data['phone']=$postdata['phone'];
            if(count($row_phone)>0){
                $allow="0";
                $msg="Phone already exists.";
            }
        }
        if(isset($postdata['cnt_code']))
        {
            $ins_data['cnt_code']=$postdata['cnt_code'];
        }

        if($allow=="1")
        {
            $result=insert("tbl_customer", $ins_data);
            if($result){
                $uid=get_last_id();
                $data['profile'] = get_user_profile($uid,$uid);
                $status=1;
                $msg="Success";
            }else{
                $status=0;
                // $msg="Error in registration.";
                $msg="שגיאה בהרשמה";
            }
        }else{
            $status=0;

        }
        
    } else {
        $status = 0;
        $msg = "User already exists with given details.";
    }
} else {
    $status = 0;
    $msg = $gbl_msg_invalid_args;
}