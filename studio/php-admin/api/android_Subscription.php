<?php
$fields = ['uid','login_token','app_token','device_type','app_version'];
$check = check_isset($fields);
$dt = date("Y-m-d H:i:s");
$expire_date = "";
$expire_time = "";
if ($check) {
    $post = get_all_data_protected($_REQUEST);
    $row = validate_token($post['login_token'], $post['uid']);
    if ($row == false) {
        $status = 2;
        $msg = $gbl_msg_invalid_token;
    }
    else{
        $data['sub_initial'] = $post;

        

        $sub_data = get_android_subscription_status($_REQUEST['sku'],$_REQUEST['purchaseToken']);
        $expire_date = $sub_data->endDateTime;

        $chk_sub_plan = explode("_",$_REQUEST['sku']);

        /* if($chk_sub_plan[0] == "yearly"){
            $expire_time = "+1 year";
        }
        else if($chk_sub_plan[0] == "monthly"){
            $expire_time = "+1 month";
        } */

        // echo "<pre>";
        // print_r($chk_sub_plan);
        
        /// THIS CHANGE WE HAVE DONE DUE TO NEW POINT THAT WE NEED TO CONVERT BASIC PLAN TO PREMIUM WHO ALREADY PURCHASED.
        if(isset($_REQUEST['purchase_status']))
        {
            if($_REQUEST['purchase_status']=="Restored")
            {
                if($_REQUEST['sku']=="monthly_basic_plan")
                {
                    $_REQUEST['sku']="monthly_premium_plan";
                }
                
            }
        }
        
        $subscribe_row = get_subscribe_detail($row['id']);
        $data['d'] = $sub_data;

        $update_data = [];
        $update_data['product_id'] = $_REQUEST['sku'];
        $update_data['device_type'] = "1";
        $update_data['purchase_token'] = $_REQUEST['purchaseToken'];
        $update_data['subscription_data'] = $_REQUEST['originalJson'];
        $update_data['transaction_id'] = "";

        if(count($subscribe_row) > 0){
            $data['row'] = "user sub found";
            if($subscribe_row['is_sub_active'] == 1 && $subscribe_row['status'] == 1)
            {
                // $expire_date = date("Y-m-d H:i:s",strtotime($expire_time, strtotime($subscribe_row['date_added'])));

                if($subscribe_row['product_id'] != $_REQUEST['sku'] || $subscribe_row['purchase_token'] != $_REQUEST['purchaseToken']){
                    // $update_data = [];
                    // $update_data['product_id'] = $_REQUEST['sku'];
                    // $update_data['device_type'] = "1";
                    // $update_data['purchase_token'] = $_REQUEST['purchaseToken'];
                    // $update_data['subscription_data'] = $_REQUEST['originalJson'];
                    // $update_data['transaction_id'] = "";
                    $update_data['status'] = '1';
                    $update_data['is_sub_active'] = '1';
                    $update_data['expire_date'] = $expire_date;
                    $update_data['date_updated'] = $dt;
                    $sub_result = update("tbl_subscription",$update_data,['cust_id'=>$row['id'],'is_delete'=>'0','is_sub_active'=>'1','status'=>'1']);
                    if($sub_result){
                        $status = 1;
                        // $msg = "Update Success";
                        $msg = "עודכן בהצלחה";
                    }else{
                        $status = 0;
                        // $msg = "Error on adding";
                        $msg = "תקלה בהוספה";
                    }
                    $data['sub_update'] = $sub_result;
                }
                else{
                    $status = 0;
                    // $msg = "Already Subscribed.";
                    $msg = "מנוי כבר מופעל";
                }
            }
            else{
                
                // $expire_date = date("Y-m-d H:i:s",strtotime("+35 minutes", $dt));
                // $expire_date = date("Y-m-d H:i:s",strtotime($expire_time, strtotime($dt)));
                // echo "exp date : " . $expire_date;
                // exit;

                $update_data['cust_id'] = $row['id'];
                $update_data['status'] = '1';
                $update_data['is_sub_active'] = '1';
                $update_data['expire_date'] = $expire_date;
                $update_data['date_added'] = $dt;
                $sub_result = insert("tbl_subscription",$update_data);
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
                    $data['cust_upd'] = $update_cust;
                }else{
                    $status = 0;
                    // $msg = "Error on adding";
                    $msg = "תקלה בהוספה";
                }
                $data['sub_insert'] = $sub_result;
            }
            $data['sub_found'] = "1";
        }
        else{
            /* $ins_data = [];
            $ins_data['cust_id'] = $row['id'];
            $ins_data['product_id'] = $_REQUEST['sku'];
            $ins_data['device_type'] = "1";
            $ins_data['purchase_token'] = $_REQUEST['purchaseToken'];
            $ins_data['status'] = '1';
            $ins_data['is_sub_active'] = '1';
            $ins_data['transaction_id'] = "";
            $ins_data['subscription_data'] = $_REQUEST['originalJson'];
            $ins_data['expire_date'] = $expire_date;
            $ins_data['date_added'] = $dt; */

            /* $chk_sub_plan = explode("_",$_REQUEST['sku']);

            //yearly_premium_plan
            //monthly_premium_plan
            if($chk_sub_plan[0] == "yearly"){
                $expire_time = "+1 year";
            }
            else if($chk_sub_plan[0] == "monthly"){
                $expire_time = "+1 month";
            } */

            // $expire_date = date("Y-m-d H:i:s",strtotime($expire_time, $dt));
            // echo "exp date : " . $expire_date;
            // exit;

            $update_data['cust_id'] = $row['id'];
            $update_data['status'] = '1';
            $update_data['is_sub_active'] = '1';
            $update_data['expire_date'] = $expire_date;
            $update_data['date_added'] = $dt;
            $sub_result = insert("tbl_subscription",$update_data);
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
                $data['cust_upd'] = $update_cust;
            }else{
                $status = 0;
                // $msg = "Error on adding";
                $msg = "תקלה בהוספה";
            }
            $data['sub_insert'] = $sub_result;
        }
    }
    // exit;
    // $data['sub_end'] = $post;
}
else {
    $status = 0;
    $msg = $gbl_msg_invalid_args;
}
?>
