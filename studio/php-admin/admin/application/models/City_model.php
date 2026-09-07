<?php
defined('BASEPATH') OR exit('No direct script access allowed');

class city_model extends CI_Model
{
	public function __construct()
	{
		parent:: __construct();
	}


	public function update($id,$data){
		$data['date_updated'] = date("Y-m-d H:i:s");
		$res = $this->db->where("id",$id)->limit(1)->update('tbl_cities',$data);
		return $res;
	}

	public function add($data)
	{
		$data['date_added'] = date('Y-m-d H:i:s');
		$data['date_updated'] = date('Y-m-d H:i:s');
		$res = $this->db->insert("tbl_cities",$data);
		if( $res ){
			$id = $this->db->insert_id();
			return $id;
		}
		return false;
	}

	public function detail($id)
	{
		$docs = $this->db->where("id",$id)->get("tbl_cities");
		if( $docs->num_rows() > 0 ){
			return $docs->result()[0];
		}
		return false;
	}

	public function get_city_list()
	{
		$list=array();
		$docs = $this->db->where("is_delete","0")->get("tbl_cities");
		return $docs;
	}

	
	public function get_ship_city_list()
	{
		$list=array();
		$docs = $this->db->where("is_delete","0")->get("tbl_ship_city");
		return $docs;
	}


	public function get_ship_city_list_ids()
	{
		$list=[];
		$docs = $this->db->where("is_delete","0")->get("tbl_ship_city");
		if($docs)
		{
			if($docs->num_rows()>0)
			{
				foreach($docs->result() as $row)
				{
					$arr_ids=explode(",",$row->city_ids);
					foreach($arr_ids as $v)
					{
						$list[]=$v;
					}
				}
			}
		}

		return $list;
	}

	public function get_ship_list_charge($id)
	{
		$list=array();
		$result = $this->db->where("parent_id",$id)->get("tbl_ship_city_charge");
		if($result)
		{
			if($result->num_rows()>0){
				return $result->result_array();
			}
		}
		return [];
	}

	public function get_list_charge()
	{
		$list=array();
		$result = $this->db->get("tbl_ship_charge");
		if($result)
		{
			if($result->num_rows()>0){
				return $result->result_array();
			}
		}
		return [];
	}


	public function get_sale_charge_detail($id)
	{
		$docs = $this->db->where("id",$id)->get("tbl_ship_city");
		if( $docs->num_rows() > 0 ){
			return $docs->result()[0];
		}
		return false;
	}
	

	public function get_list()
	{
		$list=array();
		$docs = $this->db->where("is_delete","0")->get("tbl_cities");
		if( $docs->num_rows() > 0 ){
			foreach ($docs->result() as $r) {
				$list[$r->id]=$r->city_name;
			}
		}
		return $list;
	}

	public function clear_ship_charge($id)
	{
		$this->db->where("parent_id", $id);
		$this->db->delete('tbl_ship_city_charge');
	}

	public function add_ship_charge($data)
	{
		$res = $this->db->insert("tbl_ship_city_charge",$data);
		if( $res ){
			$id = $this->db->insert_id();
			return $id;
		}
		return false;
	}


	public function clear_regular_ship_charge()
	{
		$this->db->where("parent_id", "0");
		
		$this->db->delete('tbl_ship_charge');
	}

	public function add_regular_charge($data)
	{
		$res = $this->db->insert("tbl_ship_charge",$data);
		if( $res ){
			$id = $this->db->insert_id();
			return $id;
		}
		return false;
	}

	public function update_ship_charge_row($id,$data)
	{
		$data['date_updated'] = date("Y-m-d H:i:s");
		$res = $this->db->where("id",$id)->limit(1)->update('tbl_ship_city',$data);
	}
	
	public function add_ship_list($str_ids,$price_tier="",$title="",$title_en="")
	{
		$allowed_arr=[];
		$arr_ids=explode(",",$str_ids);
		foreach($arr_ids as $id)
		{
			$allow=1;
			$result=$this->db->query("select * from tbl_ship_city where FIND_IN_SET('$id',city_ids)>0 LIMIT 1");
			if($result)
			{
				if($result->num_rows()>0){
					$allow=0;
				}
			}

			if($allow==1)
			{
				$allowed_arr[]=$id;
			}
		}

		if(count($allowed_arr)>0){
			$data=[];
			$data['city_ids']=implode(",",$allowed_arr);
			$data['date_added'] = date('Y-m-d H:i:s');
			$data['date_updated'] = date('Y-m-d H:i:s');
			$data['price_tier']=$price_tier;
			$data['title']=$title;
			$data['title_en']=$title_en;
			$res = $this->db->insert("tbl_ship_city",$data);
		}
	}

	public function update_feed_detail($uid,$data){
		$data['date_updated'] = date("Y-m-d H:i:s");
		$res = $this->db->where("id",$uid)->limit(1)->update('tbl_posts',$data);
		return $res;
	}

	public function update_feed_doc_detail($id,$data){
		//$data['date_updated'] = date("Y-m-d H:i:s");
		$res = $this->db->where("id",$id)->limit(1)->update('tbl_posts_document',$data);
		return $res;
	}

	public function GetFeedDetail($uid)
	{
		$res = $this->db->where("id",$uid)->limit(1)->get('tbl_posts');
		if($res->num_rows() > 0){
			$row = $res->result()[0];

			$images = [];
			$pdf = [];
			$video = [];

			$docs = $this->db->where("pid",$row->id)->get("tbl_posts_document");
			if( $docs->num_rows() > 0 ){
				foreach ($docs->result() as $key => $v ) {
					if( $v->doc_type == "image" ){
						array_push($images, $v);
					}else if($v->doc_type == "pdf"){
						array_push($pdf, $v);
					}else if($v->doc_type == "video"){
						array_push($video, $v);
					}
				}
			}

			$row->{"doc_images"} = $images;
			$row->{"doc_pdf"} = $pdf;
			$row->{"doc_video"} = $video;

			return $row;
		}
		return false;
	}

	public function GetFeedDocDetail($id)
	{
		$docs = $this->db->where("id",$id)->get("tbl_posts_document");
		if( $docs->num_rows() > 0 ){
			return $docs->result()[0];
		}
		return false;
	}

	public function AddNewFeed($data)
	{
		$data['date_added'] = date('Y-m-d H:i:s');
		$data['date_updated'] = date('Y-m-d H:i:s');
		$res = $this->db->insert("tbl_posts",$data);
		if( $res ){
			$id = $this->db->insert_id();
			$this->SendaddUserNotification($id);
			return $id;
		}
		return false;
	}

	//add badge notification when new post add
	public function SendaddUserNotification( $pid )
	{
		$userList = $this->db->query("SELECT id FROM tbl_users WHERE is_delete = '0' AND status = '1' AND push_on = '1' ");
		if( $userList->num_rows() > 0 ){
			$this->db->trans_start();
			foreach ($userList->result() as $key => $v ) {
				$this->db->insert("tbl_user_notification",['uid'=>$v->id,'pid'=>$pid]);
			}
			$this->db->trans_complete();
		}
	}

	public function AddFeedDocs($data)
	{
		$data['added_date'] = date('Y-m-d H:i:s');
		$res = $this->db->insert("tbl_posts_document",$data);
		if( $res ){
			return $this->db->insert_id();
		}
		return false;
	}


	public function DeleteFeedDoc($id)
	{
		return $this->db->where("id",$id)->limit(1)->delete("tbl_posts_document");
	}

	public function DeleteFeed($id)
	{

		//remove from notification
		$this->db->where("pid", $id);
		$this->db->delete('tbl_user_notification');

		$this->db->where("pid",$id)->delete("tbl_posts_document");
		$this->db->where("pid",$id)->delete("tbl_posts_read");
		$this->db->where("pid",$id)->delete("tbl_posts_view");
		return $this->db->where("id",$id)->limit(1)->delete("tbl_posts");
	}

}
