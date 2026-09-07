<?php
$fields = ['uid','login_token','app_token','device_type','app_version','type'];
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
        $type=$post['type'];
        $uid=$post['uid'];

        $limit="";
        if(isset($post['start']) && isset($post['limit']))
        {
            $limit=" LIMIT ".$post['start'].",".$post['limit'];
        }
        $unRead = 0;
        if($type=="sent"){
            // $sql="select * from tbl_request where uid='".$post['uid']."' ORDER BY id DESC ";
            $sql="SELECT c.*, ( SELECT cs.phone FROM tbl_customer AS cs WHERE cs.id = c.uid )  AS phone ,( SELECT cs.cnt_code FROM tbl_customer AS cs WHERE cs.id = c.uid ) AS cnt_code FROM tbl_request AS c,tbl_customer AS cus WHERE c.uid = '".$post['uid']."' AND c.uid = cus.id AND cus.is_delete = '0' AND c.business_id != '0' ORDER BY c.id DESC ";
            // $sql="SELECT *, ( SELECT cs.cnt_code FROM tbl_customer AS cs WHERE cs.id = c.uid ) AS cnt_code FROM tbl_request AS c WHERE c.uid = '".$post['uid']."' ORDER BY c.id DESC ".$limit;
            /* echo "sent Sql : " . $sql;
            exit; */
        }else{
            // $sql="select * from tbl_request where business_id='".$post['uid']."' ORDER BY id DESC ";
            $sql="SELECT c.*, ( SELECT cs.phone FROM tbl_customer AS cs WHERE cs.id = c.uid ) AS phone, ( SELECT cs.cnt_code FROM tbl_customer AS cs WHERE cs.id = c.uid ) AS cnt_code FROM tbl_request AS c,tbl_customer AS cus WHERE c.business_id = '".$post['uid']."' AND c.uid = cus.id AND cus.is_delete = '0' ORDER BY c.id DESC ";
            // $sql="SELECT *, ( SELECT cs.cnt_code FROM tbl_customer AS cs WHERE cs.id = c.business_id ) AS cnt_code FROM tbl_request AS c WHERE c.business_id = '".$post['uid']."' ORDER BY c.id DESC ".$limit;
            /* echo "recive Sql : " . $sql;
            exit; */
        }
        if($type=="sent"){
            // $sql="select * from tbl_request where uid='".$post['uid']."' ORDER BY id DESC ";
            $count_sql="SELECT c.*, ( SELECT cs.phone FROM tbl_customer AS cs WHERE cs.id = c.uid )  AS phone ,( SELECT cs.cnt_code FROM tbl_customer AS cs WHERE cs.id = c.uid ) AS cnt_code FROM tbl_request AS c,tbl_customer AS cus WHERE c.uid = '".$post['uid']."' AND c.uid = cus.id AND cus.is_delete = '0' AND c.is_read = '2' AND c.business_id != '0' ORDER BY c.id DESC ";
        }else{
            // $sql="select * from tbl_request where business_id='".$post['uid']."' ORDER BY id DESC ";
            $count_sql="SELECT c.*, ( SELECT cs.phone FROM tbl_customer AS cs WHERE cs.id = c.uid ) AS phone, ( SELECT cs.cnt_code FROM tbl_customer AS cs WHERE cs.id = c.uid ) AS cnt_code FROM tbl_request AS c,tbl_customer AS cus WHERE c.business_id = '".$post['uid']."' AND c.uid = cus.id AND cus.is_delete = '0' AND c.is_read = '2' ORDER BY c.id DESC ";
        }
        
        $result=$db->query($sql.$limit);
        $data['query'] = $sql.$limit;
        if($result){
            if($result->num_rows()>0){
                foreach($result->result_array() as $row){
                    
                    $row['business_row']=get_user_profile($row['business_id']);
                    /* if($uid == "110" || $uid == "109"){
                        $style_arr = [];
                        $style = explode(",",$row['styles']);
                        foreach ($style as $key => $value) {
                            # code...
                            if(!in_array($value,$style_arr)){
                                array_push($style_arr, $value);
                            }
                        }
                        $new_styles = implode(",",$style_arr);
                        $row['styles'] = $new_styles;
                        $row['artist_row']=get_user_profile($row['artists_uid']);
                        $row['business_row']=get_user_profile($row['business_id']);
                        $row['sender_row']=get_user_profile($row['uid']);
                        if($row['request_images']!=""){
                            $row['request_images']=json_decode($row['request_images']);
                        }
                        $list[]=$row;
                    }
                    else{ */

                        if(count($row['business_row']) > 0){
                            $style_arr = [];
                            $style = explode(",",$row['styles']);
                            foreach ($style as $key => $value) {
                                # code...
                                if(!in_array($value,$style_arr)){
                                    array_push($style_arr, $value);
                                }
                            }
                            $new_styles = implode(",",$style_arr);
                            $row['styles'] = $new_styles;
        
                            $row['artist_row']=get_user_profile($row['artists_uid']);
                            $row['business_row']=get_user_profile($row['business_id']);
                            $row['sender_row']=get_user_profile($row['uid']);
                            if($row['request_images']!=""){
                                $row['request_images']=json_decode($row['request_images']);
                            }
                            $list[]=$row;
                        }
                    // }
                }
            }
        }
        $count=$db->query($count_sql);
        if($count){
            $unRead = $count->num_rows();
        }
        $data['unread_request_count']=$unRead;
        $data['request_list']=$list;
    }
} else {
    $status = 0;
    $msg = $gbl_msg_invalid_args;
}
