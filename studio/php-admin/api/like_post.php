<?php
$fields = ['uid','login_token','app_token','device_type','app_version','pid','action_status'];
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
        $msg="success";
        $status=1;
        if($post['action_status']=="1")
        {   
            $is_exists="0";
            $result=$db->query("select id from tbl_post_likes where uid='".$post['uid']."' AND pid='".$post['pid']."' LIMIT 1");
            //$data['q']=$db->last_query();
            if($result)
            {
                if($result->num_rows()>0){
                    $is_exists="1";
                }
            }
            if($is_exists=="0"){
                $ins_data=[];
                $ins_data['pid']=$post['pid'];
                $ins_data['uid']=$post['uid'];
                $ins_data['date_added'] = date("Y-m-d H:i:s");
                insert('tbl_post_likes', $ins_data);
            }
        }else{
            $result=$db->query("DELETE FROM tbl_post_likes WHERE uid='".$post['uid']."' AND pid='".$post['pid']."'");
            //$data['q']=$db->last_query();
        }
        
        
    }
} else {
    $status = 0;
    $msg = $gbl_msg_invalid_args;
}