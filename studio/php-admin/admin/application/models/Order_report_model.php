<?php
defined('BASEPATH') or exit('No direct script access allowed');

class Order_report_model extends CI_Model
{
    public function __construct()
    {
        parent::__construct();
    }

    public function GetOrderReportYearList()
    {
        $this->db->select('YEAR(`order_date`) as year');
        $this->db->from('tbl_orders');
        $this->db->group_by('YEAR(order_date)');
        $this->db->order_by('order_date', 'asc');

        $result_order_year = $this->db->get();
        // echo $this->db->last_query();
        // exit;
        if ($result_order_year->num_rows() > 0) {
            $order_year_list = array();
            foreach ($result_order_year->result() as $r) {
                array_push($order_year_list, $r->year);
            }
            return $order_year_list;
        }
        return array();
    }

    public function get_total_order_and_amount($order_year)
    {

        $order_data_list = [
            [
                'year' => $order_year,
                'month' => "01",
                'month_name' => "January",
                'total_orders' => 0,
                'total_amt' => 0
            ],
            [
                'year' => $order_year,
                'month' => "02",
                'month_name' => "February",
                'total_orders' => 0,
                'total_amt' => 0
            ],
            [
                'year' => $order_year,
                'month' => "03",
                'month_name' => "March",
                'total_orders' => 0,
                'total_amt' => 0
            ],
            [
                'year' => $order_year,
                'month' => "04",
                'month_name' => "April",
                'total_orders' => 0,
                'total_amt' => 0
            ],
            [
                'year' => $order_year,
                'month' => "05",
                'month_name' => "May",
                'total_orders' => 0,
                'total_amt' => 0
            ],
            [
                'year' => $order_year,
                'month' => "06",
                'month_name' => "June",
                'total_orders' => 0,
                'total_amt' => 0
            ],
            [
                'year' => $order_year,
                'month' => "07",
                'month_name' => "July",
                'total_orders' => 0,
                'total_amt' => 0
            ],
            [
                'year' => $order_year,
                'month' => "08",
                'month_name' => "August",
                'total_orders' => 0,
                'total_amt' => 0
            ],
            [
                'year' => $order_year,
                'month' => "09",
                'month_name' => "September",
                'total_orders' => 0,
                'total_amt' => 0
            ],
            [
                'year' => $order_year,
                'month' => "10",
                'month_name' => "October",
                'total_orders' => 0,
                'total_amt' => 0
            ],
            [
                'year' => $order_year,
                'month' => "11",
                'month_name' => "November",
                'total_orders' => 0,
                'total_amt' => 0
            ],
            [
                'year' => $order_year,
                'month' => "12",
                'month_name' => "December",
                'total_orders' => 0,
                'total_amt' => 0
            ]

        ];

        foreach ($order_data_list as $key => $value) {

            $this->db->select('sum(final_total) as total_amount,count(*) as total_orders');
            $this->db->from('tbl_orders');
            $this->db->where('YEAR(order_date)', $value['year']);
            $this->db->where('month(order_date)', $value['month']);
            $result_order_data = $this->db->get();
            // echo $this->db->last_query();
            // exit;
            if ($result_order_data->num_rows() > 0) {
                foreach ($result_order_data->result() as $r) {
                    $total_order = $r->total_orders;
                    $total_amount = $r->total_amount;
                    $order_data_list[$key]['total_orders'] = $total_order;
                    $order_data_list[$key]['total_amt'] = number_format($total_amount, 2);
                }
            }
        }
        return $order_data_list;
    }
}
