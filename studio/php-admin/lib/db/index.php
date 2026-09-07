<?php 
namespace Codeigniter3\DatabaseDriver;
use Codeigniter3\DatabaseDriver;

define('CI_DRIVER_BASEPATH',__DIR__."/");
define('CI_DRIVER_APPPATH',__DIR__."/");

require_once(CI_DRIVER_BASEPATH.'functions.php');
require_once(CI_DRIVER_BASEPATH.'DB_driver.php');
require_once(CI_DRIVER_BASEPATH.'DB_driver.php');
require_once(CI_DRIVER_BASEPATH.'DB_query_builder.php');

function database_connect( $params )
{

	class CI_DB extends CI_DB_query_builder { }
	//class CI_DB extends CI_DB_driver { }

	// Load the DB driver
	$driver_file = CI_DRIVER_BASEPATH.'drivers/'.$params['dbdriver'].'/'.$params['dbdriver'].'_driver.php';

	require_once($driver_file);

	// Instantiate the DB adapter
	$driver = 'Codeigniter3\DatabaseDriver\CI_DB_'.$params['dbdriver'].'_driver';
	$DB = new $driver($params);

	$DB->initialize();

	return $DB;
}
