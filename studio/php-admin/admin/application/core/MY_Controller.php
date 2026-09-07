<?php

class MY_Controller extends CI_Controller

{

	protected $userdata = NULL;

	protected $content_view = "";

	protected $layout_view = "layout/ltf_default";



	protected $include_css = array();

	protected $include_js = array();

	protected $side_list = "";

	//protected $layout_view="layout/ltf_default";

	public $category_list = array();

	protected $view_data = array();

	var $settings = array();



	public function __construct()

	{

		parent::__construct();



		$this->load->database();

		if (!$this->db->table_exists('tbl_settings')) {

			redirect(base_url("Migration_tbl"));
		}

		$result_settings = $this->db->query("select * from tbl_settings");

		if ($result_settings->num_rows() > 0) {

			foreach ($result_settings->result() as $field_row) {

				$this->settings[$field_row->field_name] = $field_row->field_value;
			}
		}

		// Defaults so missing tbl_settings rows do not trigger PHP warnings
		$settings_defaults = array(
			'name' => 'Ink',
			'layout' => 'layout/ltf_default',
			'theam_color' => 'default',
			'app_logo' => '',
			'favicon' => '',
			'footer_text' => '',
			'danger_color' => 'red',
			'success_color' => 'green-jungle',
			'warning_button_color' => 'yellow-crusta',
			'admin_email' => '',
			'admin_phone' => '',
			'startup_image' => '',
			'package_name' => '',
			'post_limit' => '0',
		);
		foreach ($settings_defaults as $key => $value) {
			if (!array_key_exists($key, $this->settings)) {
				$this->settings[$key] = $value;
			}
		}
		if (empty($this->settings['layout'])) {
			$this->settings['layout'] = 'layout/ltf_default';
		}
		if (empty($this->settings['theam_color'])) {
			$this->settings['theam_color'] = 'default';
		}
		if (empty($this->settings['name'])) {
			$this->settings['name'] = 'Ink';
		}

		if (function_exists('is_local_admin_request') && is_local_admin_request() && isset($this->auth)) {
			$this->auth->is_login();
		}



		$cat_list = array();
		$this->category_list = $cat_list;





		$hebrew_text = array(
			"status" => "להציג מוצר באתר?",
			"active" => "פעיל",
			"back" => "חזור",
			"home" => "בית",
			"logout" => "יציאה",
			"select_icon" => "בחר אייקון",
			"Add" => "הוסף",
			"Update" => "עדכון",
			"Remove" => "הסר",
			"Edit" => "עדכון",
			'on' => "פעיל",
			'off' => "כבוי",
			'yes' => "כן",
			'no' => "לא",
			"edit_alt_text_title" => "Edit",
			"update_text" => "Update",
			"yes_btn_text" => "כן, מחק!",
			"no_btn_text" => "לא, בטל!",
			"Products" => "Products",
			"settings" => "Settings",
			"change_password" => "Change Password",
			"Manage Customers" => "Manage Customers",
			"Business Users" => "Business Users",
			"Regular Users" => "Regular Users",
			"Report on User" => "Report on User",
			"Report on Post" => "Report on Post",
			"Requests" => "Requests",
			"Subscribers" => "Subscribers",
			"cust_name" => "Name",
			"cust_email" => "E-Mail",
			"cust_phone" => "Phone",
			"cust_register_type" => "Register Type",
			"cust_user_type" => "User Type",
			"cust_status" => "Status",
			"reported_by_user" => "Reported By User",
			"comment" => "Comment",
			"Owner" => "Post Owner",
			"Post" => "Post",
			"Action" => "Action",
			"Tattoo Size" => "Tattoo Size",
			"Business" => "Business",
			"Artist" => "Artist",
			"Request Addedd" => "Request Addedd",
			"User Name" => "User Name",
			"Request Details" => "Request Details",
			"Request Images" => "Request Images",
			"Dashboard" => "Dashboard",
			"Start Date" => "Start Date",
			"End Date" => "End Date",
			"Reset Filter" => "Reset Filter",
			"Send Push Notification" => "Send Push Notification",
			"Title" => "Title",
			"Description" => "Description",
			"Please select user for send push notification" => "Please select user for send push notification",
			"Push Notification send Successfully" => "Push Notification send Successfully",
			"current_password" => "current_password",
			"new_password" => "new_password",
			"confirm_password" => "confirm_password",
			"subscription_plan"=>"Subscription Plan",
			"exp_date"=>"Exp. Date",
			"plan_status"=>"Plan Status",
			"image_limit"=>"Image Limit",
			"view_signature"=>"View Signature",
		);



		if ($this->settings['layout'] != "layout/ltf_default") {

			/*	$hebrew_text = array(

			"status" => "להציג מוצר באתר?",
			"active" => "פעיל",
			"back" => "חזור",
			"home" => "בית",
			"logout" => "יציאה",
			"select_icon" => "בחר אייקון",
			"Add" => "הוסף",
			"Update" => "עדכון",
			"Remove" => "הסר",
			"Edit" => "עדכון",
			'on' => "פעיל",
			'off' => "כבוי",
			'yes' => "כן",
			'no' => "לא",
			"edit_alt_text_title" => "Edit",
			"update_text" => "Update",
			"yes_btn_text" => "כן, מחק!",
			"no_btn_text" => "לא, בטל!",
			);*/
		}





		//$this->load->helper('language');

		//$this->lang->load('message','hebrew');

		//$var=$this->lang->language;

		//$hebrew_text=array_merge($var,$hebrew_text);



		$this->settings["hebrew_text"] = $hebrew_text;
		$ci = get_instance();
		$ci->config->set_item("hebrew_text", $hebrew_text);

		//$ci->output->cache(1); 

		//$ci->output->cache(1); 
		//$ci->output->clear_all_cache();


		/////////////////////// DEFAULT INCLUDE CSS

		array_push($this->include_css, "global/plugins/font-awesome/css/font-awesome.min.css");

		array_push($this->include_css, "global/plugins/simple-line-icons/simple-line-icons.min.css");

		array_push($this->include_css, "global/plugins/bootstrap/css/bootstrap.min.css");

		array_push($this->include_css, "global/plugins/bootstrap-switch/css/bootstrap-switch.min.css");

		array_push($this->include_css, "global/plugins/sweetalert/lib/sweet-alert.css");

		array_push($this->include_css, "global/plugins/bootstrap-summernote/summernote.css");

		array_push($this->include_css, "global/css/components.css");

		array_push($this->include_css, "global/css/plugins.min.css");

		array_push($this->include_css, "layouts/layout/css/layout.css");

		array_push($this->include_css, "layouts/layout/css/themes/" . $this->settings['theam_color'] . ".min.css");

		array_push($this->include_css, "layouts/layout/css/custom.min.css");

		array_push($this->include_css, "pages/css/custom.css");

		array_push($this->include_css, "global/plugins/crop_image/css/cropper.css");

		array_push($this->include_css, "tags/bootstrap-tagsinput.css");

		array_push($this->include_css, "global/plugins/select2/css/select2.min.css");

		array_push($this->include_css, "global/plugins/select2/css/select2-bootstrap.min.css");

		array_push($this->include_css, "global/plugins/bootstrap-multiselect/css/bootstrap-multiselect.css");

		array_push($this->include_css, "global/plugins/metisMenu/dist/metisMenu.css");



		array_push($this->include_css, "global/plugins/datatables/datatables.min.css");

		array_push($this->include_css, "global/plugins/datatables/plugins/bootstrap/datatables.bootstrap.css");

		array_push($this->include_css, "global/plugins/ladda/ladda-themeless.min.css");

		array_push($this->include_css, "layouts/layout/css/modern-admin.css");



		//assets/global/plugins/bootstrap-multiselect/css/bootstrap-multiselect.css



		// array_push($this->include_css,"global/plugins/colorpicker/css/evol-colorpicker.min.css");





		// <link href="../assets/global/plugins/select2/css/select2-bootstrap.min.css" rel="stylesheet" type="text/css" />





		// array_push($this->include_css,"global/plugins/bootstrap-multiselect/css/bootstrap-multiselect.css");

		//<link href="../assets/global/plugins/bootstrap-multiselect/css/bootstrap-multiselect.css" rel="stylesheet" type="text/css" />

		/////////////////////// END DEFAULT INCLUDE CSS









		/////////////////////// DEFAULT INCLUDE JS

		array_push($this->include_js, "global/plugins/jquery.min.js");

		array_push($this->include_js, "global/plugins/bootstrap/js/bootstrap.min.js");

		array_push($this->include_js, "global/plugins/js.cookie.min.js");

		array_push($this->include_js, "global/plugins/jquery-slimscroll/jquery.slimscroll.min.js");

		array_push($this->include_js, "global/plugins/jquery.blockui.min.js");

		array_push($this->include_js, "global/plugins/bootstrap-switch/js/bootstrap-switch.min.js");

		array_push($this->include_js, "global/plugins/sweetalert/lib/sweet-alert.min.js");



		array_push($this->include_js, "global/plugins/ladda/spin.min.js");

		array_push($this->include_js, "global/plugins/ladda/ladda.min.js");



		array_push($this->include_js, "global/scripts/app.min.js");

		array_push($this->include_js, "layouts/layout/scripts/layout.min.js");

		array_push($this->include_js, "layouts/layout/scripts/demo.min.js");

		array_push($this->include_js, "layouts/global/scripts/quick-sidebar.min.js");

		array_push($this->include_js, "global/plugins/ckeditor/ckeditor.js");

		array_push($this->include_js, "tags/bootstrap-tagsinput.js");

		array_push($this->include_js, "global/plugins/crop_image/js/cropper.js");

		array_push($this->include_js, "global/plugins/bootstrap-multiselect/js/bootstrap-multiselect.js");

		array_push($this->include_js, "global/plugins/select2/js/select2.full.min.js");

		array_push($this->include_js, "global/plugins/metisMenu/dist/metisMenu.min.js");

		array_push($this->include_js, "global/plugins/metisMenu/dist/jquery-sortable.js");

		array_push($this->include_js, "global/plugins/datatables/datatables.min.js");

		array_push($this->include_js, "global/plugins/datatables/plugins/bootstrap/datatables.bootstrap.js");

		array_push($this->include_js, "global/plugins/datatables/plugins/bootstrap/datatables.bootstrap.js");

		array_push($this->include_js, "pages/scripts/ui-buttons-spinners.min.js");

		array_push($this->include_js, "access_js.js?ver=" . rand());









		// array_push($this->include_js,"pages/scripts/components-select2.min.js");

		//global/plugins/bootstrap-multiselect/js/bootstrap-multiselect.js

		// array_push($this->include_js,"global/plugins/colorpicker/js/evol-colorpicker.js");











		//<script src="../assets/pages/scripts/components-select2.min.js" type="text/javascript"></script>

		//<script src="../assets/global/plugins/select2/js/select2.full.min.js" type="text/javascript"></script>



		/////////////////////// END DEFAULT INCLUDE JS

		$this->layout_view = $this->settings['layout'];
	}



	public function check_permission($arr, $name)

	{

		foreach ($arr as $key => $value) {

			if ($key == $name) {

				if ($value == 1)

					return 1;
			}
		}

		return 0;
	} /// check permission for admin pages



	public function _output()

	{



		if ($this->content_view !== FALSE && empty($this->content_view))

			$this->content_view = $this->router->class . '/' . $this->router->method;





		// selecting view and make data

		$content_data = file_exists(APPPATH . 'views/' . $this->content_view . EXT) ? $this->load->view($this->content_view, $this->view_data, TRUE) : FALSE;



		$this->side_list = $this->load->view('layout/slider_data.php', array("data" => $content_data, "include_css" => $this->include_css, "include_js" => $this->include_js), TRUE);

		// put data into the layout

		if ($content_data) {

			echo $this->load->view($this->layout_view, array("data" => $content_data, "include_css" => $this->include_css, "include_js" => $this->include_js, "side_list" => $this->side_list), TRUE);
		} else {

			echo "file does not exists";
		}
	}
}
