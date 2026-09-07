<?php
defined('BASEPATH') OR exit('No direct script access allowed');

class settings_model extends CI_Model
{
	public function __construct()
	{
		parent:: __construct();
	}



	public function update_settings($field_name,$data)
	{
		$this->db->where('field_name', $field_name);
    	$this->db->update("tbl_settings", $data);
	}/// update menu item

	public function get_settings($field_name)
	{
    	$this->db->select('field_value');
    	$this->db->get("tbl_settings");
		$this->db->where('field_name', $field_name);
	}/// update menu item

	public function get_pages()
	{
		$result=$this->db->get("tbl_pages");
		return $result;
	}// get list of pages
	
	public function get_sliders()
	{
		$result=$this->db->query("select * from tbl_slider");
		if($result)
		{
			if($result->num_rows()>0)
			{
				return $result->result_array();
			}
		}
		return array();
	}
	
	public function update_slider($id,$data)
	{
		$this->db->where('id', $id);
    	$this->db->update("tbl_slider", $data);
	}/// update menu item

}// Class
