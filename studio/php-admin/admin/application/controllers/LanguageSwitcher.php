<?php
defined('BASEPATH') OR exit('No direct script access allowed');
ini_set('memory_limit', '256M');

class LanguageSwitcher extends CI_Controller
{
    public function __construct()
    {
        parent::__construct();
    }

    function switchLang($language = "") {
        $language = ($language != "") ? $language : "hebrew";
        $this->session->set_userdata('site_lang', $language);
        redirect($_SERVER['HTTP_REFERER']);
    }
}
?>