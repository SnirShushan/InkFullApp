<?php
defined('BASEPATH') OR exit('No direct script access allowed');

class user_model extends CI_Model
{
	public function __construct()
	{
		parent:: __construct();
	}


	public function get_orders($id)
	{
		$docs = $this->db->where("uid",$id)->get("tbl_orders");
		if( $docs->num_rows() > 0 ){
			return $docs->result_array();
		}
		return false;
	}// get user orders detail

	public function get_order_items($id)
	{
		$docs = $this->db->where("order_id",$id)->get("tbl_order_items");
		if( $docs->num_rows() > 0 ){
			return $docs->result_array();
		}
		return false;
	}// get user orders detail items

	public function order_detail($id)
	{
		$result = $this->db->where("id",$id)->get("tbl_orders");
		if( $result->num_rows() > 0 ){
			return $result->result_array()[0];
		}
		return false;
	}


	public function update_user_detail($uid,$data){
		$data['date_updated'] = date('Y-m-d H:i:s');
		$res = $this->db->where("id",$uid)->limit(1)->update('tbl_users',$data);
		return $res;
	}


	public function GetUserDetail($uid)
	{
		$res = $this->db->where("id",$uid)->limit(1)->get('tbl_users');
		if($res->num_rows() > 0){
			return $res->result_array()[0];
		}
		return false;
	}

	public function isExistEmail($email,$skip_uid_check='')
	{
		$sql="";
		if($skip_uid_check != ""){
			$sql = "SELECT count(*) as total FROM tbl_users WHERE email = '$email' AND id != '$skip_uid_check' LIMIT 1";
		}else{
			$sql = "SELECT count(*) as total FROM tbl_users WHERE email = '$email' LIMIT 1";
		}
		$total = $this->db->query($sql)->result_array()[0]['total'];
		return (($total > 0)?true:false);
	}

	public function isExistPhoneNumber($phone_number,$skip_uid_check='')
	{
		$sql="";
		if($skip_uid_check != ""){
			$sql = "SELECT count(*) as total FROM tbl_users WHERE phone_number = '$phone_number' AND id != '$skip_uid_check' LIMIT 1";
		}else{
			$sql = "SELECT count(*) as total FROM tbl_users WHERE phone_number = '$phone_number' LIMIT 1";
		}
		$total = $this->db->query($sql)->result_array()[0]['total'];
		return (($total > 0)?true:false);		
	}


	/*- -- start country model -- -*/

	public function getCountryList()
	{
		$list = $this->db->query(" SELECT * FROM tbl_country ");
		if( $list->num_rows() > 0 ){
			return $list->result();
		}
		return false;
	}

	public function addCountry($data)
	{
		$r = $this->db->insert("tbl_country", $data);
		if($r){
			return $this->db->insert_id();
		}else{
			return false;
		}
	}

	public function getCountryDetail($id)
	{
		$list = $this->db->query(" SELECT * FROM tbl_country WHERE id = '$id' LIMIT 1");
		if( $list->num_rows() > 0 ){
			return $list->result()[0];
		}
		return false;
	}

	public function updateCountryDetail($id,$data)
	{
		$this->db->where("id",$id);
		$this->db->limit(1);
		$r = $this->db->update("tbl_country", $data);
		return $r;
	}

	public function deleteCountry($id)
	{
		$this->db->where("id",$id);
		$this->db->limit(1);
		$r = $this->db->delete("tbl_country");
		return $r;
	}

	public function isExistCountryName($countryName,$skip_uid_check='')
	{
		$sql="";
		if($skip_uid_check != ""){
			$sql = "SELECT count(*) as total FROM tbl_country WHERE country_name = '$countryName' AND id != '$skip_uid_check' LIMIT 1";
		}else{
			$sql = "SELECT count(*) as total FROM tbl_country WHERE country_name = '$countryName' LIMIT 1";
		}
		$total = $this->db->query($sql)->result_array()[0]['total'];
		return (($total > 0)?true:false);
	}

	/*- -- end country model -- -*/

	public function getPushNotificationUserTokens()
	{
		$result = [
			"android" => [],
			"ios" => [],
		];

		$sql_and = $this->db->query("SELECT id, udid FROM tbl_users WHERE push_on ='1' AND status ='1' AND device_type ='a' AND is_delete = '0' ");
		if( $sql_and->num_rows() > 0 ){
			$result['android'] = $sql_and->result();
		}


		$sql_ios = $this->db->query("SELECT u.id, u.udid, (SELECT COUNT(*) FROM tbl_user_notification as n WHERE n.uid = u.id LIMIT 1) as badge FROM tbl_users as u WHERE u.push_on ='1' AND u.status ='1' AND u.device_type ='i' AND u.is_delete = '0' ");
		if( $sql_ios->num_rows() > 0 ){
			$result['android'] = $sql_ios->result();
		}
		//

		return $result;
	}


	public function sendNotificationUserByFilter($msg,$page_id,$country_ids="",$facility_ids="")
	{
		require_once BASEPATH.'../../PUSH/push_notification.php';
		
		$result = ['status'=>true,'error'=>'Error in send push notification try again','count'=>0,'ios'=>[],'android'=>''];

		$page_title="";
		$page_t = $this->db->query("SELECT id,name FROM tbl_pages WHERE id ='$page_id' LIMIT 1");
		if( $page_t->num_rows()>0 ){
			$page_title = $page_t->result()[0]->name;
		}

		$push=[
			"action_type"=>"PageNotification",
			"page_id"=>$page_id,
			"page_title"=>$page_title,
			"message" => $msg,
		];

		$push_ios =[
			"action_type"=>"PageNotification",
			"page_id"=>$page_id,
			"page_title"=>$page_title,
			"message" => $msg,
			"title" => $page_title,
			'body' => $msg,
		];


		$sql_where = "";
        $search_And = [];

        if( $country_ids !="" ){
            $ids = implode(",",explode(",",$country_ids));
            $search_And[]=" u.country_id in ( $ids ) ";
        }

        if( $facility_ids !="" ){
            $ids = implode(",",explode(",",$facility_ids));
            $search_And[]=" u.facility_id in ( $ids ) ";
        }

        if( count($search_And)>0 ){
            $sql_where = " and " .implode(" AND ", $search_And);
        }

        //push_on

        $count = 0;

        $android_sql = "SELECT u.id,u.udid FROM tbl_users as u WHERE u.is_delete  = '0' AND u.device_type='a' $sql_where ";
        $result['android_sql'] = $android_sql;
        $sql_and = $this->db->query($android_sql); 
        if( $sql_and->num_rows() > 0 ){
        	$count += intval($sql_and->num_rows());
        	$res = $sql_and->result();
        	$result['status']=true;
        	$and_tokens=[];
        	foreach ($res as $key => $v) {
        		array_push($and_tokens, $v->udid);
        	}

			$result['android'] = sendAndroidPushNotification($and_tokens,$push);
        }


        $ios_sql = "SELECT u.id,u.udid FROM tbl_users as u WHERE u.is_delete  = '0' AND u.device_type='i' $sql_where ";
        $result['ios_sql'] = $ios_sql;
        $sql_ios = $this->db->query($ios_sql); 
        if( $sql_ios->num_rows() > 0 ){
        	$count += intval($sql_ios->num_rows());
        	$res = $sql_ios->result();
        	$result['status']=true;
        	$ios_tokens=[];

        	$result['ios']=[];
        	foreach ($res as $key => $v) {
        		// array_push($ios_tokens, $v->udid);

        		$result['ios'][] = sendApplePushNotification($v->udid, $push_ios);
        	}

        	//$result['ios'] = sendApplePushNotification($ios_tokens, $push_ios);
        }

        $result['count']=$count;

		return $result;
	}

}
