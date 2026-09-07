<?php
defined('BASEPATH') OR exit('No direct script access allowed');

class category_model extends CI_Model
{
	public function __construct()
	{
		parent:: __construct();
	}


	public function update($id,$data){
		$data['date_updated'] = date("Y-m-d H:i:s");
		$res = $this->db->where("id",$id)->limit(1)->update('tbl_category',$data);
		return $res;
	}

	public function add($data)
	{
		$data['date_added'] = date('Y-m-d H:i:s');
		$data['date_updated'] = date('Y-m-d H:i:s');
		$res = $this->db->insert("tbl_category",$data);
		if( $res ){
			$id = $this->db->insert_id();
			return $id;
		}
		return false;
	}

	public function detail($id)
	{
		$docs = $this->db->where("id",$id)->get("tbl_category");
		if( $docs->num_rows() > 0 ){
			return $docs->result()[0];
		}
		return false;
	}

	

	public function parent_cat_list()
	{
		$docs = $this->db->where("is_delete","0")->where("is_parent","1")->order_by("seq","asc")->get("tbl_category");
		if( $docs->num_rows() > 0 ){
			$list=array();
			foreach ($docs->result() as $r) {
				$list[$r->id]=$r->name;
			}
			return $list;
		}
		return array();
	}

	public function icon_list()
	{
		$docs = $this->db->get("tbl_category_icon");
		if( $docs->num_rows() > 0 ){
			$list=array();
			foreach ($docs->result() as $r) {
				array_push($list, $r->icon_name);
			}
			return $list;
		}
		return array();
	}

	public function get_cat_list(){
		$cat_list=array();
			$result_cat=$this->db->query("select * from tbl_category where is_delete='0' and is_parent='1' order by seq ASC");
			if($result_cat)
			{
				if($result_cat->num_rows()>0)
				{
					foreach ($result_cat->result() as $p_cat) {
						$single=array();
						$single['name']=$p_cat->name;
						$single['id']=$p_cat->id;
						$sub_list=array();
						$sub_result=$this->db->query("select * from tbl_category where is_delete='0' and parent_id='$p_cat->id'");
						if($sub_result)
						{
							if($sub_result->num_rows()>0)
							{
								foreach ($sub_result->result() as $s_cat) {
									$sub_single=array();
									$sub_single['name']=$s_cat->name;
									$sub_single['id']=$s_cat->id;
									$sub_single['parent_id']=$s_cat->parent_id;
									array_push($sub_list, $sub_single);
								}
							}
						}
						$single['sub_list']=$sub_list;
						array_push($cat_list, $single);

					}
				}
			}
			return $cat_list;
	}// get_cat_list


		public function get_sub_cat_list(){
		$cat_list=array();
			$result_cat=$this->db->query("select * from tbl_category where is_delete='0' and is_parent='1' order by seq ASC");
			if($result_cat)
			{
				if($result_cat->num_rows()>0)
				{
					foreach ($result_cat->result() as $p_cat) {
						$single=array();
						$single['name']=$p_cat->name;
						$single['id']=$p_cat->id;
						$sub_list=array();
						$sub_result=$this->db->query("select * from tbl_category where is_delete='0' and parent_id='$p_cat->id' order by seq ASC");
						if($sub_result)
						{
							if($sub_result->num_rows()>0)
							{
								foreach ($sub_result->result() as $s_cat) {
									$sub_single=array();
									$sub_single['name']=$s_cat->name;
									$sub_single['id']=$s_cat->id;
									$sub_single['seq']=$s_cat->seq;
									$sub_single['products']=[];
									$sub_single['parent_id']=$s_cat->parent_id;
									array_push($sub_list, $sub_single);
								}
							}
						}
						$single['sub_list']=$sub_list;
						$cat_list[$p_cat->id]= $single;

					}
				}
			}
			return $cat_list;
	}// get_sub_cat_list


	

}
