<?php
defined('BASEPATH') OR exit('No direct script access allowed');

class pickup_points_model extends CI_Model
{
	public function __construct()
	{
		parent:: __construct();
	}


	public function delete($id)
	{
		$p = $this->db->query("DELETE from tbl_pickup_points WHERE id = '$id' LIMIT 1");
		return $p;
	}


	public function getList()
	{
		$re = $this->db->get("tbl_pickup_points");
		if( $re->num_rows() > 0 ){
			return $re->result();
		}
		return false;
	}


	public function getDetail($id)
	{
		$this->db->where("id",$id);
		$this->db->limit(1);
		$re = $this->db->get("tbl_pickup_points");
		if( $re->num_rows() > 0 ){
			return $re->result()[0];
		}
		return false;
	}

	public function add($data)
	{
		$data['date_added']=date('Y-m-d H:i:s');
		$r = $this->db->insert("tbl_pickup_points",$data);
		if($r){
			return $this->db->insert_id();
		}
		return false;
	}

	public function update($id,$data)
	{
		$data['date_updated']=date('Y-m-d H:i:s');
		$this->db->where("id",$id);
		$this->db->limit(1);
		$r = $this->db->update("tbl_pickup_points",$data);
		if($r){
			return $r;
		}
		return false;
	}


}
