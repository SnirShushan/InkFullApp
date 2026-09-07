<?php 
$dd = json_decode(file_get_contents('php://input'), true);
// register_app_log('IOS In App Purchase',['post'=>$_REQUEST]);
register_app_log('IOS In App Purchase',['post'=>print_r($_REQUEST,true),'d1'=>$dd]);
$status=1;
$msg="Success";
// $data = $_REQUEST;
$original_id = "";
$expire_time = "";

if(isset($dd['signedPayload']))
{

    $obj=json_decode(base64_decode(str_replace('_', '/', str_replace('-','+',explode('.', $dd['signedPayload'])[1]))));
    $secret="3d4e16416c764617b39808e834e45067";
    $obj1=json_decode(base64_decode(str_replace('_', '/', str_replace('-','+',explode('.', $obj->data->signedTransactionInfo)[1]))));
    
    /* echo "<pre>";
    print_r($obj);
    print_r($obj1);
    exit; */

    $original_id = $obj1->originalTransactionId;
    $subscription_data = json_encode($obj1);
    $expire_date = date("Y-m-d H:i:s",($obj1->expiresDate/1000));
    $dt = date("Y-m-d H:i:s");
    // $obj1->productId
    if($obj1->transactionReason=="RENEWAL")
    {
        if($obj1->productId=="monthly_basic_plan")
        {
            $obj1->productId="monthly_premium_plan";
        }
    }
    
    $chk_sub_plan = explode("_",$obj1->productId);

    /* if($chk_sub_plan[0] == "yearly"){
        $expire_time = "+1 year";
    }
    else if($chk_sub_plan[0] == "monthly"){
        $expire_time = "+1 month";
    } */

    // $expire_date = date("Y-m-d H:i:s",strtotime($expire_time, strtotime($expire_date)));
    // $ios_sub_ipn_details = get_ios_sub_ipn_detail($dd['signedPayload']);
    $ios_sub_ipn_details = get_ios_transaction_id($original_id);
    $data['original_id']=$original_id;
    $data['ios_sub_ipn_details']=$ios_sub_ipn_details;
    if(count($ios_sub_ipn_details) > 0){
        $ios_sub_data = [];
        $ios_sub_data['signed_payload'] = $dd['signedPayload'];
        $ios_sub_data['date_added'] = $dt;
        $ios_sub_data['transcation_id'] = $obj1->transactionId;
        $ios_sub_data['original_transaction_id'] = $original_id;
        $ios_sub_data['web_order_line_item_id'] = $obj1->webOrderLineItemId;
        $ios_sub_data['bundle_id'] = $obj1->bundleId;
        $ios_sub_data['product_id'] = $obj1->productId;
        $ios_sub_data['subscription_group_identifier'] = $obj1->subscriptionGroupIdentifier;
        $ios_sub_data['purchase_date'] = date("Y-m-d H:i:s",($obj1->purchaseDate/1000));
        $ios_sub_data['original_purchase_date'] = date("Y-m-d H:i:s",($obj1->originalPurchaseDate/1000));
        $ios_sub_data['expires_date'] = $expire_date;
        $ios_sub_data['quantity'] = $obj1->quantity;
        $ios_sub_data['type'] = $obj1->type;
        $ios_sub_data['inapp_ownership_type'] = $obj1->inAppOwnershipType;
        $ios_sub_data['signed_date'] = date("Y-m-d H:i:s", (int) ($obj1->signedDate / 1000));
        // $ios_sub_data['signed_date'] = date("Y-m-d H:i:s",($obj1->signedDate/1000));
        $ios_sub_data['environment'] = $obj1->environment;
        $ios_sub_data['transaction_reason'] = $obj1->transactionReason;
        $ios_sub_data['store_front'] = $obj1->storefront;
        $ios_sub_data['store_front_id'] = $obj1->storefrontId;
        $sub_result = update("tbl_ios_subscription_ipn",$ios_sub_data,['signed_payload'=>$dd['signedPayload']]);
        $data['upd']=$ios_sub_data;
        if($sub_result){
            $status = 1;
            $msg = "Success";
        }else{
            $status = 0;
            // $msg = "Error on adding";
            $msg = "תקלה בהוספה";
        }
        $data["update data"] = $sub_result;
    }
    else{
        $ios_sub_data = [];
        $ios_sub_data['signed_payload'] = $dd['signedPayload'];
        $ios_sub_data['date_added'] = $dt;
        $ios_sub_data['transcation_id'] = $obj1->transactionId;
        $ios_sub_data['original_transaction_id'] = $original_id;
        $ios_sub_data['web_order_line_item_id'] = $obj1->webOrderLineItemId;
        $ios_sub_data['bundle_id'] = $obj1->bundleId;
        $ios_sub_data['product_id'] = $obj1->productId;
        $ios_sub_data['subscription_group_identifier'] = $obj1->subscriptionGroupIdentifier;
        $ios_sub_data['purchase_date'] = date("Y-m-d H:i:s",($obj1->purchaseDate/1000));
        $ios_sub_data['original_purchase_date'] = date("Y-m-d H:i:s",($obj1->originalPurchaseDate/1000));
        $ios_sub_data['expires_date'] = $expire_date;
        $ios_sub_data['quantity'] = $obj1->quantity;
        $ios_sub_data['type'] = $obj1->type;
        $ios_sub_data['inapp_ownership_type'] = $obj1->inAppOwnershipType;
        $ios_sub_data['signed_date'] = date("Y-m-d H:i:s", (int) ($obj1->signedDate / 1000));
        // $ios_sub_data['signed_date'] = date("Y-m-d H:i:s",($obj1->signedDate/1000));
        $ios_sub_data['environment'] = $obj1->environment;
        $ios_sub_data['transaction_reason'] = $obj1->transactionReason;
        $ios_sub_data['store_front'] = $obj1->storefront;
        $ios_sub_data['store_front_id'] = $obj1->storefrontId;
        $sub_result = insert("tbl_ios_subscription_ipn",$ios_sub_data);
        $data['ins']=$ios_sub_data;
        if($sub_result){
            $status = 1;
            $msg = "Success";
        }else{
            $status = 0;
            // $msg = "Error on adding";
            $msg = "תקלה בהוספה";
        }
        $data["insert data"] = $sub_result;
    }
    
    if($original_id != ""){
        $data['sub_upd'] = "1";

        $original_transcation_id = get_ios_subscribe_data($original_id);

        $data['original_id_1']=$original_id;
        $data['original_transcation_id']=$original_transcation_id;

        // $expire_date = date("Y-m-d H:i:s",strtotime("+1 month", strtotime($expire_date)));
        // $expire_date = date("Y-m-d H:i:s",($obj1->expiresDate/1000));
        $data['original_transID'] = $original_transcation_id;
        $data['ipn_original_transID'] = $original_id;
        if($original_transcation_id != ""){
            $data['sub_upd'] = "2";


                /**
                 * getting user which ios subscription is going to active. START
                 */

                        $db->select("*");
                        $db->from("tbl_subscription");
                        // $db->where(["is_delete"=>'0','cust_id'=>$uid,'is_sub_active'=>'1','status'=>'1']);
                        $db->where(["is_delete"=>'0','transaction_id'=>$original_transcation_id]);
                        $db->order_by("id", "desc");
                        $result_close = $db->get();
                        // echo "Query : " . $db->last_query();
                        // exit;
                        if (!$result_close) {
                            
                        } else {
                            if($result_close->num_rows()>0){
                                $rows_close=$result_close->result_array();
                                
                                $update_data_close = [];
                                $update_data_close['status'] = '2';
                                $update_data_close['is_sub_active'] = '2';
                                $update_data_close['date_updated'] = $dt;
                                // Close all subscription
                                $sub_result_1 = update("tbl_subscription",$update_data_close,['cust_id'=>$rows_close[0]['cust_id'],"is_delete"=>"0"]);

                                $db->query("DELETE from tbl_subscription where cust_id='".$rows_close[0]['cust_id']."' AND product_id='basic_free_plan' AND status='2'");
                                
                            }
                        }
                /**
                 *  END
                 */


                


            $update_data = [];
            $update_data['subscription_data'] = $subscription_data;
            $update_data['purchase_token'] = "";
            $update_data['device_type'] = "2";
            $update_data['status'] = '1';
            $update_data['is_sub_active'] = '1';
            $update_data['expire_date'] = $expire_date;
            $update_data['date_updated'] = $dt;
            $sub_result = update("tbl_subscription",$update_data,['transaction_id'=>$original_transcation_id]);
            if($sub_result){
                
                $status = 1;
                // $msg = "Update Success";
                $msg = "עודכן בהצלחה";

            }else{
                $status = 0;
                // $msg = "Error on adding";
                $msg = "תקלה בהוספה";
            }
            $data["upd_sub_data"] = $update_data;
        }
    }
    else{
        $data['sub_not_upd'] = "2";
    }
    $data['sign_payload_data'] = $obj;
}

?>
