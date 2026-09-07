<?php 

if (!function_exists('valid_login'))
{
    function valid_login()
    {   
        $CI =& get_instance();
        $CI->auth->valid_login();
    }
}


if (!function_exists('is_login'))
{
    function is_login()
    {   
        $CI =& get_instance();
        return $CI->auth->is_login();
    }
}


if (!function_exists('get_role'))
{
    function get_role()
    {   
        $CI =& get_instance();
        return $CI->auth->get_role();
    }
}

if (!function_exists('isRole'))
{
    function isRole($name)
    {   
        //$CI =& get_instance();
        return (strtolower($name) == strtolower(get_role()))?true:false;
    }
}

if (!function_exists('getLoginUserID'))
{
    function getLoginUserID()
    {   
        $CI =& get_instance();
        return $CI->auth->getUserData("id");
    }
}


if (!function_exists('getUserData'))
{
    function getUserData($name='')
    {   
        $CI =& get_instance();
        return $CI->auth->getUserData($name);
    }
}

if (!function_exists('getAccess'))
{
    function getAccess()
    {   
        $CI =& get_instance();
        return $CI->auth->getAccess();
    }
}


function ExitWithJson($itm=[])
{
    $result = ['status'=>false,'msg'=>''];
    foreach ($itm as $k => $v) {
        $result[$k] = $v;
    }
    echo json_encode($result);
    exit;
}

if (!function_exists('getUserAccessArray'))
{
    function getUserAccessArray()
    {   
        $CI =& get_instance();
        return $CI->auth->getUserAccessArray();
    }
}

//most use this
if( !function_exists("hasAccess") ){
    function hasAccess($keys, $underscore_remove_find=false)
    {
        $CI =& get_instance();
        $acl_list = $CI->auth->getAccess();
        $role = $CI->auth->get_role();

        if( $role == "supper_admin" ){
            return true;
        }


        if(in_array("full_access",$acl_list)){
            return true;
        }

        if($underscore_remove_find){
            array_walk($acl_list,function(&$v){ 
                $v = (str_replace("_","", $v));
            });
        }

        if( !is_array($keys) ){
            $kky = explode(",",str_replace(",,",",",$keys));
            array_walk($kky,function(&$v){ 
                $v = strtolower(trim($v));
            });
            $keys = $kky;
            //$keys = [$keys];
        }

        if($underscore_remove_find){
            array_walk($keys,function(&$v){ 
                $v = (str_replace("_","", $v));
            });
        }

        /*
        if(in_array("institute_addupdate",$keys)){
        }*/

        $foundCount = count(array_intersect($keys, $acl_list));

        return (($foundCount > 0)?true:false);
    }
}

if (!function_exists('RedirectIfNothasAccess'))
{
    function RedirectIfNothasAccess($keys, $underscore_remove_find=false)
    {   
        $res = hasAccess($keys, $underscore_remove_find);
        if( !$res ){
            $CI =& get_instance();
            $CI->auth->redirect_dashboard();
        }
        return $res;
    }
}

