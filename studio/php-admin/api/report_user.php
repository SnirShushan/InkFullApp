<?php
$fields = ['uid','login_token','app_token','device_type','app_version','user_id',"comment"];
$check = check_isset($fields);
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
        $msg="success";
        $status=1;
        $dt=date("Y-m-d H:i:s");
        $comment=$post['comment'];
        $user_id=$post['user_id'];

        $allow="1";
        $sql="select * from tbl_report_users where uid='".$post['user_id']."' AND reported_by_uid='".$post['uid']."' AND status='0' LIMIT 1";
        $result=$db->query($sql);
        if($result){
            if($result->num_rows()>0){
                $allow="0";
                $status=0;
                //$msg="You have already requested this report user";
                $msg="הדיווח התקבל בהצלחה";

            }
        }
        
        if($allow=="1"){
            $status=1;
            //$msg="Sent";
            // $msg="הדיווח שלך כבר נשלח";
            $msg="הדיווח שלך נשלח בהצלחה";
            
            $ins=[];
            $ins['comment']=$post['comment'];
            $ins['reported_by_uid']=$post['uid'];
            $ins['uid']=$post['user_id'];
            $ins['date_added']=$dt;
            insert('tbl_report_users', $ins);
        }

    }
} else {
    $status = 0;
    $msg = $gbl_msg_invalid_args;
}
