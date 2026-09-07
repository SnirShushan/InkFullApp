<?php
include __DIR__."/db_conn.php";
include __DIR__."/function.php";
$msg = "";
$dt = date("Y-m-d H:i:s");
$cron_subscribe_data = get_subscribe_list();

foreach ($cron_subscribe_data as $key => $cron_row)
{
    # code...
    if($cron_row['status'] == 1){
        if($cron_row['device_type'] == "1"){
            $sub_data = get_android_subscription_status($cron_row['product_id'],$cron_row['purchase_token']);
            if($sub_data->endDateTime < $dt){
                $update_data = [];
                $update_data['status'] = "2";
                $update_data['is_sub_active'] = '2';
                $update_data['date_updated'] = $dt;
                $sub_result = update("tbl_subscription",$update_data,['id'=>$cron_row['id']]);
                if($sub_result){
                    $status = 1;
                    // $msg = "Update Success";
                    $msg = "עודכן בהצלחה";
                }else{
                    $status = 0;
                    // $msg = "Error on adding";
                    $msg = "תקלה בהוספה";
                }
            }
        }
        else if($cron_row['device_type'] == "2"){
            $ipn_row = get_ios_transaction_id($cron_row['transaction_id']);
            if($ipn_row['expires_date'] < $dt){
                $update_data = [];
                $update_data['status'] = "2";
                $update_data['is_sub_active'] = '2';
                $update_data['date_updated'] = $dt;
                $sub_result = update("tbl_subscription",$update_data,['id'=>$cron_row['id']]);
                if($sub_result){
                    $status = 1;
                    // $msg = "Update Success";
                    $msg = "עודכן בהצלחה";
                }else{
                    $status = 0;
                    // $msg = "Error on adding";
                    $msg = "תקלה בהוספה";
                }
            }
        }
    }
}
?>