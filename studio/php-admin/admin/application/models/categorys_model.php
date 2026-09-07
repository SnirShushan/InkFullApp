<?php
defined('BASEPATH') or exit('No direct script access allowed');

class Categorys_model extends CI_Model
{
    public function __construct()
    {
        parent::__construct();
    }


    public function update($id, $data)
    {
        $data['date_updated'] = date("Y-m-d H:i:s");
        $res = $this->db->where("id", $id)->limit(1)->update('tbl_category', $data);
        return $res;
    }

    public function add($data)
    {
        $data['date_added'] = date('Y-m-d H:i:s');
        $data['date_updated'] = date('Y-m-d H:i:s');
        $data['is_parent'] = '1';
        $data['is_external'] = '1';
        $res = $this->db->insert("tbl_category", $data);
        if ($res) {
            $id = $this->db->insert_id();
            return $id;
        }
        return false;
    }

    public function detail($id)
    {
        $docs = $this->db->where("id", $id)->get("tbl_category");
        if ($docs->num_rows() > 0) {
            return $docs->result()[0];
        }
        return false;
    }
    public function GetCategoryList()
    {
        $cat_list = array();
        $result_cat = $this->db->query("select * from tbl_category where is_delete='0' and is_parent='1' order by seq ASC");
        if ($result_cat) {
            if ($result_cat->num_rows() > 0) {
                foreach ($result_cat->result() as $p_cat) {
                    $single = array();
                    $single['name'] = $p_cat->name;
                    $single['name_en'] = $p_cat->name_en;
                    $single['id'] = $p_cat->id;
                    $single['slug'] = $p_cat->slug;
                    $sub_list = array();
                    $sub_result = $this->db->query("select * from tbl_category where is_delete='0' and parent_id='$p_cat->id'");
                    if ($sub_result) {
                        if ($sub_result->num_rows() > 0) {
                            foreach ($sub_result->result() as $s_cat) {
                                $sub_single = array();
                                $sub_single['name'] = $s_cat->name;
                                $sub_single['name_en'] = $s_cat->name_en;
                                $sub_single['id'] = $s_cat->id;
                                $sub_single['slug'] = $s_cat->slug;
                                $sub_single['parent_id'] = $s_cat->parent_id;
                                if ($s_cat->name != $p_cat->name)
                                    array_push($sub_list, $sub_single);
                            }
                        }
                    }
                    $single['sub_list'] = $sub_list;
                    array_push($cat_list, $single);
                }
            }
        }
        return $cat_list;
    }

    public function sub_cat_detail($id, $slug)
    {

        $this->db->select('*');
        $this->db->from('tbl_category');
        $this->db->where('parent_id', $id);
        $this->db->where('slug', $slug);
        $this->db->where('is_delete', '0');
        $query = $this->db->get();

        if ($query->num_rows() > 0) {
            return $query->result()[0];
        }
        return false;
    }

    public function sub_cat_update($id, $data)
    {
        $data['date_updated'] = date("Y-m-d H:i:s");
        $res = $this->db->where("id", $id)->limit(1)->update('tbl_category', $data);
        return $res;
    }
}
