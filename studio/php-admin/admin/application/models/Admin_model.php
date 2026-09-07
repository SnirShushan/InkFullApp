<?php
defined('BASEPATH') OR exit('No direct script access allowed');
/*
	This is user login system model
	And add update user functions
*/
class admin_model extends CI_Model
{
	public function __construct()
	{
		parent:: __construct();
		$this->load->helper('My');
	}


	/*--START LOGIN SYSTEM------------------------------------------------*/

		public function is_login()
		{
			$id = $this->session->userdata("userid");
			if( intval($id) > 0 ){
				return true;
			}
			return false;

			/*$AppName = ($this->session->userdata("appname") == $this->settings['name'])?true:false;
			//return (intval($AppName)>0)?true:false;
			if(!$AppName){
				return (intval($AppName)>0)?true:false;
			}
			else 
			{
				$id = $this->session->userdata("userid");
				return (intval($id)>0)?true:false;
			}*/
		}

		public function valid_login()
		{
			if($this->session->userdata())
			{

				$id = $this->session->userdata("userid");
				$is_login = (intval($id)>0)?true:false ;
				if(!$is_login){
					redirect( base_url("login") );
					exit();
				}

				/*$AppName = ($this->session->userdata("appname") == $this->settings['name'])?true:false;
				$id = $this->session->userdata("userid");
				$is_login = (intval($id)>0)?true:false ;
				if(!$AppName){
					redirect( base_url("login") );
					exit();
				}
				if(!$is_login){
					redirect( base_url("login") );
					exit();
				}*/
			}
		}

		public function valid_login_ajax()
		{
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
				}
			}
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

				//set data in session
				$ip=$this->input->ip_address();
				$date=date('Y-m-d H:i:s');
				$db_result = $query_result->result_array()[0];
				$update_login=$this->db->query("UPDATE `tbl_admin` SET `last_login_ip`='".$ip."',`last_login_date`='".$date."' where id='".$db_result['id']."'");
				$userid = $db_result['id'];
				$username = $db_result['name'];
				$useremail = $db_result['email'];
				
				$this->session->set_userdata( array("appname"=>$this->settings['name'],"userid"=>$userid,"useremail"=>$useremail , "username" => $username,"profile_name"=>$username,"profile_image"=>$db_result['profile_image'] ));
				Add_log("login ".$useremail);
				$result['status'] = true;
			}else{
				$result['message'] = "You are not authorised to login";
				set_flashdata('msg', 'You are not authorised to login..');
			}

			return $result;
		}

	/*--STOP LOGIN SYSTEM------------------------------------------------*/


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
