<?php
defined('BASEPATH') or exit('No direct script access allowed');

class Product_sale_report_model extends CI_Model
{
    public function __construct()
    {
        parent::__construct();
    }

    public function get_product_sale_data($start_date, $end_date)
    {
        $sale_product_list = [];

        // echo '<pre>';
        // print_r($sale_product_list);
        $total_product_data = $this->db->query("select id,name,barcode from tbl_products where is_delete = '0'");
        if ($total_product_data) {
            if ($total_product_data->num_rows() > 0) {
                foreach ($total_product_data->result() as $product_data) {
                    $sale_product_list[$product_data->id] = ['pid' => $product_data->id, 'pname' => $product_data->name, 'barcode' => $product_data->barcode, 'qty' => 0];
                }
            }
        }
        $result_order_data = $this->db->query("select id from tbl_orders where order_date BETWEEN '"  . $start_date . "'  AND '" . $end_date . "'");
        if ($result_order_data) {
            if ($result_order_data->num_rows() > 0) {
                // echo $this->db->last_query();
                // exit;

                foreach ($result_order_data->result() as $order_data) {
                    $result_order_item_data = $this->db->query("select pid,order_id from tbl_order_items where order_id='$order_data->id'");
                    if ($result_order_item_data) {
                        if ($result_order_item_data->num_rows() > 0) {
                            // echo $this->db->last_query();
                            // exit;

                            foreach ($result_order_item_data->result() as $order_item_data) {
                                $final_res = $this->db->query("select pid,sum(qty) as total_qty from tbl_order_items where pid='$order_item_data->pid' AND order_id='$order_item_data->order_id'");
                                if ($final_res) {
                                    if ($final_res->num_rows() > 0) {
                                        // echo $this->db->last_query();
                                        // exit;
                                        foreach ($final_res->result() as $test) {

                                            $sale_product_list[$order_item_data->pid]['qty'] = $sale_product_list[$order_item_data->pid]['qty'] + $test->total_qty;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        return $sale_product_list;
        // echo '<pre>';
        // print_r($sale_product_list);
        // exit;

    }
}
