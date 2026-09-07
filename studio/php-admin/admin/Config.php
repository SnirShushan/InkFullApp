<?php



    //require_once FCPATH."Config.php";



/*    define('BASE_URL_CONFIG', 'http://localhost/app/BaseCamp/admin/');



    define('SITE_URL_CONFIG', 'http://localhost/app/BaseCamp/');



    define('PASSWORD_NAME_SET', '');



    define('DATABASE_NAME_SET', 'basecamp');



    define('HOSTNAME_SET', 'localhost');    



    define('USER_NAME_SET', 'root');*/



    //include_once '../Credentials.php';



    define('HOSTNAME_SET', $_ENV['DB_HOST']);

    define('USER_NAME_SET',$_ENV['DB_USER']);

    define('PASSWORD_NAME_SET', $_ENV['DB_PASS']);

    define('DATABASE_NAME_SET', $_ENV['DB_NAME']);

    define('BASE_URL_FRONT', $_ENV['SITE_URL']);
    

    define('DATABASE_CHARSET',$_ENV['DB_CHARSET']);

    

    //config of file upload 

    define('UPLOAD_PATH', '../assets/images/feeds/');





    define('UPLOAD_IMG_PATH', "../assets/images/feeds/");

    define('UPLOAD_IMG_PATH_THUMB', "../assets/images/feeds/thumb/");



    define('UPLOAD_PDF_PATH', "../assets/images/feeds/");

    define('UPLOAD_PDF_PATH_THUMB', "../assets/images/feeds/thumb/");



    define("GOOGLE_API_KEY", "AIzaSyANbPrUt4-CljdYk9GTh7g0Yh0_jGvKg_M");



define("GOOGLE_API_KEY_AndroidPushNotification", "AIzaSyDopAcF-awufYIZLTV6kfgSN2abP8Vl2W0");





define("DEVELOPER_MODE", "true");



?>