<?php
if (!defined('BASEPATH')) exit('No direct script access allowed');  
 
require_once APPPATH."third_party/slim.php";
class SlimImage extends Slim {
    public function __construct() {
        parent::__construct();
    }
}
?>