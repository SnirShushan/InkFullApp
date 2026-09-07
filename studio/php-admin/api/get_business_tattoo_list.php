<?php
$fields = ['uid','login_token','app_token','device_type','app_version','bid','start','limit'];
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
        $bid=$post['bid'];
        $uid=$post['uid'];
        $start=$post['start'];
        $limit=$post['limit'];
        $allow="1";
        $msg="success";
        $status=1;

        $arr_tatto=[];
        

        $order_by = 'order by date_added DESC';
        $profile=get_user_profile($bid);
        $post_limit = $profile['post_limit'];
        
        $total_posts=0;
        $result_count=$db->query("select id,img_type,image_name from tbl_post where uid='$bid' AND status='1' AND img_type!='1' $order_by ");
        if($result_count)
        {
            $total_posts=$result_count->num_rows;
        }

        $total_sending=$start+$limit;
        if($total_sending>$post_limit){
            $allow="";
        }

        if($allow=="")
        {
            $allowed_limit = min($limit, $post_limit - $start);
            if($allowed_limit>0){
                $limit=$allowed_limit;
                $allow="1";
            }
        }

        if($allow=="1")
        {   
            $result=$db->query("select id,img_type,image_name from tbl_post where uid='$bid' AND status='1' AND img_type!='1' $order_by LIMIT $start,$limit");
            
            if($result){
                if($result->num_rows()>0){
                    foreach($result->result() as $r){
                        $tattoos =get_post_detail($r->id,$uid);
                        $tattoos['is_multiple_image']=count(explode(",",$tattoos['image_name'])) > 1 ? "1" : "0";
                        $tattoos['image_name']=explode(",",$tattoos['image_name'])[0];
                        $tattoos['image_id']=explode(",",$tattoos['image_id'])[0];
                        $arr_tatto[] = $tattoos;
                    }
                }
            }
        }
        
        
        $data['tatto']=$arr_tatto;

    }
} else {
    $status = 0;
    $msg = $gbl_msg_invalid_args;
}
