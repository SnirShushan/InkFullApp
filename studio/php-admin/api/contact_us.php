<?php
$fields = ['uid','login_token','app_token','device_type','app_version','comment'];
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
        $row_user=get_user_profile($post['uid']);
        if(count($row_user)>0){
            // $msg="success";
            $msg="הפניה נשלחה בהצלחה!";
            $status=1;
            $ins_data=[];
            $ins_data['name']=$row_user['name'];
            $ins_data['email']=$row_user['email'];
            $ins_data['phone']=$row_user['phone'];
            $ins_data['message']=trim($post['comment']);
            $ins_data['uid']=$post['uid'];
            $ins_data['date_added'] = date("Y-m-d H:i:s");
            insert('tbl_contact_us', $ins_data);

            $subject = "התקבלה פניית צור קשר מהאפליקציה";
            $mail_res = sending_email_contact($post['uid'], $subject, $post['comment']);
            $data['mail_response'] = $mail_res;
            register_db_error(['type'=>"Contact US mail","data"=>"Contact US detail id: ".$row_user['id'].", email: ".$row_user['email'],"mail response"=>$mail_res,"row"=>$ins_data]);
        }else{
            $status=0;
            // $msg="user not found";
            $msg="המשתמש לא נמצא";
            // $msg="הפניה נשלחה בהצלחה!";
        }
        
         
        
        
    }
} else {
    $status = 0;
    $msg = $gbl_msg_invalid_args;
}