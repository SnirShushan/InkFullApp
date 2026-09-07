<?php
defined('BASEPATH') OR exit('No direct script access allowed');

class Migration extends CI_Controller 
{

	public function __construct()
	{
		parent:: __construct();
		$this->auth->valid_login();
	}

	public function index()
	{
	}

	public function create_view()
	{
		$sqlDrop = "DROP VIEW IF EXISTS view_posts;";
		$sqlView = "CREATE VIEW view_posts as 

			SELECT p.* ,

				(SELECT COUNT(DISTINCT v.uid) FROM tbl_posts_view as v WHERE v.pid = p.id LIMIT 1) as 'view_count',
				(SELECT COUNT(DISTINCT r.uid) FROM tbl_posts_read as r WHERE r.pid = p.id LIMIT 1) as 'read_count',

				(SELECT COUNT(*) FROM tbl_posts_view as v WHERE v.pid = p.id LIMIT 1) as 'view_count_total',
				(SELECT COUNT(*) FROM tbl_posts_read as r WHERE r.pid = p.id LIMIT 1) as 'read_count_total'

			FROM tbl_posts as p
		";

		$this->db->query($sqlDrop);
		$this->db->query($sqlView);
		echo "View updated";
	}


}