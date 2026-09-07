<?php
$fields = ['uid','login_token','app_token','device_type','app_version','pid',"comment"];
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
        $pid=$post['pid'];

        $allow="1";
        $sql="select * from tbl_report_posts where pid='".$post['pid']."' AND reported_by_uid='".$post['uid']."' AND status='0' LIMIT 1";
        $result=$db->query($sql);
        if($result){
            if($result->num_rows()>0){
                $allow="0";
                $status=0;
                //$msg="You have already requested this report post";
                $msg="הדיווח התקבל בהצלחה";
                
            }
        }
        
        if($allow=="1"){

            $post_detail=get_post_detail($post['pid'],$post['uid']);
            if(count($post_detail)>0)
            {
                $status=1;
                //$msg="Sent";
                // $msg="הדיווח שלך כבר נשלח";
                $msg="הדיווח שלך נשלח בהצלחה";
            
                $ins=[];
                $ins['owner']=$post_detail['uid'];
                $ins['comment']=$post['comment'];
                $ins['reported_by_uid']=$post['uid'];
                $ins['pid']=$post['pid'];
                $ins['date_added']=$dt;
                insert('tbl_report_posts', $ins);
            }else{
                $status=0;
                $msg="Post details not found";
            }
        }

    }
} else {
    $status = 0;
    $msg = $gbl_msg_invalid_args;
}
