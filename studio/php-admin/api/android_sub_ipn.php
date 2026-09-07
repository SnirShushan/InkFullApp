<?php 
$dd = json_decode(file_get_contents('php://input'), true);
register_app_log('In App Purchase',['d'=>print_r($_REQUEST,true),'d1'=>$dd]);
$status=1;
$msg="Success";
?>
