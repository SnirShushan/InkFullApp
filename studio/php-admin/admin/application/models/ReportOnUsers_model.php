<?php
defined('BASEPATH') OR exit('No direct script access allowed');

class ReportOnUsers_model extends CI_Model
{
	public function __construct()
	{
		parent:: __construct();
	}

	public function update_report_data($id,$data,$table)
	{
		$this->db->where("id",$id);
		$this->db->limit(1);
		$r = $this->db->update($table, $data);
		return $r;
	}

	public function report_user_detail($id)
	{
		$list = $this->db->query(" SELECT uid FROM tbl_report_users WHERE id = '$id' LIMIT 1");
		if( $list->num_rows() > 0 ){
			return $list->result()[0]->uid;
		}
		return false;
	}

	public function report_post_detail($id)
	{
		$list = $this->db->query(" SELECT pid FROM tbl_report_posts WHERE id = '$id' LIMIT 1");
		if( $list->num_rows() > 0 ){
			return $list->result()[0]->pid;
		}
		return false;
	}

	public function update_data($id,$data,$table)
	{
		$this->db->where("id",$id);
		$this->db->limit(1);
		$r = $this->db->update($table, $data);
		return $r;
	}

}
