<?php
$fields = ['uid', 'login_token', 'device_type', 'app_version', 'app_token', 'business_type'];
$check = check_isset($fields);
if ($check) {
    $post = get_all_data_protected($_REQUEST);
    $row = validate_token($post['login_token'], $post['uid']);

    if ($row == false) {
        $status = 2;
        $msg = $gbl_msg_invalid_token;
    } else {

        $params=[];
        $params['bid'] = $post['uid'];

        if(isset($post['business_type']))
        {
            if($post['business_type']!=""){
                $params['business_type']=$post['business_type'];
            }
            if($post['business_type']=="00"){
                $params['business_type']="0";
            }
        }
        
        if(isset($post['search_txt']))
        {
            if($post['search_txt']!=""){
                $params['search_txt']=$post['search_txt'];
            }
        }

        if(isset($post['start']))
        {
            if($post['start']!=""){
                $params['start']=$post['start'];
            }
        }

        if(isset($post['limit']))
        {
            if($post['limit']!=""){
                $params['limit']=$post['limit'];
            }
        }

        // $business_list = get_business_list($post['business_type']);
        $business_list = get_business_list($params);
        if ($business_list) {
            // $msg = "Business List";
            $msg = "רשימת עסקים";
            $data['business_list'] = $business_list;
            $status = 1;
        }
    }
} else {
    $status = 0;
    $msg = $gbl_msg_invalid_args;
}
