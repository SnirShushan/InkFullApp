<?php
defined('BASEPATH') OR exit('No direct script access allowed');

class Requests_model extends CI_Model
{
	public function __construct()
	{
		parent:: __construct();
	}

	public function get_signle_request_detail($id)
	{
		$style = [];
		$list = $this->db->query(" SELECT * FROM tbl_request WHERE id = '$id' LIMIT 1");
		if( $list->num_rows() > 0 ){
			// return $list->result()[0];
			$data = $list->result()[0];
			
			$data->artists_uid = $this->get_name($data->artists_uid);
			$data->business_id = $this->get_name($data->business_id);
			$data->cust_phone = $this->get_phone($data->uid);
			$data->cnt_code = $this->get_cnt_code($data->uid);
			$data->uid = $this->get_name($data->uid);
			// $arr_style = explode(",",$data->styles);
			
			// foreach($arr_style as $single_style){
				
			// 	$style_name = $this->get_style($single_style);
			// 	if($style_name != ""){
			// 		$style[] .= $style_name;
			// 	}
			// }
			$style_arr = [];
			$style = explode(",",$data->styles);
			foreach ($style as $key => $value) {
				# code...
				if(!in_array($value,$style_arr)){
					array_push($style_arr, $value);
				}
			}
			$new_styles = implode(",",$style_arr);
			$data->styles = $new_styles;
			
			// $data->styles = implode(",",$style);
			// echo "<pre>";
			// print_r($data);
			// exit;
			return $data;
		}
		return false;
	}

	public function get_name($id)
	{
		$list = $this->db->query(" SELECT name FROM tbl_customer WHERE id = '$id' LIMIT 1");
		if( $list->num_rows() > 0 ){
			return $list->result()[0]->name;
		}
		return false;
	}

	public function get_phone($id)
	{
		$list = $this->db->query(" SELECT phone FROM tbl_customer WHERE id = '$id' LIMIT 1");
		if( $list->num_rows() > 0 ){
			return $list->result()[0]->phone;
		}
		return false;
	}
	public function get_cnt_code($id)
	{
		$list = $this->db->query(" SELECT cnt_code FROM tbl_customer WHERE id = '$id' LIMIT 1");
		if( $list->num_rows() > 0 ){
			return $list->result()[0]->cnt_code;
		}
		return false;
	}

	public function get_style($slug)
	{
		$list = $this->db->query(" SELECT name,name_en FROM tbl_styles WHERE slug = '$slug' LIMIT 1");
		if( $list->num_rows() > 0 ){
			return $list->result()[0]->name;
		}
		return false;
	}

}
