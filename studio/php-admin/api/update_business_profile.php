<?php

$fields = ['uid', 'login_token', 'business_type', 'name', 'address', 'address_lat', 'address_lng','city_name', 'address_place_id', 'styles', 'about_text', 'device_type', 'app_version', 'app_token'];
$check = check_isset($fields);
$email = '';
$name = '';
$is_name_exists = 0;
$is_email_exists = 0;
global $signature_image_path;
if ($check) {
    $post = get_all_data_protected($_REQUEST);
    $row = validate_token($post['login_token'], $post['uid']);

    if ($row == false) {
        $status = 2;
        $msg = $gbl_msg_invalid_token;
    } else {
        $is_convert="";
        if(isset($_REQUEST['is_convert']))
        {
            if($_REQUEST['is_convert']!=""){
                $is_convert="1";
            }
        }
        if(isset($_FILES['signature_image']))
            $res_img = upload_image($_FILES['signature_image'], $signature_image_path);
        else
            $res_img="";
        // $res_img['name'] = "";
        $update_dt = date("Y-m-d H:i:s");
        $sel_style_ary = [];
        $sel_style_ary = explode(',', $post['styles']);
        $business_type = $post['business_type'];
        $business_id=[];
        $data['profile'] = get_user_profile($post['uid'],$post['uid']);
        $user=$data['profile'];
        $name = $post['name'];

        if($name != ""){
            $user_detail = check_is_unique_user_name(['id'=>$post['uid'],'name'=>$post['name']]);
            if(!$user_detail){
                $is_name_exists = 1;
                // $msg = "Name Already Exists";
                $msg = "השם כבר קיים";
            }
        }

        if(isset($post['email']))
        {
            if($post['email']!=""){
                $user_detail = get_user_by_email($post['email']);
                if(!empty($user_detail)){
                    if($user_detail['id'] != $row['id']){
                        $is_email_exists = 1;
                        // $msg = "Email Already Exists";
                        $msg = "האימייל כבר קיים";
                    }
                    else{
                        $updatedata['email']=$post['email'];
                    }
                }
                else{
                    $updatedata['email']=$post['email'];
                }
            }
        }

        if($is_email_exists == 1){
            $status = 4;
        }
        else{
            if($is_name_exists == 1){
                $status = 4;
            }
            else{
                
                //if user wants to be a artist then selected studio should get request and send them push notification
                if ($business_type == '2') {
                    $ins_studio_data = [];
                    if(isset($post['member_ids']))
                    {
                        if($post['member_ids']!="")
                        {
                            $mem_s_ids = explode(',', $post['member_ids']);
                            foreach ($mem_s_ids as $studio_key => $studio_value) {
        
                                $is_exists="0";
                                $result=$db->query("select id from tbl_artist_business_map where uid='".$post['uid']."' AND bid='".$studio_value."' LIMIT 1");
                                if($result)
                                {
                                    if($result->num_rows()>0){
                                        $is_exists="1";
                                    }
                                }
                                if($is_exists!="1")
                                {
                                    $ins_studio_data['uid'] = $post['uid'];
                                    $ins_studio_data['bid'] = $studio_value;
                                    $ins_studio_data['req_status'] = '0';
                                    $ins_studio_data['date_added'] = $update_dt;
                                    $ins_studio_data['date_updated'] = $update_dt;
                                    insert('tbl_artist_business_map', $ins_studio_data);
                                    $business_id[]=$studio_value;
                                    
                                    /* $ins_f=[];
                                    $ins_f['noti_type']="artist_request_rcvd";
                                    $ins_f['date_added']=$update_dt;
                                    $ins_f['uid']=$post['uid'];
                                    $ins_f['pid']=0;
                                    $ins_f['me']=$studio_value;
                                    insert("tbl_notifications",$ins_f); */
        
                                    $ins_f=[];
                                    $ins_f['noti_type']="artist_request_sent";
                                    $ins_f['date_added']=$update_dt;
                                    $ins_f['uid']=$studio_value;
                                    $ins_f['pid']=0;
                                    $ins_f['me']=$post['uid'];
                                    insert("tbl_notifications",$ins_f);
        
        
                                    /* $ins_f=[];
                                    $ins_f['noti_type']="studio_request_sent";
                                    $ins_f['date_added']=$update_dt;
                                    $ins_f['uid']=$studio_value;
                                    $ins_f['pid']=0;
                                    $ins_f['me']=$post['uid'];
                                    insert("tbl_notifications",$ins_f); */
        
                                    $ins_f=[];
                                    $ins_f['noti_type']="studio_request_rcvd";
                                    $ins_f['date_added']=$update_dt;
                                    $ins_f['uid']=$post['uid'];
                                    $ins_f['pid']=0;
                                    $ins_f['me']=$studio_value;
                                    insert("tbl_notifications",$ins_f);
        
                                    $business_user=get_user_profile($studio_value,$studio_value);
                                    if($business_user['push_enable'] == '1')
                                    {
                                        $title=$name." ".$gbl_msg_req_rcv_from_artist;
                                        $push_data=[];
                                        $push_data['badge_count']=1;
                                        $push_data['description']='';
                                        $push_data['pid']="0";
                                        $push_data['screen']="notification";
                                        $push_data['is_request']="0";
                                        // $push_data['owner']=$user;
                                        // $data['push']=notification($title, [$business_user['udid']], $push_data);
                                        $data['push']=notification_new($title, $business_user['udid'], $push_data,$business_user['device_type']);
                                        $data['push'] = json_decode($data['push'],true);
                                    }
                                    $data['d']=$business_user;
        
                                }
        
                            }//studio repeat
                        }//if memeber not blank
                    }//if memebers are set
        
                }
                //end code for business type studio
        
                $artist_id=[];
                //is user wants to be a studio then add selected artist on studio list and send them push notification
                if ($business_type == '1') {
                    
                    if(isset($post['member_ids']))
                    {
                        if($post['member_ids']!="")
                        {
                            $ins_artist_data = [];
                            $mem_a_ids = explode(',', $post['member_ids']);
                            foreach ($mem_a_ids as $artist_key => $artist_value) {
        
                                $is_exists="0";
                                $result=$db->query("select id from tbl_artist_business_map where uid='".$artist_value."' AND bid='".$post['uid']."' LIMIT 1");
                                if($result)
                                {
                                    if($result->num_rows()>0){
                                        $is_exists="1";
                                    }
                                }
                                if($is_exists!="1")
                                {
                                    $ins_artist_data['uid'] = $artist_value;
                                    $ins_artist_data['bid'] = $post['uid'];
                                    $ins_artist_data['req_status'] = '0';
                                    $ins_artist_data['date_added'] = $update_dt;
                                    $ins_artist_data['date_updated'] = $update_dt;
                                    insert('tbl_artist_business_map', $ins_artist_data);
                                    $artist_id[]=$artist_value;
        
                                    $ins_f=[];
                                    $ins_f['noti_type']="studio_request_rcvd";
                                    $ins_f['date_added']=$update_dt;
                                    $ins_f['uid']=$post['uid'];
                                    $ins_f['pid']=0;
                                    $ins_f['me']=$artist_value;
                                    insert("tbl_notifications",$ins_f);
        
                                    $artist_user=get_user_profile($artist_value,$artist_value);
                                    if($artist_user['push_enable'] == '1')
                                    {
                                        $title=$name." ".$gbl_msg_req_rcv_from_studio;
                                        $push_data=[];
                                        $push_data['badge_count']=1;
                                        $push_data['description']='';
                                        $push_data['pid']="0";
                                        $push_data['screen']="notification";
                                        $push_data['is_request']="0";
                                        // $push_data['owner']=$user;
                                        // $data['push']=notification($title, [$artist_user['udid']], $push_data);
                                        $data['push']=notification_new($title, $artist_user['udid'], $push_data,$artist_user['device_type']);
                                        $data['push'] = json_decode($data['push'],true);
                                    }
                                    $data['d']=$artist_user;
                                }
                        
        
                        
                            }///loop
                        }//if memeber not blank
        
                        
                    }//if memebers are set
        
        
                }

                $updatedata = [];
                //end code for business type artist
                $ins_txt="";
                if(isset($post['email']))
                {
                    if($post['email']!="")
                    {
                        // $ins_txt=",email='".$post['email']."'";
                        $updatedata['email'] = $post['email'];
                    }
                }
                //$data['address']=trim($_REQUEST['address']);
                //data['address1']=$db->escape($_REQUEST['address'],true);
                /* $address = $db_old->real_escape_string(trim($_REQUEST['address']));
                $city_name = $db_old->real_escape_string(trim($_REQUEST['city_name']));
                $about_text = $db_old->real_escape_string(trim($_REQUEST['about_text'])); */
                $address = stripslashes(trim($_REQUEST['address']));
                $city_name = stripslashes(trim($_REQUEST['city_name']));
                $about_text = stripslashes(trim($_REQUEST['about_text']));

                
                $updatedata['user_type'] = '2';
                $updatedata['business_type'] = $business_type;
                $updatedata['name'] = $post['name'];
                $updatedata['address'] = $address;
                $updatedata['city_name'] = $city_name;
                $updatedata['about_text'] = $about_text;
                $updatedata['address_lat'] = $post['address_lat'];
                $updatedata['address_lng'] = $post['address_lng'];
                $updatedata['address_place_id'] = $post['address_place_id'];
                $updatedata['styles'] = $post['styles'];
                if(isset($_FILES['signature_image']))
                    $updatedata['signature_image'] = $res_img['name'];

                $updatedata['register_date'] = $update_dt;
                $updatedata['date_updated'] = $update_dt;
                $updatedata['is_business'] = '1';

                $result = $db->update("tbl_customer", $updatedata, ['id'=>$post['uid']]);
                $data['sql']=$db->last_query();
                register_db_error(['type'=>"Business User","data"=>"Convert to business ".$post['uid'],"row"=>$user]);
                if($result){
                    $msg = "פרופיל עיסקי עודכן בהצלחה";
                    $data['profile'] = get_user_profile($post['uid'],$post['uid']);
                    $user=$data['profile'];
                    $data['styles_list'] = get_style_list();
                    $data['sel_style_ary'] = $sel_style_ary;
                    $status = 1;
                }
                else{
                    register_db_error(['type'=>"Business User","data"=>"Convert to business ".$post['uid'],"row"=>$user]);
                }


                /* $sql = "UPDATE tbl_customer set user_type='2',business_type='" . $business_type . "',name='" . $post['name'] . "',address='" . $address . "',address_lat='" . $post['address_lat'] . "',address_lng='" . $post['address_lng'] . "',address_place_id='" . $post['address_place_id'] . "',city_name='" . $city_name . "',styles='" . $post['styles'] . "' ,about_text='" . $about_text ."'".$ins_txt.",signature_image='" . $res_img['name'] . "',register_date='" . $update_dt . "',date_updated='" . $update_dt . "',is_business='1' WHERE id='" . $row['id'] ."' LIMIT 1";
                // $sql = "UPDATE tbl_customer set user_type='2',business_type='" . $business_type . "',name='" . $post['name'] . "',address='" . $db_old->real_escape_string(trim($_REQUEST['address'])) . "',address_lat='" . $post['address_lat'] . "',address_lng='" . $post['address_lng'] . "',address_place_id='" . $post['address_place_id'] . "',city_name='" . $db_old->real_escape_string(trim($_REQUEST['city_name'])) . "',styles='" . $post['styles'] . "' ,about_text='" . trim($post['about_text']) ."'".$ins_txt.",signature_image='" . $res_img['name'] . "',register_date='" . $update_dt . "',date_updated='" . $update_dt . "',is_business='1' WHERE id='" . $row['id'] ."' LIMIT 1";
                $data['sql']=$sql;
                register_db_error(['type'=>"Business User","data"=>"Convert to business ".$post['uid'],"row"=>$user]);
                $result = $db->query($sql) or (log_error($sql));
                if ($result) {
                    // $msg = "Business Profile Update Successfully";
                    $msg = "פרופיל עיסקי עודכן בהצלחה";
                    $data['profile'] = get_user_profile($post['uid'],$post['uid']);
                    $user=$data['profile'];
                    $data['styles_list'] = get_style_list();
                    $data['sel_style_ary'] = $sel_style_ary;
                    $status = 1;
        
                }//if successfully saved
                else{
                    register_db_error(['type'=>"Business User","data"=>"Convert to business ".$post['uid'],"row"=>$user]);
                } */

                // IF ITS CONVERTING FROM ARTIST TO STUDIO OR STUDIO TO ARTIST
                if($is_convert=="1")
                {

                    business_convert_effect([
                        'uid'=>$post['uid'],
                        'business_type'=>$business_type
                    ]);

                }
            }
        }
    }
} else {
    $status = 0;
    $msg = $gbl_msg_invalid_args;
}
