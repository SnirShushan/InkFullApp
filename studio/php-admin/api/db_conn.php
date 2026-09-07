<?php
    include_once __DIR__."/../vendor/autoload.php";
    $dotenv = Dotenv\Dotenv::createImmutable(__DIR__."/..");
    $dotenv->load();
    // API must return pure JSON — never echo PHP warnings/deprecations.
    error_reporting(E_ERROR | E_PARSE);
    ini_set('display_errors', '0');
    ini_set('html_errors', '0');
    // date_default_timezone_set('America/New_York');
    date_default_timezone_set('Asia/Kolkata');
    $servername=$_ENV['DB_HOST'];
    $username=$_ENV['DB_USER'];
    $password=$_ENV['DB_PASS'];
    $dbname=$_ENV['DB_NAME'];
    $base_url = $_ENV['SITE_URL']."api";


    $db_old = new mysqli($servername,$username,$password,$dbname);
        if($db_old->connect_error){
            die("Connection failed : ".$db_old->connect_error);
        }
    if($_ENV['db_env']=="ci")
    {
        // new db connection
        require_once __DIR__."/../lib/db/index.php";
        
        $db_config = array(
            'dsn'	=> '',
            'hostname' => $servername,
            'username' => $username,
            'password' => $password,
            'database' => $dbname,
            'dbdriver' => 'mysqli',
            'dbprefix' => '',
            'pconnect' => FALSE,
            'db_debug' => false,
            
            //'cache_on' => FALSE,
            //'cachedir' => '',
            'cache_on' => false,
            //'cachedir' => CI_DRIVER_APPPATH.'cache',
        
            'char_set' => "utf8mb4",// 'utf8',
            'dbcollat' => 'utf8mb4_general_ci',
            'swap_pre' => '',
            'encrypt' => FALSE,
            'compress' => FALSE,
            'stricton' => FALSE,
            'failover' => array(),
            'save_queries' => TRUE,
        );
        
        $db = Codeigniter3\DatabaseDriver\database_connect($db_config);

        if(!function_exists('get_settings')){
            function get_settings(){
                global $db;
                $setting=[];
    
                $select_setting = "SELECT * FROM tbl_settings";
                $result_setting = $db->query($select_setting);
                if($result_setting)
                {
                    if($result_setting->num_rows() > 0){
                        foreach($result_setting->result_array() as $setting_row){
                            $setting[$setting_row['field_name']]=$setting_row['field_value'];
                        }
                        return $setting;
                    }
                }
                
            }
        }

    }else{
        
        $db = new mysqli($servername,$username,$password,$dbname);
        if($db->connect_error){
            die("Connection failed : ".$db->connect_error);
        }
        if(!function_exists('get_settings')){
            function get_settings(){
                global $db_old;
                $setting=[];
    
                $select_setting = "SELECT * FROM tbl_settings";
                $result_setting = $db_old->query($select_setting);
                if($result_setting)
                {
                    if($result_setting->num_rows > 0){
                        while($setting_row=$result_setting->fetch_assoc()){
                            $setting[$setting_row['field_name']]=$setting_row['field_value'];
                        }
                        return $setting;
                    }
                }
                
            }
        }

    }


    
    
    
    $db->query("SET SESSION sql_mode = 'NO_ENGINE_SUBSTITUTION' ; ");

    $app_title=$_ENV['APP_NAME'];
        
        
    define("BASEURL", $base_url);
        
    define("APPTITLE", $app_title);
?>