<?php
// include 'function.php';

// $post = get_all_data_protected($_REQUEST);
$is_request = $_REQUEST['is_request'];

$title='Testing';
$screen = 'Notification';
$udid = '';
$description = "Testing";

$device = 'a';
$push_image = '';
if(isset($_REQUEST['udid']))
{
    $udid = $_REQUEST['udid'];
}
if(isset($_REQUEST['title']))
{
    $title = $_REQUEST['title'];
}
if(isset($_REQUEST['screen']))
{
    $screen = $_REQUEST['screen'];
}
if(isset($_REQUEST['description']))
{
    $description = $_REQUEST['description'];
}
if(isset($_REQUEST['device']))
{
    $device = $_REQUEST['device'];
}

$device_token = ["0"=>$udid]; // Token generated from Android device after setting up firebase

$push_data['badge_count']=1;
$push_data['description']='';
$push_data['pid']="0";
// $push_data['owner']=11;
$push_data['screen']=$screen;
$push_data['is_request']=$is_request;
// $data['d']=10;
// $data['push']=notification($title, [$artist_user['udid']], $push_data);
// $notify=notification("title", $device_token, $push_data);
$notify = notification_new($title,$udid,['title'=>$title,'screen'=>$screen,'description'=>$description,'push_image' => $push_image],$device);
$notify = json_decode($notify,true);  


// notification($title, $device_token, $data)

// $notify = notification($data['title'], $device_token, $data);
echo "<pre>";
print_r($notify);
