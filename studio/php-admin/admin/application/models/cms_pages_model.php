<?php
defined('BASEPATH') or exit('No direct script access allowed');

class Cms_pages_model extends CI_Model
{
    public function __construct()
    {
        parent::__construct();
    }


    public function update($id, $data)
    {
        $res = $this->db->where("id", $id)->limit(1)->update('tbl_cms_pages', $data);
        return $res;
    }

    public function add($data)
    {
        $res = $this->db->insert("tbl_cms_pages", $data);
        if ($res) {
            $id = $this->db->insert_id();
            return $id;
        }
        return false;
    }

    public function detail($id)
    {
        $docs = $this->db->where("id", $id)->get("tbl_cms_pages");
        if ($docs->num_rows() > 0) {
            return $docs->result()[0];
        }
        return false;
    }

    public function delete_page($id)
    {
        $this->db->where("id", $id)->limit("1")->delete("tbl_cms_pages");
    }

    public function GetCMSPagesList()
    {
        $this->db->select('*');
        $this->db->from('tbl_cms_pages');
        $this->db->order_by('seq', 'asc');
        $query = $this->db->get();

        if ($query->num_rows() > 0) {
            return $query->result_array();
        }
        return [];
    }

    public function get_page_url($page_url)
    {

        $result_data = $this->db->query("select COUNT(id) as total from tbl_cms_pages where page_url='$page_url'");
        if ($result_data) {
            if ($result_data->num_rows() > 0) {
                return $result_data->result_array();
            }
        }
        return array();
    }
    public function get_page_url_for_edit($id, $page_url)
    {

        $result_data = $this->db->query("select COUNT(id) as total from tbl_cms_pages where id!='$id' AND page_url='$page_url'");
        if ($result_data) {
            if ($result_data->num_rows() > 0) {
                return $result_data->result_array();
            }
        }
        return array();
    }
}
