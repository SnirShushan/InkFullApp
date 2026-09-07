<?php
$fields = ['uid','login_token','app_token','device_type','app_version'];
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
        $status=1;
        $users=[];
        $result=$db->query("select bid,req_status,date_added from tbl_artist_business_map where uid='".$post['uid']."' AND req_status IN('0','1') ORDER BY date_added DESC");
        //$data['f']=$db->last_query();
        if($result){
            if($result->num_rows()>0){
                foreach($result->result_array() as $row){
                    $profile=get_user_profile($row['bid']);
                    if(count($profile)>0){
                        $row['profile']=$profile;
                        $users[]=$row;
                    }
                }
            }
        }
        $data['users']=$users;
    }
} else {
    $status = 0;
    $msg = $gbl_msg_invalid_args;
}