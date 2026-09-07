<?php
defined('BASEPATH') OR exit('No direct script access allowed');

class popup_model extends CI_Model
{
	public function __construct()
	{
		parent:: __construct();
	}


	public function deletePopup($id)
	{
		$p = $this->db->query("DELETE from tbl_site_popup WHERE id = '$id' LIMIT 1");
		return $p;
	}


	public function getPopupList()
	{
		$re = $this->db->get("tbl_site_popup");
		if( $re->num_rows() > 0 ){
			return $re->result();
		}
		return false;
	}


	public function getPopupDetail($id)
	{
		$this->db->where("id",$id);
		$this->db->limit(1);
		$re = $this->db->get("tbl_site_popup");
		if( $re->num_rows() > 0 ){
			return $re->result()[0];
		}
		return false;
	}

	public function addPopup($data)
	{
		$data['date_added']=date('Y-m-d H:i:s');
		$r = $this->db->insert("tbl_site_popup",$data);
		if($r){
			return $this->db->insert_id();
		}
		return false;
	}

	public function updatePopup($id,$data)
	{
		$data['date_updated']=date('Y-m-d H:i:s');
		$this->db->where("id",$id);
		$this->db->limit(1);
		$r = $this->db->update("tbl_site_popup",$data);
		if($r){
			return $r;
		}
		return false;
	}


}
