<?php




if (!function_exists('set_flashdata')) {
    function set_flashdata($name, $data)
    {
        $CI = &get_instance();
        return $CI->session->set_flashdata($name, $data);
    }
}

if (!function_exists('get_flashdata')) {
    function get_flashdata($name)
    {
        $CI = &get_instance();
        return $CI->session->flashdata($name);
    }
}

if (!function_exists('is_local_admin_request')) {
    function is_local_admin_request()
    {
        $hosts = array();
        foreach (array('HTTP_HOST', 'SERVER_NAME', 'SERVER_ADDR') as $key) {
            if (empty($_SERVER[$key])) {
                continue;
            }
            $host = strtolower($_SERVER[$key]);
            $host = preg_replace('/:\d+$/', '', $host);
            $hosts[] = trim($host, '[]');
        }
        $remote = isset($_SERVER['REMOTE_ADDR']) ? trim($_SERVER['REMOTE_ADDR'], '[]') : '';
        $local = array('127.0.0.1', 'localhost', '::1', '10.0.2.2');
        return (bool) array_intersect($hosts, $local) || in_array($remote, $local, true);
    }
}

if (!function_exists('get_db_connection')) {
    function get_db_connection()
    {
        $CI = &get_instance();
        $host = $CI->db->hostname;
        $port = !empty($CI->db->port) ? (int) $CI->db->port : 3306;
        if (strpos($host, ':') !== false) {
            $parts = explode(':', $host, 2);
            $host = $parts[0];
            if (isset($parts[1]) && is_numeric($parts[1])) {
                $port = (int) $parts[1];
            }
        }
        $sql_details = array(
            'user' => $CI->db->username,
            'pass' => $CI->db->password,
            'db'   => $CI->db->database,
            'host' => $host,
            'port' => $port,
        );
        return $sql_details;
    }
}

if (!function_exists('getLoginUserID')) {
    function getLoginUserID()
    {
        $CI = &get_instance();
        return $CI->auth->getUserData("userid");
    }
}


if (!function_exists('getUserData')) {
    function getUserData($name = '')
    {
        $CI = &get_instance();
        if ($name == '') {
            return $CI->session->userdata();
        }
        return $CI->session->userdata($name);
    }
}


if (!function_exists('menu_class')) {
    function menu_class($route_prefix, $active_class = "active open", $exatMatch = false)
    {
        $CI = &get_instance();

        $resolver = function ($route_prefix) use (&$CI, $exatMatch) {
            $status = true;

            $route_prefix = str_replace("\\", "/", $route_prefix);
            $ex_tmp = explode("/", $route_prefix);
            foreach ($ex_tmp as $key => $value) {
                if ($value == "") {
                    unset($ex_tmp[$key]);
                }
            }

            if (count($ex_tmp) == 0) {
                $status = false;
                return $status;
            }

            $i = 1;
            foreach ($ex_tmp as $key => $prag) {
                $ttx = $CI->uri->segment($i);
                if ($ttx != false) {
                    $ttx = strtolower($ttx);
                }

                if ($ttx != strtolower($prag)) {
                    $status = false;
                }

                $i++;
            }

            if ($exatMatch) {
                $sa = $CI->uri->segment_array();
                $sag_url = strtolower(implode("/", $sa));
                $para_url = strtolower(implode("/", $ex_tmp));
                if ($sag_url == $para_url) {
                    $status = true;
                } else {
                    $status = false;
                }
            }

            return $status;
        };

        $status = false;
        if (!is_array($route_prefix)) {
            $route_prefix = explode(",", $route_prefix);
        }

        if (is_array($route_prefix)) {
            foreach ($route_prefix as $key => $value) {
                if ($status == false) {
                    $status = $resolver($value);
                }
            }
        } else {
            $status = $resolver($route_prefix);
        }


        if ($status) {
            return $active_class;
        }

        return "";
    }
}


if (!function_exists('FindKeyFromArray')) {

    function FindKeyFromArray($array, $key)
    {
        $result = [];
        foreach ($array as $keyName => $value) {
            if (in_array($keyName, $key)) {
                $result[$keyName] = $value;
            }
        }
        return $result;
    }
}



if (!function_exists("_set_value")) {
    function _set_value($name)
    {
        return htmlspecialchars(set_value($name));
    }
}


if (!function_exists("_value")) {
    function _value($name)
    {
        return htmlspecialchars(($name));
    }
}


if (!function_exists('validateDate')) {
    function validateDate($date, $format = 'Y-m-d H:i:s')
    {
        $d = DateTime::createFromFormat($format, $date);
        //return $d && $d->format($format) == $date;
        $return = $d && $d->format($format) == $date;
        if ($return) {
            return ['date' => $d->format('Y-m-d'), 'time' => $d->format('H:i:s'), 'date_time' => $d->format('Y-m-d H:i:s')];
        } else {
            return false;
        }
    }
}

//for display date in view page
if (!function_exists('get_my_date_format')) {
    function get_my_date_format($date, $format = 'd/m/Y', $default_return = '')
    {
        if ($date and $date != '0000-00-00' and $date != '0000-00-00 00:00:00') {
            return date($format, strtotime($date));
        } else {
            return $default_return;
        }
    }
}


if (!function_exists('toDate')) {

    function toDate($date, $format)
    {
        $d = DateTime::createFromFormat($format, $date);
        //return $d && $d->format($format) == $date;
        $return = $d && $d->format($format) == $date;
        if ($return) {
            return ['date' => $d->format('Y-m-d'), 'time' => $d->format('H:i:s'), 'date_time' => $d->format('Y-m-d H:i:s')];
        } else {
            return false;
        }
    }
}

if (!function_exists('DateFormat')) {
    function DateFormat($date, $defaultFormat = 'd/m/Y')
    {
        if ($date == "" || $date == "0000-00-00" || $date == "0000-00-00 00:00:00") {
            return "";
        }
        return date($defaultFormat, strtotime($date));
    }
}
