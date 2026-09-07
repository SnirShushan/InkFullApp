<?php
defined('BASEPATH') or exit('No direct script access allowed');

class Url_redirection_model extends CI_Model
{
    public function __construct()
    {
        parent::__construct();
    }


    public function update($id, $data)
    {
        $res = $this->db->where("id", $id)->limit(1)->update('tbl_url_redirect', $data);
        return $res;
    }

    public function add($data)
    {
        $res = $this->db->insert("tbl_url_redirect", $data);
        if ($res) {
            $id = $this->db->insert_id();
            return $id;
        }
        return false;
    }

    public function detail($id)
    {
        $docs = $this->db->where("id", $id)->get("tbl_url_redirect");
        if ($docs->num_rows() > 0) {
            return $docs->result()[0];
        }
        return false;
    }

    public function delete_url_redirection($id)
    {
        $this->db->where("id", $id)->limit("1")->delete("tbl_url_redirect");
    }
}
