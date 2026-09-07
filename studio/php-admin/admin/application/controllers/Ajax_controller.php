<?php
defined('BASEPATH') or exit('No direct script access allowed');
ini_set('memory_limit', '256M');
ini_set('max_execution_time', '0');

use PhpOffice\PhpSpreadsheet\Spreadsheet;
use PhpOffice\PhpSpreadsheet\Reader;
use Google\Client;
use Google\Service\AndroidPublisher;
use Google\Auth\Credentials\ServiceAccountCredentials;
use Google\Auth\HttpHandler\HttpHandlerFactory;

class ajax_controller extends CI_Controller
{



    /*
        UPLOAD_IMG_PATH
        UPLOAD_IMG_PATH_THUMB
        UPLOAD_PDF_PATH
        UPLOAD_PDF_PATH_THUMB
    */

    public function __construct()
    {
        parent::__construct();
        $this->load->database();
        $result_settings = $this->db->query("select * from tbl_settings");
        if ($result_settings->num_rows() > 0) {
            foreach ($result_settings->result() as $field_row) {
                $this->settings[$field_row->field_name] = $field_row->field_value;
            }
        }

        if ($this->router->class == "Ajax_controller" && ($this->router->method == "upload_product_csv_file" || $this->router->method == "exportEtpCsvNew" || $this->router->method == "exportCity" || $this->router->method == "exportShipping")) {
        } else {
            $this->auth->valid_login();
        }
        //$this->auth->valid_login();
        $this->load->library('pagination');
        $this->load->library('Cropimg');
        $this->load->model('ReportOnUsers_model');
        $this->load->model('Customer_model');

    }

    public function test()
    {
        echo "url : " . __DIR__.'../../../../api/ink-flutter-app-2ff19eb8244b.json';
        exit;
    }

    public function index()
    {
        //echo "Test";
        /*
        $result=$this->db->query("select * from tbl_products");
        if($result)
        {
            if($result->num_rows()>0)
            {
                foreach ($result->result() as $row) {
                    $sort=0;
                    if($row->price_kg<=0)
                    {
                        $sort=$row->price_unit;
                    }else{
                        $sort=$row->price_kg;
                    }
                    $this->db->query("update tbl_products set sort_price='$sort' where id='$row->id'");
                }
            }
        }*/
    }







 
    public function delete_customer_user()
    {
        $post = $this->input->post();
        if (!empty($post['uid'])) {
            $id = $this->input->post("uid");
            $this->user_model->update_user_detail($id, array("is_delete" => 1));
        }
    }



    public function remove_tag()
    {
        $post = $this->input->post();
        if (!empty($post['id'])) {
            $id = $this->input->post("id");
            $this->db->where("id", $id)->limit(1)->delete("tbl_tags");
        }
    }





  







    public function upload_image()
    {
        $post = $this->input->post();
        $result = $_FILES;
        $file_name = "";
        $msg = "Please select image file";
        $error = "";
        $status = 0;
        if (isset($_FILES['image_file']['name']) && !empty($_FILES['image_file']['name'])) {

            $config['upload_path']          = '../assets/upload/icons/';
            $config['allowed_types']        = 'jpeg|jpg|gif|png';
            $config['max_size']             = (1024 * 20);
            $config['encrypt_name'] = FALSE;
            $config['file_name'] = date("Y-m-d-H-i-s") . "_" . rand(1000, 9999);
            $this->load->library('upload', $config);
            $this->upload->initialize($config);
            $config = array();
            if (!$this->upload->do_upload('image_file')) {
                $error = $this->upload->display_errors();
                $status = 0;
                $msg = $error;
            } else {
                $status = 1;
                $data = $this->upload->data();
                $msg = $data['file_name'];
                $file_name = $data['file_name'];
                $url = config("site_url") . "/assets/upload/icons/" . $file_name;
                $msg = "<a href='" . $url . "' target='_blank'><span class='label label-primary' >" . $_FILES['image_file']['name'] . "</span></a>";
            }
        } //if pdf file is uploaded or not
        echo json_encode(array("status" => $status, "error" => $error, "msg" => $msg, "file_name" => $file_name));
    } //image upload



    public function upload_slider_image()
    {
        $post = $this->input->post();
        $result = $_FILES;
        $file_name = "";
        $msg = "Please select image file";
        $error = "";
        $status = 0;
        $url = "";
        if (isset($_FILES['image_file']['name']) && !empty($_FILES['image_file']['name'])) {

            $config['upload_path']          = '../assets/images/slider/';
            $config['allowed_types']        = 'jpeg|jpg|gif|png';
            $config['max_size']             = (1024 * 20);
            $config['encrypt_name'] = FALSE;
            $config['file_name'] = date("Y-m-d-H-i-s") . "_" . rand(1000, 9999);
            $this->load->library('upload', $config);
            $this->upload->initialize($config);
            $config = array();
            if (!$this->upload->do_upload('image_file')) {
                $error = $this->upload->display_errors();
                $status = 0;
                $msg = $error;
            } else {
                $status = 1;
                $data = $this->upload->data();
                $msg = $data['file_name'];
                $file_name = $data['file_name'];
                $url = config("site_url") . "/assets/images/slider/" . $file_name;
                $msg = "<a href='" . $url . "' target='_blank'><span class='label label-primary' >" . $_FILES['image_file']['name'] . "</span></a>";
            }
        } //if pdf file is uploaded or not

        if ($status == 0) {
            $custom_error = array();
            $custom_error['jquery-upload-file-error'] = $msg;
            $custom_error['error_msg'] = $msg;
            $custom_error['status'] = $status;
            echo json_encode($custom_error);
        } else {
            $res['data'] = ['filename' => $file_name, 'status' => $status, 'file_type' => "", "full_path" => $url];
            echo json_encode($res);
        }
    } //upload_slider_image



 // export city



    function uncode_str($str)
    {
        //return mb_convert_encoding($str,'ISO-8859-15','utf-8');;
        // return utf8_encode($str);
        return $str;
    }

    function convertToISOCharset($array)
    {
        foreach ($array as $key => $value) {
            if (is_array($value)) {
                $array[$key] = $this->convertToISOCharset($value);
            } else {
                //$array[$key] = mb_convert_encoding($value, 'ISO-8859-8', 'UTF-8');
                $array[$key] = mb_convert_encoding($value, 'ISO-8859-8', 'UTF-8');
            }
        }

        return $array;
    }




    public function uncode_str1($str)
    {
        //return mb_convert_encoding($str,'ISO-8859-15','utf-8');;
        // return utf8_decode($str);
        return $str;
    }


    public function file_check($str)
    {
        $allowed_mime_type_arr = array('image/gif', 'image/jpeg', 'image/pjpeg', 'image/png', 'image/x-png');

        $mime = mime_content_type($_FILES['file']['tmp_name']);
        if (isset($_FILES['file']['tmp_name']) && $_FILES['file']['tmp_name'] != "") {
            if (in_array($mime, $allowed_mime_type_arr)) {
                return true;
            } else {
                $this->form_validation->set_message('file_check', 'Please select only jpg/jpeg/png file.');
                return false;
            }
        } else {
            $this->form_validation->set_message('file_check', 'Please choose a file to upload.');
            return false;
        }
    }


    public function popup_image_upload_crop()
    {
        try {
            $pid = $this->input->post("pid");

            $status = 0;
            $path = '/';
            $data = "";
            $data1 = "";
            $error_msg = "";
            $name = "";
            $config['upload_path'] = "../assets/upload/popups/";
            $config['allowed_types'] = '*';
            $config['remove_spaces'] = TRUE;
            $config['encrypt_name'] = TRUE;
            $this->load->library('upload', $config);
            $this->upload->initialize($config);

            $this->form_validation->set_rules('file', '', 'callback_file_check');
            if ($this->form_validation->run() == true) {
                if (!$this->upload->do_upload('file')) {
                    $error_msg = $this->upload->display_errors();
                    $status = 0;
                } else {
                    $fileName = $this->upload->data();
                    $error_msg = $fileName;
                    $status = 1;
                    $name = $fileName['file_name'];
                }
            } else {
                $error_msg = validation_errors();
                $status = 0;
            }

            echo json_encode(array('status' => $status, "msg" => $error_msg, "image_name" => $name, "data" => $data1, "filename" => $name, "html" => $data, "img_tag_name" => "", "full_path" => getSetting("site_url") . "assets/upload/popups/" . $name));
        } catch (Exception $e) {
            echo json_encode(array('status' => 0, "msg" => $e->getMessage(), "image_name" => "", "filename" => "", "html" => "", "img_tag_name" => "", "full_path" => getSetting("site_url") . "assets/upload/popups/"));
        }
    } //popup_image_upload_crop

    public function popup_image_upload()
    {
        $post = $this->input->post();
        $result = $_FILES;
        $file_name = "";
        $img_tag_name = "";
        $msg = "Please select image file";
        $error = "";
        $status = 0;
        $html = "";
        if (isset($_FILES['file']['name']) && !empty($_FILES['file']['name'])) {

            $config['upload_path']          = '../assets/upload/popups/';
            $config['allowed_types']        = 'jpeg|jpg|gif|png';
            $config['max_size']             = (600 * 200);
            $config['encrypt_name'] = FALSE;
            $config['file_name'] = date("Y-m-d-H-i-s") . "_" . rand(1000, 9999);
            $this->load->library('upload', $config);
            $this->upload->initialize($config);
            $config = array();
            if (!$this->upload->do_upload('file')) {
                $error = $this->upload->display_errors();
                $status = 0;
                $msg = $error;
            } else {
                $status = 1;
                $data = $this->upload->data();
                $msg = $data['file_name'];
                $file_name = $data['file_name'];
                $url = config("site_url") . "/assets/upload/icons/" . $file_name;
                $msg = "<a href='" . $url . "' target='_blank'><span class='label label-primary' >" . $_FILES['file']['name'] . "</span></a>";
                $pid = $this->input->post("pid");
                $item_data = array();
                $item_data['img'] = BASE_URL_FRONT . "assets/upload/popups/" . $file_name;
                $item_data['pid'] = $pid;
                $item_data['id'] = 0;
                $item_data['name'] = $file_name;
                $html = $this->load->view('templetes/uploaded_img', $item_data, true);
                $msg = "";
                $img_tag_name = "<input type='hidden' value='" . $file_name . "' name='popup_image_names' id='popup_image_names' >";
                $html = str_replace("col-md-2", "", $html);
            }
        } //if pdf file is uploaded or not
        echo json_encode(array('status' => $status, "filename" => $file_name, "error" => $msg, "html" => $html, "img_tag_name" => $img_tag_name));
    } //image upload

    public function tag_image_upload()
    {
        $post = $this->input->post();
        $result = $_FILES;
        $file_name = "";
        $img_tag_name = "";
        $msg = "Please select image file";
        $error = "";
        $status = 0;
        $html = "";
        if (isset($_FILES['file']['name']) && !empty($_FILES['file']['name'])) {

            $config['upload_path']          = '../assets/upload/tags/';
            $config['allowed_types']        = 'jpeg|jpg|gif|png';
            $config['max_size']             = (600 * 200);
            $config['encrypt_name'] = FALSE;
            $config['file_name'] = date("Y-m-d-H-i-s") . "_" . rand(1000, 9999);
            $this->load->library('upload', $config);
            $this->upload->initialize($config);
            $config = array();
            if (!$this->upload->do_upload('file')) {
                $error = $this->upload->display_errors();
                $status = 0;
                $msg = $error;
            } else {
                $status = 1;
                $data = $this->upload->data();
                $msg = $data['file_name'];
                $file_name = $data['file_name'];
                $ins = array("image_name" => $data['file_name'], "title" => $this->input->post("title", TRUE), "alt_text" => $this->input->post("alt_text", TRUE));
                $this->db->insert("tbl_tags", $ins);
            }
        } //if pdf file is uploaded or not
        echo json_encode(array('status' => $status, "filename" => $file_name, "error" => $msg, "html" => $html, "img_tag_name" => $img_tag_name));
    } //tag image upload
   
  
 
 

    //// THIS IS THE WORKING FUNCTION AND USING THIS FOR UPLOAD/IMPORT PRODUCT FROM THE FTP
    public function test_upload()
    {
        try {
            ini_set('auto_detect_line_endings', TRUE);

            $file_name = "";
            $error_msg = "";

            $t = array();


            $data1 = array();
            $reader = new \PhpOffice\PhpSpreadsheet\Reader\Csv();
            //$reader->setInputEncoding('ISO-8859-8');
            $reader->setInputEncoding('Windows-1255');
            $reader->setDelimiter(',');
            $reader->setEnclosure('');


            //$csv_data=file_get_contents("/var/www/html/staging/uploads/ProductsAll.csv");
            //file_put_contents("/var/www/html/staging/uploads/products_modified_t.csv", $csv_data);
            //$this_dir = dirname(__FILE__);
            //$parent_dir = realpath($this_dir . '/../../..');
            //$target_path = $parent_dir . '/';
            //$filename=$target_path."/var/www/html/staging/uploads/ProductsAll.csv";
            //$spreadsheet = $reader->load("../../hahaklai.co.il/productfeed/products.csv");


            $spreadsheet = $reader->load("../uploads/products_city.csv");
            $sheetData   =  $spreadsheet->getActiveSheet()->toArray(null, true, true, true);
            $test_row = "";
            $total_Rows = 0;
            $col = 0;

            foreach ($sheetData as $row) {

                if ($col == 0) {
                    $col = 1;
                    continue;
                }
                $total_Rows++;

                $this->db->insert("tbl_city_list", ['name_he' => $row['B'], 'name_en' => $row['C'], 'date_added' => date("Y-m-d h:i:s")]);

                $col++;
            }




            echo json_encode(array("status" => 1, "msg" => " הסנכרון בוצע בהצלחה ", "dd" => "", "d" => $total_Rows, "sheet" => "", "test_row" => count($sheetData)));
        } catch (Exception $e) {
            echo json_encode(array("status" => 0, "msg" => $e->getMessage()));
        }
    } /// test upload

 
    public function block_user()
    {
        if (!hasAccess("block_user")) {
            ExitWithJson(['status' => false, 'msg' => 'Not Access']);
        }

        $res = ['status' => false];
        $uid = intval($this->input->post('uid'));
        if ($uid > 0) {
            $res['status'] = $this->user_model->update_user_detail($uid, ['status' => '0']);
        }
        echo json_encode($res);
    }

    public function active_user()
    {
        if (!hasAccess("block_user")) {
            ExitWithJson(['status' => false, 'msg' => 'Not Access']);
        }

        $res = ['status' => false];
        $uid = intval($this->input->post('uid'));
        if ($uid > 0) {
            $res['status'] = $this->user_model->update_user_detail($uid, ['status' => '1']);
        }
        echo json_encode($res);
    }

  

 
  
    public function delete_page()
    {
        if (!hasAccess("delete_pages")) {
            ExitWithJson(['status' => false, 'msg' => 'Not Access']);
        }

        $res = ['status' => false];
        $id = intval($this->input->post('id'));
        if ($id > 0) {
            $res['status'] = $this->pages_model->deletePage($id);
            if ($res['status']) {
            }
        }
        echo json_encode($res);
    }


    public function upload_crop_file()
    {
        $post = $this->input->post();
        if ($post['action'] = "Image_change") {
            $name = $this->random_number();
            $output_file = 'assets/profile_img/' . $name . '.png';
            $res = $this->base64_to_jpeg($post['image_data'], $output_file);
            if ($res) {
                $id = $this->session->userdata("userid");
                $update = array();
                $update['profile_image'] = $name . ".png";
                $result_upload = $this->auth->update_profile($update, $id);
                $old_file = "assets/profile_img/" . $this->session->userdata('profile_image');
                $this->session->set_userdata('profile_image', $update['profile_image']);
                if (file_exists($old_file)) {
                    unlink($old_file);
                }
            }
        }
    }

    function random_number($maxlength = 17)
    {
        $chary = array(
            "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",
            "0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
            "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"
        );
        $return_str = "";
        for ($x = 0; $x <= $maxlength; $x++) {
            $return_str .= $chary[rand(0, count($chary) - 1)];
        }
        return $return_str;
    }

    public function base64_to_jpeg($base64_string, $output_file)
    {
        $data = base64_decode($base64_string);
        $imagedata = base64_decode($base64_string);
        $file_name = $output_file;
        $uplode = file_put_contents($file_name, $data);

        if ($uplode) {
            return true;
        }
    } // save chart image


    public function sitemap_upload()
    {
        $post = $this->input->post();
        $result = $_FILES;
        $file_name = "";
        $img_tag_name = "";
        $msg = "Please select sitemap file";
        $error = "";
        $status = 0;
        $html = "";
        if (isset($_FILES['file']['name']) && !empty($_FILES['file']['name'])) {

            $config['upload_path']          = '../';
            $config['allowed_types']        = 'xml';
            $config['encrypt_name'] = FALSE;

            $config['file_name'] = 'sitemap.xml';
            $this->load->library('upload', $config);
            $this->upload->initialize($config);
            $config = array();
            $this->upload->overwrite = true;
            if (!$this->upload->do_upload('file')) {
                $error = $this->upload->display_errors();
                $status = 0;
                $msg = $error;
            } else {
                $status = 1;
                $data = $this->upload->data();
                $msg = $data['file_name'];
                $file_name = $data['file_name'];
            }
        } //if pdf file is uploaded or not
        echo json_encode(array('status' => $status, "filename" => $file_name, "error" => $msg, "html" => $html, "img_tag_name" => $img_tag_name));
    } //sitemap upload




    public function remove_page()
    {
        $id = $this->input->post("id");

        $this->Cms_pages_model->delete_page($id);
    }

    public function save_cms_pages_seq()
    {
        $post = $this->input->post();
        $obj = json_decode($post['seq']);
        $i = 1;
        foreach ($obj as $key => $value) {
            $this->Cms_pages_model->update($value, array("seq" => $i));
            $i++;
        }
    } //save seq




    public function video_file_upload()
    {

        $upload_file = $_FILES;
        $file_name = "";
        $img_tag_name = "";
        $msg = "Please select video file";
        $error = "";
        $status = 0;
        $html = "";
        if (isset($_FILES['file']['name']) && !empty($_FILES['file']['name'])) {

            $config['upload_path']          = '../assets/upload/product_video/';
            $config['allowed_types']        = 'webm|mov|mp4';
            $config['encrypt_name'] = FALSE;
            $config['file_name'] = date("Y-m-d-H-i-s") . "_" . rand(1000, 9999);
            $this->load->library('upload', $config);
            $this->upload->initialize($config);
            $config = array();
            if (!$this->upload->do_upload('file')) {
                $error = $this->upload->display_errors();
                $status = 0;
                $msg = $error;
            } else {
                $status = 1;
                $data = $this->upload->data();
                $msg = $data['file_name'];
                $file_name = $data['file_name'];
            }
        } //if pdf file is uploaded or not
        echo json_encode(array('status' => $status, "filename" => $file_name, "error" => $msg));
    } //product video upload

    public function report_status()
    {
        // echo "<pre>";
        // print_r($this->input->post());
        // exit;
        $response = [];
        $value = $this->input->post('value');
        $id = $this->input->post('pk');
        $block_post_id = "";
        $block_user_id = "";
        $status = "";

        if ($value == 'User Blocked') {
            $status = '1';
            $user_status = '2';
            $table = "tbl_report_users";
            $user_table = 'tbl_customer';
            $block_user_id = $this->ReportOnUsers_model->report_user_detail($id);
        }

        if ($value == 'Post Blocked') {
            $status = '1';
            $post_status = '2';
            $table = "tbl_report_posts";
            $post_table = 'tbl_post';
            $block_post_id = $this->ReportOnUsers_model->report_post_detail($id);
        }

        if($value == 'Keep Post'){
            $status = '2';
            $post_status = '1';
            $table = "tbl_report_posts";
            $post_table = 'tbl_post';
            $block_post_id = $this->ReportOnUsers_model->report_post_detail($id);
        }

        if ($value == 'Keep User') {
            $status = '2';
            $user_status = '1';
            $table = "tbl_report_users";
            $user_table = 'tbl_customer';
            $block_user_id = $this->ReportOnUsers_model->report_user_detail($id);
        }

        if($value == "Request Pending"){
            $response['change_id'] = $this->input->post("name");
            $response['status'] = '1';
            $response['msg'] = 'Unable to Change.';
        }

        if($status != ""){
            $upd['status'] = $status;
            $upd['date_updated'] = date('Y-m-d H:i:s');
    
            $update = $this->ReportOnUsers_model->update_report_data($id,$upd,$table);        
            if ($update) {
    
                if($block_user_id != ""){
                    $user_upd['status'] = $user_status;
                    $user_upd['date_updated'] = date('Y-m-d H:i:s');
        
                    $user_update = $this->ReportOnUsers_model->update_data($block_user_id,$user_upd,$user_table);
                    if ($user_update) {
                        $response['change_id'] = $this->input->post("name");
                        $response['status'] = '1';
                        $response['msg'] = 'Successfully Changed';
                    }else {
                        $response['change_id'] = $this->input->post("name");
                        $response['status'] = '0';
                        $response['msg'] = ' Unsuccessfully Changed';
                    }
                }
    
                if($block_post_id != ""){
                    $post_upd['status'] = $post_status;
                    $post_upd['date_updated'] = date('Y-m-d H:i:s');
        
                    $post_update = $this->ReportOnUsers_model->update_data($block_post_id,$post_upd,$post_table);
                    if ($post_update) {
                        $response['change_id'] = $this->input->post("name");
                        $response['status'] = '1';
                        $response['msg'] = 'Successfully Changed';
                    }else {
                        $response['change_id'] = $this->input->post("name");
                        $response['status'] = '0';
                        $response['msg'] = ' Unsuccessfully Changed';
                    }
                }
                
            } else {
                $response['change_id'] = $this->input->post("name");
                $response['status'] = '0';
                $response['msg'] = ' Unsuccessfully Changed';
            }
        }
        echo json_encode($response);
    }

    public function store_regular_user_ids()
    {
        $user_type = $this->input->post('type');
        $data = $this->Customer_model->get_user_ids($user_type);
        $status = 1;
        echo json_encode(array('status' => $status, "s_id" => $data,'msg'=>"success"));
    }

    public function store_business_user_ids()
    {
        $users_type = $this->input->post('type');
        $search = $this->input->post('search_param');

        $where = " WHERE id!=0 ";
        $where .= " AND user_type='$users_type'";

        if ($search !== "") {
            // Escape user input for LIKE
            $search = $this->db->escape_like_str($search); // safe for Hebrew
            $like = "%" . $search . "%";
            $escaped_like = $this->db->escape($like); // wraps in quotes


            $where .= " AND (
                name COLLATE utf8mb4_general_ci LIKE $escaped_like ESCAPE '!' OR
                phone COLLATE utf8mb4_general_ci LIKE $escaped_like ESCAPE '!' OR
                email COLLATE utf8mb4_general_ci LIKE $escaped_like ESCAPE '!'
            )";
        }

        $table = "SELECT
            c.`id` AS id,
            c.`name` AS name,
            c.`email` AS email,
            c.`phone` AS phone,
            c.`register_type` AS register_type,
            c.`user_type` AS user_type,
            c.`business_type` AS business_type,
            c.`status` AS status,
            c.`is_delete` AS is_delete,
            c.`sub_id` AS sub_id,
            c.`post_limit` AS post_limit,
            c.`signature_image` AS signature_image,
            (
            SELECT
                sc.`product_id` AS product_id
            FROM
                tbl_subscription sc
            WHERE
                sc.cust_id = c.id and sc.id = c.sub_id ORDER BY sc.id DESC limit 1
            ) AS plan_name,
            (
            SELECT
                sc.`expire_date` AS expire_date
            FROM
                tbl_subscription sc
            WHERE
                sc.cust_id = c.id ORDER BY sc.id DESC limit 1
            ) AS expire_date,
            (
            SELECT
                sc.`is_sub_active` AS is_sub_active
            FROM
                tbl_subscription sc
            WHERE
                sc.id = c.sub_id ORDER BY sc.id DESC limit 1
            ) AS is_sub_active
        FROM
            tbl_customer c $where";
        
        $sql_where = " c.is_delete = '0'";

        $res_data = $this->db->query($table);
        $ids = [];
        if( $res_data->num_rows() > 0 ){
			$list=array();
			foreach ($res_data->result() as $r) {
                
				array_push($list, $r->id);
			}
            $ids = $list;
		}
        // $user_type = $this->input->post('type');
        // $data = $this->Customer_model->get_user_ids($user_type);
        $status = 1;
        echo json_encode(array('status' => $status, "s_id" => $ids,'msg'=>"success"));
    }

    function send_notification()
    {
        $post = $this->input->post();
        $user_udid = [];
        $cid = explode(",",$post['cid']);
        foreach ($cid as $key => $value) {
            # code...
            // $user_udid[] = $this->Customer_model->get_customer_udid($value);
            $user_udid[] = $this->Customer_model->get_customer_udid_n_device_type($value);
        }
        
        $tokens = $user_udid;
        $device_token = $tokens; // Token generated from Android device after setting up firebase
        // $device_token = ["0"=>"cxHOOephT8ijfSWXfaJADd:APA91bESaB1_SX1arpH4nZROQyAwPPqzaWywRZ395lq-DDirQFCCuLmkaEVxN_3RdEW6HAv0KZuZD9hdAX73nQLHtZIwIIuVP85rXqE4X-V-HSOK7_DimBk7D3tmLFd9Vtn1kkJ-RLND",
        // "1"=>"d2QaRLZLQ-aRh1Iu9OzLRt:APA91bEgks_nv_WukiDnDRqmdWkzax0jcD7J7_b1H82Bl4VOKnpgY2VEMDra65JxTWCkeHsNvAZo-egUJ3QrwX4lcaxhSkAv9eBsB81RSM8Ap7ZRVKLNRt4WjEk2wIDinfzN895RVhGX",
        // "2"=>"cD6spo4s3UfBipsuxF-jth:APA91bFFAgxM3GBucPfyhyPr8R79L2LjZFyyoloVI9CeK0iIFQqz1dQZiIn9W04DYfcKqn8wmw2NDuxmIMWGPq3fVDkPdaC4fCNc2ybaume8BsAPNrf4dR6XffigjUVLF3ufT7z824JS"];

        $description = $post['description'];
        $title = $post['title'];

        $data['description'] = $description;
        $data['badge_count'] = 1;
        $data['title'] = $title;
        $data['screen'] = "home";
        
        // notification($title, $device_token, $data)
        
        // $notify = notification($data['title'], $device_token, $data);
        foreach ($device_token as $user) {
            $notify = $this->notification_new($data['title'], $user['udid'], $data,$user['device_type']);
        }
        // $notify = $this->notification_new($data['title'], $device_token, $data);
        /* echo "<pre>";
        print_r($notify);
        exit; */

        $res=array();
        $res['status']=1;
        $res['msg']="Push Notification send Successfully";
        $res['notify']=$notify;
        echo json_encode($res);
    }

    function change_user_post_limit()
    {
        // echo "<pre>";
        // print_r($this->input->post());
        // exit;
        $response = [];
		$dt = date('Y-m-d H:i:s');
		$value = $this->input->post('value');
		$id = $this->input->post('pk');
        $upd['post_limit'] = $value;
        $upd['date_updated'] = $dt;
        $res_upd = $this->Customer_model->update_detail($upd,['id'=>$id]);

        $response['change_id'] = $this->input->post("pk");
		$response['status'] = '1';
		$response['msg'] = 'Successfully Changed';
		echo json_encode($response);

    }

    function change_user_expire_date()
    {
        /* echo "<pre>";
        print_r($this->input->post());
        exit; */
        $response = [];
		$dt = date('Y-m-d H:i:s');
		$exp_date = date('Y-m-d', strtotime($this->input->post('value')));
		$id = $this->input->post('pk');
        $upd['status'] = 1;
        $upd['is_sub_active'] = 1;
        $upd['expire_date'] = $exp_date;
        $upd['date_updated'] = $dt;
        $res_upd = $this->Customer_model->update_sub_detail($upd,['id'=>$id]);

        $response['change_id'] = $this->input->post("pk");
		$response['status'] = '1';
		$response['msg'] = 'Successfully Changed';
		echo json_encode($response);

    }

    function notification_new($title, $device_token, $data1, $device_type)
    {
        if(!empty($data1))
        {
            foreach($data1 as $key => $value)
            {
                $data1[$key] = (string)$value;
            }
        } 
        // echo file_get_contents($_ENV['SITE_URL'] . "/api/fcm.json");
        // die();

        $nm=json_decode(file_get_contents($_ENV['SITE_URL'] . "/api/fcm.json"), true);

        try{
            $credential = new ServiceAccountCredentials(
                "https://www.googleapis.com/auth/firebase.messaging",
                $nm
            );

            $token = $credential->fetchAuthToken(HttpHandlerFactory::build());

            $ch = curl_init("https://fcm.googleapis.com/v1/projects/ink-flutter-app/messages:send");

            curl_setopt($ch, CURLOPT_HTTPHEADER, [
                'Content-Type: application/json',
                'Authorization: Bearer '.$token['access_token']
            ]);

            /* $data_param=[
                "message"=>[
                    "token"=>$device_token,
                    "notification"=>[
                        "title"=>$title,
                        "body"=>$data1['description']
                    ],
                    "data"=>$data1,
                    "apns"=>[
                        "payload"=>[
                            "aps"=>[
                                "category"=>"NEW_MESSAGE_CATEGORY"
                            ]
                        ]
                    ]
                ],
            ]; */
            $data_param = [
                "message" => [
                    "token" => $device_token,
                    "notification" => [
                        "title" => $title,
                        "body" => $data1['description'] ?? ""
                    ],
                    "data" => $data1
                ]
            ];
    
            // Handle Android-specific payload
            if ($device_type == "a") {
                $data_param["message"]["android"] = [
                    "priority" => "high"
                ];
    
                if (isset($data1['push_image'])) {
                    $data_param["message"]["android"]["notification"] = [
                        "image" => $data1['push_image']
                    ];
                }
            }
    
            // Handle iOS-specific payload
            if ($device_type == "i") {
                $data_param["message"]["apns"] = [
                    "headers" => [
                        "apns-priority" => "10"
                    ],
                    "payload" => [
                        "aps" => [
                            "category" => "NEW_MESSAGE_CATEGORY",
                            "content-available" => 1,
                            "alert" => [
                                "title" => $title,
                                "body" => $data1['description'] ?? ""
                            ]
                        ]
                    ]
                ];
            }

            
            if(isset($data1['push_image']))
            {
                $data_param['message']['android']=[
                    "notification"=>[
                        "image"=>$data1['push_image']
                    ]
                ];
            }

            curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data_param));
            curl_setopt($ch, CURLOPT_RETURNTRANSFER, true );
            curl_setopt($ch, CURLOPT_CUSTOMREQUEST, "post");

            $response = curl_exec($ch);

            curl_close($ch);

            return $response;

        }catch(Exception $e){
            return $e->getMessage();
        }
    }

} // class ends