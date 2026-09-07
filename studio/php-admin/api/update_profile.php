<?php
$fields = ['uid','login_token','app_token','device_type','app_version'];
$check = check_isset($fields);
$email = '';
$name = '';
$is_exists = 0;
$is_name_exists = 0;
$is_phone_wrong = 0;
$is_register = 0;
$post_name = "";
$post_phone = "";
$post_email = "";
$login_type = "";
if ($check) {
    $post = get_all_data_protected($_REQUEST);
    $row = validate_token($post['login_token'], $post['uid']);
    if ($row == false) {
        $status = 2;
        $msg = $gbl_msg_invalid_token;
    }
    else{
        $update_dt=date("Y-m-d H:i:s");

        //$sql = "UPDATE tbl_customer set name='".$post['name']."', email='".$post['email']."', date_updated='".$update_dt."' WHERE id='".$row['id']."' LIMIT 1";
        $updatedata=[];
        $updatedata['date_updated']=$update_dt;
        // $updatedata['is_register'] = 0;
        $user_detail = get_user_profile($post['uid']);
        if(!empty($user_detail)){
            $name = ($user_detail['name'] != NULL) ? trim($user_detail['name']) : '';
            $email = ($user_detail['email'] != NULL) ? trim($user_detail['email']) : '';
            $phone = ($user_detail['phone'] != NULL) ? trim($user_detail['phone']) : '';
            $login_type = $user_detail['login_type'];

            if($login_type == '2' || $login_type == '3'){
                if(($name == '' || $name == null) && ($phone == '' || $phone == null)) {
                    $is_register = 1;
                }
            }
            
            if($login_type == '1'){
                if(($name == '' || $name == null) && ($email == '' || $email == null)) {
                    $is_register = 1;
                }
            }

        }

        if(isset($post['name']))
        {
            $post_name = trim($post['name']);
            if($post_name!=""){
                $user_detail = check_is_unique_user_name(['id'=>$post['uid'],'name'=>$post_name]);
                if(!$user_detail){
                    $is_name_exists = 1;
                    // $msg = "Name Already Exists";
                    $msg = "השם כבר קיים";
                }
                else{
                    $updatedata['name']=$post_name;
                }
            }
            else{
                $is_name_exists = 1;
                $msg = "שם לא יכול להיות ריק";
            }
        }

        if(isset($post['phone']))
        {
            $post_phone = trim($post['phone']);
            if($post_phone!=""){
                $user_detail = get_user_by_phone($post_phone);
                if(!empty($user_detail)){
                    if($user_detail['id'] != $row['id'] ){
                        $is_exists = 1;
                        $msg = "מספר הטלפון כבר קיים";
                        // $msg = "Phone Already Exists";
                    }
                    else{
                        $phone = $post_phone;
                        $firstThreeDigit = substr($phone, 0, 3);
                        $firstFourDigit = substr($phone, 0, 4);
                        if ($firstThreeDigit == '972' || $firstFourDigit == '0972') {
                            $is_phone_wrong = 1;
                            $msg = "אין צורך להקליד קידומת מדינה 972";
                        }
                        else{
                            $updatedata['phone']=$post_phone;
                        }
                    }
                }
                else{
                    $phone = $post_phone;
                    $firstThreeDigit = substr($phone, 0, 3);
                    $firstFourDigit = substr($phone, 0, 4);
                    if ($firstThreeDigit == '972' || $firstFourDigit == '0972') {
                        $is_phone_wrong = 1;
                        $msg = "אין צורך להקליד קידומת מדינה 972";
                    }
                    else{
                        $updatedata['phone']=$post_phone;
                    }
                }
            }
            else{
                $is_exists = 1;
                $msg = "מספר טלפון לא יכול להיות ריק";
                // $msg = "Phone Number Cannot Be Empty";
            }
        }

        if(isset($post['email']))
        {
            $post_email = trim($post['email']);
            if($post_email!=""){
                $user_detail = get_user_by_email($post_email);
                if(!empty($user_detail)){
                    if($user_detail['id'] != $row['id']){
                        $is_exists = 1;
                        // $msg = "Email Already Exists";
                        $msg = "האימייל כבר קיים";
                    }
                    else{
                        $updatedata['email']=$post_email;
                    }
                }
                else{
                    $updatedata['email']=$post_email;
                }
            }
            else{
                $is_exists = 1;
                // $msg = "Email Cannot Be Empty";
                $msg = "האימייל לא יכול להיות ריק";
            }
        }

        if(isset($post['address']))
        {
            if($post['address']!=""){
                // $updatedata['address']=trim($post['address']);
                // $updatedata['address']=$db_old->real_escape_string(trim($_REQUEST['address']));
                $updatedata['address_lat']=$post['address_lat'];
                $updatedata['address_lng']=$post['address_lng'];
                // $updatedata['city_name']=$post['city_name'];
                // $updatedata['city_name']=$db_old->real_escape_string(trim($_REQUEST['city_name']));
                $updatedata['address_place_id']=$post['address_place_id'];

                $updatedata['address'] = stripslashes($post['address']);
                $updatedata['city_name'] = stripslashes($post['city_name']);
            }
        }

        
        if(isset($post['about_text']))
        {
            // if($post['about_text']!=""){
                $updatedata['about_text']=trim($post['about_text']);
            // }
        }

        if(isset($post['styles']))
        {
            // if($post['styles']!=""){
                $updatedata['styles']=$post['styles'];
            // }
        }

        if(isset($post['firebase_id']))
        {
            if($post['firebase_id']!=""){
                $updatedata['firebase_id']=$post['firebase_id'];
            }
        }

        if(isset($post['cnt_code']))
        {
            if($post['cnt_code']!=""){
                $updatedata['cnt_code']=$post['cnt_code'];
            }
        }

        if(isset($post['location_enable']))
        {
            if($post['location_enable']!=""){
                $updatedata['location_enable']=$post['location_enable'];
            }
        }

        if(isset($post['push_enable']))
        {
            if($post['push_enable']!=""){
                $updatedata['push_enable']=$post['push_enable'];
            }
        }

        if($is_exists == 1){
            $status = 0;
        }
        else if($is_phone_wrong == 1){
            $status = 0;
        }
        else{
            if($is_name_exists == 1){
                $status = 0;
            }
            else{
                if($login_type == '2' || $login_type == '3'){
                    if(isset($post['name']) && isset($post['phone'])){
                        if(($post_name == '' || $post_name == null) && ($post_phone == '' || $post_phone == null)) {
                            $data['check_register'] = 1;
                            $is_register = 1;
                        }
                        else{
                            $is_register = 0;
                        }
                    }
                }
                
                if($login_type == '1'){
                    if(isset($post['name']) && isset($post['email'])){
                        if(($post_name == '' || $post_name == null) && ($post_email == '' || $post_email == null)) {
                            $is_register = 1;
                        }
                        else{
                            $is_register = 0;
                        }
                    }
                }
                
                $updatedata['is_register'] = $is_register;
                $result = $db->update("tbl_customer", $updatedata, ['id'=>$post['uid']]);
                
                if($result){
                    // $msg = "Profile Update Successfully";
                    $msg = "הפרופיל עודכן בהצלחה";
                    $data['profile'] = get_user_profile($post['uid'],$post['uid']);
                    $data['artist']=get_business_artist_list($data['profile']['id'],$data['profile']['id']);
                    $data['studio']=get_business_studio_list($data['profile']['id'],$data['profile']['id']);
                    $data['followers']=get_user_followers($data['profile']['id']);
                    $status = 1;
                }
            }
        }
        
    }
} else {
    $status = 0;
    $msg = $gbl_msg_invalid_args;
}
