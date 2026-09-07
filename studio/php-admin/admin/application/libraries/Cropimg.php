<?php 
if (!defined('BASEPATH')) exit('No direct script access allowed');

include_once APPPATH.'/third_party/Crop/Crop.php';

class Cropimg{

public $param;
public $Crop_img;
public $new_crop;
public function __construct()
{
    // $this->Crop_img = new CropAvatar(
    // isset($_POST['avatar_src']) ? $_POST['avatar_src'] : null,
    // isset($_POST['avatar_data']) ? $_POST['avatar_data'] : null,
    // isset($_FILES['avatar_file']) ? $_FILES['avatar_file'] : null); 
}

public function new_crop($post)
{
	 $this->new_crop = new CropAvatar(
    isset($_POST['avatar_src']) ? $_POST['avatar_src'] : null,
    isset($_POST['avatar_data']) ? $_POST['avatar_data'] : null,
    isset($_FILES['avatar_file']) ? $_FILES['avatar_file'] : null); 

	$response = array(
	  'state'  => 200,
	  'message' => $this->new_crop-> getMsg(),
	  'result' => $this->new_crop-> getResult()
	);

	return $response;
}

}
?>