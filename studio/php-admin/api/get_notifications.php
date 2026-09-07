<?php
$fields = ['uid', 'login_token', 'device_type', 'app_version', 'app_token'];
$check = check_isset($fields);
if ($check) {
    $post = get_all_data_protected($_REQUEST);
    $row = validate_token($post['login_token'], $post['uid']);

    if ($row == false) {
        $status = 2;
        $msg = $gbl_msg_invalid_token;
    } else {
        $noti_list=[];
        $limit="";
        $extraWhere = '';
        if(isset($post['is_read']) && ($post['is_read'] == '1' || $post['is_read'] == '2')) {
            $extraWhere .= " AND n.is_read = '".$post['is_read']."'";
        }
        $unRead = 0;
        if(isset($post['start']) && isset($post['limit']))
        {
            $limit=" LIMIT ".$post['start'].",".$post['limit'];
        }
        $sql_noti="SELECT 
            n.*,
            c.id as cust_id,
            CASE WHEN(
                ((n.noti_type = 'studio_request_sent' and n.status = '1') OR (n.noti_type = 'studio_request_sent' and n.status = '2')) 
                OR ((n.noti_type = 'artist_request_sent' and n.status = '1') OR (n.noti_type = 'artist_request_sent' and n.status = '2'))
            ) THEN n.date_updated ELSE n.date_added END AS noti_date 
        FROM tbl_notifications n,tbl_customer c 
        WHERE n.me='".$post['uid']."' AND n.uid = c.id AND c.is_delete = '0' ".$extraWhere." ORDER BY noti_date DESC ".$limit;
        // $data['query'] = $sql_noti;
        $result=$db->query($sql_noti);
        if($result){
            if($result->num_rows()>0){
                foreach($result->result_array() as $row){
                    $row['noti_user']=get_user_profile($row['uid']);
                    if($row['pid'] != 0)
                    {
                        $image_name = get_post_image($row['pid'],$row['uid']);
                        $row['post_image'] = isset($image_name['image_name']) ? $image_name['image_name'] : '';
                    }
                    $noti_list[]=$row;
                    if($row['is_read'] == '2')
                    {
                        $unRead++;
                    }

                }

                
                
            }
        }
        $sql_noti="SELECT COUNT(c.id) as count FROM tbl_notifications n,tbl_customer c WHERE n.me='".$post['uid']."' AND n.uid = c.id AND c.is_delete = '0' AND n.is_read = '2' ".$extraWhere." ORDER BY n.id DESC";
        $rr=$db->query($sql_noti);
        if($rr->num_rows()>0){
            $count = $rr->row_array();
            $unRead = $count['count'];
        }

        $data['notification']=$noti_list;
        $data['unread_notification_count']=$unRead;
        $status=1;
        $msg="Success";
        
    }
} else {
    $status = 0;
    $msg = $gbl_msg_invalid_args;
}