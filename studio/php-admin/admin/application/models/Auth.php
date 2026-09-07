<?php
defined('BASEPATH') OR exit('No direct script access allowed');
/*
	This is user login system model
	And add update user functions
*/
class auth extends CI_Model
{
	public function __construct()
	{
		parent:: __construct();
		$this->load->helper('My');
	}


	/*--START LOGIN SYSTEM------------------------------------------------*/

		public function is_login()
		{
			$this->ensure_local_login();
			$id = $this->session->userdata("userid");
			if( intval($id) > 0 ){
				return true;
			}
			return false;
		}

		public function valid_login()
		{
			$this->ensure_local_login();
			if($this->session->userdata())
			{

				$id = $this->session->userdata("userid");
				$is_login = (intval($id)>0)?true:false ;
				if(!$is_login){
					redirect( base_url("login") );
					exit();
				}else{
					$this->update_login_user_access();
				}
			}
		}

		public function valid_login_ajax()
		{
			$this->ensure_local_login();
			if($this->session->userdata())
			{
				$id = $this->session->userdata("userid");
				$is_login = (intval($id)>0)?true:false ;
				if(!$is_login){
					echo json_encode([
						'status'=>false,
						'msg'=>"Invalid login"
					]);
					exit();
				}else{
					$this->update_login_user_access();
				}
			}
		}

		protected function ensure_local_login()
		{
			if (!function_exists('is_local_admin_request') || !is_local_admin_request()) {
				return false;
			}
			if (intval($this->session->userdata("userid")) > 0) {
				return true;
			}

			$row = $this->db->query("SELECT * FROM tbl_admin WHERE status = 1 ORDER BY CASE WHEN role_name = 'supper_admin' THEN 0 ELSE 1 END, id ASC LIMIT 1");
			if (!$row || $row->num_rows() < 1) {
				return false;
			}
			$this->apply_admin_session($row->row_array(), false);
			return true;
		}

		protected function apply_admin_session($db_result, $touch_login_meta = true)
		{
			$CI = &get_instance();
			$app_name = 'Ink';
			if (isset($CI->settings['name']) && $CI->settings['name'] !== '') {
				$app_name = $CI->settings['name'];
			}

			$role = $db_result['role_name'];
			$access_id = $db_result['access_id'];
			$is_admin = ($role == "supper_admin");

			if ($touch_login_meta) {
				$ip = $this->input->ip_address();
				$date = date('Y-m-d H:i:s');
				$this->db->query("UPDATE `tbl_admin` SET `last_login_ip`='".$this->db->escape_str($ip)."',`last_login_date`='".$date."' where id='".$this->db->escape_str($db_result['id'])."'");
			}

			$this->session->set_userdata(array(
				"appname" => $app_name,
				"userid" => $db_result['id'],
				"useremail" => $db_result['email'],
				"username" => $db_result['name'],
				"profile_name" => $db_result['name'],
				"profile_image" => $db_result['profile_image'],
				"role" => $role,
				"access" => array(),
				"access_id" => $access_id,
				"is_admin" => $is_admin,
			));
			return true;
		}

		/*public function get_role()
		{
			return $this->session->userdata();
		}*/

		//this function is logout 
		public function logout()
		{
			Add_log("LOGOUT");
			$this->session->unset_userdata('profile_image');
			$this->session->unset_userdata('profile_name');
			$this->session->unset_userdata('appname');
			$this->session->unset_userdata('userid');
			$this->session->unset_userdata('useremail');
			$this->session->unset_userdata('username');

			$this->session->unset_userdata('role');
			$this->session->unset_userdata('access');
			$this->session->unset_userdata('access_id');
			$this->session->unset_userdata('is_admin');

			session_destroy();
			redirect(base_url("login"));
		}

		public function change_password( $old_password, $new_password )
		{
			$result = array();
			$result['status'] = false;
			$result['message'] = "";

			$old_password = md5($old_password);
			$new_password = md5($new_password);

			$useremail = $this->session->userdata("useremail");
			$old_pass_result = $this->db->query("SELECT * FROM tbl_admin WHERE email = '".$this->db->escape_str($useremail)."' and password = '".$this->db->escape_str($old_password)."' ");
			if( $old_pass_result->num_rows() == 1 ){

				$this->db->where("email",$useremail);
				$this->db->where("password",$old_password);
				$res = $this->db->update("tbl_admin",[ "password" => $new_password ]);

				if( $res ){
					$result['message'] = "Successfully password changed";
					$result['status'] = true;
				}
			}else{
				$result['message'] = "Old password wrong";
			}

			return $result;
		}

		public function reset($email,$key,$new_password)
		{
			$result = array();
			$result['status'] = false;
			$result['message'] = "";

			//$key = md5($key);
			$new_password = md5($new_password);

			// $useremail = $this->session->userdata("useremail");
			$useremail = $email;
			$old_pass_result = $this->db->query("SELECT * FROM tbl_admin WHERE email = '".$this->db->escape_str($useremail)."' and psw_key = '".$this->db->escape_str($key)."' LIMIT 1");
			// echo "SELECT * FROM tbl_admin WHERE email = '".$this->db->escape_str($useremail)."' and psw_key = '".$this->db->escape_str($key)."' LIMIT 1";
			//print_r($old_pass_result);
			//die();
			if( $old_pass_result->num_rows() == 1 ){

				$this->db->where("email",$useremail);
				$this->db->where("psw_key",$key);
				$res = $this->db->update("tbl_admin",["password" => $new_password ,"psw_key" => ""]);

				if( $res ){
					$result['message'] = "Successfully password changed";
					$result['status'] = true;
				}
			}else{
				$result['message'] = "Key password wrong";
			}

			return $result;
		}


		//login user if true login so Set session in data
		public function login($data)
		{
			$result = array();
			$result['status'] = false;
			$result['message'] = "";

			$data["password"] = md5($data["password"]);

			$this->db->where("email",$data["email"]);
			$this->db->where("password",$data["password"]);
			$this->db->where("status",1);
			$this->db->limit(1);

			$query_result = $this->db->get("tbl_admin");
			if($query_result->num_rows()>0){
				$db_result = $query_result->result_array()[0];
				$this->apply_admin_session($db_result, true);
				Add_log("login ".$db_result['email']);
				$result['status'] = true;
			}else{
				$result['message'] = "You are not authorised to login";
				set_flashdata('msg', 'You are not authorised to login..');
			}

			return $result;
		}

		public function update_login_user_access(){
			$aid = $this->get_current_user_id();

			$has_update = intval($this->db->query("SELECT count(*) as count FROM tbl_admin as a WHERE a.id = '$aid' and a.access_update = 'Y' LIMIT 1")->result()[0]->count);


			if( $has_update == 0 ){ return false; }

			$user = $this->db->query("SELECT * FROM tbl_admin as a WHERE a.id = '$aid'  LIMIT 1");

			$db_result = $user->result_array()[0];


				$role = $db_result['role_name'];
				$access_id = $db_result['access_id'];
				$is_admin=false;
				$access = [];

				if( $role == "supper_admin" ){
					$is_admin=true;
				}else{
					$is_admin=false;
				}

				//get access level params
				$acl_access = [];
				if( $access_id != "" && $access_id != "[]"  ){
					$ids = implode(",",json_decode($access_id,true));
					$action_codes = $this->db->query("SELECT GROUP_CONCAT(action_code) as action_codes from tbl_acl_action WHERE id IN ( $ids );")->result()[0]->action_codes;
					$acl_access = [];
					if($action_codes != null && $action_codes != "" ){
						$acl_access = explode(",",$action_codes);
					}
				}else{ $acl_access = []; }

				$access = $acl_access;

				$update_login=$this->db->query("UPDATE `tbl_admin` SET access_update = 'N' where id='".$db_result['id']."' LIMIT 1 ");

				$userid = $db_result['id'];
				$username = $db_result['name'];
				$useremail = $db_result['email'];

				$this->session->set_userdata( array("appname"=>$this->settings['name'],"userid"=>$userid,"useremail"=>$useremail , "username" => $username,"profile_name"=>$username,"profile_image"=>$db_result['profile_image'] ,
					"role" => $role,
					"access" => $access,
					"access_id" => $access_id,
					"is_admin" => $is_admin,
				));

		}


		public function get_current_user_id()
		{
			$id = intval($this->session->userdata("userid"));
			return $id;
		}

		//this function is logout 
		public function get_role()
		{
			return $this->session->userdata("role");
		}

		public function getUserData($name=''){
			$data = $this->session->userdata();
			if( $name != "" ){
				return isset($data[$name])?$data[$name]:'';
			}
			return $data;
		}

		public function getAccess(){
			return $this->session->userdata("access");
		}

		public function redirect_dashboard()
		{
			if( $this->is_login() == true ){
				if( $this->get_role() == "supper_admin" ){
					redirect(base_url('ManageUsers'));
				}else if( $this->get_role() == "admin" ){
					redirect(base_url('ManageFeeds'));
				}else{
					redirect(base_url('Dashboard'));
				}
			}
		}

	/*--STOP LOGIN SYSTEM------------------------------------------------*/

	public function getUserAccessArray()
	{
		$json = [
			'_role'=> $this->get_role()
		];
		
		$acl = $this->getAccess();
		if(is_array($acl)){
			foreach ($acl as $key => $value) {
				$json[$value]=true;
			}
		}

		return $json;
	}
	

		public function get_profile($id)
		{
			$result=$this->db->query("select * from tbl_admin where id='$id' LIMIT 1");
			if($result)
			{
				if($result->num_rows()>0)
				{
					$row=$result->result();
					return $row[0];
				}
			}
		}
		////get profile detail 

		public function update_profile($data,$id)
		{
				$this->db->where("id",$id);
				$res = $this->db->update("tbl_admin",$data);
		}


}
