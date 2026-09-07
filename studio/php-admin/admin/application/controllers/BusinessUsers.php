<?php

defined('BASEPATH') or exit('No direct script access allowed');

class BusinessUsers extends MY_Controller

{

    public function __construct()
    {
        parent::__construct();
        //$this->load->model("Customers_model");
    }

    public function index()
    {
        $this->view_data['title'] = $this->settings['hebrew_text']['Business Users'];

        $this->view_data['menu'] = "Business Users";

        $this->view_data['back_button'] = base_url();

        $this->view_data['page_heading'] = $this->settings['hebrew_text']['Business Users'];

        $this->view_data['page_sub_heading'] = "";

        $this->view_data['arr_breadcrumb'] = array($this->settings['hebrew_text']['home'] => base_url("Dashboard"));

        $this->view_data['breadcrumb_home_logo'] = '<i class="icon-home"></i>';


        $this->layout_view = "layout/ltf_default";

        if ($this->auth->is_login() == false) {

            redirect(base_url('login'));
        }
    } //index

}//class
