<?php

defined('BASEPATH') or exit('No direct script access allowed');

// use Google\Cloud\Firestore\FirestoreClient;

class Products extends MY_Controller

{

	public function __construct()
	{
		parent::__construct();
	}



	public function index()
	{
		$this->view_data['title'] = "";

		$this->view_data['menu'] = "Products";

		$this->view_data['back_button'] = base_url();

		$this->view_data['page_heading'] = "";

		$this->view_data['page_sub_heading'] = "";

		$this->view_data['arr_breadcrumb'] = array("Home" => base_url("Dashboard"));

		$this->view_data['breadcrumb_home_logo'] = '<i class="icon-home"></i>';
		$this->layout_view = "layout/ltf_default";
		if ($this->auth->is_login() == false) {
			redirect(base_url('login'));
		}

		// Firestore product listing is disabled; keep view safe with an empty list
		$this->view_data['my_data'] = array();

		// $firestore = new FirestoreClient(['keyFilePath' => __DIR__ . "../../../firebase_config/download.json"]);
		// $productsRef = $firestore->collection('products');
		// $query = $productsRef->where('sellerUid', '=', 'cYqZe9pUBSY7NCfhZnibxwJyzt32');
		// $documents = $query->documents();
		// // foreach ($documents as $document) {
		// // 	if ($document->exists()) {
		// $this->view_data['my_data'] = $documents;
		// 	}
		// }

		// echo "<pre>";
		// print_r($this->view_data['my_data']);
		// exit;
	} //index 




}//class
