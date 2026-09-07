<?php

defined('BASEPATH') OR exit('No direct script access allowed');

class Dashboard extends MY_Controller 

{

	public function __construct()
	{
		parent:: __construct();
		
	}

	public function index()
    {
        $this->view_data['title'] = $this->settings['hebrew_text']['Dashboard'];
        $this->view_data['menu'] = "Dashboard";
        $this->view_data['back_button'] = base_url();
        $this->view_data['page_heading'] = $this->settings['hebrew_text']['Dashboard'];
        $this->view_data['page_sub_heading'] = "";
        $this->view_data['arr_breadcrumb'] = array($this->settings['hebrew_text']['home'] => base_url("Dashboard"));
        $this->view_data['breadcrumb_home_logo'] = '<i class="icon-home"></i>';
        $this->layout_view = "layout/ltf_default";

        if ($this->auth->is_login() == false)
		{
            redirect(base_url('login'));
        }

        $this->view_data['stat_regular'] = (int) $this->db->query("SELECT COUNT(*) AS c FROM tbl_customer WHERE user_type = '1' AND is_delete = '0'")->row()->c;
        $this->view_data['stat_business'] = (int) $this->db->query("SELECT COUNT(*) AS c FROM tbl_customer WHERE user_type = '2' AND is_delete = '0'")->row()->c;
        $this->view_data['stat_posts'] = (int) $this->db->query("SELECT COUNT(*) AS c FROM tbl_post WHERE status = '1'")->row()->c;
        $this->view_data['stat_requests'] = (int) $this->db->query("SELECT COUNT(*) AS c FROM tbl_request")->row()->c;
    } //index

}//class

?>