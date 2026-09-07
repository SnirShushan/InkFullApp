<?php 
    include_once __DIR__."/../vendor/autoload.php";
    $dotenv = Dotenv\Dotenv::createImmutable(__DIR__."/..");
    $dotenv->load();
    $servername=$_ENV['DB_HOST'];
    $username=$_ENV['DB_USER'];
    $password=$_ENV['DB_PASS'];
    $dbname=$_ENV['DB_NAME'];
    $base_url = $_ENV['SITE_URL']."api";

    if($_ENV['db_env']=="ci")
    {
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
        if($db->conn_id)
        {
            echo "Connected";
        }
        else{
            echo "Connection failed";
        }
    }
exit;
?>