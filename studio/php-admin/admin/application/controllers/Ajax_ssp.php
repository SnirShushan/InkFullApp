<?php
defined('BASEPATH') or exit('No direct script access allowed');
//ini_set('memory_limit', '256M');

class ajax_ssp extends CI_Controller
{

    public $settings = [];
    public $list_offer_cat = [];
    public $ids_pid = [];
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
        /*$result_settings=$this->db->query("select * from tbl_settings");
        if($result_settings->num_rows()>0)
        {
            foreach ($result_settings->result() as $field_row) {
                $this->settings[$field_row->field_name]=$field_row->field_value;
            }
        }*/
        $this->auth->valid_login_ajax();

        error_reporting(E_ERROR | E_PARSE);
        header("ContentType: application/json");
    }

    public function index()
    {
    }

    public function test()
    {

        $sql = "CREATE VIEW view_products as SELECT p.*, c.name as category_name FROM tbl_products as p LEFT JOIN tbl_category as c ON p.category_id = c.id ";

        //$this->db->query($sql);
    }


    // GEt Popup list
    public function getPopupList()
    {

        require('ssp.customized.class.php');
        $arr_p = array();
        $plist = $this->product_model->get_product_names();
        if ($plist) {
            if (count($plist) > 0) {
                foreach ($plist as $pr) {
                    $arr_p[$pr['id']] = $pr['name'];
                }
            }
        }

        $sql_where = "";

        $search_And = [];
        $name = $this->input->post('name');

        try {

            $table = 'tbl_site_popup';
            $primaryKey = 'id';
            $col = 0;
            $columns = array(

                array('db' => 'id', 'dt' => $col, 'field' => 'id'),
                array('db' => 'title', 'dt' => $col++, 'field' => 'title'),
                array('db' => 'popup_type', 'dt' => $col++, 'field' => 'popup_type', 'formatter' => function ($d, $row) {
                    if ($d == "1") {
                        return "After User Login";
                    } else if ($d == "2") {
                        return "Website Page";
                    } else if ($d == "3") {
                        return "Products";
                    }
                }),
                array('db' => 'description', 'dt' => $col++, 'field' => 'description', 'formatter' => function ($d, $row) {
                    if ($row['popup_type'] == "") {
                        return "";
                    } else if ($row['popup_type'] == "1") {
                        return "Home Page After Login";
                    } else if ($row['popup_type'] == "2") {
                        return $row['page_name'];
                    } else if ($row['popup_type'] == "3") {
                        $st_array = array();
                        if ($row['pids'] != "") {
                            $arr = explode(",", $row['pids']);
                            foreach ($arr as $key => $value) {
                                if (!empty($arr_p[$value])) {
                                    array_push($st_array, $arr_p[$value]);
                                }
                            }
                        }
                        return implode(",", $st_array);
                    }
                }),
                array('db' => 'status', 'dt' => $col++, 'field' => 'status', 'formatter' => function ($d, $row) {
                    $url = base_url("ManagePopups/edit/" . $row['id']);
                    $btn = " <a data-toggle='tooltip' title='Edit' class='btn btn-xs btn-outline btn-success' href='$url' data-id='$d'><i class='fa fa-pencil'></i></a>";
                    $btn .= " <button data-toggle='tooltip' title='Delete' type='button' class='btn btn-xs btn-outline btn-danger remove-popup' data-id='" . $row['id'] . "'><i class='fa fa-trash'></i></button>";

                    $btn .= "<button data-toggle='tooltip' title='View Popup' class='btn btn-warning btn-xs btn-view-popup' type='button' data-id='" . $row['id'] . "'><i class='fa fa-eye'></i></button>";
                    return $btn;
                }),
                array('db' => 'pids', 'dt' => $col++, 'field' => 'pids'),
                array('db' => 'page_name', 'dt' => $col++, 'field' => 'page_name'),

            );

            $joinQuery = "";
            $extraWhere = " is_delete  = '0' $sql_where ";
            $groupBy = "";
            $having = "";

            $json = SSP::simple($this->input->post(), get_db_connection(), $table, $primaryKey, $columns, $joinQuery, $extraWhere, $groupBy, $having);

            $json['role'] = get_role();
            $json['access'] = getUserAccessArray();

            echo json_encode($json);
        } catch (Exception $e) {
            echo $e->getMessage;
        }
    } // get Popup list



    //get all city list
    public function getCityList()
    {
        /* if( !hasAccess("view_user_list") ){
            ExitWithJson(['msg'=>'Not Access']);
        }*/

        require('ssp.customized.class.php');

        $sql_where = "";

        $search_And = [];
        $name = $this->input->post('name');

        try {

            $table = 'tbl_cities';
            $primaryKey = 'id';
            $col = 0;
            $columns = array(

                array('db' => 'id', 'dt' => $col, 'field' => 'id'),
                array('db' => 'city_name', 'dt' => $col++, 'field' => 'city_name'),
                array('db' => 'city_phone', 'dt' => $col++, 'field' => 'city_phone'),
                array('db' => 'city_id', 'dt' => $col++, 'field' => 'city_id'),
                array('db' => 'receiver_email', 'dt' => $col++, 'field' => 'receiver_email'),
                array('db' => 'receiver_phone', 'dt' => $col++, 'field' => 'receiver_phone'),
                array('db' => 'id', 'dt' => $col++, 'field' => 'id', 'formatter' => function ($d, $row) {
                    $url = base_url("ManageCity/add/" . $d);
                    $btn = " <a data-toggle='tooltip' title='Edit' class='btn btn-xs btn-outline btn-success' href='$url' data-id='$d'><i class='fa fa-pencil'></i></a>";
                    $btn .= " <button data-toggle='tooltip' title='Delete' type='button' class='btn btn-xs btn-outline btn-danger remove_city' data-id='$d'><i class='fa fa-trash'></i></button>";


                    return $btn;
                }),

            );

            $joinQuery = "";
            $extraWhere = " is_delete  = '0' $sql_where ";
            $groupBy = "";
            $having = "";

            $json = SSP::simple($this->input->post(), get_db_connection(), $table, $primaryKey, $columns, $joinQuery, $extraWhere, $groupBy, $having);

            $json['role'] = get_role();
            $json['access'] = getUserAccessArray();

            echo json_encode($json);
        } catch (Exception $e) {
            echo $e->getMessage;
        }
    } // get City list


    // Category List OLD
    public function getCategoryListOld()
    {
        /* if( !hasAccess("view_user_list") ){
            ExitWithJson(['msg'=>'Not Access']);
        }*/

        require('ssp.customized.class.php');

        $sql_where = "";

        $search_And = [];
        $name = $this->input->post('name');

        try {

            $table = 'tbl_category';
            $primaryKey = 'id';
            $col = 0;
            $columns = array(

                array('db' => 'id', 'dt' => $col, 'field' => 'id'),
                array('db' => 'name', 'dt' => $col++, 'field' => 'name'),
                array('db' => 'id', 'dt' => $col++, 'field' => 'id', 'formatter' => function ($d, $row) {
                    $url = base_url("ManageCategory/add/" . $d);
                    $btn = " <a data-toggle='tooltip' title='Edit' class='btn btn-xs btn-outline btn-success' href='$url' data-id='$d'><i class='fa fa-pencil'></i></a>";
                    $btn .= " <button data-toggle='tooltip' title='Delete' type='button' class='btn btn-xs btn-outline btn-danger remove_category' data-id='$d'><i class='fa fa-trash'></i></button>";


                    return $btn;
                }),

            );

            $joinQuery = "";
            $extraWhere = " is_delete  = '0' $sql_where ";
            $groupBy = "";
            $having = "";

            $json = SSP::simple($this->input->post(), get_db_connection(), $table, $primaryKey, $columns, $joinQuery, $extraWhere, $groupBy, $having);

            $json['role'] = get_role();
            $json['access'] = getUserAccessArray();

            echo json_encode($json);
        } catch (Exception $e) {
            echo $e->getMessage;
        }
    } // get category list old 


    // Category List O
    public function getCategoryList()
    {
        /* if( !hasAccess("view_user_list") ){
            ExitWithJson(['msg'=>'Not Access']);
        }*/

        require('ssp.customized.class.php');

        $sql_where = "";

        $search_And = [];
        $name = $this->input->post('name');

        try {

            $table = 'view_category';
            $primaryKey = 'id';
            $col = 0;
            $columns = array(

                array('db' => 'id', 'dt' => $col, 'field' => 'id'),
                array('db' => 'name', 'dt' => $col++, 'field' => 'name'),
                array('db' => 'is_parent', 'dt' => $col++, 'field' => 'is_parent', 'formatter' => function ($d, $row) {
                    if ($d == "1")
                        return "Yes";
                    else
                        return "No";
                }),
                array('db' => 'parent_name', 'dt' => $col++, 'field' => 'parent_name'),
                array('db' => 'id', 'dt' => $col++, 'field' => 'id', 'formatter' => function ($d, $row) {
                    $url = base_url("ManageCategory/add/" . $d);
                    $btn = " <a data-toggle='tooltip' title='Edit' class='btn btn-xs btn-outline btn-success' href='$url' data-id='$d'><i class='fa fa-pencil'></i></a>";
                    $btn .= " <button data-toggle='tooltip' title='Delete' type='button' class='btn btn-xs btn-outline btn-danger remove_category' data-id='$d'><i class='fa fa-trash'></i></button>";


                    return $btn;
                }),

            );

            $joinQuery = "";
            $extraWhere = " is_delete  = '0' $sql_where ";
            $groupBy = "";
            $having = "";

            $json = SSP::simple($this->input->post(), get_db_connection(), $table, $primaryKey, $columns, $joinQuery, $extraWhere, $groupBy, $having);

            $json['role'] = get_role();
            $json['access'] = getUserAccessArray();

            echo json_encode($json);
        } catch (Exception $e) {
            echo $e->getMessage;
        }
    } // get category list 

    public function getPickupPointList()
    {

        require_once('ssp.customized.class.php');

        $sql_where = "";

        $search_And = [];
        $name = $this->input->post('name');

        try {

            $table = 'tbl_pickup_points';
            $primaryKey = 'id';
            $col = 0;
            $columns = array(
                array('db' => 'id', 'dt' => $col++, 'field' => 'id', 'formatter' => function ($d, $row) {
                    return '<button class="btn btn-danger btn-xs remove_point_name" data-id="' . $d . '" type="button"><i class="fa fa-trash"></i></button>';
                }),
                array('db' => 'point_name', 'dt' => $col++, 'field' => 'point_name', 'formatter' => function ($d, $row) {
                    return '<a href="#" class="editable_txt" data-type="text" data-pk="' . $row['id'] . '" data-url="' . base_url('Ajax_controller/update_pickup_point') . '" data-title="Pickup Point">' . $d . '</a>';
                }), array('db' => 'point_comment', 'dt' => $col++, 'field' => 'point_comment', 'formatter' => function ($d, $row) {
                    return '<a href="#" class="editable_txt" data-type="text" data-pk="' . $row['id'] . '" data-url="' . base_url('Ajax_controller/update_pickup_point_comment') . '" data-title="Pickup Point Comment">' . $d . '</a>';
                }), array('db' => 'price_tier', 'dt' => $col++, 'field' => 'price_tier', 'formatter' => function ($d, $row) {
                    $arr_price = [['value' => "price", 'text' => "price"], ['value' => "price1", 'text' => "price1"]];
                    $row_json = htmlspecialchars(json_encode($arr_price), ENT_QUOTES, 'UTF-8');
                    return '<a href="#" class="editable_txt" data-source="' . $row_json . '" data-type="select" data-pk="' . $row['id'] . '" data-url="' . base_url('Ajax_controller/update_pickup_price_tier') . '" data-value="' . $d . '" data-title="Pickup Point Comment">' . $d . '</a>';
                }),


            );





            if (!empty($this->input->post("city_id"))) {
                $cid = $this->input->post("city_id", TRUE);
                if ($cid != "") {
                    $sql_where .= " city_id='$cid' ";
                }
            }

            $joinQuery = ""; //LEFT JOIN tbl_category as c ON p.category_id = c.id 
            $extraWhere = "$sql_where";
            $groupBy = "";
            $having = "";

            $json = SSP::simple($this->input->post(), get_db_connection(), $table, $primaryKey, $columns, $joinQuery, $extraWhere, $groupBy, $having);

            $json['role'] = get_role();
            $json['access'] = getUserAccessArray();

            $json['input'] = $this->input->post();

            echo json_encode($json);
        } catch (Exception $e) {
            echo $e->getMessage;
        }
    } // get Pickup point list


    public function getGroupProductList()
    {
        /* if( !hasAccess("view_user_list") ){
            ExitWithJson(['msg'=>'Not Access']);
        }*/
        $cat_list = $this->product_model->get_category_list();
        require('ssp.customized.class.php');

        $sql_where = "";

        $search_And = [];
        $name = $this->input->post('name');

        try {

            $table = 'tbl_group_products_map';
            $primaryKey = 'id';
            $col = 0;
            $columns = array(
                array('db' => 'p.name', 'dt' => $col++, 'field' => 'name', 'as' => "name"),
                array('db' => 'p.sizes', 'dt' => $col++, 'field' => 'sizes', 'as' => 'sizes', 'formatter' => function ($d, $row) {
                    return '<a href="#" class="editable_txt" data-type="text" data-pk="' . $row['pid'] . '" data-url="' . base_url('Ajax_controller/update_sizes_p') . '" data-title="' . $this->lang->line("lbl_products_group_sizes") . '">' . $d . '</a>';
                }),
                array('db' => 'p.smell', 'dt' => $col++, 'field' => 'smell', 'as' => 'smell', 'formatter' => function ($d, $row) {
                    return '<a href="#" class="editable_txt" data-type="text" data-pk="' . $row['pid'] . '" data-url="' . base_url('Ajax_controller/update_smell_p') . '" data-title="' . $this->lang->line("lbl_products_group_smell") . '">' . $d . '</a>';
                }),
                array('db' => 'p.color_code', 'dt' => $col++, 'field' => 'color_code', 'as' => 'color_code', 'formatter' => function ($d, $row) {
                    $txt = '<input  type="text" data-pid="' . $row['pid'] . '" id="cp-component-' . $row['pid'] . '" value="' . $d . '" style="background-color:' . $d . '" class="colorpicker" /> <button class="btn btn-warning btn-sm btn-xs btn-save-color-code" data-pid="' . $row['pid'] . '" ><i class="fa fa-save "></i></button> <button class="btn btn-info btn-sm btn-xs btn-remove-color-code" data-pid="' . $row['pid'] . '" ><i class="fa fa-trash "></i></button>';



                    return $txt;
                }),
                array('db' => 'p.color_name', 'dt' => $col++, 'field' => 'color_name', 'as' => 'color_name', 'formatter' => function ($d, $row) {
                    return '<a href="#" class="editable_txt" data-type="text" data-pk="' . $row['pid'] . '" data-url="' . base_url('Ajax_controller/update_color_name_p') . '" data-title="' . $this->lang->line("lbl_products_group_smell") . '">' . $d . '</a>';
                }),
                array('db' => 'm1.id', 'dt' => $col++, 'field' => 'id', 'as' => 'id'),
                array('db' => 'm1.pid', 'dt' => $col++, 'field' => 'pid', 'as' => 'pid'),

            );





            if (!empty($this->input->post("gid"))) {
                $gid = $this->input->post("gid", TRUE);
                if ($gid != "") {
                    $sql_where .= " AND m1.gid='$gid' ";
                }
            }

            $joinQuery = " FROM tbl_group_products_map m1 LEFT JOIN tbl_products p ON m1.pid = p.id"; //LEFT JOIN tbl_category as c ON p.category_id = c.id 
            $extraWhere = " p.is_delete  = '0' $sql_where ";
            $groupBy = "";
            $having = "";

            $json = SSP::simple($this->input->post(), get_db_connection(), $table, $primaryKey, $columns, $joinQuery, $extraWhere, $groupBy, $having);

            $json['role'] = get_role();
            $json['access'] = getUserAccessArray();

            $json['input'] = $this->input->post();

            echo json_encode($json);
        } catch (Exception $e) {
            echo $e->getMessage;
        }
    } // get Product list


    public function getProductList()
    {
        /* if( !hasAccess("view_user_list") ){
            ExitWithJson(['msg'=>'Not Access']);
        }*/
        $this->list_offer_cat = GetOfferCategoryList();
        $this->ids_pid = GetYProducts();
        $cat_list = $this->product_model->get_category_list();
        require('ssp.customized.class.php');

        $sql_where = "";

        $search_And = [];
        $name = $this->input->post('name');

        try {

            $table = 'view_products';
            $primaryKey = 'id';
            $col = 0;
            $columns = array(
                array('db' => 'is_cat_featured', 'dt' => $col++, 'field' => 'is_cat_featured', 'formatter' => function ($d, $row) {
                    $checked = "";
                    if ($d == 1)
                        $checked = " checked ";
                    $html1 = "<input " . $checked . " type='checkbox' class=' chk_if_cat_featured' name='is_cat_featured[]' id='is_cat_featured_" . $row['id'] . "' data-id='" . $row['id'] . "'  /> ";
                    return $html1;
                }),
                array('db' => 'is_featured', 'dt' => $col++, 'field' => 'is_featured', 'formatter' => function ($d, $row) {
                    $checked = "";
                    if ($d == 1)
                        $checked = " checked ";
                    $html1 = "<input " . $checked . " type='checkbox' class=' chk_if_featured' name='is_featured[]' id='is_featured_" . $row['id'] . "' data-id='" . $row['id'] . "'  /> ";
                    return $html1;
                }),
                array('db' => 'is_home_sale', 'dt' => $col++, 'field' => 'is_home_sale', 'formatter' => function ($d, $row) {
                    $checked = "";
                    if ($d == 1)
                        $checked = " checked ";
                    $html1 = "<input " . $checked . " type='checkbox' class='chk_is_home_sale' name='is_home_sale[]' id='is_home_sale_" . $row['id'] . "' data-id='" . $row['id'] . "'  /> ";
                    return $html1;
                }),

                array('db' => 'offer_status_text', 'dt' => $col++, 'field' => 'offer_status_text', 'formatter' => function ($d, $row) {
                    return $d;
                    // if (in_array($row['category_id'], $this->list_offer_cat))
                    //     return "Group";
                    // if ($d != "")
                    //     return "Yes";
                    // if (in_array($row['id'], $this->ids_pid))
                    //     return "Get";
                    // return "No";
                }),
                array('db' => 'name', 'dt' => $col++, 'field' => 'name'),
                array('db' => 'dept_name', 'dt' => $col++, 'field' => 'dept_name'),
                array('db' => 'category_name', 'dt' => $col++, 'field' => 'category_name'),

                array('db' => 'price', 'dt' => $col++, 'field' => 'price', 'formatter' => function ($d, $row) {
                    return number_format($d, 2) . " ₪";
                }),
                array('db' => 'price1', 'dt' => $col++, 'field' => 'price1', 'formatter' => function ($d, $row) {
                    return number_format($d, 2) . " ₪";
                }),
                array('db' => 'stock', 'dt' => $col++, 'field' => 'stock', 'formatter' => function ($d, $row) {
                    return $d;
                }),
                array('db' => 'is_out_stock', 'dt' => $col++, 'field' => 'is_out_stock', 'formatter' => function ($d, $row) {
                    return $d;
                }),
                array('db' => 'status', 'dt' => $col++, 'field' => 'status', 'formatter' => function ($d, $row) {
                    $url = base_url("Products/add/" . $row['id']);
                    $btn = " <a data-toggle='tooltip' title='Edit' class='btn btn-xs btn-outline btn-success' href='$url' data-id='" . $row['id'] . "'><i class='fa fa-pencil'></i></a>";
                    $btn .= " <button data-toggle='tooltip' title='Delete' type='button' class='btn btn-xs btn-outline btn-danger remove_product' data-id='" . $row['id'] . "'><i class='fa fa-trash'></i></button>";
                    return $btn;
                }),
                array('db' => 'id', 'dt' => $col++, 'field' => 'id'),
                array('db' => 'category_id', 'dt' => $col++, 'field' => 'category_id'),
            );

            if (!empty($this->input->post("search_text"))) {
                $search_text = $this->input->post("search_text", TRUE);
                $sql_where .= " AND (name LIKE '%" . $search_text . "%' OR category_name LIKE '%" . $search_text . "%')";
            }

            if (!empty($this->input->post("qty_type"))) {
                $qty_type = $this->input->post("qty_type", TRUE);
                if ($qty_type == "unit") {
                    $sql_where .= " AND unit='1' ";
                } else if ($qty_type == "weight") {
                    $sql_where .= " AND weight='1' ";
                } else if ($qty_type == "both") {
                    $sql_where .= " AND unit='1' AND weight='1'";
                }
            }

            if (!empty($this->input->post("cat_id"))) {
                $cat = $this->input->post("cat_id", TRUE);
                if ($cat != "") {
                    $sql_where .= " AND category_id='$cat' ";
                }
            }

            $joinQuery = " FROM view_products "; //LEFT JOIN tbl_category as c ON p.category_id = c.id 
            $extraWhere = " is_delete  = '0' $sql_where ";
            $groupBy = "";
            $having = "";

            $json = SSP::simple($this->input->post(), get_db_connection(), $table, $primaryKey, $columns, $joinQuery, $extraWhere, $groupBy, $having);

            $json['role'] = get_role();
            $json['access'] = getUserAccessArray();

            $json['input'] = $this->input->post();

            echo json_encode($json);
        } catch (Exception $e) {
            echo $e->getMessage;
        }
    } // get Product list



    public function getProductListUpdate()
    {
        /* if( !hasAccess("view_user_list") ){
            ExitWithJson(['msg'=>'Not Access']);
        }*/
        $cat_list = $this->product_model->get_category_list();
        require('ssp.customized.class.php');

        $sql_where = "";

        $search_And = [];
        $name = $this->input->post('name');

        try {

            $table = 'view_products';
            $primaryKey = 'id';
            $col = 0;
            $columns = array(

                array('db' => 'is_featured', 'dt' => $col++, 'field' => 'is_featured', 'formatter' => function ($d, $row) {
                    $checked = "";
                    $ids = array();
                    if (!empty($this->session->userdata("selected_products"))) {
                        $ids = $this->session->userdata("selected_products");
                    }
                    if (in_array($row['id'], $ids)) {
                        $checked = " checked ";
                    }
                    $html1 = "<input " . $checked . " type='checkbox' class=' chk_if_selected' name='is_selected[]' id='is_selected_" . $row['id'] . "' data-id='" . $row['id'] . "'  /> ";
                    return $html1;
                }),
                array('db' => 'name', 'dt' => $col++, 'field' => 'name'),

                array('db' => 'category_name', 'dt' => $col++, 'field' => 'category_name'),
                array('db' => 'dept_name', 'dt' => $col++, 'field' => 'dept_name'),
                array('db' => 'price_kg', 'dt' => $col++, 'field' => 'price_kg', 'formatter' => function ($d, $row) {
                    return number_format($d, 2) . " ₪";
                }),
                array('db' => 'price_unit', 'dt' => $col++, 'field' => 'price_unit', 'formatter' => function ($d, $row) {
                    return number_format($d, 2) . " ₪";
                }),
                array('db' => 'stock', 'dt' => $col++, 'field' => 'stock', 'formatter' => function ($d, $row) {
                    return $d;
                }),

                array('db' => 'id', 'dt' => $col++, 'field' => 'id'),
            );

            if (!empty($this->input->post("search_text"))) {
                $search_text = $this->input->post("search_text", TRUE);
                $sql_where .= " AND (name LIKE '%" . $search_text . "%' OR category_name LIKE '%" . $search_text . "%')";
            }

            if (!empty($this->input->post("qty_type"))) {
                $qty_type = $this->input->post("qty_type", TRUE);
                if ($qty_type == "unit") {
                    $sql_where .= " AND unit='1' ";
                } else if ($qty_type == "weight") {
                    $sql_where .= " AND weight='1' ";
                } else if ($qty_type == "both") {
                    $sql_where .= " AND unit='1' AND weight='1'";
                }
            }

            if (!empty($this->input->post("cat_id"))) {
                $cat = $this->input->post("cat_id", TRUE);
                if ($cat != "") {
                    $sql_where .= " AND category_id='$cat' ";
                }
            }




            $joinQuery = " FROM view_products "; //LEFT JOIN tbl_category as c ON p.category_id = c.id 
            $extraWhere = " is_delete  = '0' $sql_where ";
            $groupBy = "";
            $having = "";

            $json = SSP::simple($this->input->post(), get_db_connection(), $table, $primaryKey, $columns, $joinQuery, $extraWhere, $groupBy, $having);

            $json['role'] = get_role();
            $json['access'] = getUserAccessArray();

            $json['input'] = $this->input->post();

            echo json_encode($json);
        } catch (Exception $e) {
            echo $e->getMessage;
        }
    } // get Product list for update

    public function getOfferList()
    {

        require('ssp.customized.class.php');
        $sql_where = "";
        $search_And = [];
        $name = $this->input->post('name');

        try {
            $table = 'tbl_offers';
            $primaryKey = 'id';
            $col = 0;
            $columns = array(
                array('db' => 'title', 'dt' => $col++, 'field' => 'title'),
                array('db' => 'id', 'dt' => $col++, 'field' => 'id', 'formatter' => function ($d, $row) {
                    $url = base_url("BulkOffer/edit/" . $d);
                    $btn = " <a data-toggle='tooltip' title='Edit Detail' class='btn btn-xs btn-outline btn-success' href='$url' data-id='" . $d . "'><i class='fa fa-pencil'></i></a>";
                    $del_btn = " <button data-toggle='tooltip' title='Delete Offer' class='btn btn-xs btn-outline btn-danger remove_offer' type='button'  data-id='" . $d . "'><i class='fa fa-trash'></i></button> ";
                    return $del_btn . " " . $btn;
                }),
            );


            $joinQuery = ""; //LEFT JOIN tbl_category as c ON p.category_id = c.id 
            $extraWhere = "";
            $groupBy = "";
            $having = "";

            $json = SSP::simple($this->input->post(), get_db_connection(), $table, $primaryKey, $columns, $joinQuery, $extraWhere, $groupBy, $having);

            $json['role'] = get_role();
            $json['access'] = getUserAccessArray();
            $json['input'] = $this->input->post();

            echo json_encode($json);
        } catch (Exception $e) {
            echo $e->getMessage;
        }
    } // get offerlist



    public function getCustomerList()
    {
        /* if( !hasAccess("view_user_list") ){
            ExitWithJson(['msg'=>'Not Access']);
        }*/

        require('ssp.customized.class.php');

        $sql_where = "";

        $search_And = [];
        $name = $this->input->post('name');

        try {

            $table = 'tbl_users';
            $primaryKey = 'id';
            $col = 0;
            $columns = array(

                array('db' => 'u.fname', 'dt' => $col++, 'field' => 'fname'),
                array('db' => 'u.lname', 'dt' => $col++, 'field' => 'lname'),
                array('db' => 'u.email', 'dt' => $col++, 'field' => 'email'),
                array('db' => 'u.phone_number', 'dt' => $col++, 'field' => 'phone_number'),
                array('db' => 'c.city_name', 'dt' => $col++, 'field' => 'city_name'),
                array('db' => 'u.postal_code', 'dt' => $col++, 'field' => 'postal_code'),
                array('db' => 'u.price_tier', 'dt' => $col++, 'field' => 'price_tier'),
                array('db' => 'u.id', 'dt' => $col++, 'field' => 'id', 'formatter' => function ($d, $row) {
                    $url = base_url("Customer/view/" . $row['id']);
                    $btn = " <a data-toggle='tooltip' title='View Detail' class='btn btn-xs btn-outline btn-success' href='$url' data-id='" . $row['id'] . "'><i class='fa fa-eye'></i></a>";

                    $btn .= " <a data-toggle='tooltip' data-placement='right' title='Remove Customer' class='btn btn-xs btn-outline btn-danger remove_customer' href='javascript:void(0);' data-id='" . $row['id'] . "'><i class='fa fa-trash'></i></a>";
                    return $btn;
                }),

            );

            $joinQuery = "from tbl_users u LEFT JOIN tbl_cities as c ON u.city_id = c.id "; //LEFT JOIN tbl_category as c ON p.category_id = c.id 
            $extraWhere = " u.is_delete='0'";
            $groupBy = "";
            $having = "";

            $json = SSP::simple($this->input->post(), get_db_connection(), $table, $primaryKey, $columns, $joinQuery, $extraWhere, $groupBy, $having);

            $json['role'] = get_role();
            $json['access'] = getUserAccessArray();

            $json['input'] = $this->input->post();

            echo json_encode($json);
        } catch (Exception $e) {
            echo $e->getMessage;
        }
    } // get Customer



    public function getOrderList()
    {
        /* if( !hasAccess("view_user_list") ){
            ExitWithJson(['msg'=>'Not Access']);
        }*/

        require('ssp.customized.class.php');

        $sql_where = "";

        $search_And = [];
        $name = $this->input->post('name');
        $lang = $this->input->post("lang");
        $this->config->set_item("lang_he", $lang);
        try {

            $table = 'tbl_orders';
            $primaryKey = 'id';
            $col = 0;
            $columns = array(
                array('db' => 'o.order_date', 'dt' => $col++, 'field' => 'order_date', 'formatter' => function ($d, $row) {
                    return date("d/m/Y h:i A", strtotime($d));
                }),
                array('db' => 'o.delivery_date', 'dt' => $col++, 'field' => 'delivery_date', 'formatter' => function ($d, $row) {
                    return date("d/m/Y h:i A", strtotime($d . " " . $row['delivery_time']));
                }),
                array('db' => 'u.fname', 'dt' => $col++, 'field' => 'fname'),
                array('db' => 'u.email', 'dt' => $col++, 'field' => 'email'),
                array('db' => 'o.city_id', 'dt' => $col++, 'field' => 'city_id', 'formatter' => function ($d, $row) {
                    $city_list = GetCityArr();
                    return $city_list[$d];
                }),
                array('db' => 'o.ship_charge', 'dt' => $col++, 'field' => 'ship_charge', 'formatter' => function ($d, $row) {
                    return number_format($d, 2) . " ₪";
                }),
                array('db' => 'o.final_total', 'dt' => $col++, 'field' => 'final_total', 'formatter' => function ($d, $row) {
                    return number_format($d, 2) . " ₪";
                }),

                array('db' => 'o.payment_type', 'dt' => $col++, 'field' => 'payment_type', 'formatter' => function ($d, $row) {
                    return GetOrderStatusText($d, $row['order_status'], $this->config->item("lang_he"));
                }),

                array('db' => 'o.id', 'dt' => $col++, 'field' => 'id', 'formatter' => function ($d, $row) {
                    $url = base_url("Orders/view/" . $row['id']);
                    $btn = " <a data-toggle='tooltip' title='View Detail' class='btn btn-xs btn-outline btn-success' href='$url' data-id='" . $row['id'] . "'><i class='fa fa-eye'></i></a>";
                    return $btn;
                }),
                array('db' => 'o.delivery_time', 'dt' => $col++, 'field' => 'delivery_time'),
                array('db' => 'o.order_status', 'dt' => $col++, 'field' => 'order_status'),

            );

            $joinQuery = "from tbl_orders o LEFT JOIN tbl_users as u ON o.uid = u.id "; //LEFT JOIN tbl_category as c ON p.category_id = c.id 
            $extraWhere = "";
            $groupBy = "";
            $having = "";

            $json = SSP::simple($this->input->post(), get_db_connection(), $table, $primaryKey, $columns, $joinQuery, $extraWhere, $groupBy, $having);

            $json['role'] = get_role();
            $json['access'] = getUserAccessArray();

            $json['input'] = $this->input->post();

            echo json_encode($json);
        } catch (Exception $e) {
            echo $e->getMessage;
        }
    } // get Order list

    //get all Institute list
    public function getUsers()
    {
        if (!hasAccess("view_user_list")) {
            ExitWithJson(['msg' => 'Not Access']);
        }

        require('ssp.customized.class.php');

        $sql_where = "";

        $search_And = [];
        $name = $this->input->post('name');

        try {

            $table = 'tbl_users';
            $primaryKey = 'id';

            $columns = array(

                array('db' => 'u.id', 'dt' => 0, 'field' => 'id'),
                array('db' => 'u.name', 'dt' => 1, 'field' => 'name'),

                array('db' => 'u.email', 'dt' => 2, 'field' => 'email'),
                array('db' => 'u.phone_number', 'dt' => 3, 'field' => 'phone_number'),
                array('db' => 'c.country_name', 'dt' => 4, 'field' => 'country_name'),
                array('db' => 'u.status', 'dt' => 5, 'field' => 'status', 'formatter' => function ($d, $row) {
                    return ($d == '1' ? 'Active' : 'Block');
                }),

                array('db' => 'u.profile_image', 'dt' => 6, 'field' => 'profile_image', 'formatter' => function ($d, $row) {
                    return $d;
                }),
            );

            $joinQuery = " FROM tbl_users as u LEFT JOIN tbl_country as c ON u.country_id = c.id ";
            $extraWhere = " u.is_delete  = '0' $sql_where ";
            $groupBy = "";
            $having = "";

            $json = SSP::simple($this->input->post(), get_db_connection(), $table, $primaryKey, $columns, $joinQuery, $extraWhere, $groupBy, $having);

            $json['role'] = get_role();
            $json['access'] = getUserAccessArray();

            echo json_encode($json);
        } catch (Exception $e) {
            echo $e->getMessage;
        }
    } // get Users


    public function getFeeds()
    {
        if (!hasAccess("view_feed_list")) {
            ExitWithJson(['msg' => 'Not Access']);
        }

        require('ssp.customized.class.php');

        $sql_where = "";

        $search_And = [];

        try {

            $table = 'view_posts';
            $primaryKey = 'id';

            $columns = array(
                array('db' => 'p.id', 'dt' => 0, 'field' => 'id'),
                array('db' => 'p.title', 'dt' => 1, 'field' => 'title'),
                array('db' => 'p.date_added', 'dt' => 2, 'field' => 'date_added', 'formatter' => function ($d, $row) {
                    return date("m/d/Y", strtotime($d));
                }),

                array('db' => 'p.view_count', 'dt' => 3, 'field' => 'view_count'),
                array('db' => 'p.read_count', 'dt' => 4, 'field' => 'read_count', 'formatter' => function ($d, $row) {
                    return $d;
                }),

                array('db' => 'p.image', 'dt' => 5, 'field' => 'image', 'formatter' => function ($d, $row) {
                    return base_url(UPLOAD_IMG_PATH . $d);
                }),

                array('db' => 'p.view_count_total', 'dt' => 6, 'field' => 'view_count_total'),
                array('db' => 'p.read_count_total', 'dt' => 7, 'field' => 'read_count_total', 'formatter' => function ($d, $row) {
                    return $d;
                }),

            );

            $joinQuery = " FROM view_posts as p ";
            $extraWhere = " p.is_delete  = '0' $sql_where ";
            $groupBy = "";
            $having = "";

            $json = SSP::simple($this->input->post(), get_db_connection(), $table, $primaryKey, $columns, $joinQuery, $extraWhere, $groupBy, $having);

            $json['role'] = get_role();
            $json['access'] = getUserAccessArray();

            echo json_encode($json);
        } catch (Exception $e) {
            echo $e->getMessage;
        }
    }


    public function getCountry()
    {
        if (!isRole("supper_admin")) {
            ExitWithJson(['msg' => 'Not Access']);
        }

        require('ssp.customized.class.php');

        $sql_where = "";

        $search_And = [];

        try {

            $table = 'tbl_country';
            $primaryKey = 'id';

            $columns = array(
                array('db' => 'p.id', 'dt' => 0, 'field' => 'id'),
                array('db' => 'p.country_name', 'dt' => 1, 'field' => 'country_name'),
                array('db' => 'p.date_added', 'dt' => 2, 'field' => 'date_added', 'formatter' => function ($d, $row) {
                    return $d;
                }),
            );

            $joinQuery = " FROM tbl_country as p ";
            $extraWhere = " p.is_delete  = '0' $sql_where ";
            $groupBy = "";
            $having = "";

            $json = SSP::simple($this->input->post(), get_db_connection(), $table, $primaryKey, $columns, $joinQuery, $extraWhere, $groupBy, $having);

            $json['role'] = get_role();
            $json['access'] = getUserAccessArray();

            echo json_encode($json);
        } catch (Exception $e) {
            echo $e->getMessage;
        }
    }

    public function getFacility()
    {
        if (!hasAccess("view_facility_list")) {
            ExitWithJson(['msg' => 'Not Access']);
        }

        require('ssp.customized.class.php');

        $sql_where = "";

        $search_And = [];

        try {

            $table = 'tbl_facility';
            $primaryKey = 'id';

            $columns = array(
                array('db' => 'f.id', 'dt' => 0, 'field' => 'id'),
                array('db' => 'f.name', 'dt' => 1, 'field' => 'name'),
                array('db' => 'f.c_type', 'dt' => 2, 'field' => 'c_type', 'formatter' => function ($d, $row) {
                    $itm = ['2' => 'Checkbox', '1' => 'Dropdown'];
                    return isset($itm[$d]) ? $itm[$d] : $d;
                }),
                array('db' => 'f.slug', 'dt' => 3, 'field' => 'slug'),
                array('db' => 'f.value_list', 'dt' => 4, 'field' => 'value_list', 'formatter' => function ($d, $row) {
                    if ($d == "") {
                        return 0;
                    }
                    return count(explode(",", $d));
                }),
            );

            $joinQuery = " FROM tbl_facility as f ";
            $extraWhere = "$sql_where";
            $groupBy = "";
            $having = "";

            $json = SSP::simple($this->input->post(), get_db_connection(), $table, $primaryKey, $columns, $joinQuery, $extraWhere, $groupBy, $having);

            $json['role'] = get_role();
            $json['access'] = getUserAccessArray();

            echo json_encode($json);
        } catch (Exception $e) {
            echo $e->getMessage;
        }
    }

    public function getPages()
    {
        if (!hasAccess("view_pages_list")) {
            ExitWithJson(['msg' => 'Not Access']);
        }

        require('ssp.customized.class.php');

        $sql_where = " p.is_delete = '0' ";

        $search_And = [];

        try {

            $table = 'tbl_pages';
            $primaryKey = 'id';

            $columns = array(
                array('db' => 'p.id', 'dt' => 0, 'field' => 'id'),
                array('db' => 'p.name', 'dt' => 1, 'field' => 'name'),
                array('db' => 'p.date_added', 'dt' => 2, 'field' => 'date_added'),
                array('db' => 'p.date_updated', 'dt' => 3, 'field' => 'date_updated'),
                array('db' => 'p.status', 'dt' => 4, 'field' => 'status'),
                /*array('db'=>'p.c_type', 'dt'=> 2, 'field' => 'c_type','formatter'=>function($d, $row){
                    $itm = ['2'=>'Checkbox','1'=>'Dropdown'];
                    return isset($itm[$d])?$itm[$d]:$d;
                }),
                array('db'=>'p.slug', 'dt'=> 3, 'field' => 'slug'),
                array('db'=>'p.value_list', 'dt'=> 4, 'field' => 'value_list','formatter'=>function($d, $row){
                    if($d==""){ return 0; }
                    return count(explode(",",$d));
                }),*/
            );

            $joinQuery = " FROM tbl_pages as p ";
            $extraWhere = "$sql_where";
            $groupBy = "";
            $having = "";

            $json = SSP::simple($this->input->post(), get_db_connection(), $table, $primaryKey, $columns, $joinQuery, $extraWhere, $groupBy, $having);

            $json['role'] = get_role();
            $json['access'] = getUserAccessArray();

            echo json_encode($json);
        } catch (Exception $e) {
            echo $e->getMessage;
        }
    }

    public function getUsersNotification()
    {
        if (!hasAccess("send_notification")) {
            ExitWithJson(['msg' => 'Not Access']);
        }

        require('ssp.customized.class.php');

        $sql_where = "";

        $search_And = [];
        $name = $this->input->post('name');

        $country_ids = $this->input->post('country_ids');
        if ($country_ids != "") {
            $ids = implode(",", explode(",", $country_ids));
            $search_And[] = " u.country_id in ( $ids ) ";
        }

        $facility_ids = $this->input->post('facility_ids');
        if ($facility_ids != "") {
            $ids = implode(",", explode(",", $facility_ids));
            $search_And[] = " u.facility_id in ( $ids ) ";
        }

        if (count($search_And) > 0) {
            $sql_where = " and " . implode(" AND ", $search_And);
        }


        try {

            $table = 'tbl_users';
            $primaryKey = 'id';

            $columns = array(
                array('db' => 'u.id', 'dt' => 0, 'field' => 'id'),
                array('db' => 'u.name', 'dt' => 1, 'field' => 'name'),

                array('db' => 'u.email', 'dt' => 2, 'field' => 'email'),
                array('db' => 'u.phone_number', 'dt' => 3, 'field' => 'phone_number'),
                array('db' => 'u.country_name', 'dt' => 4, 'field' => 'country_name'),
                array('db' => 'u.facility_name', 'dt' => 5, 'field' => 'facility_name', 'formatter' => function ($d, $row) {
                    return $d;
                })
            );

            $joinQuery = " FROM view_user as u ";
            $extraWhere = " u.is_delete  = '0' $sql_where ";
            $groupBy = "";
            $having = "";

            $json = SSP::simple($this->input->post(), get_db_connection(), $table, $primaryKey, $columns, $joinQuery, $extraWhere, $groupBy, $having);

            $json['role'] = get_role();
            $json['access'] = getUserAccessArray();

            echo json_encode($json);
        } catch (Exception $e) {
            echo $e->getMessage;
        }
    }

    public function get_Category_List()
    {
        require('ssp.customized.class.php');

        $sql_where = "";

        $search_And = [];
        $name = $this->input->post('name');

        try {

            $table = 'tbl_category';
            $primaryKey = 'id';
            $col = 0;
            $columns = array(

                array('db' => 'id', 'dt' => $col, 'field' => 'id'),
                array('db' => 'name', 'dt' => $col++, 'field' => 'name'),
                array('db' => 'name_en', 'dt' => $col++, 'field' => 'name_en'),
                array('db' => 'id', 'dt' => $col++, 'field' => 'id', 'formatter' => function ($d, $row) {
                    $url = base_url("ManageCategoryHead/add/" . $d);
                    $btn = " <a data-toggle='tooltip' title='Edit' class='btn btn-xs btn-outline btn-success' href='$url' data-id='$d'><i class='fa fa-pencil'></i></a>";
                    return $btn;
                }),

            );

            $joinQuery = "";
            $extraWhere = " is_delete  = '0' $sql_where ";
            $groupBy = "";
            $having = "";

            $json = SSP::simple($this->input->post(), get_db_connection(), $table, $primaryKey, $columns, $joinQuery, $extraWhere, $groupBy, $having);

            $json['role'] = get_role();
            $json['access'] = getUserAccessArray();

            echo json_encode($json);
        } catch (Exception $e) {
            echo $e->getMessage;
        }
    } // get category list


    public function getCMSPagesList()
    {
        require('ssp.customized.class.php');

        $sql_where = "";

        $search_And = [];
        $name = $this->input->post('name');

        try {

            $table = 'tbl_cms_pages';
            $primaryKey = 'id';
            $col = 0;
            $columns = array(

                array('db' => 'id', 'dt' => $col, 'field' => 'id'),
                array('db' => 'title', 'dt' => $col++, 'field' => 'title'),
                array('db' => 'meta_title', 'dt' => $col++, 'field' => 'meta_title'),
                array('db' => 'meta_desc', 'dt' => $col++, 'field' => 'meta_desc'),
                array('db' => 'description', 'dt' => $col++, 'field' => 'description'),
                array('db' => 'id', 'dt' => $col++, 'field' => 'id', 'formatter' => function ($d, $row) {
                    $url = base_url("ManageCMSPages/add/" . $d);
                    $btn = " <a data-toggle='tooltip' title='Edit' class='btn btn-xs btn-outline btn-success' href='$url' data-id='$d'><i class='fa fa-pencil'></i></a>";
                    $btn .= " <button data-toggle='tooltip' title='Delete' type='button' class='btn btn-xs btn-outline btn-danger remove_page' data-id='$d'><i class='fa fa-trash'></i></button>";


                    return $btn;
                }),

            );

            $joinQuery = "";
            $extraWhere = "";
            $groupBy = "";
            $having = "";

            $json = SSP::simple($this->input->post(), get_db_connection(), $table, $primaryKey, $columns, $joinQuery, $extraWhere, $groupBy, $having);

            $json['role'] = get_role();
            $json['access'] = getUserAccessArray();

            echo json_encode($json);
        } catch (Exception $e) {
            echo $e->getMessage;
        }
    } // getCMSPagesList


    public function getUrlRedirectionList()
    {
        require('ssp.customized.class.php');

        $sql_where = "";

        $search_And = [];
        $name = $this->input->post('name');

        try {

            $table = 'tbl_url_redirect';
            $primaryKey = 'id';
            $col = 0;
            $columns = array(

                array('db' => 'id', 'dt' => $col, 'field' => 'id'),
                array('db' => 'old_url', 'dt' => $col++, 'field' => 'old_url'),
                array('db' => 'new_url', 'dt' => $col++, 'field' => 'new_url'),

                array('db' => 'id', 'dt' => $col++, 'field' => 'id', 'formatter' => function ($d, $row) {
                    $url = base_url("ManageUrlRedirection/add/" . $d);
                    $btn = " <a data-toggle='tooltip' title='Edit' class='btn btn-xs btn-outline btn-success' href='$url' data-id='$d'><i class='fa fa-pencil'></i></a>";
                    $btn .= " <button data-toggle='tooltip' title='Delete' type='button' class='btn btn-xs btn-outline btn-danger remove_url_redirection' data-id='$d'><i class='fa fa-trash'></i></button>";


                    return $btn;
                }),

            );

            $joinQuery = "";
            $extraWhere = "";
            $groupBy = "";
            $having = "";

            $json = SSP::simple($this->input->post(), get_db_connection(), $table, $primaryKey, $columns, $joinQuery, $extraWhere, $groupBy, $having);

            $json['role'] = get_role();
            $json['access'] = getUserAccessArray();

            echo json_encode($json);
        } catch (Exception $e) {
            echo $e->getMessage;
        }
    } // getUrlRedirectionList

    public function getCustomersList()
    {
        require('ssp.customized.class.php');

        $sql_where = "";

        $search_And = [];
        $name = $this->input->post('name');

        try {

            $table = 'tbl_customer';
            $primaryKey = 'id';
            $col = 0;
            $columns = array(

                array('db' => 'id', 'dt' => $col, 'field' => 'id'),
                array('db' => 'name', 'dt' => $col++, 'field' => 'name'),
                array('db' => 'email', 'dt' => $col++, 'field' => 'email'),
                array('db' => 'phone', 'dt' => $col++, 'field' => 'phone'),
                array('db' => 'register_type', 'dt' => $col++, 'field' => 'register_type', 'formatter' => function ($d, $row) {
                    $register_type = "";
                    if ($row['register_type'] == '1') {
                        $register_type = "Phone";
                    }
                    if ($row['register_type'] == '2') {
                        $register_type = "Apple";
                    }
                    return $register_type;
                }),

                array('db' => 'user_type', 'dt' => $col++, 'field' => 'user_type', 'formatter' => function ($d, $row) {
                    $user_type = '';
                    if ($row['user_type'] == '1') {
                        $user_type = "Public User";
                    }
                    if ($row['user_type'] == '2') {
                        if ($row['business_type'] == '1') {
                            $user_type = "Studio";
                        }
                        if ($row['business_type'] == '0') {
                            $user_type = "Artist";
                        }
                    }


                    return $user_type;
                }),
                array('db' => 'status', 'dt' => $col++, 'field' => 'status', 'formatter' => function ($d, $row) {
                    $status_label = '';
                    if ($row['status'] == '0') {
                        $status_label = "<label class='badge badge-warning'>Not Approved</label>";
                    }
                    if ($row['status'] == '1') {
                        $status_label = "<label class='badge badge-success'>Approved</label>";
                    }
                    if ($row['status'] == '2') {
                        $status_label = "<label class='badge badge-danger'>Blocked</label>";
                    }
                    if ($row['status'] == '3') {
                        $status_label = "<label class='badge badge-danger'>Archive/Deleted</label>";
                    }
                    return $status_label;
                }),
                array('db' => 'business_type', 'dt' => $col++, 'field' => 'business_type'),


            );

            $joinQuery = "";
            $extraWhere = "";
            $groupBy = "";
            $having = "";

            $json = SSP::simple($this->input->post(), get_db_connection(), $table, $primaryKey, $columns, $joinQuery, $extraWhere, $groupBy, $having);

            $json['role'] = get_role();
            $json['access'] = getUserAccessArray();

            echo json_encode($json);
        } catch (Exception $e) {
            echo $e->getMessage;
        }
    } // getCustomersList

    public function getUsersList()
    {
        require('ssp.customized.closer.class.php');
        SSP::AllowSQLInTable();

        $users_type = $this->input->post('user_type');
        $search = $this->input->post('search[value]');

        $where = " WHERE id!=0 ";
        if($users_type == "business"){
            $where .= " AND user_type=2";
        }
        else if($users_type == "regular"){
            $where .= " AND user_type=1";
        }

        /* if($search != ""){
            $where .= " AND (name LIKE '%".$search."%' OR phone LIKE '%".$search."%' OR email LIKE '%".$search."%')";
        } */

        if ($search !== "") {
            // Escape user input for LIKE
            $search = $this->db->escape_like_str($search); // safe for Hebrew
            $like = "%" . $search . "%";
            $escaped_like = $this->db->escape($like); // wraps in quotes

            // Add to WHERE
            /* $where .= " AND (
                name LIKE $escaped_like ESCAPE '!' OR
                phone LIKE $escaped_like ESCAPE '!' OR
                email LIKE $escaped_like ESCAPE '!'
            )"; */

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

        // echo "Query : " . $table;
        // exit;

        $search_And = [];
        $name = $this->input->post('name');

        try {

            $table = "($table)";
            $primaryKey = 'c.id';
            $col = 0;
            $columns = array(
                
                array('db' => 'c.id', 'dt' => $col++, 'field' => 'id'),
                array('db' => 'c.name', 'dt' => $col++, 'field' => 'name'),
                array('db' => 'c.email', 'dt' => $col++, 'field' => 'email'),
                array('db' => 'c.phone', 'dt' => $col++, 'field' => 'phone'),
                array('db' => 'c.register_type', 'dt' => $col++, 'field' => 'register_type', 'formatter' => function ($d, $row) {
                    $register_type = "";
                    if ($row['register_type'] == '1') {
                        $register_type = "Phone";
                    }
                    else if ($row['register_type'] == '2') {
                        $register_type = "Apple";
                    }
                    else if ($row['register_type'] == '3') {
                        $register_type = "Gmail";
                    }
                    return $register_type;
                }),

                array('db' => 'c.user_type', 'dt' => $col++, 'field' => 'user_type', 'formatter' => function ($d, $row) {
                    $user_type = '';
                    if ($row['user_type'] == '1') {
                        $user_type = "Public User";
                    }
                    if ($row['user_type'] == '2') {
                        if ($row['business_type'] == '1') {
                            $user_type = "Studio";
                        }
                        if ($row['business_type'] == '2') {
                            $user_type = "Artist";
                        }
                    }
                    return $user_type;
                }),

                array('db' => 'c.status', 'dt' => $col++, 'field' => 'status', 'formatter' => function ($d, $row) {
                    $status_label = '';
                    if ($row['status'] == '0') {
                        $status_label = "<label class='badge badge-warning'>Not Approved</label>";
                    }
                    if ($row['status'] == '1') {
                        $status_label = "<label class='badge badge-success'>Approved</label>";
                    }
                    if ($row['status'] == '2') {
                        $status_label = "<label class='badge badge-danger'>Blocked</label>";
                    }
                    if ($row['status'] == '3') {
                        $status_label = "<label class='badge badge-danger'>Archive/Deleted</label>";
                    }
                    return $status_label;
                }),
                array('db' => 'c.plan_name', 'dt' => $col++, 'field' => 'plan_name', 'formatter' => function ($d, $row) {
                    // return $d;
                    if($row['plan_name'] == ""){
                        return "-";
                    }
                    else{
                        $subscription_array = [
                            "subscription_premium_5day"=>"5Days Premium Subscription",
                            "subscription_basic_5day"=>"5Days Basic Subscription",
                            "subscription_premium_10day"=>"10Days Premium Subscription",
                            "subscription_premium_10days"=>"10Days Premium Subscription",
                            "subscription_basic_10day"=>"10Days Basic Subscription",
                            "subscription_premium_15day"=>"15Days Premium Subscription",
                            "subscription_basic_15day"=>"15Days Basic Subscription",
                            "subscription_premium_20day"=>"20Days Premium Subscription",
                            "subscription_basic_20day"=>"20Days Basic Subscription",
                            "subscription_silver"=>"Silver Subscription",
                            "subscription_yearly"=>"Yearly Subscription",
                            "yearly_premium_plan"=>"Yearly Premium Subscription",
                            "monthly_premium_plan"=>"Monthly Premium Subscription",
                            "monthly_basic_plan"=>"Monthly Basic Subscription",
                            "yearly_basic_plan"=>"Yearly Basic Subscription",
                            "basic_free_plan"=>"Basic Free Plan"

                        ];
                        return $subscription_array[$row['plan_name']];
                    }
                }),
                array('db' => 'CAST(c.expire_date AS CHAR)', 'dt' => $col++, 'field' => 'expire_date', 'formatter' => function ($d, $row) {
                    // return $d;
                    if($row['plan_name'] == "basic_free_plan"){
                        return "-";
                    }
                    $html = '<a href="javascript:void(0);" class="exp_change" data-type="date" data-pk="'.$row['sub_id'].'" data-cust_id="'.$row['id'].'" data-val="'.$row['sub_id'].'" data-value="'.GetDateFormat($row['CAST(c.expire_date AS CHAR)']).'" data-title="Select Expire Date" data-sub_id="'.$row['sub_id'].'" ><span >'.GetDateFormat($row['CAST(c.expire_date AS CHAR)']).'</span></a>';
                    return $html;
                }),
                array('db' => 'c.is_sub_active', 'dt' => $col++, 'field' => 'is_sub_active', 'formatter' => function ($d, $row) {
                    // return $d;
                    $status_label = '-';
                    if ($row['is_sub_active'] == '1') {
                        $status_label = "<label class='badge badge-success'>Active</label>";
                    }
                    if ($row['is_sub_active'] == '2') {
                        $status_label = "<label class='badge badge-danger'>Expire</label>";
                    }
                    return $status_label;
                }),
                array('db' => 'c.post_limit', 'dt' => $col++, 'field' => 'post_limit', 'formatter' => function ($d, $row) {
                    // return $d;
                    if($row['plan_name'] != "basic_free_plan"){
                        return "-";
                    }
                    $html = '<a href="javascript:void(0);" class="post-limit" data-id="'.$row['id'].'" data-form="emp_app" data-val="'.$row['id'].'" data-value="'.$d.'" id="'.$row['id'].'" data-type="text" data-pk="'.$row['id'].'" data-title="Enter Post Limit" ><span>'.$d.'</span></a>';
                    return $html;
                }),
                array('db' => 'c.signature_image', 'dt' => $col++, 'field' => 'signature_image', 'formatter' => function ($d, $row) {
                    $html = "";
                    if($row['signature_image'] != ""){
                        $html = "<a class='btn btn-mini btn-outline-warning mr-2 btn_view_signature' href='javascript:void(0)' data-img_name='".$row['signature_image']."' data-id='".$row['id']."'><i class='fa fa-eye'></i></a>";
                    }
                    return $html;
                }),
                array('db' => 'c.id', 'dt' => $col++, 'field' => 'id', 'formatter' => function ($d, $row) {
                    return "";
                }),
                array('db' => 'c.business_type', 'dt' => $col++, 'field' => 'business_type'),
                array('db' => 'c.sub_id', 'dt' => $col++, 'field' => 'sub_id'),
            );

            $joinQuery = " FROM ($table) as c";
            $extraWhere = "$sql_where";
            $groupBy = "";
            $having = "";
            $json = SSP::simple($this->input->post(), get_db_connection(), $table, $primaryKey, $columns, $joinQuery, $extraWhere, $groupBy, $having);

            $json['role'] = get_role();
            $json['access'] = getUserAccessArray();
            /* echo '<pre>';
            print_r($json['sql']);
            exit; */
            echo json_encode($json);
        } catch (Exception $e) {
            echo $e->getMessage;
        }
    } // getUsersList

    public function getReortedUsersList()
    {
        require('ssp.customized.closer.class.php');
        SSP::AllowSQLInTable();
        $where = "";
        $table = "SELECT
            c.`id` AS id,
            c.`comment` AS comment,
            c.`status` AS status,
            (
            SELECT cs.name AS name
            FROM
                tbl_customer AS cs
            WHERE
                c.uid = cs.id
            ) AS name,
            (
            SELECT cs.name AS name
            FROM
                tbl_customer AS cs
            WHERE
                c.reported_by_uid = cs.id
            ) AS reported_by_user
        FROM
            tbl_report_users c $where ORDER BY c.id DESC";
        $sql_where = "";

        // echo "Query : " . $table;
        // exit;

        $search_And = [];
        $name = $this->input->post('name');

        try {

            $table = "($table)";
            $primaryKey = 'c.id';
            $col = 0;
            $columns = array(

                array('db' => 'c.id', 'dt' => $col, 'field' => 'id'),
                array('db' => 'c.name', 'dt' => $col++, 'field' => 'name'),
                array('db' => 'c.reported_by_user', 'dt' => $col++, 'field' => 'reported_by_user'),
                array('db' => 'c.comment', 'dt' => $col++, 'field' => 'comment'),
                array('db' => 'status', 'dt' => $col++, 'field' => 'status', 'formatter' => function ($d, $row) {
                    $status_label = '';
                    if($d == '0'){
                        $status_label = 'Request Pending';
                        $label = 'label-success';
                    }
                    if($d == '1'){
                        $status_label = 'User Blocked';
                        $label = 'label-danger';
                    }
                    if($d == '2'){
                        $status_label = 'Keep User';
                        $label = 'label-success';
                    }
                    return 
                    '<a href="#" class="status" data-value="'.$status_label.'" data-type="select" data-placement="right" data-pk="'.$row['id'].'" data-name="status" data-title="Select Status">
                        <span class="label '.$label.'">'.$status_label.'</span>
                    </a>';
                }), 
            );

            $joinQuery = " FROM ($table) as c";
            $extraWhere = "$sql_where";
            $groupBy = "";
            $having = "";

            $json = SSP::simple($this->input->post(), get_db_connection(), $table, $primaryKey, $columns, $joinQuery, $extraWhere, $groupBy, $having);

            $json['role'] = get_role();
            $json['access'] = getUserAccessArray();

            echo json_encode($json);
        } catch (Exception $e) {
            echo $e->getMessage;
        }
    } // getReortedUsersList

    public function getReortedPostsList()
    {
        require('ssp.customized.closer.class.php');
        SSP::AllowSQLInTable();
        $table = "SELECT
            c.`id` AS id,
            c.`comment` AS comment,
            c.`status` AS status,
            (
                SELECT
                    cs.name AS name
                FROM
                    tbl_customer AS cs
                WHERE
                    c.owner = cs.id
            ) AS owner,
            (
                SELECT
                    cs.name AS name
                FROM
                    tbl_customer AS cs
                WHERE
                    c.reported_by_uid = cs.id
            ) AS reported_by_user,(
                SELECT
                    cs.image_name AS image
                FROM
                    tbl_post AS cs
                WHERE
                    c.pid = cs.id
            ) AS post_image
        FROM
            tbl_report_posts c ORDER BY c.id DESC";
        $sql_where = "";

        // echo "Query : " . $table;
        // exit;

        $search_And = [];
        $name = $this->input->post('name');

        try {

            $table = "($table)";
            $primaryKey = 'c.id';
            $col = 0;
            $columns = array(

                array('db' => 'c.id', 'dt' => $col, 'field' => 'id'),
                array('db' => 'c.owner', 'dt' => $col++, 'field' => 'owner'),
                array('db' => 'c.reported_by_user', 'dt' => $col++, 'field' => 'reported_by_user'),
                array('db' => 'c.post_image', 'dt' => $col++, 'field' => 'post_image', 'formatter' => function ($d, $row) {
                    
                    if($row['post_image'] != ''){
                        return '<img src="'.$row['post_image'].'" alt="" height="100px" width="100px">';
                    }
                    else{
                        return '';
                    }
                    
                }),
                array('db' => 'c.comment', 'dt' => $col++, 'field' => 'comment'),
                array('db' => 'status', 'dt' => $col++, 'field' => 'status', 'formatter' => function ($d, $row) {
                    $status_label = '';
                    if($d == '0'){
                        $status_label = 'Request Pending';
                        $label = 'label-success';
                    }
                    if($d == '1'){
                        $status_label = 'Post Blocked';
                        $label = 'label-danger';
                    }
                    if($d == '2'){
                        $status_label = 'Keep Post';
                        $label = 'label-success';
                    }
                    return '<a href="#" class="status" data-value="'.$status_label.'" data-type="select" data-placement="right" data-pk="'.$row['id'].'" data-name="status" data-title="Select Status">
                        <span class="label '.$label.'">'.$status_label.'</span>
                    </a>';
                }), 
            );

            $joinQuery = " FROM ($table) as c";
            $extraWhere = "$sql_where";
            $groupBy = "";
            $having = "";

            $json = SSP::simple($this->input->post(), get_db_connection(), $table, $primaryKey, $columns, $joinQuery, $extraWhere, $groupBy, $having);

            $json['role'] = get_role();
            $json['access'] = getUserAccessArray();

            echo json_encode($json);
        } catch (Exception $e) {
            echo $e->getMessage;
        }
    } // getReortedPostsList

    public function getRequestsList()
    {
        require('ssp.customized.closer.class.php');
        SSP::AllowSQLInTable();

        $start_date = "";
        $end_date = "";
        $where = " WHERE id!=0 ";

        if($this->input->post('start_date') != ""){
            $start_date = date('Y-m-d',strtotime($this->input->post('start_date')));
        }
        if($this->input->post('end_date') != ""){
            $end_date = date('Y-m-d',strtotime($this->input->post('end_date')));
        }
    
        if ($start_date != "" && $end_date != "") {
            $where .= " AND (DATE(date_added)>='$start_date' AND DATE(date_added)<='$end_date') ";
        } else if ($start_date != "" && $end_date == "") {
            $where .= " AND DATE(date_added)='$start_date'";
        }
        $table = "SELECT
            c.`id` AS id,
            c.`name` AS name,
            c.`phone` AS phone,
            c.`tattoo_size` AS tattoo_size,
            c.`date_added` AS date_added,
            (
                SELECT
                    cs.name AS name
                FROM
                    tbl_customer AS cs
                WHERE
                    c.uid = cs.id
            ) AS user_name,
            (
                SELECT
                    cs.name AS name
                FROM
                    tbl_customer AS cs
                WHERE
                    c.artists_uid = cs.id
            ) AS artists_name,
            (
                SELECT
                    cs.name AS name
                FROM
                    tbl_customer AS cs
                WHERE
                    c.business_id = cs.id
            ) AS business_name,
            ( SELECT cs.phone FROM tbl_customer AS cs WHERE cs.id = c.uid )  AS cust_phone ,
            ( SELECT cs.cnt_code FROM tbl_customer AS cs WHERE cs.id = c.uid ) AS cnt_code
        FROM
            tbl_request c $where
            ORDER BY c.id DESC";
        $sql_where = "";

        // echo "Query : " . $table;
        // exit;

        $search_And = [];
        $name = $this->input->post('name');

        try {

            $table = "($table)";
            $primaryKey = 'c.id';
            $col = 0;
            $columns = array(
                
                array('db' => 'c.name', 'dt' => $col++, 'field' => 'name'),
                array('db' => 'c.cust_phone', 'dt' => $col++, 'field' => 'cust_phone', 'formatter' => function ($d, $row) {

                    $html = "";
                    if ($d != "") {
                        $html = $row['cnt_code'] . $d;
                    }

                    return $html;
                }),
                array('db' => 'c.tattoo_size', 'dt' => $col++, 'field' => 'tattoo_size'),
                array('db' => 'c.user_name', 'dt' => $col++, 'field' => 'user_name'),
                array('db' => 'c.artists_name', 'dt' => $col++, 'field' => 'artists_name'),
                array('db' => 'c.business_name', 'dt' => $col++, 'field' => 'business_name'),
                array('db' => 'c.date_added', 'dt' => $col++, 'field' => 'date_added', 'formatter' => function ($d, $row) {

                    if ($d != "0000-00-00 00:00:00") {
                        return date('d/m/y', strtotime($d));
                    } else {
                        return $d;
                    }
                }),
                array('db' => 'c.id', 'dt' => $col++, 'field' => 'id', 'formatter' => function ($d, $row) {

                    return "<a class='btn btn-mini btn-outline-warning mr-2' href='" . base_url('Requests/view/' . $d) . "'><i class='fa fa-eye'></i></a>";
                }),
                array('db' => 'c.cnt_code', 'dt' => $col++, 'field' => 'cnt_code'),
            );

            $joinQuery = " FROM ($table) as c";
            $extraWhere = "$sql_where";
            $groupBy = "";
            $having = "";

            $json = SSP::simple($this->input->post(), get_db_connection(), $table, $primaryKey, $columns, $joinQuery, $extraWhere, $groupBy, $having);

            $json['role'] = get_role();
            $json['access'] = getUserAccessArray();

            echo json_encode($json);
        } catch (Exception $e) {
            echo $e->getMessage;
        }
    } // getRequestsList

    public function getSubscriberList()
    {
        require('ssp.customized.closer.class.php');
        SSP::AllowSQLInTable();

        $table = "SELECT
            c.`id` AS id,
            c.`product_id` AS plan_name,
            c.`status` AS status,
            c.`is_delete` AS is_delete,
            (
                SELECT
                    cs.name AS name
                FROM
                    tbl_customer AS cs
                WHERE
                    c.cust_id = cs.id
            ) AS user_name
        FROM
            tbl_subscription c
            ORDER BY id DESC";
        $sql_where = "";

        $sql_where = " c.is_delete = '0'";

        $search_And = [];
        $name = $this->input->post('name');

        try {

            $table = "($table)";
            $primaryKey = 'c.id';
            $col = 0;
            $columns = array(
                
                array('db' => 'c.user_name', 'dt' => $col++, 'field' => 'user_name'),
                array('db' => 'c.plan_name', 'dt' => $col++, 'field' => 'plan_name'),
                array('db' => 'c.status', 'dt' => $col++, 'field' => 'status', 'formatter' => function ($d, $row) {
                    $status_label = '';
                    if ($row['status'] == '1') {
                        $status_label = "<label class='badge badge-success'>Active</label>";
                    }
                    if ($row['status'] == '2') {
                        $status_label = "<label class='badge badge-danger'>Expired</label>";
                    }
                    return $status_label;
                }),
                // array('db' => 'c.id', 'dt' => $col, 'field' => 'id', 'formatter' => function ($d, $row) {

                //     return "<a class='btn btn-mini btn-outline-warning mr-2' href='" . base_url('Requests/view/' . $d) . "'><i class='fa fa-eye'></i></a>";
                // }),
                // array('db' => 'c.id', 'dt' => $col, 'field' => 'id'),
            );

            $joinQuery = " FROM ($table) as c";
            $extraWhere = "$sql_where";
            $groupBy = "";
            $having = "";

            $json = SSP::simple($this->input->post(), get_db_connection(), $table, $primaryKey, $columns, $joinQuery, $extraWhere, $groupBy, $having);

            $json['role'] = get_role();
            $json['access'] = getUserAccessArray();

            echo json_encode($json);
        } catch (Exception $e) {
            echo $e->getMessage;
        }
    } // getSubscriberList

} // class ends