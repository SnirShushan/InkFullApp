<?php
$output_type=0;
$token = $_REQUEST['sign_payload'];
$obj=json_decode(base64_decode(str_replace('_', '/', str_replace('-','+',explode('.', $token)[1]))));
$secret="3d4e16416c764617b39808e834e45067";
echo "<pre>";
// print_r($obj);
$obj1=json_decode(base64_decode(str_replace('_', '/', str_replace('-','+',explode('.', $obj->data->signedTransactionInfo)[1]))));
print_r($obj1);
echo "\npurchase date : ". date("Y-m-d H:i:s",($obj1->purchaseDate/1000));
echo "\nexpires date : ".  date("Y-m-d H:i:s",($obj1->expiresDate/1000));


$subscription_data = json_encode($obj1);
$expire_date = date("Y-m-d H:i:s",($obj1->expiresDate/1000));
$dt = date("Y-m-d H:i:s");

$update_data = [];
$update_data['subscription_data'] = $subscription_data;
$update_data['product_id'] = $obj1->productId;
$update_data['cust_id'] = '2473';
$update_data['transaction_id'] = $obj1->originalTransactionId;
$update_data['purchase_token'] = "";
$update_data['device_type'] = "2";
$update_data['status'] = '1';
$update_data['is_sub_active'] = '1';
$update_data['expire_date'] = $expire_date;
$update_data['date_updated'] = $dt;
$sub_result = insert("tbl_subscription",$update_data);
echo "\nsub add query : ".$db->last_query();
if($sub_result){
    echo "\ninserted";
    $ins_id = get_last_id();

    $get_settings = get_settings();
    $post_limit = $get_settings['post_limit'];

    $update_cust = [];
    $update_cust['sub_id'] = $ins_id;
    $update_cust['is_business'] = '1';
    $update_cust['business_type'] = '2';
    $update_cust['user_type'] = '2';
    $update_cust['post_limit'] = $post_limit;
    $update_cust['date_updated'] = $dt;
    update("tbl_customer",$update_cust,['id'=>'2473']);
    echo "\ncust update query : ".$db->last_query();
    $data['cust_upd'] = $update_cust;
}


?>
