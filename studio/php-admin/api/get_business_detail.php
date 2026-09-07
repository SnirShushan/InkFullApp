<?php
$fields = ['uid','login_token','app_token','device_type','app_version','bid'];
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
        $order = 'order by date_added DESC';
        $data['detail']=get_business_detail($post['bid'],$post['uid'],15,$order);
    }
} else {
    $status = 0;
    $msg = $gbl_msg_invalid_args;
}
