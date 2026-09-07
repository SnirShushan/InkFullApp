<?php
defined('BASEPATH') or exit('No direct script access allowed');

class Setting extends MY_Controller
{

	public function __construct()
	{
		parent::__construct();
		$this->auth->valid_login();

		$this->load->model("settings_model");
		$this->load->library('Cropimg');
	}

	public function index()
	{

		$detail_settings = $this->settings;

		if (!empty($this->input->post('btn_update'))) {
			$post = $this->input->post();
			

			$update = array();
			$update['field_value'] = $post['admin_email'];
			$update = $this->settings_model->update_settings("admin_email", $update);

			$update = array();
			$update['field_value'] = $post['admin_phone'];
			$update = $this->settings_model->update_settings("admin_phone", $update);

			set_flashdata('msg', 'Update Successfully..');
			redirect(base_url("Setting"));
		}

		if ($this->input->post('btn_image_update')) 
		{
			$created_dt = date("Y-m-d H:i:s");
            if(!empty($_FILES['startup_image']['name'])){
                $config['upload_path'] = '../assets/uploads';
                $config['allowed_types'] = "jpg|jpeg|png|gif";
                $config['file_name'] = md5($created_dt)."_".$_FILES['startup_image']['name'];
    
                $this->load->library('upload',$config);
                $this->upload->initialize($config);

				if (!$this->upload->do_upload('startup_image')) {
					$error = array('error' => $this->upload->display_errors());
				} else {
					if (file_exists('../assets/uploads/' . $detail_settings['startup_image'])){
						unlink('../assets/uploads/' . $detail_settings['startup_image']);
					}
					$data = array('upload_data' => $this->upload->data());
					$data = $this->upload->data();
					$data1 = array();
					$file_name = $data['file_name'];
					$update = array();
					$update['field_value'] = $file_name;
					$file_name = "startup_image";
					$update = $this->settings_model->update_settings($file_name, $update);
					set_flashdata('msg', 'Image Update Successfully..');
					redirect(base_url("Setting"));
				}
				$this->view_data['error'] = "";
				$this->view_data['data'] = $this->upload->data();
				$this->view_data['error'] = $this->upload->display_errors();
				set_flashdata('Error', $this->upload->display_errors());
				redirect(base_url("Setting"));
            }else{
                $startup_image = '';
                if($startup_image == ''){
                    set_flashdata('Error', 'Please Upload Image');
					redirect(base_url("Setting"));
                }
            }
		}
		
		if($this->input->post('btn_update_package_name'))
		{
			$post = $this->input->post();

			$update = array();
			$update['field_value'] = $post['package_name'];
			$update = $this->settings_model->update_settings("package_name", $update);

			set_flashdata('msg', 'Update Successfully..');
			redirect(base_url("Setting"));
		}

		if($this->input->post('btn_update_post_limit'))
		{
			$post = $this->input->post();

			$update = array();
			$update['field_value'] = $post['post_limit'];
			$update = $this->settings_model->update_settings("post_limit", $update);

			set_flashdata('msg', 'Post Limit Update Successfully..');
			redirect(base_url("Setting"));
		}

		
		$this->view_data['title'] = "System Setting";
		$this->view_data['menu'] = "Setting";
		$this->view_data['page_heading'] = "System Setting";
		$this->view_data['page_sub_heading'] = "";
		$this->view_data['arr_breadcrumb'] = array("Home" => base_url());
		$this->view_data['breadcrumb_home_logo'] = '<i class="icon-home"></i>';
		$this->view_data['setting'] = $this->settings;
	}



	public function index1()
	{
		exit;
		$this->view_data['title'] = "System Setting";
		$this->view_data['menu'] = "Setting";
		$this->view_data['page_heading'] = "System Setting";
		$this->view_data['page_sub_heading'] = "";
		$this->view_data['arr_breadcrumb'] = array("Home" => base_url());
		$this->view_data['breadcrumb_home_logo'] = '<i class="icon-home"></i>';
		$this->view_data['Setting'] = $this->settings;
		$detail_settings = $this->settings;

		$post = $this->input->post();
		if (isset($post['logo_save'])) {
			if (isset($_FILES['logo']['name']) && !empty($_FILES['logo']['name'])) {
				$config['upload_path']          = './assets/upload/';
				$config['allowed_types']        = 'gif|jpg|png|jpeg';
				$config['max_size']             = (1024 * 20);
				$config['min_width']  = '200';
				$config['min_height']  = '200';
				$new_name = time() . rand();
				$config['file_name'] = $new_name;
				$this->load->library('upload', $config);
				$this->upload->initialize($config);
				$config = array();
				if (!$this->upload->do_upload('logo')) {
					$error = array('error' => $this->upload->display_errors());
				} else {
					unlink('./assets/upload/' . $detail_settings['app_logo']);
					$data = array('upload_data' => $this->upload->data());
					$data = $this->upload->data();
					$data1 = array();
					$file_name = $data['file_name'];
					$update = array();
					$update['field_value'] = $file_name;
					$file_name = "app_logo";
					$update = $this->settings_model->update_settings($file_name, $update);
					set_flashdata('msg', 'Logo Update Successfully..');
					redirect(base_url("Setting"));
				}
				$this->view_data['error'] = "";
				$this->view_data['data'] = $this->upload->data();
				$this->view_data['error'] = $this->upload->display_errors();
				set_flashdata('Error', $this->upload->display_errors());
				redirect(base_url("Setting"));
			}
		}
		if (isset($post['logo_save_fev'])) {
			if (isset($_FILES['fevlogo']['name']) && !empty($_FILES['fevlogo']['name'])) {
				$config['upload_path']          = './assets/upload/';
				$config['allowed_types']        = 'ico|png';
				$config['max_size']             = (1024 * 20);
				$config['min_width']  = '200';
				$config['min_height']  = '200';
				$new_name = time() . rand();
				$config['file_name'] = $new_name;
				$this->load->library('upload', $config);
				$this->upload->initialize($config);
				$config = array();
				if (!$this->upload->do_upload('fevlogo')) {
					$error = array('error' => $this->upload->display_errors());
				} else {
					unlink('./assets/upload/' . $detail_settings['favicon']);
					$data = array('upload_data' => $this->upload->data());
					$data = $this->upload->data();
					$data1 = array();
					$file_name = $data['file_name'];
					$update = array();
					$update['field_value'] = $file_name;
					$file_name = "favicon";
					$update = $this->settings_model->update_settings($file_name, $update);
					set_flashdata('msg', 'Favicon Update Successfully..');
					redirect(base_url("Setting"));
				}
				$this->view_data['error'] = "";
				$this->view_data['data'] = $this->upload->data();
				$this->view_data['error'] = $this->upload->display_errors();
				set_flashdata('Error', $this->upload->display_errors());
				redirect(base_url("Setting"));
			}
		}
		if (isset($post['submit_appname'])) {
			$update = array();
			$update['field_value'] = $post['app_name'];
			$file_name = "name";
			$update = $this->settings_model->update_settings($file_name, $update);
			set_flashdata('msg', 'Site Name Update Successfully..');
			redirect(base_url("Setting"));
		}

		if (isset($post['submit_footer'])) {
			$update = array();
			$update['field_value'] = $post['footer_text'];
			$file_name = "footer_text";
			$update = $this->settings_model->update_settings($file_name, $update);
			set_flashdata('msg', 'Footer Text Update Successfully..');
			redirect(base_url("Setting"));
		}

		if (isset($post['submit_theam_color'])) {
			/* 
			1 default
			2 darkblue
			3 blue
			4 grey
			5 light2
			*/
			$color_selected = array(
				'1' => "default",
				'2' => "darkblue",
				'3' => "blue",
				'4' => "grey",
				'5' => "light2",
				'6' => "custom"
			);
			if ($post['theam_color'] > 6 || $post['theam_color'] < 0) {
				die();
			}
			$update = array();
			$update['field_value'] = $color_selected[$post['theam_color']];
			$file_name = "theam_color";
			$update = $this->settings_model->update_settings($file_name, $update);
			set_flashdata('msg', 'Theam Update Successfully..');
			redirect(base_url("Setting"));
		}
		if (isset($post['submit_sucsess_color'])) {
			$color_selected = array(
				'1' => "green-jungle",
				'2' => "yellow-gold",
				'3' => "purple",
				'4' => "blue",
				'5' => "yellow-mint",
				'6' => "green-haze"
			);
			if ($post['button_color'] > 6 || $post['button_color'] < 0) {
				die();
			}
			$update = array();
			$update['field_value'] = $color_selected[$post['button_color']];
			$file_name = "success_color";

			$update = $this->settings_model->update_settings($file_name, $update);
			//die();
			set_flashdata('msg', 'Button Update Successfully..');
			redirect(base_url("Setting"));
		}
		if (isset($post['submit_denger_color'])) {
			$color_selected = array(
				'1' => "red",
				'2' => "red-thunderbird",
				'3' => "red-mint",
				'4' => "red-haze",
				'5' => "yellow-mint",
				'6' => "red-soft"
			);
			if ($post['danger_button_color'] > 6 || $post['danger_button_color'] < 0) {
				die();
			}
			$update = array();
			$update['field_value'] = $color_selected[$post['danger_button_color']];
			$file_name = "danger_color";
			$update = $this->settings_model->update_settings($file_name, $update);
			set_flashdata('msg', 'Button Update Successfully..');
			redirect(base_url("Setting"));
		}
		if (isset($post['submit_warning_color'])) {
			// print_r($post);
			// die();
			$color_selected = array(
				'1' => "yellow-crusta",
				'2' => "yellow-soft",
				'3' => "yellow-casablanca",
				'4' => "grey-salt",
				'5' => "yellow-mint",
				'6' => "grey-mint"
			);
			if ($post['warning_button_color'] > 6 || $post['warning_button_color'] < 0) {
				die();
			}
			$update = array();
			$update['field_value'] = $color_selected[$post['warning_button_color']];
			$file_name = "warning_button_color";
			$update = $this->settings_model->update_settings($file_name, $update);
			set_flashdata('msg', 'Warning Update Successfully..');
			redirect(base_url("Setting"));
		}
		if (isset($post['theme_direction'])) {
			//print_r($post);

			$direction_selected = array(
				'1' => "layout/default",
				'2' => "layout/ltf_default"
			);
			$update = array();
			$update['field_value'] = $direction_selected[$post['direction']];
			$file_name = "layout";
			// print_r($update);
			// die();
			$update = $this->settings_model->update_settings($file_name, $update);
			set_flashdata('msg', 'Direction Update Successfully..');
			redirect(base_url("Setting"));
		}

		//submit_denger_color
	} // index method

	public function Personal()
	{

		// $this->view_data['title'] = "Personal Setting";
		// $this->view_data['menu'] = "Setting";
		// $this->view_data['page_heading']="Personal Setting";
		// $this->view_data['page_sub_heading']="";
		// $this->view_data['arr_breadcrumb']=array("Home"=>base_url());
		// $this->view_data['breadcrumb_home_logo']='<i class="icon-home"></i>';

		//print_r($this->session->userdata("role_id")); 
		// print_r($all_role->result());

		$this->view_data['title'] = "Profile Settings";
		$this->view_data['menu'] = "Setting_";
		$this->view_data['page_heading'] = "Profile Settings";
		$this->view_data['page_sub_heading'] = "";
		$this->view_data['arr_breadcrumb'] = array("Home" => base_url());
		$this->view_data['breadcrumb_home_logo'] = '<i class="icon-home"></i>';
		$this->view_data['Setting'] = $this->settings;
		$this->view_data['back_button'] = base_url();
		$detail_settings = $this->settings;

		$post = $this->input->post();
		if (isset($post['logo_save'])) {
			$update_data = array();
			if (isset($_FILES['logo']['name']) && !empty($_FILES['logo']['name'])) {
				$config['upload_path']          = './assets/upload/';
				$config['allowed_types']        = 'gif|jpg|png|jpeg';
				$config['max_size']             = (500 * 500);
				$config['min_width']  = '200';
				$config['min_height']  = '200';
				$new_name = time() . rand();
				$config['file_name'] = $new_name;
				$this->load->library('upload', $config);
				$this->upload->initialize($config);
				$config = array();
				if (!$this->upload->do_upload('logo')) {
					$error = array('error' => $this->upload->display_errors());
				} else {
					//unlink('./assets/upload/'.$detail_settings['app_logo']);
					//$data = array('upload_data' => $this->upload->data());
					$data = $this->upload->data();
					$data1 = array();
					//$file_name = $data['file_name'];
					$update_data['profile_image'] = $data['file_name'];
					//$update=array();
					//$update['field_value']=$file_name;
					//$file_name="app_logo";
					//$update=$this->settings_model->update_settings($file_name,$update);
				}
				$this->view_data['error'] = "";
				$this->view_data['data'] = $this->upload->data();
				$this->view_data['error'] = $this->upload->display_errors();
				if (isset($update_data['profile_image']) && ($update_data['profile_image'] != "")) {

					$this->session->set_userdata('profile_image', $update_data['profile_image']);
				}
			}

			$update_data['name'] = $this->input->post("profile_name", TRUE);
			$this->auth->update_profile($update_data, $this->session->userdata("userid"));
			// $this->session->userdata("profile_name")
			$this->session->set_userdata('profile_name', $update_data['name']);
			set_flashdata('message', 'Updated Profile Name Successfully');
		}
		$this->view_data['profile'] = $this->auth->get_profile($this->session->userdata("userid"));
	}
}
