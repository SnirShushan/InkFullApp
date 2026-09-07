<?php
// $fields = ['uid','login_token','app_token','device_type','app_version','name','phone',"business_id"];
$fields = ['uid','login_token','app_token','device_type','app_version','business_id'];
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

        if(isset($post['business_id']) && ($post['business_id'] == "0" || $post['business_id'] == "")){
            $status = 0;
            $msg = "Something went wrong while sending your request. Please try again.";
        }
        else{

            $ins=[];
            $ins['date_added']=$dt;
            $ins['name']=$post['name'];
            $ins['uid']=$post['uid'];
            // $ins['phone']=$post['phone'];
            $ins['tattoo_size']=$post['tattoo_size'];
            // $ins['styles']=$post['styles'];
            $ins['business_id']=$post['business_id'];
            $ins['image1_id']=chk_get($post,"image1_id");
            $ins['image2_id']=chk_get($post,"image2_id");
            $ins['image3_id']=chk_get($post,"image3_id");
            $ins['image1_name']=chk_get($post,"image1_name");
            $ins['image2_name']=chk_get($post,"image2_name");
            $ins['image3_name']=chk_get($post,"image3_name");
            if(isset($_REQUEST['request_images']))
            {
                $arr_requestImages=json_decode($_REQUEST['request_images']);
                $k=1;
                if(!empty($arr_requestImages))
                {
                    foreach($arr_requestImages as $single){
                        if($k>=1 && $k<=3){
                            $ins['image'.$k.'_id']=$single->imageId;
                            $ins['image'.$k.'_name']=$single->imageUrl;
                            $k++;
                        }
                    }
                }
                $ins['request_images']=$_REQUEST['request_images'];
            }
    
            
            $style_arr = [];
            $style = explode(",",$post['styles']);
            foreach ($style as $key => $value) {
                # code...
                if(!in_array($value,$style_arr)){
                    array_push($style_arr, $value);
                }
            }
            $new_styles = implode(",",$style_arr);
            $ins['styles'] = $new_styles;
    
            $ins['front_side']=chk_get($post,"front_side");
            $ins['back_side']=chk_get($post,"back_side");
            $ins['front_data']=chk_get($post,"front_data");
            $ins['back_data']=chk_get($post,"back_data");
            //$ins['back_data_image']=chk_get($post,"back_data_image");
            //$ins['front_data_image']=chk_get($post,"front_data_image");
            $ins['description']=chk_get($post,"description");
            $ins['artists_uid']=chk_get($post,"artists_uid");
            $ins['email']=chk_get($post,"email");
            $ins['is_contact_request']=chk_get($post,"is_contact_request");
    
            if(isset($_FILES['front_data_image']))
            {
                $res_img=upload_image($_FILES['front_data_image'],$body_image_path);
                //$data['f']=$res_img;
                $front_data_image = $res_img['name'];
                if($res_img['has_error'] != "1"){
                    $ins['front_data_image']=$front_data_image;
                }
            }
    
            if(isset($_FILES['back_data_image']))
            {
                $res_img=upload_image($_FILES['back_data_image'],$body_image_path);
                //$data['f1']=$res_img;
                $back_data_image = $res_img['name'];
                if($res_img['has_error'] != "1"){
                    $ins['back_data_image']=$back_data_image;
                }
            }
            $data['a']=$ins;
            insert('tbl_request', $ins);
            $status=1;
    
            $user_id = $post['uid'];
            $business_id = $post['business_id'];
            $business = get_user_profile($business_id,$business_id);
            $user = get_user_profile($user_id,$user_id);
            
            if($business['push_enable'] == '1')
            {
                // $title = $post['name']." מתבקש לקעקוע";
                $title = $post['name']." שלח לך בקשה";
                $push_data=[];
                $push_data['badge_count'] = 1;
                $push_data['description']='';
                $push_data['pid'] = "0";
                $push_data['screen'] = "notification";
                $push_data['is_request'] = "1";
                // $push_data['owner'] = $user;
                // $data['push'] = notification($title, [$business['udid']], $push_data);
                $data['push'] = notification_new($title, $business['udid'], $push_data,$business['device_type']);
                $data['push'] = json_decode($data['push'],true);
            }
        }

    }
} else {
    $status = 0;
    $msg = $gbl_msg_invalid_args;
}