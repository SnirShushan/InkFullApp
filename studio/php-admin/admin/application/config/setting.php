<?php
defined('BASEPATH') OR exit('No direct script access allowed');

/*
	Website default language ( store in sesstion ['site_lang'] )
	if not found lang name so default is loaded by hooks
*/
$config['default_language'] = 'english';

/*
	language as custome labels sore in file prefix name
	default is null ( so not loaded )
	if set message so loaded file from below
	contain in application\language\english\message_lang.php
*/
$config['default_language_message'] = 'message';

/*  this is just infomation 
	url : https://github.com/bcit-ci/codeigniter3-translations

	CodeIgniter message translations labguage default in english
	if you want to change it to others languages so set here

	available for following library ( updated 16-07-2018 from codeigniter3-translations )

	calendar_lang , date_lang , db_lang , email_lang , form_validation_lang , ftp_lang , imglib_lang , migration_lang , number_lang , pagination_lang , profiler_lang , unit_test_lang , upload_lang 

	default all loaded

*/
$config['default_language_library'] = array();

//here set custome setting start
$config['upload_path'] = UPLOAD_PATH;

