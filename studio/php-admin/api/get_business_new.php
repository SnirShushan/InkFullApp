<?php
$fields = ['uid','login_token','app_token','device_type','app_version'];
$check = check_isset($fields);
$job_list = [];
if ($check) {
    $post = get_all_data_protected($_REQUEST);
    $row = validate_token($post['login_token'], $post['uid']);
    if ($row == false) {
        $status = 2;
        $msg = $gbl_msg_invalid_token;
    }
    else{
        $status=1;
        $msg="success";
        $business=[];
        $first_business=[];
        $sub_business_list = [];
        $params=[];
        $styles = "";
        $search_text = "";
        $is_filter = "2";
        $is_closest = "";
        $popup_text = "";
        $user_address_empty = 2;
        if(isset($post['styles']))
        {
            if($post['styles']!=""){
                $params['styles']=$post['styles'];
                $styles = "1";
                $is_filter = "1";
            }
        }else if(isset($user_styles))
        {
            if($user_styles!=""){
                $params['styles']=$user_styles;
            }
        }

        $new = "";
        if(isset($post['new']))
        {
            if($post['new']!=""){
                $params['new']=$post['new'];
                $new = "1";
            }
        }

        if(isset($post['is_closest']))
        {
            if($post['is_closest'] == "1"){
                $is_closest = "1";
                if(isset($post['lat']) && $post['lat']!="")
                {
                    if(isset($post['lng']) && $post['lng']!=""){
                        if(isset($post['radius']) && $post['radius']!=""){
                            // if($post['lat']!="" && $post['lng']!="" && $post['radius']!=""){
                                $params['user_lat']=$post['lat'];
                                $params['user_lng']=$post['lng'];
                                $params['is_closest']=$post['is_closest'];
                                // $params['radius']=$post['radius'];
                                // $is_filter = "1";
                            // }
                        }
                    }
                    
                }
                else{
                    $user_data = get_user_profile($post['uid']);
                    $user_lat = $user_data['address_lat'];
                    $user_lng = $user_data['address_lng'];
                    if($user_lat!="" && $user_lng != ""){
                        $params['is_closest']=$post['is_closest'];
                        $params['user_lat']=$user_lat;
                        $params['user_lng']=$user_lng;
                    }
                    /* else{
                        $user_address_empty = 1;
                    } */
                }
            }
        }

        if(isset($post['is_filter_location']))
        {
            if($post['is_filter_location'] == "1"){
                $params['is_filter_location'] = $post['is_filter_location'];
            }
        }

        if(isset($post['lat']))
        {
            if(isset($post['lng'])){
                if(isset($post['radius'])){
                    if($post['lat']!="" && $post['lng']!="" && $post['radius']!=""){
                        $params['lat']=$post['lat'];
                        $params['lng']=$post['lng'];
                        $params['radius']=$post['radius'];
                        $is_filter = "1";
                        $is_closest = "1";
                    }
                }
            }
            
        }else if(isset($lat)){
            if(isset($lng)){
                if(isset($radius)){
                    $params['lat_ord']=$lat;
                    $params['lng_ord']=$lng;
                    // $params['radius']=$radius;
                }
            }
        }

        if(isset($post['is_recommended']))
        {
            if($post['is_recommended'] == "1"){
                $user_data = get_user_profile($post['uid']);
                $user_styles = $user_data['styles'];
                if($user_styles!=""){
                    $params['is_recommended']=$user_styles;
                }
            }
        }

        if(isset($post['start']))
        {
            if($post['start']!=""){
                $params['start']=$post['start'];
            }
        }

        if(isset($post['limit']))
        {
            if($post['limit']!=""){
                $params['limit']=$post['limit'];
            }
        }

        if(isset($post['search_txt']))
        {
            if($post['search_txt']!=""){
                $params['search_txt']=$post['search_txt'];
                $search_text=$post['search_txt'];
            }
        }

        if(isset($post['uid']))
        {
            if($post['uid']!=""){
                $params['uid']=$post['uid'];
            }
        }

        // if(isset($limit))
        //     $params['limit']=$limit;

        // if(isset($start))
        //     $params['start']=$start;
        
        $plist=get_business_search($params);
        $bi_post_limit = 0;
        if(isset($b_post_limit))
        {
            $bi_post_limit = $b_post_limit;
        }
        $order = 'order by date_added DESC';
        if(isset($order_by))
        {
            $order = $order_by;
        }
        if($plist){
            if(count($plist)>0){
                $premium_ids = [];
                foreach($plist as $bid){
                    $user=get_business_detail($bid,$post['uid'],$bi_post_limit,$order);
                    if(count($user)>0){
                        $business[]=$user;
                        foreach ($business as $key => $value) {
                            # code...
                            $get_user_sub_detail = get_subscribe_detail($value['id']);
                            if(count($get_user_sub_detail)>0){
                                if($get_user_sub_detail['status'] == "1" && $get_user_sub_detail['is_sub_active'] == "1"){
                                    if($get_user_sub_detail['is_premium'] == "1"){
                                        if(!in_array($value['id'],$premium_ids)){
                                            $premium_ids[]= $value["id"];
                                        }
                                    }                                
                                }
                            }
                        }
                    }
                }
            }
        }
        
        // $data['premium_ids']=$premium_ids;

        $popular="";
        if(isset($post['popular']))
        {
            if($post['popular']!=""){
                $popular=$post['popular'];
            }
        }

        $user_sub = get_subscription_list();
        // echo "<pre>";
        // print_r($user_sub);
        $random_id = "";
        if($user_sub){
            // $premium_ids = [];
            foreach ($user_sub as $key => $value) {
                # code...
                /* if($value['is_premium'] == "1"){
                    $premium_ids[]= $value["uid"];
                } */
                
                foreach ($business as $bus_key => $bus_value) {
                    # code...
                    if($value['uid'] == $bus_value['id']){
                        $posts_images = array();
                        if(!empty($bus_value['posts']['posts_images']))
                        {
                            $posts_images = $bus_value['posts']['posts_images'];
                        }
                        unset($bus_value['posts']['posts_images']);
                        
                        $bus_value['business_img'] = $posts_images;
                        $sub_business_list[] = $bus_value;
                    }
                }
            }
        }

        if(isset($is_home) && $is_home)
        {
            if(empty($sub_business_list))
            {
                if(isset($user_styles))
                {
                    if($user_styles!=""){
                        unset($params['styles']);
                        $plist=get_business_search($params);
                        foreach($plist as $bid){
                            $user=get_business_detail($bid,$post['uid'],$bi_post_limit,$order);
                            if(count($user)>0){
                                $business[]=$user;
                            }
                        }


                        if($user_sub){
                            $premium_ids = [];
                            foreach ($user_sub as $key => $value) {
                                # code...
                                if($value['is_premium'] == "1"){
                                    $premium_ids[]= $value["uid"];
                                }
                                
                                foreach ($business as $bus_key => $bus_value) {
                                    # code...
                                    if($value['uid'] == $bus_value['id']){
                                        $posts_images = array();
                                        if(!empty($bus_value['posts']['posts_images']))
                                        {
                                            $posts_images = $bus_value['posts']['posts_images'];
                                        }
                                        unset($bus_value['posts']['posts_images']);
                                        
                                        $bus_value['business_img'] = $posts_images;
                                        $sub_business_list[] = $bus_value;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        if($popular == "1" ||$new == "1" || $styles == "1" || (isset($post['is_recommended']) && $post['is_recommended'] == "1"))
        {

            if($popular=="1")
            {
                usort($business, 'sortByrank');
            }
            
            /* $user_sub = get_subscription_list();
            // echo "<pre>";
            // print_r($user_sub);
            $random_id = "";
            if($user_sub){
                $premium_ids = [];
                foreach ($user_sub as $key => $value) {
                    # code...
                    if($value['is_premium'] == "1"){
                        $premium_ids[]= $value["uid"];
                    }
                    
                    foreach ($business as $bus_key => $bus_value) {
                        # code...
                        if($value['uid'] == $bus_value['id']){
                            $sub_business_list[] = $bus_value;
                        }
                    }
                }
            } */

            // print_r($sub_business_list);
            // exit;

            $premium_ids_list = [];
            $pre_ran_id = [];
            foreach ($sub_business_list as $key => $value) {
                # code...
                foreach ($premium_ids as $pre_key => $pre_value) {
                    # code...
                    if(in_array($premium_ids[$pre_key],$value)){
                        $premium_ids_list[] = $value;
                    }
                }

            }
            
            // print_r($premium_ids_list);

            if($popular=="1")
            {
                usort($premium_ids_list, 'sortByrank');
                $high_follower_value = 0;
                foreach ($premium_ids_list as $key => $value)
                {
                    # code...
                    if($key == 0 ){
                        $high_follower_value = $value['followers'];
                    }
                    if($value['followers'] == $high_follower_value){
                        if(!in_array($value['id'],$pre_ran_id)){
                            $pre_ran_id[] = $value['id'];
                        }
                    }
                }
                if($pre_ran_id){
                    $pre_random_id = array_rand($pre_ran_id);
                }
            }
            
            if($premium_ids){
                $random_id = array_rand($premium_ids);
                $data['rand_id'] = $random_id;
            }

            if($popular=="1"){
                foreach ($sub_business_list as $key => $value) {
                    # code...
                    if(isset($pre_random_id)){
                        if($pre_ran_id[$pre_random_id] == $value['id']){
                            $first_business[] = $value;
                        }
                        else{
                            $sub_business_list[]=$value;
                        }
                    }
                    else{
                        // echo "\n2";
                        $sub_business_list[]=$value;
                    }
                }
            }
            else{
                foreach ($sub_business_list as $key => $value) {
                    # code...
                    if(isset($random_id)){
                        // echo "\n1";
                        if($premium_ids[$random_id] == $value['id']){
                            $data['premium_id'] = $value['id'];
                            $sub_business_list[0] = $value;
                        }
                        else{
                            $sub_business_list[]=$value;
                        }
                    }
                    else{
                        // echo "\n2";
                        $sub_business_list[]=$value;
                    }
                }
            }
        }
        // exit;

        if($popular == "1"){
            usort($sub_business_list, 'sortByrank');
        }
        
        $business_new = [];
        if($is_closest == "1"){
            /* if($user_address_empty == 1){
                $status = "0";
                $msg = "User Address is empty";
                $popup_text = "יש להגדיר כתובת או לאפשר שימוש במיקום שלך";
            } */
            // else{
                $closest_user_sub = get_subscription_list();
                foreach ($business as $bus_key => $bus_value) {
                    # code...
                    foreach ($closest_user_sub as $key => $value) {
                        if($value['uid'] == $bus_value['id']){
                            $posts_images = array();
                            if(!empty($bus_value['posts']['posts_images']))
                            {
                                $posts_images = $bus_value['posts']['posts_images'];
                            }
                            unset($bus_value['posts']['posts_images']);
                            
                            $bus_value['business_img'] = $posts_images;
                            $business_new[] = $bus_value;
                        }
                    }
                }
            // }
            $business = $business_new;
            // $data['business']=$business;
            // $data['is_filter']=$is_filter;
        }
        else{
            $business_new = [];
            $business_new = $first_business;
            foreach ($sub_business_list as $value) {
                # code...
                if(!in_array($value,$business_new)){
                    $business_new[] = $value;
                }
            }
            /* echo "<pre>";
            print_r($business_new);
            exit; */
            $business = $business_new;
            // $data['business']=$business;
            // $data['is_filter']=$is_filter;
        }
        
        // $limited_business=[];
        // if(isset($_REQUEST['start']) && isset($_REQUEST['limit']))
        // {
        //     $start_pagination=$db->real_escape_string($_REQUEST['start']);
        //     $limit_pagination=$db->real_escape_string($_REQUEST['limit']);
        //     if(isset($business[$start_pagination]))
        //     {
        //         for($record_number=$start_pagination;$record_number<=$limit_pagination;$record_number++){
        //             if(isset($business[$record_number]))
        //                 $limited_business[]=$business[$record_number];
        //         }
        //         $business=$limited_business;
        //     }
        // }
        
        $data['business']=$business;
        $data['popup_text']=$popup_text;
        $data['is_filter']=$is_filter;
        $data['is_closest'] = $is_closest;
    }
} else {
    $status = 0;
    $msg = $gbl_msg_invalid_args;
}