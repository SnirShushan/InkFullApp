<?php
$fields = ['uid','login_token','app_token','device_type','app_version'];
$check = check_isset($fields);
$is_subscribe = "";
$product_id = "";
$expire_time = "";
$subscribe_status = 0;
$is_premium = "";
$total_post = "";
$is_post_limit = '0';
$is_add_post = '0';
$popup_text = '';
$popup_text_title = '';
$popup_text_subtitle = '';
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
        $dt = date("Y-m-d H:i:s");

        if(isset($post['is_add_post']) && $post['is_add_post'] != "0" ){
            $is_add_post = $post['is_add_post'];
        }

        $subscribe_row = get_subscribe_detail($row['id']);
        // $sub_id = $subscribe_row['id'];
        $user_detail = get_user_profile($row['id']);
        $is_subscribe = "";
        $expire_date = "";

        // $total_post = get_post_count($row['id']);
        
        if($subscribe_row){
            $msg = "success";
            $status = 1;
            $sub_id = $subscribe_row['id'];

            $product_id = $subscribe_row['product_id'];
            $chk_sub_plan = explode("_",$subscribe_row['product_id']);
            $data['row']=$subscribe_row;
            if($subscribe_row['status'] == '1' && $subscribe_row['is_sub_active'] == '1')
            {
                if($subscribe_row['device_type'] == "1")
                {
                    if($chk_sub_plan[1] == "premium"){
                        $is_premium = 1;
                    }
                    else if($chk_sub_plan[1] == "basic"){
                        $is_premium = 0;
                    }


                    $sub_data = get_android_subscription_status($subscribe_row['product_id'],$subscribe_row['purchase_token']);

                    try{
                            log_activity([
                                    'req'=>[
                                        'product_id'=>$subscribe_row['product_id'],
                                        'purchase_token'=>$subscribe_row['purchase_token']
                                    ],
                                    'title'=>"Check Sub. Restore Android Status:",
                                    'data'=>$sub_data
                                ]);
                                
                        } catch (Exception $e) {
                            
                        }


                    
                    
                    $expire_date = $subscribe_row['expire_date'];
                     if(isset($sub_data->endDateTime)){
                        if($expire_date<=$sub_data->endDateTime)
                        {
                            $expire_date=$sub_data->endDateTime;
                        }
                        //$subscribe_status = 0;
                        //$data['is_cancel_plan'] = "1";
                        //$is_subscribe = "פג תוקף המנוי";
                        //$is_subscribe = "Subscription Expired";
                        
                    }


                    // $expire_date = $subscribe_row['expire_date'];
                   
                        if(strtotime($expire_date) >= strtotime($dt)){
                            $is_subscribe = "Subscription Activated";
                            $subscribe_status = 1;
                            // $is_subscribe = "מנוי הופעל";
                        }
                        else{
                            $is_subscribe = "Subscription Expired";
                            $subscribe_status = 0;
                            $data['is_cancel_plan'] = "0";
                           
                        }
                    
                }
                else if($subscribe_row['device_type'] == "2")
                {
                    
                    if($chk_sub_plan[1] == "premium"){
                        $is_premium = 1;
                    }
                    else if($chk_sub_plan[1] == "basic"){
                        $is_premium = 0;
                    }
                    
                    $expire_date = $subscribe_row['expire_date'];
                    if($expire_date != NULL)
                    {
                        // if($dt < $expire_date){
                        $data['check_ex']=$expire_date;
                        $data['check_dt']=$dt;
                        if(strtotime($expire_date) >= strtotime($dt)){
                            $is_subscribe = "Subscription Activated";
                            $subscribe_status = 1;
                            // $is_subscribe = "מנוי הופעל";
                        }
                        else{
                            $is_subscribe = "Subscription Expired";
                            $subscribe_status = 0;
                            // $is_subscribe = "פג תוקף המנוי";
                        }
                    }
                    else{
                        $is_subscribe = "Subscription Activated";
                        $subscribe_status = 1;
                    }
                }else if($subscribe_row['device_type'] == "3")
                {
                    
                    $is_premium = 0;
                    
                    
                    $expire_date = $subscribe_row['expire_date'];
                    if($expire_date != NULL)
                    {
                        
                        if(strtotime($expire_date) >= strtotime($dt)){
                            $is_subscribe = "Subscription Activated";
                            $subscribe_status = 1;
                          
                        }
                        else{
                            $is_subscribe = "Subscription Activated";
                            $subscribe_status = 1;
                          
                        }
                    }
                    else{
                        $is_subscribe = "Subscription Activated";
                        $subscribe_status = 1;
                    }

                    // OVERRITE VALUE AS FREE PLAN WILL NEVER EXPIRE
                    $is_subscribe = "Subscription Activated";
                    $subscribe_status = 1;
                }


            }
            else if($subscribe_row['status'] == '2'){
                $is_subscribe = "Subscription Expired";
                $subscribe_status = 0;
                // $is_subscribe = "פג תוקף המנוי";
            }

            // if($is_subscribe == "Subscription Activated"){
            if($subscribe_status == 1){
                $update_data = [];
                $update_data['status'] = '1';
                $update_data['expire_date'] = $expire_date;
                $update_data['date_updated'] = $dt;
                $sub_result = update("tbl_subscription",$update_data,['cust_id'=>$row['id'],"is_delete"=>"0",'id'=>$sub_id]);
                if($sub_result){

                    
                    $data['update_status'] = 1;
                    // $msg = "Update Success";
                    $data['update_msg'] = "עודכן בהצלחה";
                }else{
                    $data['update_status'] = 0;
                    // $msg = "Error on adding";
                    $data['update_msg'] = "תקלה בהוספה";
                }

                if($is_add_post == "1"){
                    $upload_limit = get_user_post_limit($row['id']);
    
                    $uploaded_post = get_post_count($row['id']);
                    
                    if($uploaded_post >= $upload_limit){
    
                        $is_post_limit = '1';
                     
                        $subject = "המשתמש הגיע למגבלת העלאת הפוסטים";
                        $popup_text = "הגעת לכמות המירבית של תמונות שניתן להעלות. אנחנו על זה!\nניצור איתך קשר בקרוב (עד 3 ימי עסקים) ";
                        $popup_text_title = "הגעת למקסימום התמונות שאפשר להעלות";
                        // $popup_text_subtitle = "שדרוג התכנית יאפשר לך להעלות תמונות נוספות ללא הגבלה. נוכל לחזור אליך עם פרטים נוספים תוך 3 ימי עסקים.";
                        $popup_text_subtitle = "שדרוג התוכנית יאפשר לך להעלות תמונות נוספות ללא הגבלה ועוד פיצ'רים נוספים";
        
                        

                        /* if($user_detail['is_email_send'] == "2"){
                            $data['mail_data'] = sending_email_admin($row['id'],$subject);
                            $db->update("tbl_customer", ['is_email_send'=>'1'], ['id'=>$post['uid']]);
                        } */
                    }
                }
            }
            
            elseif($subscribe_status == 0 ){
                $update_data = [];
                $update_data['status'] = '2';
                $update_data['is_sub_active'] = '2';
                $update_data['date_updated'] = $dt;
                
                // Close all subscription
                $sub_result = update("tbl_subscription",$update_data,['cust_id'=>$row['id'],"is_delete"=>"0"]);
                $db->query("DELETE from tbl_subscription where cust_id='".$row['id']."' AND product_id='basic_free_plan' AND status='2'");
                //$sub_result = update("tbl_subscription",$update_data,['cust_id'=>$row['id'],"is_delete"=>"0",'id'=>$sub_id]);
                if($sub_result){
                    $data['update_status'] = 1;
                    // $msg = "Update Success";
                    $data['update_msg'] = "עודכן בהצלחה";
                    if($user_detail['business_type']!="2")
                    {

                        $db->update("tbl_customer", ['business_type'=>'2'], ['id'=>$post['uid']]);
                        business_convert_effect([
                            'uid'=>$post['uid'],
                            'business_type'=>"2",
                            'title'=>"Convert due to expiry of subscription for ".$post['uid'].", Business Type = 2",
                            'user_detail'=>$user_detail
                        ]);
                    }



                    // $update_data = [];
                    // $update_data['status'] = '2';
                    // $update_data['is_sub_active'] = '2';
                    // $update_data['date_updated'] = $dt;
                    // $sub_result = update("tbl_subscription",$update_data,['cust_id'=>$row['id'],"is_delete"=>"0",'id'=>$sub_id]);
                    
                        $insert_data = [];
                        $insert_data['subscription_data'] = json_encode([]);
                        $insert_data['purchase_token'] = "";
                        $insert_data['device_type'] = "3";
                        $insert_data['status'] = '1';
                        $insert_data['is_sub_active'] = '1';
                        $insert_data['expire_date'] = $dt;
                        $insert_data['date_updated'] = $dt;
                        $insert_data['cust_id'] = $row['id'];
                        $insert_data['product_id'] = "basic_free_plan";
                        $insert_data['date_added'] = $dt;

                        $sub_result = insert("tbl_subscription",$insert_data);
                        if($sub_result){
                            $status = 1;
                            $msg = "Success";

                            $ins_id = get_last_id();

                            $get_settings = get_settings();
                            $post_limit = $get_settings['post_limit'];
                            
                            $update_cust = [];
                            $update_cust['sub_id'] = $ins_id;
                            $update_cust['post_limit'] = $post_limit;
                            $update_cust['date_updated'] = $dt;
                            update("tbl_customer",$update_cust,['id'=>$row['id']]);


                            
                        }

                }else{
                    $data['update_status'] = 0;
                    // $msg = "Error on adding";
                    $data['update_msg'] = "תקלה בהוספה";
                }
            }


            // checking latest data. as above code updated the status of the subscription.
            $subscribe_row_check = get_subscribe_detail($row['id']);
            {
                if(count($subscribe_row_check)>0)
                {
                    $data['row_check1']=$subscribe_row_check;
                    if($subscribe_row_check['status'] == '1' && $subscribe_row_check['is_sub_active'] == '1'){
                        

                             $is_premium = 0;
                             $chk_sub_plan = explode("_",$subscribe_row_check['product_id']);
                             if($chk_sub_plan[1] == "premium"){
                                    $is_premium = 1;
                                }
                                else if($chk_sub_plan[1] == "basic"){
                                    $is_premium = 0;
                                }

                            $expire_date = $subscribe_row_check['expire_date'];
                            

                            if($expire_date != NULL)
                            {
                                
                                if(strtotime($expire_date) >= strtotime($dt)){
                                    
                                    $is_subscribe = "Subscription Activated";
                                    $subscribe_status = 1;
                                    
                                }
                                else{

                                    if($chk_sub_plan[1] == "premium"){
                                        $is_subscribe = "Subscription Expired";
                                        $subscribe_status = 0;
                                    }else{
                                          $is_subscribe = "Subscription Activated";
                                        $subscribe_status = 1;
                                    }
                                
                                }
                            }

                            if($chk_sub_plan[1] == "basic"){
                                $is_subscribe = "Subscription Activated";
                                $subscribe_status = 1;

                            }
     
                    }
                }
                
            }


            $data['product_id'] = $product_id;
            $data['subscription_detail'] = $is_subscribe;
            $data['subscription_status'] = $subscribe_status;
            $data['is_premium'] = $is_premium;
            $data['expire_date'] = $expire_date;
            $data['current_date'] = $dt;
            // $data['total_post_add'] = $total_post;
            $data['is_post_limit'] = $is_post_limit;
            $data['popup_text'] = $popup_text;
            $data['popup_text_title'] = $popup_text_title;
            $data['popup_text_subtitle'] = $popup_text_subtitle;
        }
        else{
            // $msg = "User Not Found";
            $msg = "המשתמש לא נמצא";
            $status = 0;
        }

        $name_exists_msg = "";
        if(isset($post['name']) && trim($post['name'])!=""){
            $user_detail = check_is_unique_user_name(['id'=>$post['uid'],'name'=>$post['name']]);
            if(!$user_detail){
                $name_exists_msg = "השם כבר קיים";
            }
        }
        $data['subscription_status'] = $subscribe_status;
        $data['is_name_exist'] = $name_exists_msg;
    }
} else {
    $status = 0;
    $msg = $gbl_msg_invalid_args;
}
