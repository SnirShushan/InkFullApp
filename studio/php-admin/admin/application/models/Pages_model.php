<?php
defined('BASEPATH') OR exit('No direct script access allowed');

class pages_model extends CI_Model
{
	public function __construct()
	{
		parent:: __construct();
	}


	public function deletePage($id)
	{
		$p = $this->db->query("DELETE from tbl_pages WHERE id = '$id' LIMIT 1");
		return $p;
	}


	public function getPageList()
	{
		$re = $this->db->get("tbl_pages");
		if( $re->num_rows() > 0 ){
			return $re->result();
		}
		return false;
	}


	public function getPageDetail($id)
	{
		$this->db->where("id",$id);
		$this->db->limit(1);
		$re = $this->db->get("tbl_pages");
		if( $re->num_rows() > 0 ){
			return $re->result()[0];
		}
		return false;
	}

	public function addPage($data)
	{
		$data['date_added']=date('Y-m-d H:i:s');
		$r = $this->db->insert("tbl_pages",$data);
		if($r){
			return $this->db->insert_id();
		}
		return false;
	}

	public function updatePage($id,$data)
	{
		$data['date_updated']=date('Y-m-d H:i:s');
		$this->db->where("id",$id);
		$this->db->limit(1);
		$r = $this->db->update("tbl_pages",$data);
		if($r){
			return $r;
		}
		return false;
	}


}
