<?php 
include_once __DIR__."/../vendor/autoload.php";
$dotenv = Dotenv\Dotenv::createImmutable(__DIR__."/..");
$dotenv->load();
$servername=$_ENV['DB_HOST'];
$username=$_ENV['DB_USER'];
$password=$_ENV['DB_PASS'];
$dbname=$_ENV['DB_NAME'];
$base_url = $_ENV['SITE_URL']."api";
$db_old = new mysqli($servername,$username,$password,$dbname);
        if($db_old->connect_error){
            die("Connection failed : ".$db_old->connect_error);
        }
        else{
            echo "Connected";
        }

        
exit;
?>