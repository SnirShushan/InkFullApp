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
        $start = "0";
        $limit = "6";
        $user_styles = $user_data['styles'];
        $followers=[];
        $params = [];
        $params['start']=$start;
        $params['limit']=$limit;
        
        $followers = get_new_user_list($post['uid'], $params);
        $data['new_user_list']=$followers;
        $data['is_new_notification'] = '2';

        $sql_noti="SELECT n.*,c.id as cust_id FROM tbl_notifications n,tbl_customer c WHERE n.me='".$post['uid']."' AND n.uid = c.id AND c.is_delete = '0' AND n.is_read = '2' ORDER BY n.id DESC limit 1";
        $result=$db->query($sql_noti);

        if($result){
            if($result->num_rows()>0){
                $data['is_new_notification'] = '1';
            }
        }

        if($data['is_new_notification'] == '2')
        {
            $recv_count_sql="SELECT c.*, ( SELECT cs.phone FROM tbl_customer AS cs WHERE cs.id = c.uid ) AS phone, ( SELECT cs.cnt_code FROM tbl_customer AS cs WHERE cs.id = c.business_id ) AS cnt_code FROM tbl_request AS c,tbl_customer AS cus WHERE c.business_id = '".$post['uid']."' AND c.uid = cus.id AND cus.is_delete = '0' AND c.is_read = '2' ORDER BY c.id DESC ";
            $recv_count=$db->query($recv_count_sql);
            if($recv_count->num_rows() > 0){
                $data['is_new_notification'] = '1';
            }
        }

        $user_data = get_user_profile($post['uid']);
        $user_styles = $user_data['styles'];
        if($user_styles!=""){
            $stylespost_params['is_recommended']=$user_styles;
        }
        $stylespost_params['uid']=$post['uid'];
        $stylespost_params['start'] = "0";
        $stylespost_params['limit'] = "1";
        // $plist=search_posts($stylespost_params);
        $plist=new_posts_count($stylespost_params);
        $data['total_post_count'] = $plist;
    }
} else {
    $status = 0;
    $msg = $gbl_msg_invalid_args;
}