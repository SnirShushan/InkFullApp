<?php
$fields = ['phone','app_token','device_type','app_version'];
$check = check_isset($fields);

if ($check) {
    $status = 1;
    $msg = "Success";
    $is_exists = 0;
    $row = get_user_by_phone($_REQUEST['phone']);
    
    if (count($row) > 0) {
        $is_exists = 1;
        $data['email']=($row['email'] == null) ? "" : $row['email'];
    }
    $data['is_exists'] = $is_exists;
} else {
    $status = 0;
    $msg = $gbl_msg_invalid_args;
}