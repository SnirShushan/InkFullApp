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


            $dt = date("Y-m-d H:i:s");
            $exists="0";

            $result_sub_check = get("tbl_subscription", "*", "cust_id='".$row['id']."' AND product_id='basic_free_plan' AND is_sub_active='1' LIMIT 1");
                $rows_req=[];
                if ($result_sub_check) {
                    if( $result_sub_check->num_rows() > 0 ){
                        $exists="1";    
                    }
                }
            

            if($exists=="1")
            {
                $status = 0;
                $msg = "You are already subscribed to this plan";
            }else{
                
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
                    $data['cust_upd'] = $update_cust;
                    //$data['old_post_limit']=$row['post_limit'];
                }else{
                    $status = 0;
                    // $msg = "Error on adding";
                    $msg = "תקלה בהוספה";
                }
            }



    }
}
else {
    $status = 0;
    $msg = $gbl_msg_invalid_args;
}
?>
