<?php

defined('BASEPATH') OR exit('No direct script access allowed');

class User extends MY_Controller 

{

	public function __construct()
	{
		parent:: __construct();
		
	}



	public function index()
	{
		$this->view_data['title'] = "User";

		$this->view_data['menu'] = "Home";	

		$this->view_data['back_button']=base_url(); 
		$this->view_data['city_list']=$this->product_model->get_city_list_names();
		

	
	}//index

	public function forgot_password()
	{
		
		$this->view_data['title'] =$this->lang->line('forgot_password_title');

		$this->view_data['menu'] = "Login";	

		$this->view_data['back_button']=base_url(); 
		$this->view_data['city_list']=$this->product_model->get_city_list_names();
		$this->view_data['msg']="";
		$this->view_data['popup_ids']=getPopupIds(array("page_name"=>"ForgotPassword","popup_type"=>"2"));

		if(!empty($this->input->post("btn-forgot-password")))
		{
			$email=$this->input->post("email",TRUE);
			$found_email=$this->user_model->get_user_by_email($email);
			if($found_email!=false)
			{
				$hash=$this->user_model->add_password_key($found_email->id);
				$link=base_url("PasswordReset-").$hash;
				$this->view_data['msg']="<div class='alert alert-success'>".$this->lang->line('forgot_password_success_sent')."</div>";
				$html=$this->lang->line("forgot_password_email_html");
				$html=str_replace("{{user}}", $found_email->fname, $html);
				$html=str_replace("{{link}}", $link, $html);

				$item_data=array("data"=>$html);
				$html=$this->load->view('templetes/email_template', $item_data, true);

				send_email_general($email,$this->lang->line('forgot_password_email_subject'),$html);	
				send_email_general("nilesh@smart-webtech.com",$this->lang->line('forgot_password_email_subject'),$html);	
			}else{
				$this->view_data['msg']="<div class='alert alert-danger'>".$this->lang->line('forgot_password_email_not_found')."</div>";		
			}
			
		}

	}//Login 


	public function reset_password($hash)
	{
		$allow=0;
		$this->view_data['title'] =$this->lang->line('reset_password_title');
		$this->view_data['menu'] = "Login";	
		$this->view_data['back_button']=base_url(); 
		$this->view_data['city_list']=$this->product_model->get_city_list_names();
		$this->view_data['msg']="";
		$this->view_data['popup_ids']=getPopupIds(array("page_name"=>"ForgotPassword","popup_type"=>"2"));

		$result_row=$this->user_model->get_user_with_hash($hash);
		if($result_row==false)
		{
			$this->view_data['msg']="<div class='alert alert-danger'>".$this->lang->line('reset_password_error_expire')."</div>";
		}else{
			$row=$result_row;
			if(strtotime($row->pass_key_expire)<strtotime(date("Y-m-d H:i:s")))
			{
				$this->view_data['msg']="<div class='alert alert-danger'>".$this->lang->line('reset_password_error_expire')."</div>";
			}else{
				$allow=1;
			}
		}

		
		if(!empty($this->input->post("btn-reset-password")))
		{
			$pass1=$this->input->post("pass1",TRUE);
			$pass2=$this->input->post("pass2",TRUE);
			if($pass1==$pass2)
			{
				$allow=0;
				$password=md5($pass1);
				$this->view_data['msg']="<div class='alert alert-success'>".$this->lang->line('reset_password_success')."</div>";
				$this->user_model->update($row->id,array("pass_key"=>"","pass_key_expire"=>NULL,"password"=>$password));
			}else{
				$allow=1;
				$this->view_data['msg']="<div class='alert alert-danger'>".$this->lang->line('reset_password_error')."</div>";
			}

			
			
		}
		$this->view_data['allow']=$allow;

	}// reset password 


	public function login()
	{
		
		$this->view_data['title'] =$this->lang->line('login_page_title');

		$this->view_data['menu'] = "Login";	

		$this->view_data['back_button']=base_url(); 
		$this->view_data['city_list']=$this->product_model->get_city_list_names();
		$this->view_data['msg']="";
		$this->view_data['popup_ids']=getPopupIds(array("page_name"=>"Login","popup_type"=>"2"));

		if(validateLogin()!=false)
		{

			if(trim($this->session->userdata("phone_number")==""))
				{
					$this->session->set_flashdata('mobile_num_error', $this->lang->line('phone_require_onboard'));
					redirect(base_url("my-account"));

					//$this->lang->line('phone_require_onboard')
				}

			if(!empty($this->session->userdata("ref")))
			{
				redirect(base_url($this->session->userdata("ref")));
			}else{
				redirect(base_url());
			}
		}

		$post=$this->input->post();
		if(!empty($post['inp_reg_email']) && !empty($post['inp_reg_pass']))
		{
			$email=$this->input->post("inp_reg_email",TRUE);
			$pass=$this->input->post("inp_reg_pass");
			$is_valid=$this->user_model->check_login(array("email"=>$email,"password"=>$pass));
			if($is_valid==false)
			{
				$this->view_data['msg']="<div class='alert alert-danger'>".$this->lang->line('invalid_login')."</div>";	
			}else{

						$userdata=$this->user_model->get_profile($is_valid);
                        $userdata=(array)$userdata;
                        $this->session->set_userdata($userdata);
                        

                        $data['data']=$userdata; 
                        $data['data']['user_id']=$userdata['id'];
                        $data['data']['name']=$userdata['fname'];
                        $data['data']['phone_no']=$userdata['phone_number'];
                        $data['data']['email']=$userdata['email'];
                        $data['data']['is_login']="1";
                        $data['data']['cntCode']=$post["countryCode_list"];
                      
                        $this->input->set_cookie(array('name' =>'user_id','value' =>$userdata['id'],'expire'=>'999600'));
                      
                        $this->input->set_cookie(array('name' =>'name','value' =>$userdata['fname'],'expire'=>'999600'));
                       
                        $this->input->set_cookie(array('name' =>'phone_no','value' =>$userdata['phone_number'],'expire'=>'999600'));
                        
                        $this->input->set_cookie(array('name' =>'is_login','value' =>"1",'expire'=>'999600'));
                        
                        $this->input->set_cookie(array('name' =>'cntCode','value' =>$post["countryCode_list"],'expire'=>'999600'));
					$this->session->set_userdata("p","1");

					if(trim($this->session->userdata("phone_number")==""))
					{
						$this->session->set_flashdata('mobile_num_error', $this->lang->line('phone_require_onboard'));
						redirect(base_url("my-account"));

						//$this->lang->line('phone_require_onboard')
					}
				if(!empty($this->session->userdata("ref")))
				{
					redirect(base_url($this->session->userdata("ref")));
				}else{
					redirect(base_url());
				}
			}
		}

	}//Login 


	public function register()
	{
		
		$this->view_data['title'] = $this->lang->line('register_page_title');

		$this->view_data['menu'] = "Register";	

		$this->view_data['back_button']=base_url(); 
		$this->view_data['city_list']=$this->product_model->get_city_list_names();
		$this->view_data['msg']="";
		$this->view_data['popup_ids']=getPopupIds(array("page_name"=>"Register","popup_type"=>"2"));
		if(validateLogin()!=false)
		{

			if(trim($this->session->userdata("phone_number")==""))
				{
					$this->session->set_flashdata('mobile_num_error', $this->lang->line('phone_require_onboard'));
					redirect(base_url("my-account"));

					//$this->lang->line('phone_require_onboard')
				}

			if(!empty($this->session->userdata("ref")))
			{
				redirect(base_url($this->session->userdata("ref")));
			}else{
				redirect(base_url());
			}
		}

	}//Login 

	public function login_old()
	{
		
		$this->view_data['title'] = $this->lang->line('login_register');

		$this->view_data['menu'] = "Home";	

		$this->view_data['back_button']=base_url(); 
		$this->view_data['city_list']=$this->product_model->get_city_list_names();
		$this->view_data['msg']="";

		if(!empty($this->input->post("register")))
		{
			$post=get_post_data();
			$exists=$this->user_model->check_duplicate_email($post['regi_email']);
			if($exists==1)
			{
				$this->view_data['msg']=error_msg_html($this->lang->line('email_already_register'));
			}else{
				$ins=array();
				$ins['email']=$post['regi_email'];
				$ins['password']=md5($post['regi_password']);
				$ins['ip_registered']=$this->input->ip_address();
				$id=$this->user_model->add($ins);
				if($id!=false)
				{
					$this->view_data['msg']=success_msg_html($this->lang->line('register_success')." ".$this->lang->line('click_to_login'));
				}else{
					$this->view_data['msg']=error_msg_html($this->lang->line('error_in_register'));	
				}
			}
			
		}

		if(!empty($this->input->post("login")))
		{
			$post=get_post_data();
			$post['email']=$post['login_email'];
			$post['password']=$post['login_password'];
			$check_login=$this->user_model->check_login($post);
			if($check_login==false)
			{
				$this->view_data['msg']=error_msg_html($this->lang->line('invalid_login'));	
			}else{
				$userdata=$this->user_model->get_profile($check_login);
				$userdata=(array)$userdata;
				$this->session->set_userdata($userdata);
				if(!empty($this->input->get("ref")))
				{
					redirect(base_url($this->input->get("ref")));
				}else{
					redirect(base_url("my-account?p=1"));
				}
			}
			
		}

	}//Login

	public function logout()
	{
		$this->session->sess_destroy();
		redirect(base_url("Login"));
	}

	public function my_account()
	{
		
		$check_login=validateLogin();
		if($check_login==false)
			redirect(base_url());
		$this->view_data['title'] = $this->lang->line('my_account_page_title');
		$this->view_data['menu'] = "my-account";
		$this->view_data['back_button']=base_url(); 
		$this->view_data['city_rows']=$this->product_model->get_city_rows();
		$this->view_data['city_list']=$this->product_model->get_city_list_names();
		$this->view_data['extra_js']=$this->load->view('User/address.js', array(), true);
		$this->view_data['msg']="";
		$popup_ids=getPopupIds(array("page_name"=>"my-account","popup_type"=>"2"));
		
		if(!empty($this->input->get("p")))
		{
			if($this->input->get("p")!="")
			{
				$extra_ids=getPopupIds(array("popup_type"=>$this->input->get("p",TRUE)));		
				if($extra_ids!="")
				{
						if($popup_ids=="")
						{
							$popup_ids=$extra_ids;
						}else{
							$popup_ids.=",".$extra_ids;
						}
				}
			}
		}
		

		$this->view_data['popup_ids']=$popup_ids;
		

		
		if(!empty($this->input->post("btn_update")))
		{
			$post=get_post_data();
			$ins=array();
			$ins['fname']=$post['fname'];
			$ins['lname']=$post['lname'];
			//$ins['email']=$post['email'];
			$ins['phone_number']=$post['phone_number'];
			$ins['address']=$post['address'];
			$ins['postal_code']=$post['postal_code'];
			$ins['city_id']=$post['city'];
			
			$updated=$this->user_model->update($this->session->userdata("id"),$ins);
			
			$this->session->set_userdata("phone_number",$post['phone_number']);
			
			$this->view_data['msg']=success_msg_html($this->lang->line('profile_updated'));	
				
		}

		if(!empty($this->input->post("btn_change_password")))
		{
			$post=get_post_data();
			$ins=array();

			$check_pass=$this->user_model->check_pass($this->session->userdata("id"),$post['old_password']);
			if($check_pass==false)
			{
				$this->view_data['msg']=success_msg_html($this->lang->line('invalid_old_password'));	
			}else{
				$ins['password']=md5($post['cnf_password']);
				$updated=$this->user_model->update($this->session->userdata("id"),$ins);
				$this->view_data['msg']=success_msg_html($this->lang->line('profile_updated'));	
			}
				
		}



		$this->view_data['profile']=$this->user_model->detail($this->session->userdata("id"));
		$orders=$this->user_model->get_orders($this->session->userdata("id"));
		$this->view_data['orders']=$orders;
		$html="";
		if($orders)
		{
			foreach ($orders as $ord) {
				$items=$this->user_model->get_order_items($ord['id']);
				$para=array();
				$para['row']=$ord;
				$para['items']=$items;
				
				$html.=$this->load->view('templetes/order_card', $para, true);
			}
		}
		$this->view_data['order_html']=$html;
		$this->view_data['city_list']=$this->user_model->get_city_list();
		$this->view_data['city_name_list']=$this->user_model->get_city_list_name();
		$this->view_data['card_list']=$this->user_model->get_card_list($this->session->userdata("id"));
		$this->view_data['address_list']=$this->user_model->get_address_list($this->session->userdata("id"));
		
		
	}//MY Account



}//class

?>