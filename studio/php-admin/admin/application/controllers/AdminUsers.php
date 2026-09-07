<?php
defined('BASEPATH') OR exit('No direct script access allowed');

class AdminUsers extends MY_Controller 
{

	public function __construct()
	{
		parent:: __construct();

		//if not login redirect login page
		valid_login();
		//if not access it redirect dashboard
		
		$this->load->model("user_model");
		
	}

	public function index()
	{

		$this->view_data['title'] = "Manage Users";
		$this->view_data['menu'] = "manage_users";
		$this->view_data['page_heading']="Manage Users";
		$this->view_data['page_sub_heading']="";
		$this->view_data['arr_breadcrumb']=array("Home"=>base_url());
		$this->view_data['breadcrumb_home_logo']='<i class="icon-home"></i>';
		
		//$this->view_data['settings']=$this->settings;
	}

	public function add()
	{
		$this->view_data['title'] = "Manage Users";
		$this->view_data['menu'] = "manage_users";
		$this->view_data['page_heading']="Manage Users";
		$this->view_data['page_sub_heading']="";
		$this->view_data['arr_breadcrumb']=array("Home"=>base_url());
		$this->view_data['breadcrumb_home_logo']='<i class="icon-home"></i>';
	}


	public function Edit($uid)
	{

		RedirectIfNothasAccess('update_user_detail');
		
		$this->view_data['title'] = "Edit Users";
		$this->view_data['menu'] = "manage_users";
		$this->view_data['page_heading']="Edit User";
		$this->view_data['page_sub_heading']="";
		$this->view_data['arr_breadcrumb']=array("Home"=>base_url(),"Manage Users"=>base_url('ManageUsers'));
		$this->view_data['breadcrumb_home_logo']='<i class="icon-home"></i>';

		$this->view_data['error']="";

		$row = $this->user_model->GetUserDetail($uid);
		if(!$row){
			redirect(base_url('ManageUsers'));
		}

		$this->view_data['facility_list'] = $this->facility_model->getFacilityList();
		$this->view_data['country_list'] = $this->user_model->getCountryList();

		if($this->input->post()){

			$config=[
				array(
					'field' => 'name',
					'label' => 'name',
					'rules' => 'required'
				),
				array(
					'field' => 'phone_number',
					'label' => 'phone number',
					'rules' => 'required|callback_user_phone_number_check['.$uid.']'
				),
				array(
					'field' => 'email',
					'label' => 'email',
					'rules' => 'required|valid_email|callback_user_email_check['.$uid.']'
				),
				array(
					'field' => 'country_id',
					'label' => 'country',
					'rules' => ''
				),
			];
			$this->form_validation->set_rules($config);

	        if ($this->form_validation->run()){
	        	$form_data = $this->input->post();
 	        	
				$valid_data = true;
				
				if( $valid_data ){

					$country_name = $this->user_model->getCountryDetail($form_data['country_id']);
					if($country_name){
						$form_data['country'] = $country_name->country_name;
					}
		
		        	$res = $this->user_model->update_user_detail($uid,$form_data);
		        	if(!$res){
		        		$this->view_data['error'] = "Error Update User";
		        	}else{
		        		set_flashdata("msg_success","User <b>".$form_data['name']."</b> is successfully updated.");
		        		redirect("ManageUsers/Edit/".$uid);
		        	}

				}//validation done

	        }else{
	        	$this->view_data['error'] = validation_errors();
	        }

		}

		$this->view_data['row'] = $row;
	}
	
}