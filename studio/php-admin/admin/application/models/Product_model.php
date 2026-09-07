<?php
defined('BASEPATH') or exit('No direct script access allowed');

class product_model extends CI_Model
{
	public function __construct()
	{
		parent::__construct();
	}

	public function get_categoet_products($category_id)
	{

		$ids = $this->get_child_category_ids1($category_id);
		if (count($ids) > 0) {
			$this->db->where_in('p.category_id', $ids);
		} else {
			$this->db->where('p.category_id', $category_id);
		}

		$this->db->from('tbl_products p');
		$this->db->order_by('p.seq');
		$query = $this->db->get();

		if ($query->num_rows() > 0) {
			return $query->result_array();
		}
		return [];
	}

	public function get_child_category_ids1($id)
	{
		$ids = array();
		$result = $this->db->query("select id from tbl_category where parent_id='$id' AND is_delete='0' ORDER BY seq");
		if ($result) {
			if ($result->num_rows() > 0) {
				foreach ($result->result() as $r) {
					array_push($ids, $r->id);
				}
			}
		}
		return $ids;
	}


	public function add_sale_product_group($pid, $parent_pid, $price)
	{

		$p = $this->db->select('id')->where("pid", $pid)->where("parent_pid", $parent_pid)->get("tbl_sale_products");
		if ($p->num_rows() > 0) {
		} else {
			$data = ['pid' => $pid, "parent_pid" => $parent_pid, "price" => $price];
			$data['date_added'] = date('Y-m-d H:i:s');
			$data['date_updated'] = date('Y-m-d H:i:s');
			$res = $this->db->insert("tbl_sale_products", $data);
		}
	}


	public function add_sale_product($pid, $parent_pid)
	{

		$p = $this->db->select('id')->where("pid", $pid)->where("parent_pid", $parent_pid)->get("tbl_sale_products");
		if ($p->num_rows() > 0) {
		} else {
			$data = ['pid' => $pid, "parent_pid" => $parent_pid];
			$data['date_added'] = date('Y-m-d H:i:s');
			$data['date_updated'] = date('Y-m-d H:i:s');
			$res = $this->db->insert("tbl_sale_products", $data);
		}
	}

	public function remove_sale_product($pid, $parent_pid)
	{
		$this->db->where("pid", $pid)->where("parent_pid", $parent_pid)->limit(1)->delete("tbl_sale_products");
	}

	public function update_sale_product($id, $upd)
	{
		$upd['date_updated'] = date('Y-m-d H:i:s');
		$this->db->where("id", $id)->limit(1)->update('tbl_sale_products', $upd);
	}

	public function remove_sale_produc_by_parent($pid)
	{
		$this->db->where("parent_pid", $pid)->delete("tbl_sale_products");
	}

	public function get_list_sale_products($pid)
	{
		$list = [];
		$p = $this->db->select('s.*,s.price as sale_price,p.name,p.price,p.price1')->where("s.pid=p.id")->where("s.parent_pid", $pid)->get("tbl_sale_products s,tbl_products p");
		if ($p->num_rows() > 0) {
			foreach ($p->result() as $r) {
				$list[] = $r;
			}
		}
		return $list;
	}

	public function get_list_cat_sale_products($id)
	{
		$list = [];
		$p = $this->db->select('s.*,s.price as sale_price,p.name,p.price,p.price1')->where("s.pid=p.id")->where("s.offer_id", $id)->get("tbl_sale_products s,tbl_products p");
		if ($p->num_rows() > 0) {
			foreach ($p->result() as $r) {
				$list[] = $r;
			}
		}
		return $list;
	}

	public function remove_cat_sale_product($pid, $offer_id)
	{
		$this->db->where("pid", $pid)->where("offer_id", $offer_id)->limit(1)->delete("tbl_sale_products");
	}


	public function add_cat_sale_product($pid, $offer_id)
	{

		$p = $this->db->select('id')->where("pid", $pid)->where("offer_id", $offer_id)->get("tbl_sale_products");
		if ($p->num_rows() > 0) {
		} else {
			$data = ['pid' => $pid, "offer_id" => $offer_id];
			$data['date_added'] = date('Y-m-d H:i:s');
			$data['date_updated'] = date('Y-m-d H:i:s');
			$res = $this->db->insert("tbl_sale_products", $data);
		}
	}

	public function get_product_dropdown()
	{
		$list = [];
		$p = $this->db->select('id,name,product_id,barcode')->where("status", '1')->where("is_delete", '0')->get("tbl_products");
		if ($p->num_rows() > 0) {
			foreach ($p->result() as $r) {
				$list[] = $r;
			}
		}
		return $list;
	}


	public function get_product_with_mapped()
	{
		$list = [];
		$p = $this->db->select('pid')->where("status", '1')->where("is_delete", '0')->get("tbl_products");
		if ($p->num_rows() > 0) {
			foreach ($p->result() as $r) {
				$list[] = $r;
			}
		}
		return $list;
	}

	public function get_product_group_list()
	{
		$list = [];
		$p = $this->db->select('*')->get("tbl_group_products");
		if ($p->num_rows() > 0) {
			foreach ($p->result() as $r) {
				$list[] = $r;
			}
		}
		return $list;
	}

	public function get_product_group_p_ids($id)
	{
		$list = [];
		$p = $this->db->select('pid')->where("gid", $id)->get("tbl_group_products_map");
		if ($p->num_rows() > 0) {
			foreach ($p->result() as $r) {
				$list[] = $r->pid;
			}
		}
		return $list;
	}


	public function get_product_group_id_from_pid($id)
	{
		$list = [];
		$p = $this->db->select('*')->where("pid", $id)->get("tbl_group_products_map");
		if ($p->num_rows() > 0) {
			foreach ($p->result() as $r) {
				$list[] = $r->gid;
			}
		}
		return $list;
	}




	public function get_product_group_single($id)
	{
		$p = $this->db->select('*')->where("id", $id)->get("tbl_group_products");
		if ($p->num_rows() > 0) {
			$rows = $p->result();
			return $rows[0];
		}
		return false;
	}

	public function update_product_group($id, $upd)
	{
		$res = $this->db->where("id", $id)->limit(1)->update('tbl_group_products', $upd);
		return $res;
	}

	public function remove_product_group_map($id)
	{
		$this->db->where("gid", $id)->delete("tbl_group_products_map");
	}

	public function remove_producr_group($id)
	{
		$this->db->where("id", $id)->delete("tbl_group_products");
		$this->db->where("gid", $id)->delete("tbl_group_products_map");
	}


	public function update_customer($id, $data)
	{
		$data['date_updated'] = date("Y-m-d H:i:s");
		$res = $this->db->where("id", $id)->limit(1)->update('tbl_users', $data);
		return $res;
	}

	public function remove_p_comment($id)
	{
		$this->db->where("id", $id)->limit(1)->delete("tbl_products_comment");
	}
	public function remove_offer_category($id)
	{
		$this->db->where("offer_id", $id)->delete("tbl_offers_category");
	}


	public function get_product_comment($pid)
	{
		//$this->db->where("status","1");
		$this->db->where("pid", $pid);
		$result = $this->db->get("tbl_products_comment");
		return $result->result_array();
	} // get product comment

	public function add_p_comment($data)
	{
		$data['date_added'] = date('Y-m-d H:i:s');
		$data['date_updated'] = date('Y-m-d H:i:s');
		$res = $this->db->insert("tbl_products_comment", $data);
		if ($res) {
			$id = $this->db->insert_id();
			return $id;
		}
		return false;
	}

	public function update_p_comment_csv($id, $data)
	{
		if ($data != "") {
			$this->db->query("Delete from tbl_products_comment where pid='$id'");
			$arr = explode(",", $data);
			foreach ($arr as $key => $value) {
				$this->add_p_comment(array("comment" => $value, "pid" => $id));
			}
		}
	}

	public function update_p_comment($id, $data)
	{
		$data['date_updated'] = date("Y-m-d H:i:s");
		$res = $this->db->where("id", $id)->limit(1)->update('tbl_products_comment', $data);
		return $res;
	}

	public function update($id, $data)
	{
		$data['date_updated'] = date("Y-m-d H:i:s");
		$res = $this->db->where("id", $id)->limit(1)->update('tbl_products', $data);
		return $res;
	}

	public function update_image($id, $data)
	{

		$res = $this->db->where("id", $id)->limit(1)->update('tbl_product_images', $data);
		return $res;
	}



	public function add($data)
	{
		$data['date_added'] = date('Y-m-d H:i:s');
		$data['date_updated'] = date('Y-m-d H:i:s');
		$res = $this->db->insert("tbl_products", $data);
		if ($res) {
			$id = $this->db->insert_id();
			return $id;
		}
		return false;
	}


	public function add_offer($data)
	{
		$data['date_added'] = date('Y-m-d H:i:s');
		$data['date_updated'] = date('Y-m-d H:i:s');
		$res = $this->db->insert("tbl_offers", $data);
		if ($res) {
			$id = $this->db->insert_id();
			return $id;
		}
		return false;
	}


	public function add_product_group($data)
	{
		$data['date_added'] = date('Y-m-d H:i:s');
		$data['date_updated'] = date('Y-m-d H:i:s');
		$res = $this->db->insert("tbl_group_products", $data);
		if ($res) {
			$id = $this->db->insert_id();
			return $id;
		}
		return false;
	}

	public function add_product_group_map($data)
	{
		$res = $this->db->insert("tbl_group_products_map", $data);
		if ($res) {
			$id = $this->db->insert_id();
			return $id;
		}
		return false;
	}



	public function add_offer_category($data)
	{

		$res = $this->db->insert("tbl_offers_category", $data);
		if ($res) {
			$id = $this->db->insert_id();
			return $id;
		}
		return false;
	}

	public function update_offer($id, $data)
	{
		$data['date_updated'] = date("Y-m-d H:i:s");
		$res = $this->db->where("id", $id)->limit(1)->update('tbl_offers', $data);
		return $res;
	}

	public function get_offer_category_list($pid)
	{
		$parent_list = array();
		$child_list = array();
		$list = array();
		$result = $this->db->query("select * from tbl_offers_category where offer_id='$pid'");
		if ($result) {
			if ($result->num_rows() > 0) {
				foreach ($result->result_array() as $value) {
					if ($value['is_parent'] == "1")
						array_push($parent_list, $value['category_id']);
					else
						array_push($child_list, $value['category_id']);
				}
			}
		}
		return array("parent_list" => $parent_list, "child_list" => $child_list);
	} // category list

	public function add_image($data)
	{
		$data['date_added'] = date('Y-m-d H:i:s');
		$res = $this->db->insert("tbl_product_images", $data);
		if ($res) {
			$id = $this->db->insert_id();
			return $id;
		}
		return false;
	}

	public function remove_image($id)
	{
		$this->db->where("id", $id)->limit(1)->delete("tbl_product_images");
	}

	public function delete_all_product()
	{
		$this->db->where("1", "1")->delete("tbl_products");
		$this->db->where("1", "1")->delete("tbl_product_images");
	}

	public function delete_product($id)
	{
		$this->db->where("id", $id)->limit("1")->delete("tbl_products");
		$this->db->where("pid", $id)->limit("1")->delete("tbl_product_images");
	}
	public function disable_category()
	{
		//$this->db->where("id",$id);
		$r = $this->db->update("tbl_category", array("is_delete" => "1"));
	}

	public function update_category($id, $data)
	{
		$data['date_updated'] = date("Y-m-d H:i:s");
		$this->db->where("id", $id);
		$r = $this->db->update("tbl_category", $data);
	}


	public function category_add_import($name, $parent, $all)
	{
		//$name =group
		//$parent = Department
		//echo "Group (Name) : ".$name." , Department (Parent) : ".$parent;
		$sub_id = "";
		$parent_id = "";
		$parent_copy = 0;
		$parent_en = $all['dept_name_en'];
		$name_en = $all['group_name_en'];
		if (trim($parent) == trim($name)) {
			$parent_copy = 1;
		}


		if (trim($parent) != "" && trim($name) == "") {
			$name = $parent;
			$name_en = $parent_en;
		}

		$is_delete = 0;
		$is_sale_cat = 0;

		if ($name == trim("כללית") || $parent == trim("כללית")) {
			$is_delete = 1;
			$is_sale_cat = 1;
		}

		if ($name == trim("מבצע") || $parent == trim("מבצע")) {
			$is_delete = 1;
			$is_sale_cat = 1;
		}


		$this->db->where("is_parent", "1");
		$ct1 = $this->db->where("name", $parent)->get("tbl_category");


		if ($ct1->num_rows() > 0) {
			$row1 = $ct1->result()[0];
			$parent_id = $row1->id;
			$upd_cat = array("is_delete" => $is_delete, "is_sale_cat" => $is_sale_cat);
			if (trim($parent_en) != "") {
				$upd_cat["name_en"] = $parent_en;
			}
			$this->update_category($row1->id, $upd_cat);
		} else {


			$ins = array();
			$ins['name'] = $parent;
			$ins['name_en'] = $parent_en;
			$ins['is_parent'] = "1";
			$ins['parent_id'] = "0";
			$ins['is_sale_cat'] = $is_sale_cat;
			$ins['slug'] = url_title($parent);
			$res = $this->db->insert("tbl_category", $ins);

			if ($res) {
				$id = $this->db->insert_id();
				$parent_id = $id;
				//echo "And Id".$id;
			}
		}


		$this->db->where("is_parent", "0");
		$ct = $this->db->where("name", $name)->get("tbl_category");


		if ($ct->num_rows() > 0) {
			$row = $ct->result()[0];
			$sub_id = $row->id;
			$upd_cat = array("is_delete" => $is_delete, "is_sale_cat" => $is_sale_cat);
			if (trim($name_en) != "") {
				$upd_cat["name_en"] = $name_en;
			}
			$this->update_category($row->id, $upd_cat);
		} else {

			$ins = array();
			$ins['name'] = $name;
			$ins['name_en'] = $name_en;
			$ins['parent_id'] = $parent_id;
			$ins['parent_copy'] = $parent_copy;
			$ins['is_parent'] = "0";
			$ins['is_sale_cat'] = $is_sale_cat;
			$ins['slug'] = url_title($name);
			$res = $this->db->insert("tbl_category", $ins);


			if ($res) {
				$id = $this->db->insert_id();
				$sub_id = $id;
			}
		}

		return $sub_id;
	}




	public function detail($id)
	{
		$docs = $this->db->where("id", $id)->get("tbl_products");
		if ($docs->num_rows() > 0) {
			return $docs->result()[0];
		}
		return false;
	}


	public function get_offer_detail($id)
	{
		$docs = $this->db->where("id", $id)->get("tbl_offers");
		if ($docs->num_rows() > 0) {
			return $docs->result()[0];
		}
		return false;
	}



	public function get_product_by_id($id)
	{
		$docs = $this->db->where("product_id", $id)->get("tbl_products");
		if ($docs->num_rows() > 0) {
			return $docs->result()[0];
		}
		return false;
	}

	public function get_product_detail($id)
	{
		$docs = $this->db->where("pid", $id)->get("tbl_products");
		if ($docs->num_rows() > 0) {
			return $docs->result()[0];
		}
		return false;
	}


	public function get_category_list()
	{
		$list = array();
		$result = $this->db->query("select * from tbl_category");
		if ($result) {
			if ($result->num_rows() > 0) {
				foreach ($result->result() as $value) {
					$list[$value->id] = $value->name;
				}
			}
		}
		return $list;
	} // category list

	public function get_images_list($pid)
	{
		$list = array();
		$result = $this->db->query("select * from tbl_product_images where pid='$pid'");
		if ($result) {
			if ($result->num_rows() > 0) {
				foreach ($result->result() as $value) {
					array_push($list, $value);
				}
			}
		}
		return $list;
	} // category list


	public function get_product_export()
	{
		//$this->db->where("status","1");
		//$this->db->where("is_delete","0");
		//$result=$this->db->get("tbl_products");
		$result = $this->db->query("SELECT p.* FROM `tbl_products` p, `tbl_category` c  WHERE p.category_id=c.id AND p.is_delete='0' ORDER BY c.seq ASC");
		return $result->result_array();
	} // export product

	public function get_product_names()
	{
		$this->db->where("status", "1");
		$this->db->where("is_delete", "0");
		$result = $this->db->get("tbl_products");
		return $result->result_array();
	} // export product

	public function get_selected_category()
	{
		$list = array();
		$result = $this->db->get("tbl_offers_category");
		$arr = $result->result_array();
		if (count($arr) > 0) {
			foreach ($result->result() as $key => $value) {
				array_push($list, $value->category_id);
			}
		}
		return $list;
	} // get_selected_category

	public function get_child_category_ids($id)
	{
		$ids = array();
		$result = $this->db->query("select id from tbl_category where parent_id='$id' AND is_delete='0' ");
		if ($result) {
			if ($result->num_rows() > 0) {
				foreach ($result->result() as $r) {
					array_push($ids, $r->id);
				}
			}
		}
		return $ids;
	}

	public function get_product_names_by_category($id)
	{
		$this->db->select('p.*,c.name as category_name');
		$this->db->from('tbl_products p');
		$this->db->join('tbl_category c', 'p.category_id = c.id');
		$this->db->where('p.status', "1");
		$this->db->where('p.is_delete', "0");

		if ($id != 0) {
			$ids = $this->get_child_category_ids($id);
			if (count($ids) > 0) {
				$this->db->where_in('p.category_id', $ids);
			} else {
				$this->db->where('p.category_id', $id);
			}
		}






		$query = $this->db->get();

		if ($query->num_rows() > 0) {
			return $query->result_array();
		} else {
			return array();
		}

		/*$this->db->where("status","1");
    	$this->db->where("is_delete","0");
    	$this->db->where("category_id",$id);
    	$result=$this->db->get("tbl_products");
    	return $result->result_array();*/
	} // export product




	public function remove_mapping_category_pid($pid)
	{
		$this->db->where("product_id", $pid)->delete("tbl_mapping_category");
	}

	public function add_mapping_category($data)
	{
		$res = $this->db->insert("tbl_mapping_category", $data);
		if ($res) {
			$id = $this->db->insert_id();
			return $id;
		}
		return false;
	}

	public function get_selected_mapping_category($pid)
	{
		$list = array();
		//$result = $this->db->get("tbl_mapping_category");
		$result = $this->db->query("select * from tbl_mapping_category where product_id='$pid'");
		$arr = $result->result_array();
		if (count($arr) > 0) {
			foreach ($result->result() as $key => $value) {
				array_push($list, $value->cat_id);
			}
		}
		return $list;
	} // get_selected_category

	public function get_selected_mapping_category_list($pid)
	{
		$parent_list = array();
		$child_list = array();
		$list = array();
		$result = $this->db->query("select * from tbl_mapping_category where product_id='$pid'");
		if ($result) {
			if ($result->num_rows() > 0) {
				foreach ($result->result_array() as $value) {
					if ($value['is_parent'] == "1")
						array_push($parent_list, $value['cat_id']);
					else
						array_push($child_list, $value['cat_id']);
				}
			}
		}
		return array("parent_list" => $parent_list, "child_list" => $child_list);
	} // get_selected_category

	public function get_prodcut_page_url_for_edit($id, $page_url)
	{

		$result_data = $this->db->query("select COUNT(id) as total from tbl_products where id!='$id' AND page_url='$page_url'");
		if ($result_data) {
			if ($result_data->num_rows() > 0) {
				return $result_data->result_array();
			}
		}
		return array();
	}

	public function update_atl_text_by_pid($id, $data)
	{
		$res = $this->db->where("id", $id)->limit(1)->update('tbl_product_images', $data);
		return $res;
	}

	public function add_video($data)
	{

		$res = $this->db->insert("tbl_videos", $data);
		if ($res) {
			$id = $this->db->insert_id();
			return $id;
		}
		return false;
	}

	public function get_seq_value($id)
	{
		$seq_val = 1;
		$result = $this->db->query("select * from tbl_videos where pid='$id'");
		if ($result) {
			$seq_val = $result->num_rows() + $seq_val;
		}
		return $seq_val;
	}

	public function get_videos_list($pid)
	{
		$list = array();
		$result = $this->db->query("select * from tbl_videos where pid='$pid' order by seq");
		if ($result) {
			if ($result->num_rows() > 0) {
				foreach ($result->result() as $value) {
					array_push($list, $value);
				}
			}
		}
		return $list;
	} // category list

	public function remove_video($id)
	{
		$this->db->where("id", $id)->limit(1)->delete("tbl_videos");
	}

	public function update_product_video_seq($id, $data)
	{

		$res = $this->db->where("id", $id)->limit(1)->update('tbl_videos', $data);
		return $res;
	}
}
