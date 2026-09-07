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
        $user_data = get_user_profile($post['uid']);
        $status=1;
        $msg="success";
        $styles = [];
        if(isset($user_data['styles']) && $user_data['styles'] != '')
        {
            $styles['styles'] = $user_data['styles'];
        }
        $styles['start'] = "0";
        $styles['limit'] = "6";
        $styles['uid'] = $post['uid'];
        $plist=random_posts($styles);
        $data['random_query'] = $db->last_query();
        $data['tattos_in_style'] = [];
        if($plist->num_rows()>0){
            $data['tattos_in_style'] = $plist->result_array();
        }
    }
} else {
    $status = 0;
    $msg = $gbl_msg_invalid_args;
}