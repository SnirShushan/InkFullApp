<?php
$fields = ['uid','login_token','app_token','device_type','app_version'];
$check = check_isset($fields);
global $profile_image_path;

if ($check) {
    $post = get_all_data_protected($_REQUEST);
    $row = validate_token($post['login_token'], $post['uid']);
    if ($row == false) {
        $status = 2;
        $msg = $gbl_msg_invalid_token;
    }
    else{
        $user_data = get_user_profile($post['uid'],$post['uid']);
        $profile_image = $user_data['profile_image'];
        $profile = $profile_image_path . $user_data['profile_image'];
       
        if (file_exists($profile)) {
            if($profile_image != ""){
                unlink($profile);
                $msg = 'Success';
            }
        } else {
            $status=0;
            // $msg = 'Error in removing image ' . $profile_image ;
            $msg = 'שגיאה בהסרת תמונה' . $profile_image ;
        }
        $update_dt = date("Y-m-d H:i:s");
        
        
        $result=update("tbl_customer", ['profile_image'=>"",'date_updated'=>$update_dt], ['id'=>$row['id']]);
        if($result){
            // $msg = "Profile Image Removed Successfully";
            $msg = "תמונת פרופיל הוסרה בהצלחה";
            $data['profile'] = get_user_profile($post['uid'],$post['uid']);
            $status = 1;
        }        
    }
} else {
    $status = 0;
    $msg = $gbl_msg_invalid_args;
}