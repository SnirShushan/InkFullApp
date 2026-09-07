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
        $start = "0";
        $limit = "6";
        $user_styles = $user_data['styles'];
        $radius = "40";
        $lat = $user_data['address_lat'];
        $lng = $user_data['address_lng'];
        $b_post_limit = 5; // need integer value for compare do not put string limit
        $order_by = 'order by date_added DESC';
        $is_home = true;
        include_once("get_business.php");
        $followers=[];
        $params = [];
        $params['start']=$start;
        $params['limit']=$limit;
        
        // $data['followers'] = get_user_followers($post['uid']);
        
        /* $styles = [];
        if(isset($user_data['styles']) && $user_data['styles'] != '')
        {
            $styles['styles'] = $user_data['styles'];
        }
        $styles['start'] = "0";
        $styles['limit'] = "6";
        $styles['uid'] = $post['uid'];
        $plist=random_posts($styles);
        $data['tattos_in_style'] = [];
        if($plist->num_rows()>0){
            $data['tattos_in_style'] = $plist->result_array();
        } */

        if(isset($post['start']) && $post['start'] != ""){
            $params['start']=$post['start'];
        }
        if(isset($post['limit']) && $post['limit'] != ""){
            $params['limit']=$post['limit'];
        }

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


        // if($data['is_new_notification'] == '2')
        // {
        //     $sent_count_sql="SELECT c.*, ( SELECT cs.phone FROM tbl_customer AS cs WHERE cs.id = c.uid )  AS phone ,( SELECT cs.cnt_code FROM tbl_customer AS cs WHERE cs.id = c.uid ) AS cnt_code FROM tbl_request AS c,tbl_customer AS cus WHERE c.uid = '".$post['uid']."' AND c.uid = cus.id AND cus.is_delete = '0' AND c.is_read = '2' ORDER BY c.id DESC ";
        //     $sent_count=$db->query($sent_count_sql);
        //     if($sent_count->num_rows() > 0){
        //         $data['is_new_notification'] = '1';
        //     }
        // }

        if($data['is_new_notification'] == '2')
        {
            $recv_count_sql="SELECT c.*, ( SELECT cs.phone FROM tbl_customer AS cs WHERE cs.id = c.uid ) AS phone, ( SELECT cs.cnt_code FROM tbl_customer AS cs WHERE cs.id = c.business_id ) AS cnt_code FROM tbl_request AS c,tbl_customer AS cus WHERE c.business_id = '".$post['uid']."' AND c.uid = cus.id AND cus.is_delete = '0' AND c.is_read = '2' ORDER BY c.id DESC ";
            $recv_count=$db->query($recv_count_sql);
            if($recv_count->num_rows() > 0){
                $data['is_new_notification'] = '1';
            }
        }
    }
} else {
    $status = 0;
    $msg = $gbl_msg_invalid_args;
}