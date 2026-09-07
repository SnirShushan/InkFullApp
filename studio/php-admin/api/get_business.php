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

 
        
        $bi_post_limit = 5;
        if(isset($b_post_limit))
        {
            $bi_post_limit = $b_post_limit;
        }
        $order = 'order by date_added DESC';
        


        $popular="";
        if(isset($post['popular']))
        {
            if($post['popular']!=""){
                $popular=$post['popular'];
            }
        }

        
        if($popular=="1"){
            $params['popular']="1";
        }
        $random_id="";
        // GETTING BUSINESS LIST FOR THE PREMIUM BUSINESSS ONLY.
        if(isset($post['is_filter_location']))
        {
            if($post['is_filter_location'] != "1"){
                $params['premium']="1";
                
                $plist_premium=get_business_search($params);
        
                $premium_ids = [];
                if($plist_premium){
                    if(count($plist_premium)>0){
                        foreach($plist_premium as $bid){
                            $premium_ids[]= $bid;
                        }
                    }
                }
                $random_id="";
                $data['pids']=$premium_ids;
                if(count($premium_ids)>0){
                    $random_id = array_rand($premium_ids);
                    $random_id=$premium_ids[$random_id];
                    $data['rand_id'] = $random_id;
                }
            }
        }

        /* $params['premium']="1";
        
        $plist_premium=get_business_search($params);

        $premium_ids = [];
        if($plist_premium){
            if(count($plist_premium)>0){
                foreach($plist_premium as $bid){
                    $premium_ids[]= $bid;
                }
            }
        }
        $random_id="";
        $data['pids']=$premium_ids;
        if(count($premium_ids)>0){
            $random_id = array_rand($premium_ids);
            $random_id=$premium_ids[$random_id];
            $data['rand_id'] = $random_id;
        } */

        
        //GETTING BUSINESS SEARCH LIST WITH ALL FILTER PARAMTERES.
        if(isset($_REQUEST['start']))
        {
            if($params['start']!=0 || $params['start']!="0"){
                $random_id="";
            }
        }
        
        unset($params['premium']);
        $params['random_id']=$random_id;
        

        /// HOME PAGE DATA GET
        if(isset($is_home) && $is_home)
        {
                if(isset($user_styles))
                {
                    if($user_styles!=""){
                        unset($params['styles']);
                    }
                }   
        }


        $business_new = [];
        $plist=get_business_search($params);
        if($random_id!=""){
            // $user=get_business_detail($random_id,$post['uid'],$bi_post_limit,$order,"1");
            $user=get_business_detail_new($random_id,$post['uid'],$bi_post_limit,$order,"1");
            if(count($user)>0)
                $business[]=$user;
        }   
        
        foreach($plist as $bid){

            // $user=get_business_detail($bid,$post['uid'],$bi_post_limit,$order,"1");
            $user=get_business_detail_new($bid,$post['uid'],$bi_post_limit,$order,"1");
            if(count($user)>0){
                $business[]=$user;
            }
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

        foreach ($business as $bus_key => $bus_value) {
                    # code...
                    
                        $posts_images = array();
                        if(!empty($bus_value['posts']['posts_images']))
                        {
                            $posts_images = $bus_value['posts']['posts_images'];
                        }
                        unset($bus_value['posts']['posts_images']);
                        
                        $business[$bus_key]['business_img'] = $posts_images;
                        
                    
                }
        
        $data['business']=$business;
        $data['popup_text']=$popup_text;
        $data['is_filter']=$is_filter;
        $data['is_closest'] = $is_closest;
    }
} else {
    $status = 0;
    $msg = $gbl_msg_invalid_args;
}