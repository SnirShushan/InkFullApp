<?php

defined('BASEPATH') OR exit('No direct script access allowed');

class Test extends MY_Controller 

{

	public function __construct()
	{
		parent:: __construct();
		
	}



	public function index()
	{
		$this->layout_view="layout/lft_default_ori";
		
		$this->view_data['title'] = $this->lang->line('terms');

		$this->view_data['menu'] = "Test";	

		$this->view_data['back_button']=base_url(); 
		

	
	}//index



}//class

?>