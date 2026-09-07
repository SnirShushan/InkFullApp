<?php
$fields = ['uid','login_token','app_token','device_type','app_version'];
$check = check_isset($fields);
$dt = date("Y-m-d H:i:s");
$expire_date = "";
$trans_id = "";
if ($check) {
    $post = get_all_data_protected($_REQUEST);
    $row = validate_token($post['login_token'], $post['uid']);
    if ($row == false) {
        $status = 2;
        $msg = $gbl_msg_invalid_token;
    }
    else{
        // $transaction_id = $_REQUEST['purchaseID'];
        // $ipn_row = get_ios_transaction_id($transaction_id);
        // echo "<pre>";
        // print_r($ipn_row);
        // exit;
        // $sub_data = get_android_subscription_status($_REQUEST['sku'],$_REQUEST['purchaseToken']);
        // $obj=json_decode(base64_decode(str_replace('_', '/', str_replace('-','+',explode('.', $_REQUEST['signedPayload'])[1]))));
        // $secret="3d4e16416c764617b39808e834e45067";
        // $obj1=json_decode(base64_decode(str_replace('_', '/', str_replace('-','+',explode('.', $obj->data->signedTransactionInfo)[1]))));
        // $expire_date = date("Y-m-d H:i:s",($obj1->expiresDate/1000));
        // $product_id = $obj1->productId;
        // $transaction_id = $obj1->transactionId;
        // $subscription_data = json_encode($obj1);
        
        $secret="3d4e16416c764617b39808e834e45067";


        if(isset($_REQUEST['purchase_status']))
        {
            if($_REQUEST['purchase_status']=="Restored")
            {
                if($_REQUEST['productID']=="monthly_basic_plan")
                {
                    $_REQUEST['productID']="monthly_premium_plan";
                }
                
            }
        }

        $is_sandbox="";

        
        if(isset($_REQUEST['is_sandbox']))
        {
            if($_REQUEST['is_sandbox']=="1")
            {
                $is_sandbox="1";
                
            }
        }

        $product_id = $_REQUEST['productID'];
        $trans_id = $_REQUEST['original_transaction_id'];//transaction id
        $subscription_data = "";
        $expire_date = "";
        $expire_time = "";

        if($trans_id == ""){
            $trans_id = $_REQUEST['purchaseID'];
        }

        $chk_sub_plan = explode("_",$product_id);

        /* if($chk_sub_plan[0] == "yearly"){
            $expire_time = "+1 year";
        }
        else if($chk_sub_plan[0] == "monthly"){
            $expire_time = "+1 month";
        } */

        $subscribe_row = get_subscribe_detail($row['id'],"1");
        $data['subscribe_row']=$subscribe_row;
        if(count($subscribe_row) > 0){
            $sub_id = $subscribe_row['id'];
            $transaction_id = $subscribe_row['transaction_id'];
            if($transaction_id=="")
            {
                $transaction_id = $trans_id;
            }
            $ipn_row = get_ios_transaction_id($transaction_id);

            $expire_date = date("Y-m-d H:i:s",strtotime("+1 month", strtotime($subscribe_row['date_added'])));
            if($is_sandbox=="1")
            {
                $expire_date = date("Y-m-d H:i:s",strtotime("+5 minute", strtotime($subscribe_row['date_added'])));
            }
            // $expire_date = date("Y-m-d H:i:s",strtotime($expire_time, strtotime($subscribe_row['date_added'])));

            if(count($ipn_row) > 0){
                $expire_date = $ipn_row['expires_date'];
                $obj = json_decode(base64_decode(str_replace('_', '/', str_replace('-','+',explode('.', $ipn_row['signed_payload'])[1]))));
                // $secret="3d4e16416c764617b39808e834e45067";
                $obj_data = json_decode(base64_decode(str_replace('_', '/', str_replace('-','+',explode('.', $obj->data->signedTransactionInfo)[1]))));
                $subscription_data = json_encode($obj_data);
            }
            
            if($subscribe_row['is_sub_active'] == 1 && $subscribe_row['status'] == 1)
            {
                if($subscribe_row['product_id'] != $product_id || $subscribe_row['expire_date'] != $expire_date){
                    $update_data = [];
                    $update_data['product_id'] = $product_id;
                    $update_data['device_type'] = "2";
                    $update_data['purchase_token'] = "";
                    $update_data['subscription_data'] = $subscription_data;
                    $update_data['status'] = '1';
                    $update_data['expire_date'] = $expire_date;
                    $update_data['is_sub_active'] = '1';
                    $update_data['transaction_id'] = $transaction_id;
                    $update_data['date_updated'] = $dt;
                    $data['updating']="1";
                    $sub_result = update("tbl_subscription",$update_data,['cust_id'=>$row['id'],'is_delete'=>'0','id'=>$sub_id]);
                    if($sub_result){
                        $status = 1;
                        // $msg = "Update Success";
                        $msg = "עודכן בהצלחה";
                        
                            $update_cust = [];
                            $update_cust['sub_id'] = $sub_id;
                            $update_cust['date_updated'] = $dt;
                            update("tbl_customer",$update_cust,['id'=>$row['id']]);
                    }else{
                        $status = 0;
                        // $msg = "Error on adding";
                        $msg = "שגיאה בעדכון";
                    }
                    $data["upd_sub_data"] = $update_data;
                }
                else{
                    $status = 0;
                    // $msg = "Already Subscribed.";
                    $msg = "מנוי כבר מופעל";
                }
            }
            else{
                $ipn_row = get_ios_transaction_id($trans_id);

                if(count($ipn_row) > 0){
                    $expire_date = $ipn_row['expires_date'];
                    // $expire_date = date("Y-m-d H:i:s",strtotime("+1 month", strtotime($subscribe_row['date_added'])));
                    // $expire_date = date("Y-m-d H:i:s",strtotime($expire_time, strtotime($subscribe_row['date_added'])));
                    $obj = json_decode(base64_decode(str_replace('_', '/', str_replace('-','+',explode('.', $ipn_row['signed_payload'])[1]))));
                    // $secret="3d4e16416c764617b39808e834e45067";
                    $obj_data = json_decode(base64_decode(str_replace('_', '/', str_replace('-','+',explode('.', $obj->data->signedTransactionInfo)[1]))));
                    $subscription_data = json_encode($obj_data);
                }

                $ins_data = [];
                $ins_data['cust_id'] = $row['id'];
                $ins_data['device_type'] = "2";
                $ins_data['product_id'] = $product_id;
                $ins_data['subscription_data'] = $subscription_data;
                $ins_data['status'] = '1';
                $ins_data['is_sub_active'] = '1';
                $ins_data['transaction_id'] = $trans_id;
                $ins_data['date_added'] = $dt;
                $data['updating']="2";
                if($expire_date != ""){
                    $ins_data['expire_date'] = $expire_date;
                }

                $sub_result = insert("tbl_subscription",$ins_data);
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
                $data["ins_sub_data_ios"] = $ins_data;
            }

            /* else{
                $ins_data = [];
                $ins_data['cust_id'] = $row['id'];
                $ins_data['device_type'] = "2";
                $ins_data['product_id'] = $product_id;
                $ins_data['subscription_data'] = $subscription_data;
                $ins_data['expire_date'] = $expire_date;
                $ins_data['transaction_id'] = $transaction_id;
                $ins_data['date_added'] = $dt;
                $sub_result = insert("tbl_subscription",$ins_data);
                if($sub_result){
                    $status = 1;
                    $msg = "Success";
                }else{
                    $status = 0;
                    // $msg = "Error on adding";
                    $msg = "תקלה בהוספה";
                }
            } */
        }
        else{
            $ipn_row = get_ios_transaction_id($trans_id);
            $data['trans_check_1']=$trans_id;
            $data['ipn_row_1']=$ipn_row;
            if(count($ipn_row) > 0){
                $expire_date = $ipn_row['expires_date'];
                $obj = json_decode(base64_decode(str_replace('_', '/', str_replace('-','+',explode('.', $ipn_row['signed_payload'])[1]))));
                // $secret="3d4e16416c764617b39808e834e45067";
                $obj_data = json_decode(base64_decode(str_replace('_', '/', str_replace('-','+',explode('.', $obj->data->signedTransactionInfo)[1]))));
                $subscription_data = json_encode($obj_data);
            }

            $ins_data = [];
            $ins_data['cust_id'] = $row['id'];
            $ins_data['device_type'] = "2";
            $ins_data['product_id'] = $product_id;
            $ins_data['subscription_data'] = $subscription_data;
            $ins_data['status'] = '1';
            $ins_data['is_sub_active'] = '1';
            $ins_data['transaction_id'] = $trans_id;
            $ins_data['date_added'] = $dt;
            $data['updating']="3";
            if($expire_date != ""){
                $ins_data['expire_date'] = $expire_date;
            }

            $sub_result = insert("tbl_subscription",$ins_data);
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
            $data["ins_sub_data_ios"] = $ins_data;
        }
    }
}
else {
    $status = 0;
    $msg = $gbl_msg_invalid_args;
}
?>
