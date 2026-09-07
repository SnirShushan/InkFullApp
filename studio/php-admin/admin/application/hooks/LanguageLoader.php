<?php
class LanguageLoader
{
    function initialize() {
        $ci =& get_instance();
        $ci->load->helper('language');
        $ci->config->load('setting');

        $default_language = $ci->config->item('default_language');
        $default_language_message = $ci->config->item('default_language_message');
        $default_language_library = $ci->config->item('default_language_library');

        if( !is_array($default_language_library) )
        { $default_language_library = array($default_language_library); }
        $default_language = ($default_language)?$default_language:'english';


        $site_lang = $ci->session->userdata('site_lang');
        if ($site_lang) {

            if( $ci->session->userdata('site_lang') != "english" ){
                $ci->config->set_item('language', $ci->session->userdata('site_lang'));  
                $ci->lang->is_loaded = array();
                if( count($default_language_library) > 0 ){
                    foreach ($default_language_library as $key => $language_lib) {
                        $ci->lang->load($language_lib, $ci->session->userdata('site_lang'));
                    }
                }
            }

            if( $default_language_message ){
                $ci->lang->load($default_language_message ,$ci->session->userdata('site_lang'));
            }

        } else {

            if( $default_language != "english" ){
                $ci->config->set_item('language', $default_language);  
                $ci->lang->is_loaded = array();
                if( count($default_language_library) > 0 ){
                    foreach ($default_language_library as $key => $language_lib) {
                        $ci->lang->load($language_lib, $default_language );
                    }
                }
            }

            if( $default_language_message ){
                $ci->lang->load($default_language_message ,$default_language);
            }
        }
        
    }
}
