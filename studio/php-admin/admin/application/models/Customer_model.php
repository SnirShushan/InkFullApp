<?php
defined('BASEPATH') OR exit('No direct script access allowed');

class Customer_model extends CI_Model
{
	public function __construct()
	{
		parent:: __construct();
	}

	public function get_user_ids($user_type)
	{
		$docs = $this->db->query(" SELECT id FROM tbl_customer WHERE user_type = '$user_type' ");
		if( $docs->num_rows() > 0 ){
			$list=array();
			foreach ($docs->result() as $r) {
				array_push($list, $r->id);
			}
			return $list;
		}
		return array();
	}

	public function get_customer_udid_n_device_type($id)
	{
		$this->db->select("udid,device_type");
		$this->db->from("tbl_customer");
		$this->db->where("id",$id);        
		$this->db->where("is_delete=0");
		$result = $this->db->get();
		$result =$result->result_array();
		if(!empty($result)){
			return  $result[0];
		}else{
			return;
		}
	}

	public function update_detail($data,$where){
    	$this->db->update('tbl_customer',$data,$where);
    }// update data to table

	public function update_sub_detail($data,$where){
    	$this->db->update('tbl_subscription',$data,$where);
    }// update data to table


	public function get_subscription_detail($id)
	{
		$this->db->select("*");
		$this->db->from("tbl_subscription");
		$this->db->where(["id"=>$id,"is_delete"=>"0"]);
		$result = $this->db->get();
		$result =$result->result_array();
		if(!empty($result)){
			return  $result[0];
		}else{
			return;
		}
	}

}
