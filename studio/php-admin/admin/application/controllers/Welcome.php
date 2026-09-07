<?php
defined('BASEPATH') OR exit('No direct script access allowed');

class Welcome extends MY_Controller 
{


	public function __construct()
	{
		parent:: __construct();

		//if not login redirect login page
		valid_login();
		//if not access it redirect dashboard
		//RedirectIfNothasAccess('full_access');

	}

	public function index()
	{
		$this->view_data['title'] = "Profile Settings";
		$this->view_data['menu'] = "Setting_";
		$this->view_data['page_heading']="Profile Settings";
		$this->view_data['page_sub_heading']="";
		$this->view_data['arr_breadcrumb']=array("Home"=>base_url());
		$this->view_data['breadcrumb_home_logo']='<i class="icon-home"></i>';
		
		$this->view_data['back_button']=base_url();

		$kk = $this->input->get("key");
		if( $kk != "access" ){
			exit;
		}
	}
	

	public function remove_temp_ac(){
		 
	}

}
