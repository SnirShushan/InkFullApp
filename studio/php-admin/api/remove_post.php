<?php

$fields = ['uid', 'login_token', 'pid', 'device_type', 'app_version', 'app_token'];
$check = check_isset($fields);
$email = '';
$name = '';
global $signature_image_path;
if ($check) {
    $post = get_all_data_protected($_REQUEST);
    $row = validate_token($post['login_token'], $post['uid']);

    if ($row == false) {
        $status = 2;
        $msg = $gbl_msg_invalid_token;
    } else {
        $dt = date("Y-m-d H:i:s");
        $update_data = [];
        $update_data['date_updated'] = $dt;
        $post_row=get_post_detail($post['pid'],$post['uid']);
        if(count($post_row)>0){
            if($post_row['uid']==$post['uid'])
            {
                $status=1;
                $msg="Success";
                $db->query("delete from tbl_post where id='".$post['pid']."'");
                $db->query("delete from tbl_post_likes where pid='".$post['pid']."'");
                $db->query("delete from tbl_report_posts where pid='".$post['pid']."'");
                $db->query("delete from tbl_saved_post where pid='".$post['pid']."'");
                $db->query("delete from tbl_notifications where pid='".$post['pid']."'");
                register_db_error(['type'=>"info","data"=>"post delete ".$post['pid']." by ".$post['uid'],"row"=>$post_row]);

            }else{
                $status=0;
                $msg="You can just delete your post";
            }
        }else{
            $status=0;
            // $msg="Post detail not found";
            $msg="פרטי הפוסט לא נמצאו";
        }
    }
} else {
    $status = 0;
    $msg = $gbl_msg_invalid_args;
}
