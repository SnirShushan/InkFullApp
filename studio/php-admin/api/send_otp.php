<?php

$fields = ['phone','app_token','otp','device_type','app_version'];

$check = check_isset($fields);



if ($check) {

    $status = 1;

    $msg = "Success";

    $post = get_all_data_protected($_REQUEST);

    $otp_msg= "Your login OTP is ".$post['otp'].". It is valid for 10 minutes.";

    $otp_msg="קוד האימות שלך הוא ".$post['otp'].", הקוד תקף ל-10 דקות";

    

    $res=send_sms( $post['phone'], $otp_msg );

    $data['res']=$res;

    

    if($res->status)

    {

        $status=1;

    }else{

        $status=0;

        $msg="אירעה שגיאה, יש לבדוק שמספר הטלפון נכון או לנסות שליחת קוד מחדש";
        $data['err_res']=$res->error;

    }

} else {

    $status = 0;

    $msg = $gbl_msg_invalid_args;

}