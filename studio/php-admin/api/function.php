<?php
define("GOOGLE_API_KEY", "AIzaSyDdTeFwDMiycVp1HyLduCxPxFKSpK0RaK0");
// define("GOOGLE_AUTH_KEY", "AAAA08Tq19M:APA91bGEYH87NYkx9kcG7xLplly2aLazT2F_8JIM2nRDnegTrBwMK3OKJ36uGcsBvRvlkAj_kz78RQAYhvZsNRcGuwtX8Xq4lCdUCMBixJuEauUgR826_KhP8j0slzC9byOT_86JhPEL");
define("GOOGLE_AUTH_KEY", "AAAAikauheM:APA91bFLrU91JLI2p8f_2VvYIkwIE4UCQFTga0WOgPNtW3NxbO1WpyXnS3gayqTJy8h9akvhKrBrUkT_sXqLgHqeDjGWFWo31m2eJ-gR6jOtcxuXoW9L8e6T2_M_5_Y_3OoBkJvb1_ng");

include __DIR__ . "/smtp/class.smtp.php";
include __DIR__ . "/smtp/class.phpmailer.php";
include __DIR__ . "/smtp/email.config.php";

include_once 'TimeZoneConvert.php';

use Google\Auth\Credentials\ServiceAccountCredentials;
use Google\Auth\HttpHandler\HttpHandlerFactory;

use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\SMTP;
use PHPMailer\PHPMailer\Exception;

//////////////////// PROJECT FUNCTION STARST HERE //////////////////////////////////
function sortByrank($a, $b) {
    if($a['followers'] == $b['followers']) return 0;
    // return ($a['followers'] > $b['followers'] )?-1:1;
    return ($a['followers'] > $b['followers'])?-1:1; //it will sort by ASC
}

function get_style_list()
{
    global $db;
    $db->select("*");
    $db->from("tbl_styles");
    $db->order_by("seq", "asc");
    $result = $db->get();
    if (!$result) {
        register_db_error(array("sql" => $db->last_query(), "error" => $db->error()));
        return [];
    } else {
        return $result->result_array();
    }
}

function get_style_detail($slug)
{
    global $db;
    $db->select("*");
    $db->from("tbl_styles");
    $db->where("slug", $slug);
    $db->order_by("seq", "asc");
    $db->limit('1');
    $result = $db->get();
    if (!$result) {
        register_db_error(array("sql" => $db->last_query(), "error" => $db->error()));
        return [];
    } else {
        return $result->row_array();
    }
}
function get_business_list($param=[])
{
    global $db;
    $user_list = [];
    $bid = $param['bid'];
    $where = "c.user_type='2' AND c.is_delete='0' AND c.status='1'";
    $limit = "";
    if(isset($param['business_type'])){
        if($param['business_type']!=""){
            $where.=" AND c.business_type='".$param['business_type']."'";
        }
    }

    if(isset($param['search_txt'])){
        if($param['search_txt']!=""){
           
            $where.=" AND ( c.name LIKE '%".$param['search_txt']."%')";
        }
    }

    if(isset($param['start']) && isset($param['limit'])){
        if($param['start']!=""){
           
            $limit.=" LIMIT ".$param['start'].",".$param['limit'];
        }
    }
    
    // $sql = "SELECT * FROM tbl_customer WHERE ".$where.$limit;
    $sql = "SELECT
        c.*,
        CASE WHEN(
        SELECT
            id
        FROM
            tbl_artist_business_map
        WHERE
            bid = '$bid' AND uid = c.id AND req_status IN('0', '1')
        ORDER BY
            id
        DESC
    LIMIT 1
    ) THEN 1 ELSE 0
    END AS is_request_sent
    FROM
        tbl_customer AS c WHERE ".$where . " ORDER BY is_request_sent DESC" . $limit;
    $result = $db->query($sql);
    if (!$result) {
        register_db_error(array("sql" => $db->last_query(), "error" => $db->error()));
        return [];
    } else {
        if($result->num_rows()>0)
        {
            foreach($result->result_array() as $row){
                // $row['is_request_sent'] = is_artist_requst_sent($row['id'],$param['bid']);
                $user_list[] = $row;
            }
        }
        return $user_list;
        // return $result->result_array();
    }
}

function is_artist_requst_sent($uid,$bid)
{
    global $db;
    $is_request_sent = "0";
    $sql="SELECT uid,id FROM tbl_artist_business_map WHERE bid='$bid' AND uid='$uid' AND req_status IN('0','1') ORDER BY id DESC LIMIT 1";
    $result=$db->query($sql);
    if($result)
    {
        if($result->num_rows()>0)
        {
            foreach($result->result() as $row){
                if(count(get_user_profile($row->uid)) > 0){
                    $is_request_sent = "1";
                }
            }
        }
    }
    return $is_request_sent;
}

function search_posts($param=[]){
    global $db;
    $post_where = "";
    if(isset($param['my'])){
        if($param['my']!=""){
           
            $post_where .= " AND uid='".$param['uid']."'";
        }
    }
    
    $post_sql="SELECT id from tbl_post where status='1' ".$post_where." ORDER BY id DESC";
    $extra_where = "";
    
    $post_ids = [];

    if(isset($param['not_in'])){
        if($param['not_in']!=""){
           
            $extra_where .= " AND p.id not in (".$param['not_in'].")";
        }
    }

     
    $post_sql = $post_sql ;
    $result=$db->query($post_sql);
    if (!$result) {
        register_db_error(array("sql" => $db->last_query(), "error" => $db->error()));
        $post_ids = [];
    } else {
        $rows=$result->result_array();
        foreach($rows as $r){
            $post_ids[] = $r['id'];
        }
    }

    $order_by = "";
    $extra_field = "";
    $extra_sql_start = "";
    $extra_sql_end = "";

    if(isset($param['is_recommended'])){
        $arr_styles=explode(",",$param['is_recommended']);
        if(count($arr_styles)>0)
        {
            $where_str=[];
            $extra_field.="CASE WHEN(";
            foreach($arr_styles as $single_style){
                $where_str[]=" find_in_set('$single_style', p.styles)>0 ";
            }
            $extra_field.=implode("OR",$where_str);
            $extra_field.=") THEN 1 ELSE 0 END AS recommanded,";

        }
        $order_by = " ORDER BY recommanded DESC, p.id DESC ";

        $extra_sql_start = "SELECT * FROM (";
        $extra_sql_end = ") AS subquery ORDER BY RAND();";
    }

    if(isset($param['most_view'])){
        if($param['most_view']=="1"){
            if($order_by == ""){
                $order_by = " ORDER BY view_count DESC ";
            }
            else{
                $order_by .= " ,view_count DESC ";
            }
        }
    }

    if(isset($param['is_new'])){
        if($param['is_new']=="1"){
            if($order_by == ""){
                $order_by = " ORDER BY date_added DESC ";
            }
            else{
                $order_by .= " ,date_added DESC ";
            }
        }
    }
    
    // $sql="SELECT id from tbl_post where status='1' ";
    /* $countSQL = "SELECT
        COUNT(DISTINCT p.id) as total_posts
    FROM
        tbl_post p,tbl_subscription s,tbl_customer c
    WHERE
    p.status='1' AND p.uid=s.cust_id AND c.id=p.uid AND c.is_delete='0' AND s.status='1' AND s.is_sub_active='1'"; */
    /* $countSQL = "SELECT
        COUNT(DISTINCT p.id) as total_posts
    FROM
        tbl_post p,tbl_subscription s,tbl_customer c
    WHERE
    p.status='1' AND p.uid=s.cust_id AND c.id=p.uid 
    AND
       (
        SELECT s.status
        FROM tbl_subscription s
        WHERE p.uid = s.cust_id ORDER BY s.id DESC LIMIT 1
    ) = '1' AND
    (
        SELECT s.is_sub_active
        FROM tbl_subscription s
        WHERE p.uid = s.cust_id ORDER BY s.id DESC LIMIT 1
    ) = '1'"; */

    $where="";
    $limit="";

    $post_count = get_post_count($param['uid']);
    $profile = get_user_profile($param['uid']);
    $post_limit = $profile['post_limit'];

    if(isset($param['styles'])){
        $arr_styles=explode(",",$param['styles']);
        if(count($arr_styles)>0)
        {
            $where_str=[];
            $where.="AND (";
            foreach($arr_styles as $single_style){
                if(trim($single_style) != '')
                {
                    $where_str[]=" find_in_set('$single_style', p.styles)>0 ";
                }
            }
            $where.=implode("OR",$where_str);
            $where.=")";
        }
    }

    if(isset($param['following'])){
        if($param['following']=="1"){
            $friends_ids=get_my_following_ids_list($param['uid']);
            $where.=" AND uid IN(".implode(",",$friends_ids).")";
        }
    }

    if(isset($param['my'])){
        if($param['my']=="1"){
            $where.=" AND uid=".$param['uid'] . " AND NOT (
            (
                SELECT
                    s.product_id
                FROM
                    tbl_subscription s
                WHERE
                    s.cust_id = p.uid
                ORDER BY
                    s.id
                DESC
                LIMIT 1
            ) LIKE '%basic%'
            AND p.img_type = '1')";
            if(count($post_ids) > 0){
                if($post_count >= $post_limit){
                    $sub_detail=get_subscribe_detail($param['uid']);
                    if(isset($sub_detail['is_premium']))
                    {
                        if($sub_detail['is_premium']=="1")
                            $allow_all="1";

                    }

                    if($allow_all=="")
                    {
                        //$extra_where .= " AND p.id IN(".implode(',',array_slice($post_ids, 0, $post_limit, true)).") ";
                    }
                }
            }
        }
    }

    if(isset($param['search_txt'])){
        if($param['search_txt']!=""){
           
            $where.=" AND ( description LIKE '%".$param['search_txt']."%')";
        }
    }

    $not_in_post_ids = ""; 
    if(isset($param['post_ids']) && $param['post_ids'] != ""){
        $not_in_post_ids = " AND p.id NOT IN(".$param['post_ids'].")"; 
    }

    if(isset($param['start']) && isset($param['limit'])){
        if($param['start']!=""){
           
            $limit.=" LIMIT ".$param['start'].",".$param['limit'];
        }
    }

    $rand = '';
    $random_where = "";
    $random_group = "";
    if(isset($param['is_random']) && $param['is_random'] == '1')
    {
        /* $random_where  = " AND
            p.uid IN (
            SELECT uid
            FROM (
                SELECT DISTINCT p.uid
                FROM tbl_post p
                JOIN tbl_subscription s ON p.uid = s.cust_id
                JOIN tbl_customer c ON p.uid = c.id
                WHERE
                    p.status = '1'
                    AND (
                        SELECT s.status
                        FROM tbl_subscription s
                        WHERE p.uid = s.cust_id
                        ORDER BY s.id DESC
                        LIMIT 1
                    ) = '1'
                    AND (
                        SELECT s.is_sub_active
                        FROM tbl_subscription s
                        WHERE p.uid = s.cust_id
                        ORDER BY s.id DESC
                        LIMIT 1
                    ) = '1'
                    AND c.status = '1'
                    AND c.is_delete = '0' $where
                LIMIT 6 
            ) AS unique_uids
        )"; */
        $random_group = " GROUP BY p.uid";
        $rand = ' ORDER BY RAND()';
    }

    if($rand == "" && $order_by == ""){
        $order_by = " ORDER BY p.id DESC";
    }
    
    $sql="SELECT
        DISTINCT p.id,
        p.uid,
        p.view_count,
        p.date_added,
        p.img_type,
        p.image_name,
        p.image_id,
        $extra_field
        (
            SELECT id
            FROM tbl_subscription s
            WHERE p.uid = s.cust_id AND s.status = '1' AND s.is_sub_active = '1' ORDER BY s.id DESC LIMIT 1
        ) AS sub_id,
        (
            SELECT id
            FROM tbl_customer c
            WHERE p.uid = c.id AND c.status = '1' AND c.is_delete = '0'
        ) AS cust_id,
        (
            SELECT s.status
            FROM tbl_subscription s
            WHERE p.uid = s.cust_id ORDER BY s.id DESC LIMIT 1
        ) AS sub_status,
        (
            SELECT s.is_sub_active
            FROM tbl_subscription s
            WHERE p.uid = s.cust_id ORDER BY s.id DESC LIMIT 1
        ) AS is_sub_active,
        (
            SELECT s.product_id
            FROM tbl_subscription s
            WHERE p.uid = s.cust_id ORDER BY s.id DESC LIMIT 1
        ) AS product_id
    FROM
        tbl_post p
    WHERE
        p.status = '1' 
    ";
    $having = "";
    if(!isset($param['my'])){
        $having = " HAVING
            sub_id IS NOT NULL AND cust_id IS NOT NULL AND sub_status = '1' AND is_sub_active = '1'";
    }
    /* $sql="SELECT
        DISTINCT p.id,
        ($countSQL $where $extra_where $rand limit 1) as total_posts,
        p.uid,
        p.view_count,
        p.date_added,
        $extra_field
        s.cust_id,
        c.id as cust_id
    FROM
        tbl_post p,tbl_subscription s,tbl_customer c
    WHERE
    p.status='1' AND p.uid=s.cust_id AND c.id=p.uid AND c.is_delete='0' AND s.status='1' AND s.is_sub_active='1'"; */

    $count_result = [];
    if(isset($param['my'])){
        if($param['my']=="1"){
            $post_sql=$extra_sql_start .$sql.$where." AND img_type='0'".$random_where.$not_in_post_ids.$extra_where.$random_group.$having.$rand.$order_by.$limit . $extra_sql_end;
            $result=$db->query($post_sql);
            $count_result = $db->query($post_sql)->result_array();

            $post_sql=$extra_sql_start .$sql.$where." AND img_type='1'".$random_where.$not_in_post_ids.$extra_where.$random_group.$having.$rand.$order_by.$limit . $extra_sql_end;
            $result=$db->query($post_sql);
            $count_result2 = $db->query($post_sql)->result_array();
            $count_result = array_merge($count_result,$count_result2);

        }
    }
    else{
        $post_sql=$extra_sql_start .$sql.$where.$random_where.$not_in_post_ids.$extra_where.$random_group.$having.$rand.$order_by.$limit . $extra_sql_end;
        $result=$db->query($post_sql);
        $count_result = $db->query($post_sql)->result_array();
    }

    // echo "<pre>";
    // print_r(count($count_result));
    // exit;
    $extra_results = [];
    /* if(isset($param['is_random']) && $param['is_random'] == '1' && $param['limit'] > 4)
    {
        if (count($count_result) < 6) {
            $remaining = 6 - count($count_result);
            $remaining_limit = " limit " . $remaining;
            $fetched_ids = array_column($count_result, 'id');
            $not_in_post_ids = '';
            if (!empty($fetched_ids)) {
                $not_in_post_ids = ' AND p.id NOT IN (' . implode(',', $fetched_ids) . ')';
            }
    
            $ramain_post_sql=$sql.$where.$random_where.$not_in_post_ids.$extra_where.$random_group.$having.$rand.$order_by.$remaining_limit;
            $extra_results = $db->query($ramain_post_sql)->result_array();
        }
    } */
    // $results = array_merge($count_result, $extra_results);
    // echo "\nQuery : " . $db->last_query();
    // exit;

    $unique_posts = $count_result;
    $fetched_ids = array_column($count_result, 'id');
    $limit_count = (isset($param['limit'])) ? $param['limit'] : "";
    if(isset($param['is_random']) && $param['is_random'] == '1' && ($limit_count == 4 || $limit_count == 6))
    {
        while (count($unique_posts) < $limit_count) {
            $remaining = $limit_count - count($unique_posts);
        
            // Prepare NOT IN clause to prevent duplicate post IDs
            $not_in_post_ids = '';
            if (!empty($fetched_ids)) {
                $not_in_post_ids = ' AND p.id NOT IN (' . implode(',', $fetched_ids) . ')';
            }
        
            // Query to fetch additional unique posts
            $remaining_limit = " LIMIT " . $remaining;
            $ramain_post_sql = $sql . $where . $random_where . $not_in_post_ids . $extra_where . $having . $rand . $order_by . $remaining_limit;
        
            // Fetch additional posts
            $extra_results = $db->query($ramain_post_sql)->result_array();
        
            // Break if no more results to avoid infinite loop
            if (empty($extra_results)) {
                break;
            }
        
            // Merge additional posts and update fetched IDs
            $unique_posts = array_merge($unique_posts, $extra_results);
            $fetched_ids = array_column($unique_posts, 'id');
        
            // Remove any duplicate post IDs (just in case)
            $unique_posts = array_map('unserialize', array_unique(array_map('serialize', $unique_posts)));
        
            // Stop once we have 6 unique posts
            if (count($unique_posts) == $limit_count) {
                break;
            }
        }
        $unique_posts = array_slice($unique_posts, 0, $limit_count);
    }

    $results = $unique_posts;

    return $results;

}

function get_post_detail($id,$uid)
{
    global $db;
    $db->select("*");
    $db->from("tbl_post");
    $db->where(["id =" => $id, "status" => '1']);
    $result = $db->get();
    if (!$result) {
        register_db_error(array("sql" => $db->last_query(), "error" => $db->error()));
        return [];
    } else {
        $rows=$result->result_array();
        if(count($rows)>0){
            $row=$rows[0];
            $owner=get_user_profile($row['uid']);
            $row['owner']=$owner;
            if($owner['business_type'] == "1"){
                $row['artist']=get_user_profile($row['artist_uid']);
            }
            else{
                $row['artist']=[];
            }
            $row['liked']=get_liked_by_me($row['uid'],$uid);
            $row['followers']=get_user_followers($row['uid']);
            $row['post_liked']=get_post_liked_by_me($row['id'],$uid);
            $row['post_likes']=get_post_likes($row['id']);
            
            //$row['q']=$db->last_query();
            return $row;
        }else{
            return [];
        }
    }
}
function get_post_image($id,$uid)
{
    global $db;
    $db->select("image_name");
    $db->from("tbl_post");
    $db->where(["id =" => $id, "status" => '1']);
    $result = $db->get();
    if (!$result) {
        register_db_error(array("sql" => $db->last_query(), "error" => $db->error()));
        return [];
    } else {
        $rows=$result->result_array();
        if(count($rows)>0){
            $row=$rows[0];
            //$row['q']=$db->last_query();
            return $row;
        }else{
            return [];
        }
    }
}

function get_business_posts($bid,$uid,$post_limit,$order_by = '',$show_less=''){
    global $db;
    global $data;
    $data['show_less']=$show_less;
    $list=[];
    $arr_tatto=[];
    $arr_sketch=[];
    $result=$db->query("select id,img_type,image_name from tbl_post where uid='$bid' AND status='1' AND img_type='1' $order_by LIMIT 0,$post_limit");
    $posts_images = array();
    if($result){
        if($result->num_rows()>0){
            foreach($result->result() as $r){

                $single = [];
                $single['post_id'] = $r->id;
                $single['image_url'] = explode(",",$r->image_name)[0]; //get_post_image($r->image_name);
                $single['is_multiple_image'] = count(explode(",",$r->image_name))> 1 ? "1" : "0";
                $posts_images[] = $single;

                if($show_less=="")
                {
                    if($r->img_type=="1")
                    {
                        $sketches=get_post_detail($r->id,$uid);
                        $sketches['is_multiple_image']=count(explode(",",$sketches['image_name'])) > 1 ? "1" : "0";
                        $sketches['image_name']=explode(",",$sketches['image_name'])[0];
                        $sketches['image_id']=explode(",",$sketches['image_id'])[0];
                        $arr_sketch[]=$sketches;
                    }
                }
                
            }
        }
    }
    $result=$db->query("select id,img_type,image_name from tbl_post where uid='$bid' AND status='1' AND img_type='0' $order_by LIMIT 0,$post_limit");
    // $posts_images = array();
    if($result){
        if($result->num_rows()>0){
            foreach($result->result() as $r){

                $single = [];
                $single['post_id'] = $r->id;
                $single['image_url'] = explode(",",$r->image_name)[0]; //get_post_image($r->image_name);
                $single['is_multiple_image'] = count(explode(",",$r->image_name))> 1 ? "1" : "0";
                $posts_images[] = $single;

                if($show_less=="")
                {
                    if($r->img_type=="0")
                    {
                        $tattoos=get_post_detail($r->id,$uid);
                        $tattoos['is_multiple_image']=count(explode(",",$tattoos['image_name'])) > 1 ? "1" : "0";
                        $tattoos['image_name']=explode(",",$tattoos['image_name'])[0];
                        $tattoos['image_id']=explode(",",$tattoos['image_id'])[0];
                        $arr_tatto[]=$tattoos;
                    }
                }
                
            }
        }
    }
    
    return ['sketch'=>$arr_sketch,'tatto'=>$arr_tatto , 'posts_images' => $posts_images];
}

function get_business_detail($bid,$uid,$limit = 0,$order_by = '',$show_less=''){
    global $db;
    $profile=get_user_profile($bid);
    $post_limit = $profile['post_limit'];
    if($limit != 0)
    {
        if($post_limit > $limit)
        {
            $post_limit = $limit;
        }
    }

    $profile['styles_he'] = [];
    if($profile['styles'] != '')
    {
        // $user_styles = $profile['styles'];
        $user_styles=explode(",",$profile['styles']);
        foreach($user_styles as $user_style)
        {
            $style_detail = get_style_detail(trim($user_style));
            $profile['styles_he'][] .= $style_detail['name'];
        }
    
    }

    $profile['artist']=[];
    $profile['studio']=[];

    if($show_less=="")
    {
        $profile['liked']=get_liked_by_me($bid,$uid);
        $profile['followers']=get_user_followers($bid);

        if($profile['business_type']=="1")
        {
            $profile['artist']=get_business_artist_list($bid,$uid);
        }
        if($profile['business_type']=="2")
        {
            $profile['studio']=get_business_studio_list($uid,$bid);
        }
    }else{
        $profile['liked']="0";
        $profile['followers']="0";
        $profile['artist']=[];
        $profile['studio']=[];
        
    }

    $profile['posts']=get_business_posts($bid,$uid,$post_limit,$order_by,$show_less);
    
    
    return $profile;

}

function get_business_artist_list($bid,$uid){
    global $db;
    $user_list=[];
    $sql="select uid from tbl_artist_business_map where bid='$bid' AND req_status='1'";
    $result=$db->query($sql);
    if($result)
    {
        if($result->num_rows()>0)
        {
            foreach($result->result() as $row){
                $user_check=get_user_profile($row->uid);
                if(count($user_check) > 0){
                    $user_list[]=$user_check; 
                }
            }
        }
    }
    return $user_list;
}

function get_subscription_list(){
    global $db;
    $user_list=[];
    $list=[];
    $uids = [];
    $is_premium = "";
    // $sql="select cust_id,product_id from tbl_subscription where status='1'";
    // $sql="SELECT cust_id,product_id FROM tbl_subscription WHERE is_sub_active='1' AND status='1' GROUP BY cust_id ORDER BY id DESC";
    $sql = "SELECT
        sub.cust_id,
        sub.product_id,
        c.id,
        c.sub_id
    FROM
        tbl_subscription sub
    JOIN
        tbl_customer c 
    on 
        sub.cust_id = c.id AND sub.id = c.sub_id
    WHERE
        sub.is_sub_active = '1' AND sub.status = '1' 
    GROUP BY
        cust_id
    ORDER BY
        id
    DESC";
    $result=$db->query($sql);
    if($result)
    {
        if($result->num_rows()>0)
        {
            foreach($result->result() as $row)
            {
                $chk_sub_plan = explode("_",$row->product_id);
                if($chk_sub_plan[1] == "premium"){
                    $is_premium = "1";
                }
                else if($chk_sub_plan[1] == "basic"){
                    $is_premium = "0";
                }
                if(!in_array($row->cust_id,$uids))
                {
                    $user_list['uid']=$row->cust_id;
                    $user_list['is_premium']=$is_premium;
                }
                $list[] = $user_list;
            }
        }
    }
    return $list;
}

function get_post_count($uid)
{
    global $db;
    $total_post = 0;
    $db->select("count(uid) as total_post");
    $db->from("tbl_post");
    $db->where(['uid'=>$uid,"status!=" => '3']);
    $result = $db->get();
    if (!$result) {
        register_db_error(array("sql" => $db->last_query(), "error" => $db->error()));
        return [];
    } else {
        $rows=$result->result_array();
        if(count($rows)>0){
            $total_post=$rows[0]['total_post'];
            return $total_post;
        }else{
            return $total_post;
        }
    }
}

function get_user_post_limit($id)
{
    global $db;
    $total_post = 0;
    $db->select("post_limit");
    $db->from("tbl_customer");
    $db->where(['id'=>$id,'status'=>'1','is_delete'=>'0']);
    $result = $db->get();
    if (!$result) {
        register_db_error(array("sql" => $db->last_query(), "error" => $db->error()));
        return [];
    } else {
        $rows=$result->result_array();
        if(count($rows)>0){
            $total_post=$rows[0]['post_limit'];
            return $total_post;
        }else{
            return $total_post;
        }
    }
}

function get_business_search($param=[]){
    global $db;
    global $data;
    $ids=[];
    $extra_sel="";
    // $extra_where=" AND id!='". $param['uid']."'";
    $extra_where="";
    
    $where="";
    $order_by="";
    $limit = "";
    if(isset($param['styles'])){
        $arr_styles=explode(",",$param['styles']);
        if(count($arr_styles)>0)
        {
            $where_str=[];
            $where.="AND (";
            foreach($arr_styles as $single_style){
                if(trim($single_style) != '')
                {
                    $where_str[]=" find_in_set('$single_style', c.styles)>0 ";
                }
            }
            $where.=implode("OR",$where_str);
            $where.=")";
        }
    }

    if(isset($param['search_txt'])){
        if($param['search_txt']!=""){
           
            $where.=" AND ( c.name LIKE '%".$param['search_txt']."%')";
            $extra_where="";
        }
    }

    if(isset($param['new'])){
        if($param['new']!=""){
            $order_by=" ORDER BY c.register_date DESC";
        }
    }

    if(isset($param['lat']))
    {
        if(isset($param['lng']))
        {
            if($param['lat']!="" && $param['lng']!="" && $param['radius']!=""){
                //$where.=" AND distance1 < ".$param['radius'];
                if(isset($param['is_filter_location']))
                {
                    if($param['is_filter_location'] == "1"){
                        // $where.="  HAVING distance1 <= ".$param['radius'];
                        if(isset($param['is_closest'])){
                            if($param['is_closest'] != "1"){
                                $order_by = " ORDER BY distance1";
                            }
                        }
                    }
                }
                if($order_by == ""){
                    $order_by = " HAVING distance1 <= ".$param['radius'] . " ORDER BY distance1";
                    // $order_by = " ORDER BY distance1";
                }
                else{
                    $order_by .= ", distance1";
                }
                // $extra_sel=",(SQRT(POW(69.1 * (address_lat - ".$param['lat']."), 2) + POW(69.1 * (".$param['lng']." - address_lng) * COS(address_lat / 57.3), 2))) AS distance1 ";// for distance in miles
                $extra_sel.=",(SQRT(POW(111.32 * (c.address_lat - ".$param['lat']."), 2) + POW(111.32 * (".$param['lng']." - c.address_lng) * COS(c.address_lat / 57.3), 2))) AS distance1 ";// for distance in kilometers
            }
        }
    }
    else if(isset($param['lat_ord']))
    {
        if(isset($param['lng_ord'])){
            if($param['lat_ord']!="" && $param['lng_ord']!="")
            {
                $order_by = " ORDER BY distance1 ASC";
                // $extra_sel=",(SQRT(POW(69.1 * (address_lat - ".$param['lat']."), 2) + POW(69.1 * (".$param['lng']." - address_lng) * COS(address_lat / 57.3), 2))) AS distance1 ";// for distance in miles
                $extra_sel=",(SQRT(POW(111.32 * (c.address_lat - ".$param['lat_ord']."), 2) + POW(111.32 * (".$param['lng_ord']." - c.address_lng) * COS(c.address_lat / 57.3), 2))) AS distance1 ";
            }
        }
    }

    if(isset($param['is_recommended'])){
        $arr_styles=explode(",",$param['is_recommended']);
        if(count($arr_styles)>0)
        {
            $where_str=[];
            $extra_sel.=",CASE WHEN(";
            foreach($arr_styles as $single_style){
                $where_str[]=" find_in_set('$single_style', c.styles)>0 ";
            }
            $extra_sel.=implode("OR",$where_str);
            $extra_sel.=") THEN 1 ELSE 0 END AS recommanded";

        }
        if($order_by == ""){
            $order_by = " ORDER BY recommanded DESC";
        }
        else{
            $order_by .= ", recommanded DESC";
        }
        // $order_by = " ORDER BY recommanded DESC";
    }

    if(isset($param['is_closest'])){
        if($param['is_closest'] == "1"){
            if($param['user_lat']!="" && $param['user_lng']!="" ){
                $order_by = " ORDER BY user_distance";
                // $extra_sel=",(SQRT(POW(69.1 * (address_lat - ".$param['lat']."), 2) + POW(69.1 * (".$param['lng']." - address_lng) * COS(address_lat / 57.3), 2))) AS distance1 ";// for distance in miles
                $extra_sel=",(SQRT(POW(111.32 * (c.address_lat - ".$param['user_lat']."), 2) + POW(111.32 * (".$param['user_lng']." - c.address_lng) * COS(c.address_lat / 57.3), 2))) AS user_distance ";// for distance in kilometers
            }
        }
    }

    if(isset($param['popular'])){
        if($param['popular'] == "1"){
            $order_by=" ORDER BY total_active_followers DESC";
        }
    }
    

    /* if(isset($param['lat']))
    {
        if(isset($param['lng']))
        {
            if($param['lat']!="" && $param['lng']!="" && $param['radius']!=""){
                //$where.=" AND distance1 < ".$param['radius'];
                if(isset($param['is_filter_location']))
                {
                    if($param['is_filter_location'] == "1"){
                        $where.="  HAVING distance1 <= ".$param['radius'];
                        if(isset($param['is_closest'])){
                            if($param['is_closest'] != "1"){
                                $order_by = " ORDER BY distance1";
                            }
                        }
                    }
                }
                if($order_by == ""){
                    $order_by = " ORDER BY distance1";
                }
                else{
                    $order_by .= ", distance1";
                }
                // $extra_sel=",(SQRT(POW(69.1 * (address_lat - ".$param['lat']."), 2) + POW(69.1 * (".$param['lng']." - address_lng) * COS(address_lat / 57.3), 2))) AS distance1 ";// for distance in miles
                $extra_sel.=",(SQRT(POW(111.32 * (address_lat - ".$param['lat']."), 2) + POW(111.32 * (".$param['lng']." - address_lng) * COS(address_lat / 57.3), 2))) AS distance1 ";// for distance in kilometers
            }
        }
    }
    else if(isset($param['lat_ord']))
    {
        if(isset($param['lng_ord'])){
            if($param['lat_ord']!="" && $param['lng_ord']!="")
            {
                $order_by = " ORDER BY distance1 ASC";
                // $extra_sel=",(SQRT(POW(69.1 * (address_lat - ".$param['lat']."), 2) + POW(69.1 * (".$param['lng']." - address_lng) * COS(address_lat / 57.3), 2))) AS distance1 ";// for distance in miles
                $extra_sel=",(SQRT(POW(111.32 * (address_lat - ".$param['lat_ord']."), 2) + POW(111.32 * (".$param['lng_ord']." - address_lng) * COS(address_lat / 57.3), 2))) AS distance1 ";
            }
        }
    } */

    if(isset($param['start']) && isset($param['limit'])){
        if($param['start']!=""){
           
            $limit.=" LIMIT ".$param['start'].",".$param['limit'];
        }
    }

    if(isset($param['premium'])){
        if($param['premium']!=""){
            $extra_where.=" and s.product_id like '%premium%' ";
            $limit='';
        }
    }

    if(isset($param['random_id'])){
        if($param['random_id']!=""){
            $extra_where.=" and c.id!=".$param['random_id'];
        }
    }
    

    // $sql="select id".$extra_sel." from tbl_customer where user_type='2' AND status='1' AND is_delete='0' AND id!='". $param['uid']."'";
    $sql="select c.id,s.product_id,COUNT(DISTINCT CASE WHEN fs.id IS NOT NULL THEN f.id END) AS total_active_followers".$extra_sel." from tbl_customer c 
    JOIN  tbl_subscription s ON s.id = c.sub_id AND s.status = '1' AND s.is_delete = '0'
    LEFT JOIN tbl_follows f_rel ON f_rel.follow_uid = c.id LEFT JOIN tbl_customer f ON f.id = f_rel.uid AND f.user_type = '2' AND f.status = '1' AND f.is_delete = '0'
    LEFT JOIN tbl_subscription fs ON fs.id = f.sub_id AND fs.status = '1' AND fs.is_delete = '0'
    WHERE c.user_type = '2' AND c.status = '1' AND c.is_delete = '0' ". $extra_where." ";

    $result=$db->query($sql.$where." GROUP BY c.id, s.product_id  ".$order_by.$limit);
    // echo "query : " . $db->last_query();
    // exit;
    // Don't embed SQL in API JSON (bloated / can break clients).
    // $data['q']=$db->last_query();
    if($result){
        if($result->num_rows()>0){
            foreach($result->result() as $r){
                $ids[]=$r->id;
            }
        }
    }
    return $ids;
}


function get_liked_by_me($fid,$uid){
    global $db;
    $result=$db->query("select id from tbl_follows where follow_uid='$fid' AND uid='$uid' LIMIT 1");
    if($result){
        if($result->num_rows()>0){
           return "1";
        }
    }
    return "0";
}

function get_post_liked_by_me($pid,$uid){
    global $db;
    $result=$db->query("select id from tbl_post_likes where pid='$pid' AND uid='$uid' LIMIT 1");
    if($result){
        if($result->num_rows()>0){
           return "1";
        }
    }
    return "0";
}



function get_post_likes($pid){
    global $db;
    return 0;
    $result=$db->query("select COUNT(p.id) as total_likes from tbl_post_likes p,tbl_customer c where pid='$pid' AND f.uid=c.id AND c.is_delete='0' ");
    if($result){
        if($result->num_rows()>0){
            $rows=$result->result_array();
            $row=$rows[0];
            if(isset($row['total_likes']))
                return $row['total_likes'];
        }
    }
    return 0;
}


function get_user_followers($uid,$params = []){
    global $db;
    /* $where_uid = " AND follow_uid='$uid' AND f.uid = c.id
        AND
        (
            SELECT s.status
            FROM tbl_subscription s
            WHERE f.uid = s.cust_id ORDER BY s.id DESC LIMIT 1
        ) = '1' AND
        (
            SELECT s.is_sub_active
            FROM tbl_subscription s
            WHERE f.uid = s.cust_id ORDER BY s.id DESC LIMIT 1
        ) = '1'
    ";
    if(isset($params['is_following']) && $params['is_following'] == '1')
    {
        $where_uid = " AND uid = '$uid' AND f.follow_uid = c.id 
        
        AND
        (
            SELECT s.status
            FROM tbl_subscription s
            WHERE f.follow_uid = s.cust_id ORDER BY s.id DESC LIMIT 1
        ) = '1' AND
        (
            SELECT s.is_sub_active
            FROM tbl_subscription s
            WHERE f.follow_uid = s.cust_id ORDER BY s.id DESC LIMIT 1
        ) = '1'";
    } */

    $where_uid = " AND follow_uid='$uid' AND f.uid = c.id";
    if(isset($params['is_following']) && $params['is_following'] == '1')
    {
        $where_uid = " AND uid = '$uid' AND f.follow_uid = c.id";
    }

    // $query = "SELECT COUNT(f.id) as total_follow FROM tbl_follows f, tbl_customer c WHERE c.is_delete='0' $where_uid";
    $query = "SELECT
        COUNT(f.id) AS total_follow
    FROM
        tbl_follows f,
        tbl_customer c
    WHERE
        c.is_delete='0' $where_uid";

    $result=$db->query($query);
    // echo "Query : " . $db->last_query();
    // exit;

    if($result){
        if($result->num_rows()>0){
            $rows=$result->result_array();
            $row=$rows[0];
            if(isset($row['total_follow']))
                return $row['total_follow'];
        }
    }
    return 0;
}

function get_follower_list_old($uid)
{
    global $db;
    $list=[];
    $result=$db->query("select uid from tbl_follows where follow_uid='$uid'");
    if($result){
        if($result->num_rows()>0){
            foreach($result->result() as $row){
                $list[]=get_user_profile($row->uid);
            }
            
        }
    }

    return $list;
}

function get_follower_list($uid, $params = [])
{
    global $db;
    $list=[];
    $limit = '';
    $where_uid = " AND follow_uid='$uid'";
    $join = " f.uid = c.id";
    if(isset($params['is_following']) && $params['is_following'] == '1')
    {
        $where_uid = " AND uid = '$uid'";
        $join = " f.follow_uid = c.id";
    }
    if(isset($params['limit']))
    {
        $limit = " LIMIT ". $params['limit'];
        if(isset($params['start']))
        {
            $limit .= " OFFSET  ". $params['start'];
        }
    }
    $result=$db->query("select c.id, c.name, c.status, c.email, c.phone, c.cnt_code, c.lang, c.profile_image, c.styles, c.business_type, c.user_type, c.login_type, c.address, c.address_lat, c.address_lng, c.address_place_id,c.city_name, c.about_text, c.post_limit, c.is_register from tbl_follows f left join tbl_customer c on $join where c.is_delete = '0' $where_uid $limit");
    /* echo "Query : " . $db->last_query();
    exit; */
    if($result){
        if($result->num_rows()>0){
            foreach($result->result() as $rows){
                $row=get_user_profile($rows->id);
                if($row['user_type'] == "2"){
                    if($row['city_name'] == ""){
                        $row['city_name'] = get_city_name($row['address_lat'],$row['address_lng']);
                        // $city_result = $db->update("tbl_customer", ['city_name'=>$row['city_name']], ['id'=>$row['id']]);
                    }
                }
                $list[]=$row;
            }
            // $list = $result->result_array();
        }
    }

    return $list;
}

function get_new_user_list($uid, $params = [])
{
    global $db;
    $list=[];
    $limit = '';
    if(isset($params['limit']))
    {
        $limit = " LIMIT ". $params['limit'];
        if(isset($params['start']))
        {
            $limit .= " OFFSET  ". $params['start'];
        }
    }
    // $result=$db->query("select c.id, c.name, c.status, c.email, c.phone, c.cnt_code, c.lang, c.profile_image, c.styles, c.business_type, c.user_type, c.login_type, c.address, c.address_lat, c.address_lng, c.address_place_id, c.about_text, c.post_limit, c.is_register from tbl_customer c where  c.is_delete = '0' ORDER BY register_date DESC $limit");

    // $result=$db->query("SELECT s.cust_id,s.product_id,c.id, c.name, c.status, c.email, c.phone, c.cnt_code, c.lang, c.profile_image, c.styles, c.business_type, c.user_type, c.login_type, c.address, c.address_lat, c.address_lng, c.address_place_id, c.about_text, c.post_limit, c.is_register FROM tbl_subscription s LEFT JOIN tbl_customer c on s.cust_id = c.id WHERE s.is_sub_active='1' AND s.status='1' AND c.is_delete = '0' GROUP BY s.cust_id ORDER BY c.register_date DESC $limit");
    $sql = "SELECT
            c.id, c.name, c.register_date, c.status, c.email, c.phone, c.cnt_code, c.lang, c.profile_image, c.styles, c.business_type, c.user_type, c.login_type, c.address, c.address_lat, c.address_lng, c.address_place_id, c.about_text, c.post_limit, c.is_register,
            (
                SELECT id
                FROM tbl_subscription s
                WHERE c.id = s.cust_id AND s.status = '1' AND s.is_sub_active = '1' ORDER BY s.id DESC LIMIT 1
            ) AS sub_id,
            (
                SELECT s.status
                FROM tbl_subscription s
                WHERE c.id = s.cust_id ORDER BY s.id DESC LIMIT 1
            ) AS sub_status,
            (
                SELECT s.is_sub_active
                FROM tbl_subscription s
                WHERE c.id = s.cust_id ORDER BY s.id DESC LIMIT 1
            ) AS is_sub_active
        FROM
            tbl_customer c 
        WHERE
            c.is_delete = '0' AND c.is_business = '1'
        HAVING
            sub_id IS NOT NULL AND sub_status = '1' AND is_sub_active = '1'
        ORDER BY
            c.register_date
        DESC
        $limit";
    $result=$db->query($sql);
    if($result){
        if($result->num_rows()>0){
            // foreach($result->result() as $row){
            //     $list[]=get_user_profile($row->uid);
            // }
            $list = $result->result_array();
        }
    }
    // echo "Query : " . $db->last_query();
    // exit;

    return $list;
}

function get_follower_ids_list($uid)
{
    global $db;
    $list=[];
    $result=$db->query("select uid from tbl_follows where follow_uid='$uid'");
    if($result){
        if($result->num_rows()>0){
            foreach($result->result() as $row){
                $list[]=$row->uid;
            }
            
        }
    }

    return $list;
}


function get_my_following_ids_list($uid)
{
    global $db;
    $list=[];
    $result=$db->query("select f.follow_uid from tbl_follows f,tbl_customer c where f.uid='$uid' AND f.follow_uid=c.id AND c.is_delete='0'");
    if (!$result) {
        register_db_error(array("sql" => $db->last_query(), "error" => $db->error()));
        return [];
    }else{
        if($result->num_rows()>0){
            foreach($result->result() as $row){
                $list[]=$row->follow_uid;
            }
        }
    }

    return $list;
}

function get_user_udid($uid)
{
    global $db;
    $db->select("udid");
    $db->from("tbl_customer");
    $db->where(["id" => $uid, "is_delete" => "0"]);
    $db->limit(1);
    $result = $db->get();
    if (!$result) {
        register_db_error(array("sql" => $db->last_query(), "error" => $db->error()));
        return [];
    } else {
        if ($result->num_rows() > 0) {
            $rows = $result->result_array();
            return $rows[0];
        } else {
            return [];
        }
    }
}


function get_user_by_phone($phone)
{
    global $db;
    $row = [];
    $result = get("tbl_customer", "*", ['phone' => $phone, 'is_delete' => '0'], "", 1);
    if ($result) {
        if (num_rows($result) > 0) {
            $row = fetch_assoc($result);
        }
    }
    return $row;
}

function get_user_by_email($email)
{
    global $db;
    $row = [];
    $result = get("tbl_customer", "*", ['email' => $email, 'is_delete' => '0'], "", 1);
    if ($result) {
        if (num_rows($result) > 0) {
            $row = fetch_assoc($result);
        }
    }
    return $row;
}

function check_is_unique_user_name($data)
{
    global $db;
    $db->select("name");
    $db->from("tbl_customer");
    $db->where(["name" => $data['name'], "is_delete" => "0"]);
    $db->where_not_in('id',$data['id']);
    $db->limit(1);
    $result = $db->get();
    // echo "\nQuery : " . $db->last_query();
    // exit;
    if ($result) {
        if (num_rows($result) > 0) {
            return false;
        }
    }
    return true;
}

function get_subscribe_list()
{
    global $db;
    $db->select("*");
    $db->from("tbl_subscription");
    $db->where(["is_delete" => '0']);
    $result = $db->get();
    if (!$result) {
        register_db_error(array("sql" => $db->last_query(), "error" => $db->error()));
        return [];
    } else {
        return $result->result_array();
    }
}

function get_subscribe_detail($uid,$is_premium="")
{
    $is_premium = "";
    global $db;
    $db->select("*");
    $db->from("tbl_subscription");
    // $db->where(["is_delete"=>'0','cust_id'=>$uid,'is_sub_active'=>'1','status'=>'1']);
    $where_check=["is_delete"=>'0','cust_id'=>$uid];
    if($is_premium=="1")
    {
        $where_check['product_id']="monthly_premium_plan";
    }
    $db->where($where_check);
    $db->order_by("id", "desc");
    $result = $db->get();
    // echo "Query : " . $db->last_query();
    // exit;
    if (!$result) {
        register_db_error(array("sql" => $db->last_query(), "error" => $db->error()));
        return [];
    } else {
        if($result->num_rows()>0){
            $rows=$result->result_array();
            $chk_sub_plan = explode("_",$rows[0]['product_id']);
            if($chk_sub_plan[1] == "premium"){
                $is_premium = "1";
            }
            else if($chk_sub_plan[1] == "basic"){
                $is_premium = "0";
            }
            $rows[0]['is_premium']=$is_premium;
            return $rows[0];
        }else{
            return [];
        }
    }
}

function is_user_sub_active($id)
{
    global $db;
    $db->select("is_sub_active");
    $db->from("tbl_subscription");
    $db->where(["is_delete"=>'0','id'=>$id]);
    $result = $db->get();
    if (!$result) {
        register_db_error(array("sql" => $db->last_query(), "error" => $db->error()));
        return [];
    } else {
        if($result->num_rows()>0){
            $rows=$result->result_array();
            return $rows[0]['is_sub_active'];
        }else{
            return [];
        }
    }
}

function get_user_sub_id($id)
{
    global $db;
    $db->select("sub_id");
    $db->from("tbl_customer");
    $db->where(["status"=>'1','id'=>$id,'is_delete'=>'0']);
    $result = $db->get();
    if (!$result) {
        register_db_error(array("sql" => $db->last_query(), "error" => $db->error()));
        return [];
    } else {
        if($result->num_rows()>0){
            $rows=$result->result_array();
            return $rows[0]['sub_id'];
        }else{
            return '';
        }
    }
}

function get_ios_subscribe_data($transaction_id)
{
    global $db;
    $db->select("transaction_id");
    $db->from("tbl_subscription");
    // $db->where(["is_delete" => '0','transaction_id'=>$transaction_id,'is_sub_active'=>'1']);
    $db->where(["is_delete" => '0','transaction_id'=>$transaction_id]);
    $db->order_by("id", "desc");
    $db->limit(1);
    $result = $db->get();
    if (!$result) {
        register_db_error(array("sql" => $db->last_query(), "error" => $db->error()));
        return [];
    } else {
        if($result->num_rows()>0){
            $rows=$result->result_array();
            return $rows[0]['transaction_id'];
        }else{
            return "";
        }
    }
}

/* function get_ios_sub_ipn_detail($signed_payload)
{
    global $db;
    $db->select("*");
    $db->from("tbl_ios_subscription_ipn");
    $db->where(['signed_payload'=>$signed_payload]);
    $result = $db->get();
    if (!$result) {
        register_db_error(array("sql" => $db->last_query(), "error" => $db->error()));
        return [];
    } else {
        if($result->num_rows()>0){
            $rows=$result->result_array();
            return $rows[0];
        }else{
            return [];
        }
    }
} */
function get_ios_sub_ipn_detail($original_id)
{
    global $db;
    $db->select("*");
    $db->from("tbl_ios_subscription_ipn");
    $db->where(['original_transaction_id'=>$original_id]);
    $result = $db->get();
    if (!$result) {
        register_db_error(array("sql" => $db->last_query(), "error" => $db->error()));
        return [];
    } else {
        if($result->num_rows()>0){
            $rows=$result->result_array();
            return $rows[0];
        }else{
            return [];
        }
    }
}

function get_ios_transaction_id($original_transaction_id)
{
    global $db;
    $db->select("*");
    $db->from("tbl_ios_subscription_ipn");
    $db->where(['original_transaction_id'=>$original_transaction_id]);
    $db->order_by("date_added", "DESC");
    $result = $db->get();
    if (!$result) {
        register_db_error(array("sql" => $db->last_query(), "error" => $db->error()));
        return [];
    } else {
        if($result->num_rows()>0){
            $rows=$result->result_array();
            return $rows[0];
        }else{
            return [];
        }
    }
}

function get_android_subscription_status( $productId, $purchaseToken )
{
	$result = (object)[ 'status' => false, 'msg'=>'', 'error'=>'' ,'purchase'=>false ];

	$result->isActiveSubscription = false;

	$result->priceAmount = 0;
	$result->priceCurrency = '';

	$result->acknowledgementState = false;
	$result->startDateTime = '';
	$result->endDateTime = '';

	$result->autoRenewing = false;
	//$result->autoResumeDateTime = '';

	$result->isCancel = false;
	$result->userCancelDateTime = '';

	$result->isCancelReason = false;

	$result->orderId='';
	$result->countryCode = "";

	$result->startDateTimeUTC = '';
	$result->endDateTimeUTC = '';
	$result->userCancelDateTimeUTC = '';

	$result->productId = $productId;
	$result->isIntroductoryPriceInfo = false;

	//default 
	// $packageName = "com.diuk.appdiuk";
	// $packageName = "com.swt.inappdemoflutter";
	$packageName = "com.itapp2u.ink";
	// $packageName = "com.vm.inapp";
	$result->packageName = $packageName;


	if( $productId == "" || $purchaseToken == "" ){
		$result->error = "productId or purchaseToken is empty";
		$result->msg = $result->error;
		return $result;
	}

	// 
	// $productId = "com.diuk.appdiuk.samplequotes.subyearly";
	// $purchaseToken = "aedcppobkdleklecmpjdkcnp.AO-J1OyI58FJdPFzhzNhJB-4lN-baQdvTZPvQtl0h4qutnWB4KqpRFlpDqcFduWwhA1Gd9IxW058Ese4oPQga6Jcnn_scYLmAw";

	try {
        
		$client = new Google_Client();
		// $client->setAuthConfig(__DIR__.'/fluttertestinapp-b21b3bd7f5ab.json');
		// $client->setAuthConfig(__DIR__.'/inappdemo-ecaff-d735f6c01bdc.json');
		// $client->setAuthConfig(__DIR__.'/inappdemo-ecaff-310f7b8360a3.json');
		// $client->setAuthConfig(__DIR__.'/inappsubscriptionv3-45a9e37342f6.json');
		$client->setAuthConfig(__DIR__.'/ink-flutter-app-2ff19eb8244b.json');

		//inlive set key for more req.
		//$apiKey = "AIzaSyBvGo9XFgyyGfBwi-rJYqhu9DiUx1olaQQ"; //Your API key
		//$client->setDeveloperKey($apiKey);

		$client->addScope('https://www.googleapis.com/auth/androidpublisher');

		$service = new Google_Service_AndroidPublisher($client);

		$purchase = $service->purchases_subscriptions->get($packageName, $productId, $purchaseToken);
		$result->purchase = $purchase;

		//1.99, priceAmountMicros is 1990000
		$price = floatval($purchase->priceAmountMicros / 1000000);

		if( isset($purchase->introductoryPriceInfo) ){
			$price = floatval($purchase->introductoryPriceInfo->introductoryPriceAmountMicros / 1000000);
			$result->isIntroductoryPriceInfo = true;
		}
		
		// print_r( $purchase );
        // exit;

		$result->priceAmount = $price;
		$result->priceCurrency = $purchase->priceCurrencyCode;

		$result->acknowledgementState = $purchase->acknowledgementState==1?true:false;
		$result->autoRenewing = $purchase->autoRenewing;
		$result->isCancel = $purchase->autoRenewing == true ? false:true;

		$result->isCancelReason = $purchase->cancelReason==1?true:false;
		$result->orderId= $purchase->orderId;

		//local time zone wise return 
		$result->startDateTime = date('Y-m-d H:i:s',($purchase->startTimeMillis/1000));
		$result->endDateTime = date('Y-m-d H:i:s',($purchase->expiryTimeMillis/1000));

		if( $purchase->userCancellationTimeMillis ){
			$result->userCancelDateTime = date('Y-m-d H:i:s',($purchase->userCancellationTimeMillis/1000));
		}

		//to UTC time
		$result->startDateTimeUTC = convertDatetimeZone($result->startDateTime,date_default_timezone_get(),'UTC');
		$result->endDateTimeUTC = convertDatetimeZone($result->endDateTime,date_default_timezone_get(),'UTC');

		if( $result->userCancelDateTime != "" ){
			$result->userCancelDateTimeUTC = convertDatetimeZone($result->userCancelDateTimeUTC,date_default_timezone_get(),'UTC');
		}

		$result->countryCode = $purchase->countryCode;
		$result->status = true;
		//promotionCode
		//$purchase->getCancelSurveyResult();
		//var_dump( $purchase->getAutoRenewing() );

		//check is active subsc status 
		$now = strtotime(convertDatetimeZone( date('Y-m-d H:i:s') ,date_default_timezone_get(),'UTC'));
		$exp_time = strtotime(convertDatetimeZone($result->endDateTime,date_default_timezone_get(),'UTC'));
		$result->isActiveSubscription = $exp_time > $now;

		//$v = $service->purchases_subscriptions->cancel($packageName,$productId, $purchaseToken);

		// var_dump( $sub->purchases_subscriptions->cancel($json->packageName, $json->productId, $json->purchaseToken)); // OK

		// var_dump($sub->purchases_subscriptions->revoke($json->packageName, $json->productId, $json->purchaseToken)); // KO { "error": { "code": 500, "message": null } }

	} catch (Exception $e) {
		$result->error = $e->getMessage();
		$result->msg = "Error";
	}

    // echo "<pre>";
    // print_r($result);
    // exit;
	return $result;
}

//time zone convert 
function convertDatetimeZone($datetime,$timeZone='UTC',$outTimeZone=''){
	if( $outTimeZone == '' ){
		$outTimeZone = date("P");
	}
	$d = new TimeZoneConvert($datetime , $timeZone );
	return $d->toTimeZone( $outTimeZone );
}

function get_user_profile($id,$logged_in_uid="")
{
    global $db;
    $row = [];
    $extra_fields=",firebase_id,location_enable,udid,push_enable,login_token,is_delete,device_type";
    if($logged_in_uid!=$id){
        $extra_fields="";
    }
    $result = get("tbl_customer", "id".$extra_fields.",name,status,email,phone,cnt_code,lang,profile_image,styles,business_type,user_type,login_type,address,address_lat,address_lng,address_place_id,city_name,about_text,post_limit,is_register,is_email_send_plan_upgrade,is_email_send", ['id' => $id, 'is_delete' => '0'], "", 1);
    if ($result) {
        if (num_rows($result) > 0) {
            $row = fetch_assoc($result);
            if($row['user_type'] == "2"){
                if($row['city_name'] == ""){
                    $row['city_name'] = get_city_name($row['address_lat'],$row['address_lng']);
                    $db->update("tbl_customer", ['city_name'=>$row['city_name']], ['id'=>$row['id']]);
                }
            }
        }
    }
    return $row;
}

function get_udid($uids)
{
    global $db;
    $rows = [];
    
    $result = get("tbl_customer", "device_type,udid,push_enable", "id IN(".implode(",",$uids).")");
    if ($result) {
        if( $result->num_rows() > 0 ){
            foreach ($result->result_array() as $row) {
                $rows[]=$row;
            }
        }
    }
    return $rows;
}

function get_city_name($address_lat,$address_lng)
{
    global $db;
    $city_name = "";
    $apiKey = 'AIzaSyDdTeFwDMiycVp1HyLduCxPxFKSpK0RaK0';

    // Latitude and Longitude
    $latitude = floatval($address_lat);
    $longitude = floatval($address_lng);

    // Geocoding API URL
    $url = "https://maps.googleapis.com/maps/api/geocode/json?latlng=".$latitude.",".$longitude."&key=".$apiKey;

    // Fetch the JSON response
    $response = file_get_contents($url);    
    $data = json_decode($response, true);

    // Extract the city name from the response
    if (isset($data['results'][0])) {
        $components = $data['results'][0]['address_components'];
        foreach ($components as $component) {
            if (in_array('locality', $component['types'])) {
                $city_name = $component['long_name'];
                break;
            }
        }
    }
    return $city_name;
}

function validate_token($token, $uid, $check_status = "")
{
    global $db;

    $where = ['login_token' => $token, 'id' => $uid];

    if ($check_status == "1") {
        $extra_where = "";
    } else {
        $where['status'] = "1";
    }

    $result = get("tbl_customer", "id,login_token", $where);
    if (num_rows($result) > 0) {
        $row = fetch_assoc($result);
        return $row;
    }
    return false;
} // validate_token

// sending mail to admin 
function sending_email_admin($uid,$subject)
{
    $get_settings = get_settings();
    $admin_emails = explode(",",$get_settings['admin_email']);
    // $admin_emails = $get_settings['admin_email'];
    // echo "\nadmin emails : " ; print_r($admin_emails);
    // echo "\nSubject : " . $subject;

    $user_detail = get_user_profile($uid);
    // echo "<pre>";
    // print_r($user_detail);
    // exit;

    $business_type = "";
    if($user_detail['business_type'] == '1'){
        $business_type = "Studio";
    }
    else if($user_detail['business_type'] == '2'){
        $business_type = "Artist";
    }
    
    $message = "
    <tr>
        <td colspan='2'>
            <p style='font-size:18px;line-height:15px;'><b>User Detail</b></p>
        </td>
    </tr>
    <tr>
        <td width='20%' style='padding-top:1px;'>
            <p style='font-size:14px;line-height:10px;padding-top:5px;'><b>User Name</b></p>
        </td>
        <td>
            <p style='font-size:14px;line-height:10px;padding-top:5px;'>: ".$user_detail['name']."</p>
        </td>
    </tr>";
    if($user_detail['email'] != ""){
        $message .= "<tr>
            <td width='20%'>
                <p style='font-size:14px;line-height:10px;padding-top:5px;'><b>User Email</b></p>
            </td>
            <td>
                <p style='font-size:14px;line-height:10px;padding-top:5px;'>: ".$user_detail['email']."</p>
            </td>
        </tr>";
    }
    
    if($user_detail['phone'] != ""){
        $message .= "<tr>
            <td width='20%'>
                <p style='font-size:14px;line-height:10px;padding-top:5px;'><b>User Phone</b></p>
            </td>
            <td>
                <p style='font-size:14px;line-height:10px;padding-top:5px;'>: +".($user_detail['cnt_code'] == "" ? "972" : $user_detail['cnt_code'])." ".$user_detail['phone']."</p>
            </td>
        </tr>";
    }
    $message .= "<tr>
            <td width='20%'>
                <p style='font-size:14px;line-height:10px;padding-top:5px;'><b>Business Type</b></p>
            </td>
            <td>
                <p style='font-size:14px;line-height:10px;padding-top:5px;'>: ".$business_type."</p>
            </td>
        </tr>
    ";

    // echo "message : " . $message;
    
    $mail_data = [];
    foreach ($admin_emails as $key => $to) {
        # code...
        $mail = send_email($to, $message, $subject);
        if($mail){
            $mail_data[] = "mail send";
        }
        else{
            $mail_data[] = "mail not send";
        }
    }
    return $mail_data;
}
///////////////////// PROJECT FUNCTION ENDS HERE ///////////////////////////////////

















function upload_image($file, $path)
{
    $has_error = "";

    if (isset($file["tmp_name"])) {
        $typ = $file['type'];
        $image_info = getimagesize($file["tmp_name"]);
        $image_width = $image_info[0];
        $image_height = $image_info[1];
        $path_parts = pathinfo($file["name"]);
        $extension = $path_parts['extension'];
        if ($typ == "image/jpeg" || $typ == "image/jpg" ||  $typ == "image/png" ||  $typ == "image/gif" || $typ == "application/octet-stream") {
            $uploaddir = $path;
            $name = date('Y-m-d-H-i-s') . "-" . rand() . "." . $extension;
            $uploadimages = $uploaddir . basename($name);
            if (move_uploaded_file(strip_tags($file['tmp_name']), $uploadimages)) {
                $profile_image = $name;
                $msg = "Success uploaded";
            } else {
                $profile_image = 'default.jpg';
                $msg = "Not uploaded";
                $has_error = "1";
            }
        } else {
            $profile_image = 'default.jpg';
            $msg = "Invalid image type.";
            $has_error = "1";
        }
    } else {
        $profile_image = 'default.jpg';
        $msg = "Not set as file";
        $has_error = "1";
    }
    $arr = array();
    $arr['error'] = $msg;
    $arr['name'] = $profile_image;
    $arr['has_error'] = $has_error;
    return $arr;
} // upload images




function getDatesFromRange($start, $end, $format = 'Y-m-d')
{

    // Declare an empty array
    $array = array();

    // Variable that store the date interval
    // of period 1 day
    $interval = new DateInterval('P1D');

    $realEnd = new DateTime($end);
    $realEnd->add($interval);

    $period = new DatePeriod(new DateTime($start), $interval, $realEnd);

    // Use loop to store date into array
    foreach ($period as $date) {
        $week_day = isWeekend($date->format('Y-m-d'));
        if ($week_day) {
            $array[] = $date->format('Y-m-d');
        }
        // $array[] = $date->format($format); 
    }

    // Return the array elements
    return $array;
}





function log_error($sql)
{
    global $db;
    global $msg;
    global $status;
    $status = 0;
    $msg = " There is an error " . $db->error . ". And SQL is " . $sql;
}

function mt_rand_str($l, $c = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890')
{
    for ($s = '', $cl = strlen($c) - 1, $i = 0; $i < $l; $s .= $c[mt_rand(0, $cl)], ++$i);
    return $s;
}

function check_isset($fields)
{
    global $db;
    foreach ($fields as $value) {
        if (!isset($_REQUEST[$value]))
            return false;
    }
    return true;
}

function get_request_protect_data($fields)
{
    global $db;
    $postdata = array();
    foreach ($fields as $value) {
        $postdata[$value] = real_escape($_REQUEST["$value"]);
    }
    return $postdata;
} // get_request_protect_data

function get_all_data_protected($post)
{
    global $db;
    $postdata = array();
    foreach ($post as $key => $value) {
        $postdata[$key] = real_escape($post[$key]);
    }
    return $postdata;
}



function send_email($to, $msg, $subject, $baseurl = '', $lan = 1, $attachment = array())
{
    // include __DIR__ . "/smtp/email.config.php";

    $mail = new PHPMailer(true);
    //$mail->SMTPDebug = 2;
    /* $mail->isSMTP();
    $mail->CharSet = 'UTF-8';
    //$mail->Host = "mail.itapp2u.com";
    $mail->Host = $userprofile['host'];
    $mail->SMTPAuth = true;
    //$mail->Username = "developer@itapp2u.com";
    $mail->Username = $userprofile['user'];
    //$mail->Password =  "Admin@2020";
    $mail->Password =  $userprofile['password'];
    $mail->SMTPSecure = "ssl";
    //$mail->Port = "465";
    $mail->Port = $userprofile['port'];
    //$mail->From = "developer@itapp2u.com";
    $mail->From = $userprofile['sendfrom'];
    //$mail->FromName = "Homeco";
    $mail->FromName = $userprofile['sendname'];
    $mail->isHTML(true);
    $mail->Subject = $subject; */

    $mail->isSMTP();
    // $mail->SMTPDebug = 2;
    $mail->CharSet = 'UTF-8';
    $mail->Host = $_ENV['SMTP_HOST'];
    $mail->SMTPAuth = true;
    $mail->Username = $_ENV['SMTP_USER'];
    $mail->Password = $_ENV['SMTP_PASS'];
    // $mail->SMTPSecure = "ssl";
    $mail->SMTPSecure = PHPMailer::ENCRYPTION_STARTTLS;
    $mail->Port = $_ENV['SMTP_PORT'];
    $mail->From = $_ENV['EMAIL_FROM'];
    $mail->FromName = $_ENV['EMAIL_FROM_NAME'];
    $mail->isHTML(true);
    // $mail->Subject = $subject;
    
    //language=1=>Eng,2=>Heb
    //if($lan==1)			
    $msg = get_email_template_eng($msg);
    //else
    //		$msg=get_email_template($msg);
    // $mail->Body = $msg;

    /* if ($attachment != "") {
        //$arr_attachment=explode(",",$attachment);
        foreach ($attachment as $key => $value) {
            $mail->AddAttachment("errors/" . $value);
        }
    } */
    /* $mail->AddAddress($to);
    //$mail->AddAddress("mayur@smart-webtech.com");
    // $mail->AddBCC("rac.swt@yopmail.com");
    //$mail->AddBCC("nilesh@smart-webtech.com");
    if ($mail->send()) {
        return true;
        // $status = "1";
        // $msg = "Sent email.";
    } else {
        return false;
        // $status = "0";
        // $msg = "Error occur in send email.";
    } */

    try{
        $from = $_ENV['EMAIL_FROM'];
        $from_name = $_ENV['EMAIL_FROM_NAME'];
        $mail->setFrom($from, $from_name);
        $mail->addAddress($to);
        $mail->Body = $msg;
        $mail->Subject = $subject;
        /* $mail->Body = $msg;
        echo "<pre>";
        print_r($mail);
        exit; */
        // send mail
        if($mail->send()){
            return "Mail sent successfully!";
        }
        else{
            return "Mail could not be sent. Mailer Error: {$mail->ErrorInfo}";
        }

    } catch (Exception $e) {
        return "Mail could not be sent. Mailer Error: {$mail->ErrorInfo}";
    }
    // return  array("msg" => $msg, "status" => $status);
} // send_email

function get_email_template_eng($data)
{
    // $files_path = $_ENV['SITE_URL'] . "assets/img/logo.png";
    $files_path = "";
    
    $message = "<style type='text/css' media='screen'>
        a {
            color: #007bff;
            text-decoration: none;
        }

        @media only screen and (max-device-width: 480px),
        only screen and (max-width: 480px) {
            .mobile-shell {
                width: 100% !important;
                min-width: 100% !important;
            }
        }
    </style>
    <table width='100%' border='0' cellspacing='0' cellpadding='0' >
        <tr>
            <td align='center' valign='top'>
                <table width='650' border='0' cellspacing='0' cellpadding='0' class='mobile-shell' bgcolor='#fff' style='border-top: 9px solid #e51e2a;border-bottom: 9px solid #e51e2a;padding:20px 30px;'>
                    <tr>
                        <td class='td container' style='width:850px; min-width:850px; font-size:0pt; line-height:0pt; margin:0; font-weight:normal; padding:10px 0px;'>
                            <table width='100%' border='0' cellspacing='0' cellpadding='0'>
                                <tr>
                                    <td>
                                        <table width='100%' border='0' cellspacing='0' cellpadding='0'>
                                            <tr>
                                                <td valign='top' style='color:#333; font-family:poppins; '>
                                                    <img src='{{logo_url}}' alt='' srcset=''>
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                            </table>
                            <table  width='100%' style=' text-align: left; border-top: 1px solid #eee;margin: 5px 0px; padding: 5px 0px;'>
                                <tr style='vertical-align: baseline;'>
                                    $data
                                </tr>
                            </table>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>";
    return $message;
} // get email template for english

function notification($title, $device_token, $push_data)
{

    $url = 'https://fcm.googleapis.com/fcm/send';

    $path_to_firebase_cm = 'https://fcm.googleapis.com/fcm/send';
    $fields = array(
        'registration_ids' => $device_token,
        'notification' => array('title' => $title, 'badge' => $push_data['badge_count'], 'body' => $push_data['description']),
        'data' => $push_data
    );

    // print_r($fields);
    // exit;


    $headers = array(
        'Authorization:key=' . GOOGLE_AUTH_KEY,
        'Content-Type:application/json'
    );

    $ch = curl_init();

    curl_setopt($ch, CURLOPT_URL, $path_to_firebase_cm);
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
    curl_setopt($ch, CURLOPT_IPRESOLVE, CURL_IPRESOLVE_V4);
    curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($fields));

    $result = curl_exec($ch);
    curl_close($ch); // die;

    //return external_push($fields);
    return $result;
} //send push notification

// function notification_new($title, $device_token, $data1, $device_type = "a")
function notification_new($title, $device_token, $data1, $device_type)
{
    global $base_url;
    if(!empty($data1))
    {
        foreach($data1 as $key => $value)
        {
            $data1[$key] = (string)$value;
        }
    } 
    // echo file_get_contents($base_url . "fcm.json");
    // die();

    $nm=json_decode(file_get_contents($base_url . "fcm.json"), true);

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
                            "category"=>"NEW_MESSAGE_CATEGORY",
                            "content-available" => 1
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

function chk_get($post,$vl){
    if(isset($post[$vl])){
        if($post[$vl]!=""){
            return $post[$vl];
        }
    }
    return '';

}

///// Common database functions 
function real_escape($str)
{
    global $db_old;
    global $db_env;
   
   
    if ($db_env != "ci"){
        return $db_old->real_escape_string($str);
    }else{
        return $str;
    }
    
}
function fetch_assoc($result_set)
{
    global $db;
    global $db_env;
    global $data;
    if ($db_env == "ci") {
        $row = $result_set->row();
        if (isset($row))
            return (array)$row;
        else
            return false;
    } else {
        return $result_set->fetch_assoc();
    }
}


function num_rows($result_set)
{
    global $db;
    global $db_env;
    if ($db_env == "ci") {
        if (is_array($result_set)) {
            return count($result_set);
        } else {
            return $result_set->num_rows();
        }
    } else
        return $result_set->num_rows;
}


function fetch_object($result_set)
{
    global $db;
    global $db_env;
    if ($db_env == "ci")
        return $result_set->result();
    else
        return $result_set->fetch_object();
}

function get_last_id()
{
    global $db_env;
    if ($db_env == "ci")
        return get_last_id_ci_db();
    else
        return get_last_id_normal_db();
}

function insert($table, $ins_data)
{
    global $db_env;
    if ($db_env == "ci")
        return insert_ci_db($table, $ins_data);
    else
        return insert_normal_db($table, $ins_data);
}


function update($tbl, $updatedata, $where = "")
{
    global $db_env;
    if ($db_env == "ci")
        return update_ci_db($tbl, $updatedata, $where);
    else
        return update_normal_db($tbl, $updatedata, $where);
}

function query($sql)
{
    global $db;
    global $db_env;
    if ($db_env == "ci")
        return $db->query($sql) or register_db_error(array("sql" => $db->last_query(), "error" => $db->error()));
    else
        return $db->query($sql) or register_db_error(array("sql" => $sql, "error" => $db->error));
}

function get($tbl, $fields = "*", $where = "", $start = "", $limit = "")
{

    global $db_env;
    if ($db_env == "ci")
        return get_ci($tbl, $fields, $where, $start, $limit);
    else
        return get_normal($tbl, $fields, $where, $start, $limit);
}

function get_last_id_ci_db()
{
    global $db;
    return $db->insert_id();
}

function insert_ci_db($table, $ins_data)
{
    global $db;
    $result = $db->insert($table, $ins_data);
    if (!$result) {
        register_db_error(array("sql" => $db->last_query(), "error" => $db->error()));
    }
    if ($result) {
        return true;
    } else {
        return false;
    }
} // insert data into db


function update_ci_db($tbl, $updatedata, $where = "")
{
    global $db;
    $result = $db->update($tbl, $updatedata, $where);
    
    if (!$result) {
        register_db_error(array("sql" => $db->last_query(), "error" => $db->error()));
    }
    return $result;
} /// update table


function get_ci($tbl, $fields = "*", $where = "", $start = "", $limit = "")
{
    global $db;
    global $data;

    $db->select($fields);
    $db->from($tbl);
    if ($where != "")
        $db->where($where);
    if ($limit != "" && $start != "")
        $db->limit($limit, $start);
    if ($limit != "" && $start == "")
        $db->limit($limit, 0);


    $result = $db->get();
    // $data['sql']=$db->last_query();
    if (!$result) {
        register_db_error(array("sql" => $db->last_query(), "error" => $db->error()));
    }

    if ($result) {
        return $result;
    } else {
        return [];
    }
} /// get date from the table



function get_last_id_normal_db()
{
    global $db;
    return $db->insert_id;
}

function insert_normal_db($table, $data)
{
    global $db;
    $field_list = array();
    $value_list = array();
    foreach ($data as $field => $value) {
        array_push($field_list, $field);
        array_push($value_list, "'" . $value . "'");
    }

    $sql = "INSERT INTO $table (" . implode(",", $field_list) . ") ";
    $sql .= " VALUES (" . implode(",", $value_list) . ")";

    $result = $db->query($sql) or register_db_error(array("sql" => $sql, "error" => $db->error));

    if ($result) {
        return true;
    } else {
        return false;
    }
} // insert data into db


function update_normal_db($tbl, $updatedata, $where = "")
{
    global $db;

    $value_list = array();
    $where_list = array();
    $where_string = "";

    foreach ($updatedata as $field => $value) {
        array_push($value_list, $field . "='" . $value . "'");
    }

    if (is_array($where)) {
        foreach ($where as $field => $value) {
            array_push($where_list, $field . "='" . $value . "'");
        }

        if (count($where_list) > 0) {
            $where_string = implode(" AND ", $where_list);
            $where_string = " WHERE " . $where_string;
        }
    } else {
        if ($where != "") {
            $where_string = " WHERE " . $where;
        }
    }


    $sql_update = "UPDATE $tbl SET " . implode(",", $value_list) . " " . $where_string;
    //$data['sql']=$sql_update;
    $result = $db->query($sql_update) or register_db_error(array("sql" => $sql_update, "error" => $db->error));
    return $result;
} /// update table

function get_normal($tbl, $fields = "*", $where = "", $start = "", $limit = "")
{

    global $db;
    global $data;
    $value_list = array();
    $where_list = array();
    $where_string = "";


    if (is_array($where)) {
        foreach ($where as $field => $value) {
            array_push($where_list, $field . "='" . $value . "'");
        }

        if (count($where_list) > 0) {
            $where_string = implode(" AND ", $where_list);
            $where_string = " WHERE " . $where_string;
        }
    } else {
        if ($where != "") {
            $where_string = " WHERE " . $where;
        }
    }

    if ($start != "" && $limit != "")
        $where_string .= " LIMIT " . $start . "," . $limit;

    if ($start == "" && $limit != "")
        $where_string .= " LIMIT " . $limit;

    $sql_select = "SELECT $fields FROM  $tbl " . $where_string;
    //echo "<Br>".$sql_select;
    //$data['sql']=$sql_select;
    $result = $db->query($sql_select) or register_db_error(array("sql" => $sql_select, "error" => $db->error));
    return $result;
} /// get date from the table


function register_db_error($arr = array())
{
    global $db;
    $log_type = "Error";

    if (isset($arr['type']))
        $log_type = $arr['type'];

    $LogFile = __DIR__ . "/errors/log/" . date("Y-m-d") . ".json";
    if (file_exists($LogFile)) {
        $filedata = file_get_contents($LogFile);
        $obj = json_decode($filedata);
        array_push($obj, array("date" => date("Y-m-d H:i:s"), "type" => $log_type, "data" => $arr));
        $filedata = json_encode($obj);
        file_put_contents($LogFile, $filedata);
    } else {
        $obj = array();
        array_push($obj, array("date" => date("Y-m-d H:i:s"), "type" => $log_type, "data" => $arr));
        $filedata = json_encode($obj);
        file_put_contents($LogFile, $filedata);
    }
} // register dn error


function register_app_log($title = "", $arr = array())
{
    global $db,$data;
    $log_type = "Error";

    if (isset($arr['type']))
        $log_type = $arr['type'];

    $app_data = [];
    $app_data['req_param'] = $_REQUEST;
    $app_data['files'] = $_FILES;
    $app_data['ext'] = $arr;
    $app_data['res'] = $data;

    $LogFile = __DIR__ . "/errors/app_log/" . date("Y-m-d") . ".json";
    if (file_exists($LogFile)) {
        $filedata = file_get_contents($LogFile);
        
        $obj = json_decode($filedata,true);
        if(!is_array($obj))
        {
            $obj=[];
        }
        array_push($obj, array("date" => date("Y-m-d H:i:s"), "type" => $log_type, "data" => $app_data, 'title' => $title));
        $filedata = json_encode($obj);
        file_put_contents($LogFile, $filedata);
    } else {
        $obj = array();
        array_push($obj, array("date" => date("Y-m-d H:i:s"), "type" => $log_type, "data" => $app_data, "title" => $title));
        $filedata = json_encode($obj);
        file_put_contents($LogFile, $filedata);
    }
} // register app log


function get_client_ip()
{
    $ipaddress = '';
    if (isset($_SERVER['HTTP_CLIENT_IP']))
        $ipaddress = $_SERVER['HTTP_CLIENT_IP'];
    else if (isset($_SERVER['HTTP_X_FORWARDED_FOR']))
        $ipaddress = $_SERVER['HTTP_X_FORWARDED_FOR'];
    else if (isset($_SERVER['HTTP_X_FORWARDED']))
        $ipaddress = $_SERVER['HTTP_X_FORWARDED'];
    else if (isset($_SERVER['HTTP_FORWARDED_FOR']))
        $ipaddress = $_SERVER['HTTP_FORWARDED_FOR'];
    else if (isset($_SERVER['HTTP_FORWARDED']))
        $ipaddress = $_SERVER['HTTP_FORWARDED'];
    else if (isset($_SERVER['REMOTE_ADDR']))
        $ipaddress = $_SERVER['REMOTE_ADDR'];
    else
        $ipaddress = 'UNKNOWN';
    return $ipaddress;
} // get_client_ip


function random_posts($param=[]){
    global $db;
    $post_sql="SELECT id from tbl_post where status='1' ";
    $extra_where = "";
    $post_where = "";
    $post_ids = [];

    /* if(isset($param['not_in'])){
        if($param['not_in']!=""){
           
            $extra_where .= " AND p.id not in (".$param['not_in'].")";
        }
    }

    if(isset($param['my'])){
        if($param['my']!=""){
           
            $post_where .= " AND uid=".$param['uid'];
        }
    } */
    $post_sql = $post_sql . $post_where ;
    $result=$db->query($post_sql);
    if (!$result) {
        register_db_error(array("sql" => $db->last_query(), "error" => $db->error()));
        $post_ids = [];
    } else {
        $rows=$result->result_array();
        foreach($rows as $r){
            $post_ids[] = $r['id'];
        }
    }

    
    // $sql="SELECT id from tbl_post where status='1' ";
    $sql="SELECT
        DISTINCT p.id,p.uid,p.image_name,p.image_id,
        s.cust_id,
        c.id as cust_id
    FROM
        tbl_post p,tbl_subscription s,tbl_customer c
    WHERE
    p.status='1' AND p.uid=s.cust_id AND c.id=p.uid AND c.is_delete='0' AND s.status='1' AND s.is_sub_active='1' ";

    $where="";
    $limit="";

    /* $post_count = get_post_count($param['uid']);
    $profile = get_user_profile($param['uid']);
    $post_limit = $profile['post_limit']; */

    if(isset($param['styles'])){
        $arr_styles=explode(",",$param['styles']);
        if(count($arr_styles)>0)
        {
            $where_str=[];
            $where.="AND (";
            foreach($arr_styles as $single_style){
                if(trim($single_style) != '')
                {
                    $where_str[]=" find_in_set('$single_style', p.styles)>0 ";
                }
            }
            $where.=implode("OR",$where_str);
            $where.=")";
        }
    }

    /* if(isset($param['following'])){
        if($param['following']!="0"){
            $friends_ids=get_my_following_ids_list($param['uid']);
            $where.=" AND uid IN(".implode(",",$friends_ids).")";
        }
    }

    if(isset($param['my'])){
        if($param['my']!=""){
           
            $where.=" AND uid=".$param['uid'];
            if(count($post_ids) > 0){
                if($post_count >= $post_limit){
                    $extra_where .= " AND p.id IN(".implode(',',array_slice($post_ids, 0, $post_limit, true)).") ";
                }
            }
        }
    }

    if(isset($param['search_txt'])){
        if($param['search_txt']!=""){
           
            $where.=" AND ( description LIKE '%".$param['search_txt']."%')";
        }
    } */

    if(isset($param['start']) && isset($param['limit'])){
        if($param['start']!=""){
           
            $limit.=" LIMIT ".$param['start'].",".$param['limit'];
        }
    }

    $rand = ' ORDER BY RAND()';
    
    $sql=$sql.$where.$extra_where.$rand.$limit;
    $result=$db->query($sql);
    // echo "\nQuery : " . $db->last_query();
    // exit;
    return $result;

}

function get_business_studio_list($bid,$uid){
    global $db;
    $user_list=[];
    $sql="select bid from tbl_artist_business_map where uid='$uid' AND req_status='1'";
    $result=$db->query($sql);
    if($result)
    {
        if($result->num_rows()>0)
        {
            foreach($result->result() as $row){
                $user_check=get_user_profile($row->bid);
                if(count($user_check) > 0){
                    $user_list[]=$user_check; 
                }
            }
        }
    }
    return $user_list;
}

function send_sms( $phone_number, $otp_msg ){
	$res = (object)['status'=>false,'http_status'=>'','message'=>'','error'=>'','data'=>''];
	$curl = curl_init();

	curl_setopt_array($curl, array(
	  CURLOPT_URL => 'https://capi.upsend.co.il/api/v2/SMS/SendSms',
	  CURLOPT_RETURNTRANSFER => true,
	  CURLOPT_ENCODING => '',
	  CURLOPT_MAXREDIRS => 10,
	  CURLOPT_TIMEOUT => 0,
	  CURLOPT_FOLLOWLOCATION => true,
	  CURLOPT_HTTP_VERSION => CURL_HTTP_VERSION_1_1,
	  CURLOPT_CUSTOMREQUEST => 'POST',
	));

	curl_setopt ($curl, CURLOPT_SSL_VERIFYHOST, 0);
	curl_setopt($curl, CURLOPT_SSL_VERIFYPEER, false);
    curl_setopt($curl, CURLOPT_USERPWD, "UPSEND110108:1cb88b77-06db-40dd-bea0-98dfe4aeac10");
	// curl_setopt($curl, CURLOPT_HTTPHEADER,array(
	// 	'Content-Type: application/json',
	// 	'Authorization: Basic VVBTRU5EMTEwMTA4OjFjYjg4Yjc3LTA2ZGItNDBkZC1iZWEwLTk4ZGZlNGFlYWMxMA=='
	// ));

	//"Your login OTP is 255. Do not share it with anyone. It is valid for 10 minutes."

	//$otp_msg = "Your login OTP is ".$otp_code.". It is valid for 10 minutes.";
	//"Your login OTP is {0}. It is valid for 10 minutes."

	$post_data=[
		"Data" => [
			"Message" => $otp_msg,
			"Recipients"=>[[ "Phone" => $phone_number ]],
			"Settings" => [
				"Sender" => "Ink App"
			]
		]
	];
	curl_setopt($curl, CURLOPT_POSTFIELDS, json_encode($post_data));

	$response = curl_exec($curl);
	$http_status = curl_getinfo($curl, CURLINFO_HTTP_CODE);
	$error_msg="";
	if( curl_errno($curl) ){
		$error_msg = curl_error($curl);
	}
	curl_close($curl);

	$res->error = $error_msg;
	$res->http_status = $http_status;


	//log api response
	
	$logs_lines = [];
	$logs_lines[] = "status_code: ".$http_status." Phone: ".$phone_number." DateTime:".date("Y-m-d H:i:s");
	$logs_lines[] = "errors: ".$error_msg;
	$logs_lines[] = "response: ".$response;

    $params_log=[];
    $params_log['type']='Info';
    $params_log['logs']=$logs_lines;

	register_app_log("OTP_SEND_API", $params_log);



	if( trim($response) != "" ){
		$obj = json_decode($response);
		$res->data = $obj;

		$res->message = $obj->StatusDescription;

		if( $obj->StatusId == 1){
			$res->message = "msg sent successfully";
			$res->status = true;
		}else{
			//error in sent otp
			if( $obj->StatusDescription == "No valid recipients" ){
				$res->message = "Invalid phone number";
			}else{
				$res->message = "sms could not be sent";
			}
			$res->error = $obj->StatusDescription;
		}
	}

	if( $http_status != "" && $http_status == 401 ){
		//AuthorizationError
		//$res->message = "OTP sent successfully";
	}


	//print_r($res);
	return $res;
}

function register_app_log_new($title = "", $arr = array())
{
    global $db, $data;
    $log_type = "Error";

    if (isset($arr['type'])) {
        $log_type = $arr['type'];
    }

    // Prepare the log entry data
    $app_data = [];
    $app_data['req_param'] = $_REQUEST;
    $app_data['files'] = $_FILES;
    $app_data['ext'] = $arr;
    $app_data['res'] = $data;

    $log_entry = array(
        "date" => date("Y-m-d H:i:s"),
        "type" => $log_type,
        "data" => $app_data,
        "title" => $title
    );

    $current_date = date("Y-m-d");

    // Select query to check if a record for the current date exists
    $sql = "SELECT log_data FROM tbl_app_log WHERE log_date = '" . real_escape($current_date) . "'";
    $result = $db->query($sql) or register_db_error(array("sql" => $sql, "error" => $db->error));
    /* echo "<pre>";
    print_r($result);
    exit; */

    if ($result && $result->num_rows() > 0) {
        // If record exists, decode the existing JSON and append new entry
        $row = fetch_assoc($result);
        $existing_data = json_decode($row['log_data'], true);
        if (!is_array($existing_data)) {
            $existing_data = [];
        }
        array_push($existing_data, $log_entry);

        // Update the existing record in the database
        $updated_data = json_encode($existing_data);
        $db->update("tbl_app_log", ['log_data' => $updated_data, 'updated_at' => date("Y-m-d H:i:s")], ['log_date' => $current_date]);
    } else {
        // If no record exists, create a new one
        $new_data = json_encode([$log_entry]);
        $db->insert("tbl_app_log", [
            'log_date' => $current_date,
            'log_data' => $new_data,
            'created_at' => date("Y-m-d H:i:s"),
            'updated_at' => date("Y-m-d H:i:s")
        ]);
    }
}

function get_business_detail_new($bid,$uid,$limit = 0,$order_by = '',$show_less=''){
    global $db;
    $profile=get_user_profile($bid);
    $post_limit = $profile['post_limit'];
    if($limit != 0)
    {
        if($post_limit > $limit)
        {
            $post_limit = $limit;
        }
    }

    $profile['styles_he'] = [];
    if($profile['styles'] != '')
    {
        // $user_styles = $profile['styles'];
        $user_styles=explode(",",$profile['styles']);
        foreach($user_styles as $user_style)
        {
            $style_detail = get_style_detail(trim($user_style));
            $profile['styles_he'][] .= $style_detail['name'];
        }
    
    }

    $profile['posts']=get_business_posts($bid,$uid,$post_limit,$order_by,$show_less);
    
    return $profile;

}

function new_posts_count($param=[])
{
    global $db;

    $order_by = "";
    $extra_field = "";
    $extra_sql_start = "";
    $extra_sql_end = "";

    if(isset($param['is_recommended'])){
        $arr_styles=explode(",",$param['is_recommended']);
        if(count($arr_styles)>0)
        {
            $where_str=[];
            $extra_field.="CASE WHEN(";
            foreach($arr_styles as $single_style){
                $where_str[]=" find_in_set('$single_style', p.styles)>0 ";
            }
            $extra_field.=implode("OR",$where_str);
            $extra_field.=") THEN 1 ELSE 0 END AS recommanded,";

        }
        $order_by = " ORDER BY recommanded DESC, p.id DESC ";

        $extra_sql_start = "SELECT * FROM (";
        $extra_sql_end = ") AS subquery ORDER BY RAND();";
    }

    $countSQL = "SELECT
        COUNT(DISTINCT p.id) as total_posts
    FROM
        tbl_post p,tbl_subscription s,tbl_customer c
    WHERE
    p.status='1' AND p.uid=s.cust_id AND c.id=p.uid 
    AND
       (
        SELECT s.status
        FROM tbl_subscription s
        WHERE p.uid = s.cust_id ORDER BY s.id DESC LIMIT 1
    ) = '1' AND
    (
        SELECT s.is_sub_active
        FROM tbl_subscription s
        WHERE p.uid = s.cust_id ORDER BY s.id DESC LIMIT 1
    ) = '1'";

    $post_sql=$extra_sql_start .$countSQL. $extra_sql_end;
    $count_result = $db->query($post_sql)->result_array();
    $count_result = $count_result[0]['total_posts'] ?? 0;
    return $count_result;

}

function get_noti_user_profile($id)
{
    global $db;
    $row = [];
    $result = get("tbl_customer", "id, name, profile_image", ['id' => $id, 'is_delete' => '0'], "", 1);
    if ($result) {
        if (num_rows($result) > 0) {
            $row = fetch_assoc($result);
        }
    }
    return $row;
}

function sending_email_contact($uid,$subject,$contact_txt)
{
    global $db;

    $user_detail = get_user_profile($uid);
    // echo "<pre>";
    // print_r($user_detail);
    // exit;

    $business_type = "Regular User";
    if($user_detail['is_business'] == '1'){
        if($user_detail['business_type'] == '1'){
            $business_type = "Studio";
        }
        else if($user_detail['business_type'] == '2'){
            $business_type = "Artist";
        }
    }
    
    $message = "
    <tr>
        <td colspan='2'>
            <p style='font-size:18px;line-height:15px;'><b>User Detail</b></p>
        </td>
    </tr>
    <tr>
        <td width='20%' style='padding-top:1px;'>
            <p style='font-size:14px;line-height:10px;padding-top:5px;'><b>User Name</b></p>
        </td>
        <td>
            <p style='font-size:14px;line-height:10px;padding-top:5px;'>: ".$user_detail['name']."</p>
        </td>
    </tr>";
    if($user_detail['email'] != ""){
        $message .= "<tr>
            <td width='20%'>
                <p style='font-size:14px;line-height:10px;padding-top:5px;'><b>User Email</b></p>
            </td>
            <td>
                <p style='font-size:14px;line-height:10px;padding-top:5px;'>: ".$user_detail['email']."</p>
            </td>
        </tr>";
    }
    
    if($user_detail['phone'] != ""){
        $message .= "<tr>
            <td width='20%'>
                <p style='font-size:14px;line-height:10px;padding-top:5px;'><b>User Phone</b></p>
            </td>
            <td>
                <p style='font-size:14px;line-height:10px;padding-top:5px;'>: +".($user_detail['cnt_code'] == "" ? "972" : $user_detail['cnt_code'])." ".$user_detail['phone']."</p>
            </td>
        </tr>";
    }
    $message .= "<tr>
            <td width='20%'>
                <p style='font-size:14px;line-height:10px;padding-top:5px;'><b>Business Type</b></p>
            </td>
            <td>
                <p style='font-size:14px;line-height:10px;padding-top:5px;'>: ".$business_type."</p>
            </td>
        </tr>
        <tr>
            <td width='20%'>
                <p style='font-size:14px;line-height:10px;padding-top:5px;'><b>Comment</b></p>
            </td>
            <td>
                <p style='font-size:14px;line-height:10px;padding-top:5px;'>: ".$contact_txt."</p>
            </td>
        </tr>
    ";

    // $to = "rac.swt@yopmail.com";
    $emails = ["Inkraelco@gmail.com","Itapp2u@gmail.com"];
    // $emails = ["rac.swt@yopmail.com","developer.swt@yopmail.com"];
    $mail_data = [];
    foreach ($emails as $key => $to) {
        # code...
        $mail = send_email($to, $message, $subject);
        $mail_data[] = $mail;
    }
    return $mail_data;
}

if (!function_exists('log_db_check')) {
    function log_db_check($param_data=[])
    {
        try{
            $dbPath="../assets/uploads/local_db/".date("m-Y").".db";
            $defaultDb="../assets/uploads/local_db/default.db";
            

            // Check if data.db exists
            if (!file_exists($dbPath)) {
                if (file_exists($defaultDb)) {
                    // Copy default structure
                    if (!copy($defaultDb, $dbPath)) {
                        //die('❌ Failed to create data.db from default.db');
                    }
                } else {
                    //die('❌ Default database (default.db) not found!');
                }
            }
                
        } catch (Exception $e) {
            //$result->error = $e->getMessage();
            //$result->msg = "Error";
        }
    }
}


if (!function_exists('log_activity')) {
    function log_activity($param_data=[])
    {
        try{

            $req_data=[];
            $params=[];
            $title="";
            if(isset($param_data['req']))
                $req_data=$param_data['req'];
            
            if(isset($param_data['title']))
                $title=$param_data['title'];

            if(isset($param_data['data']))
                $params=$param_data['data'];
            

            log_db_check();
            $db_log = new Db_core( '../assets/uploads/local_db/'.date('m-Y').'.db' );
            
            $db_log->insert( "tbl_action_log", [
                'action'=>$db_log->escape($title),
                "req"=>$db_log->escape(json_encode($req_data)),
                "res"=>$db_log->escape(json_encode($params)),
                'date_added'=>date("Y-m-d H:i:s")
            ] );
                
        } catch (Exception $e) {
            //$result->error = $e->getMessage();
            //$result->msg = "Error";
        }
    }
}


if (!function_exists('business_convert_effect')) {
    function business_convert_effect($param_data=[])
    {
        global $db;
            $sql_remove_1="DELETE FROM tbl_artist_business_map where uid='".$param_data['uid']."' OR bid='".$param_data['uid']."' ";
            $sql_remove_2="DELETE FROM tbl_notifications where  (uid='".$param_data['uid']."' OR me='".$param_data['uid']."') AND ( noti_type='studio_request_sent' OR noti_type='studio_request_rcvd' OR noti_type='artist_request_rcvd' OR noti_type='artist_request_sent' )";



            /// TAKING BACKUP OF THE ROWS BEFORE REMOVING.
            try{

                $arr_backup_rows=[];

                $result_backup_query=$db->query("SELECT * FROM tbl_artist_business_map where uid='".$param_data['uid']."' OR bid='".$param_data['uid']."' ");
                $rows_map=[];
                if($result_backup_query)
                {
                    if($result_backup_query->num_rows()>0){
                        foreach($result_backup_query->result() as $row_backup)
                            $rows_map[]=$row_backup;
                    }
                }
                $arr_backup_rows['tbl_artist_business_map']=$rows_map;


                $result_backup_query=$db->query("SELECT * FROM tbl_notifications where  (uid='".$param_data['uid']."' OR me='".$param_data['uid']."') AND ( noti_type='studio_request_sent' OR noti_type='studio_request_rcvd' OR noti_type='artist_request_rcvd' OR noti_type='artist_request_sent' )");
                $rows_noti=[];
                if($result_backup_query)
                {
                    if($result_backup_query->num_rows()>0){
                        foreach($result_backup_query->result() as $row_backup)
                            $rows_noti[]=$row_backup;
                    }
                }
                $arr_backup_rows['tbl_notifications']=$rows_noti;


                $result = get("tbl_request", "*", "find_in_set('".$param_data['uid']."',artists_uid)>0");
                $rows_req=[];
                if ($result) {
                    if( $result->num_rows() > 0 ){
                        foreach ($result->result_array() as $row_backup) {
                            if($row_backup['artists_uid']!="")
                            {
                                $rows_req[]=$row_backup;
                                $arr_artists=explode(",",$row_backup['artists_uid']);
                                if (($key = array_search($param_data['uid'], $arr_artists)) !== false) {
                                    unset($arr_artists[$key]);
                                }
                                $artists_string=implode(",",$arr_artists);
                                $db->update("tbl_request", ['artists_uid'=>$artists_string], ['id'=>$row_backup['id']]);
                            }
                        }
                    }
                }
                $arr_backup_rows['tbl_request']=$rows_req;



                $result = get("tbl_post", "*", "find_in_set('".$param_data['uid']."',artist_uid)>0");
                $rows_req=[];
                if ($result) {
                    if( $result->num_rows() > 0 ){
                        foreach ($result->result_array() as $row_backup) {
                            if($row_backup['artist_uid']!="")
                            {
                                $rows_req[]=$row_backup;
                                $arr_artists=explode(",",$row_backup['artist_uid']);
                                if (($key = array_search($param_data['uid'], $arr_artists)) !== false) {
                                    unset($arr_artists[$key]);
                                }
                                $artists_string=implode(",",$arr_artists);
                                $db->update("tbl_post", ['artist_uid'=>$artists_string], ['id'=>$row_backup['id']]);
                            }
                        }
                    }
                }
                $arr_backup_rows['tbl_post']=$rows_req;


                $action_title="Convert request for ".$param_data['uid'].", Business Type = ".$param_data['business_type'];
                if(isset($param_data['title']))
                {
                    $action_title=$param_data['title'];
                }


                $user_detail=[];
                if(isset($param_data['user_detail']))
                {
                    $user_detail=$param_data['user_detail'];
                    $arr_backup_rows['user_detail']=$user_detail;
                }

                $db->query($sql_remove_1);
                $db->query($sql_remove_2);
                log_activity([
                    'req'=>$_REQUEST,
                    'title'=>$action_title,
                    'data'=>$arr_backup_rows
                ]);
                    
            } catch (Exception $e) {
            }
    }//business conver effect
}

function get_home_posts($param=[])
{
    global $db;
    $post_where = "";
    
    $post_sql="SELECT id from tbl_post where status='1' ".$post_where." ORDER BY id DESC";
    $extra_where = "";
    
    $post_ids = [];
 
    $post_sql = $post_sql ;
    $result=$db->query($post_sql);
    if (!$result) {
        register_db_error(array("sql" => $db->last_query(), "error" => $db->error()));
        $post_ids = [];
    } else {
        $rows=$result->result_array();
        foreach($rows as $r){
            $post_ids[] = $r['id'];
        }
    }

    $order_by = "";
    $extra_field = "";
    $extra_sql_start = "";
    $extra_sql_end = "";
    $where="";
    $limit="";

    $post_count = get_post_count($param['uid']);
    $profile = get_user_profile($param['uid']);
    $post_limit = $profile['post_limit'];

    if(isset($param['styles'])){
        $arr_styles=explode(",",$param['styles']);
        if(count($arr_styles)>0)
        {
            $where_str=[];
            $where.="AND (";
            foreach($arr_styles as $single_style){
                if(trim($single_style) != '')
                {
                    $where_str[]=" find_in_set('$single_style', p.styles)>0 ";
                }
            }
            $where.=implode("OR",$where_str);
            $where.=")";
        }
    }

    $not_in_post_ids = ""; 
    

    if(isset($param['start']) && isset($param['limit'])){
        if($param['start']!=""){
           
            $limit.=" LIMIT ".$param['start'].",".$param['limit'];
        }
    }

    $rand = '';
    $random_where = "";
    $random_group = "";
    if(isset($param['is_random']) && $param['is_random'] == '1')
    {
        $random_group = " GROUP BY p.uid";
        $rand = ' ORDER BY RAND()';
    }

    if($rand == "" && $order_by == ""){
        $order_by = " ORDER BY p.id DESC";
    }
    
    $sql="SELECT
        DISTINCT p.id,
        p.uid,
        p.view_count,
        p.date_added,
        p.img_type,
        p.image_name,
        p.image_id,
        $extra_field
        (
            SELECT id
            FROM tbl_subscription s
            WHERE p.uid = s.cust_id AND s.status = '1' AND s.is_sub_active = '1' ORDER BY s.id DESC LIMIT 1
        ) AS sub_id,
        (
            SELECT id
            FROM tbl_customer c
            WHERE p.uid = c.id AND c.status = '1' AND c.is_delete = '0'
        ) AS cust_id,
        (
            SELECT s.status
            FROM tbl_subscription s
            WHERE p.uid = s.cust_id ORDER BY s.id DESC LIMIT 1
        ) AS sub_status,
        (
            SELECT s.is_sub_active
            FROM tbl_subscription s
            WHERE p.uid = s.cust_id ORDER BY s.id DESC LIMIT 1
        ) AS is_sub_active,
        (
            SELECT s.product_id
            FROM tbl_subscription s
            WHERE p.uid = s.cust_id ORDER BY s.id DESC LIMIT 1
        ) AS product_id
    FROM
        tbl_post p
    WHERE
        p.status = '1' 
    ";
    $having = " HAVING
        sub_id IS NOT NULL AND cust_id IS NOT NULL AND sub_status = '1' AND is_sub_active = '1'";
    
    $count_result = [];
    $post_sql=$extra_sql_start .$sql.$where.$random_where.$not_in_post_ids.$extra_where.$random_group.$having.$rand.$order_by.$limit . $extra_sql_end;
    $result=$db->query($post_sql);
    $count_result = $db->query($post_sql)->result_array();

    $extra_results = [];
    if(isset($param['is_random']) && $param['is_random'] == '1' && $param['limit'] > 4)
    {
        if (count($count_result) < 6) {
            $remaining = 6 - count($count_result);
            $remaining_limit = " limit " . $remaining;
            $fetched_ids = array_column($count_result, 'id');
            $not_in_post_ids = '';

            if (!empty($fetched_ids)) {
                $not_in_post_ids = ' AND p.id NOT IN (' . implode(',', $fetched_ids) . ')';
            }

            $ramain_post_sql=$sql.$where.$random_where.$not_in_post_ids.$extra_where.$random_group.$having.$rand.$order_by.$remaining_limit;
            $extra_results = $db->query($ramain_post_sql)->result_array();
        }

    } 

    $unique_posts = $count_result;
    $fetched_ids = array_column($count_result, 'id');
    $limit_count = (isset($param['limit'])) ? $param['limit'] : "";
    if(isset($param['is_random']) && $param['is_random'] == '1' && ($limit_count == 4 || $limit_count == 6))
    {
        while (count($unique_posts) < $limit_count) {
            $remaining = $limit_count - count($unique_posts);
        
            // Prepare NOT IN clause to prevent duplicate post IDs
            $not_in_post_ids = '';
            if (!empty($fetched_ids)) {
                $not_in_post_ids = ' AND p.id NOT IN (' . implode(',', $fetched_ids) . ')';
            }
        
            // Query to fetch additional unique posts
            $remaining_limit = " LIMIT " . $remaining;
            $ramain_post_sql = $sql . $where . $random_where . $not_in_post_ids . $extra_where . $having . $rand . $order_by . $remaining_limit;
        
            // Fetch additional posts
            $extra_results = $db->query($ramain_post_sql)->result_array();
        
            // Break if no more results to avoid infinite loop
            if (empty($extra_results)) {
                break;
            }
        
            // Merge additional posts and update fetched IDs
            $unique_posts = array_merge($unique_posts, $extra_results);
            $fetched_ids = array_column($unique_posts, 'id');
        
            // Remove any duplicate post IDs (just in case)
            $unique_posts = array_map('unserialize', array_unique(array_map('serialize', $unique_posts)));
        
            // Stop once we have 6 unique posts
            if (count($unique_posts) == $limit_count) {
                break;
            }
        }
        $unique_posts = array_slice($unique_posts, 0, $limit_count);
    }

    $results = $unique_posts;

    return $results;

}