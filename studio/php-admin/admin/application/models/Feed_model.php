<?php
defined('BASEPATH') OR exit('No direct script access allowed');

class feed_model extends CI_Model
{
	public function __construct()
	{
		parent:: __construct();
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
