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
        $update_dt=date("Y-m-d H:i:s");
        if(!empty($_FILES['profile_image'])){

            $file_type = $_FILES['profile_image']['type'];
            $file_explode = explode('.',$_FILES['profile_image']['name']);
            $file_end = end($file_explode);
            $file_ext = strtolower($file_end);
            $type = ["jpeg","jpg","png","gif"];

            if(!in_array($file_ext,$type)){
                $status = 0;
                // $msg = "Extension not allowed, please choose jpeg, png or gif file.";
                $msg = "יש להעלות תמונה בפורמט  jpeg, png או gif";
            }
            else{
                $res_img=upload_image($_FILES['profile_image'],$profile_image_path);
                $profile_image = $res_img['name'];
                
    
                if($res_img['has_error'] == "1"){
                    // $msg = "file not uploaded ".$res_img['error'];
                    $msg = "העלאת התמונה נכשלה ".$res_img['error'];
                }
                else{
                   
                    $result=update("tbl_customer", ['profile_image'=>$profile_image], ['id'=>$row['id']]);
                    if($result){
                        // $msg = "Profile Image Update Successfully";
                        $msg = "תמונת פרופיל עודכנה בהצלחה";
                        $data['profile'] = get_user_profile($post['uid'],$post['uid']);
                        $status = 1;
                    }
                }
            }
        }
        else{
            // $msg = "Please Upload image";
            $msg = "אנא העלה תמונה";
        }
        
    }
} else {
    $status = 0;
    $msg = $gbl_msg_invalid_args;
}