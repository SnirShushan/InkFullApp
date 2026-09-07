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
        //$data['profile'] = get_user_profile($row['id']);
        $list_styles_hw=[];
        $list_styles_en=[];
        $styles=get_style_list();
        foreach($styles as $s){
            $list_styles_hw[$s['slug']]=$s['name'];
            $list_styles_en[$s['slug']]=$s['name_en'];
        }

        $user_data = get_user_profile($post['uid']);
        $user_styles = $user_data['styles'];
        $status=1;
        $msg = "Success";
        $posts=[];
        $params=[];
        $params['uid']=$post['uid'];
        if(isset($post['styles']))
        {
            if($post['styles']!=""){
                $params['styles']=$post['styles'];
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

        if(isset($post['is_closest']))
        {
            if($post['is_closest'] == "1"){
                $user_data = get_user_profile($post['uid']);
                $lat = $user_data['address_lat'];
                $lng = $user_data['address_lng'];
                if(isset($lat)){
                    if(isset($lng)){
                        if(isset($radius)){
                            $params['lat']=$lat;
                            $params['lng']=$lng;
                            $params['radius']=$radius;
                        }
                    }
                }
            }
        }

        if(isset($post['is_random']))
        {
            if($post['is_random'] == "1"){
                $params['is_random']=$post['is_random'];
            }
        }

        if(isset($post['most_view']))
        {
            if($post['most_view'] == "1"){
                $params['most_view']=$post['most_view'];
            }
        }

        if(isset($post['is_new']))
        {
            if($post['is_new'] == "1"){
                $params['is_new']=$post['is_new'];
            }
        }

        if(isset($post['post_ids']) && $post['post_ids'] != '')
        {
            $params['post_ids']=$post['post_ids'];
        }

        if(isset($post['following']))
        {
            if($post['following']!="0"){
                $params['following']=$post['following'];
            }
        }

        if(isset($post['my']))
        {
            if($post['my']!=""){
                $params['my']=$post['my'];
            }
        }

        if(isset($post['search_txt']))
        {
            if($post['search_txt']!=""){
                $params['search_txt']=$post['search_txt'];
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
        $posts_tatto=[];
        $posts_img=[];
        $plist=search_posts($params);
        $data['q']=$db->last_query();
        $post_list = [];
        $recomand_list = [];
        $total_post = 0;
        /* if($plist){
            if($plist->num_rows()>0){
                $post_list = $plist->result();
            }
        } */

        if($plist){
            // if($plist->num_rows()>0){
            if(count($plist)>0){
                
                // foreach($plist->result() as $post_id){
                foreach($plist as $key => $post_id){
                    
                    /* $product = [];
                    $product = explode("_",$post_id['product_id']);
                    $plan_type = $product[1];
                    
                    if($plan_type == "basic" && $post_id['img_type'] == "1"){
                        continue;
                    } */
                    // $posts=$plist;

                    // $post_detail=get_post_detail($post_id->id,$post['uid']);
                    /* $post_detail=get_post_detail($post_id['id'],$post['uid']);
                    if(count($post_detail)>0){
                        // $profile = get_user_profile($post_detail['uid']);
                        // $post_limit = $profile['post_limit'];
                        // echo "<pre>";
                        // print_r($profile);
                        // exit;

                        $list_slug=[];
                        $list_slug_en=[];
                        if(isset($post_detail['styles']))
                        {
                            $arr_style=explode(",",$post_detail['styles']);
                            foreach($arr_style as $s1){
                                if(isset($list_styles_hw[$s1])){
                                    $list_slug[]="#".$list_styles_hw[$s1];
                                    $list_slug_en[]="#".$list_styles_en[$s1];
                                }
                            }
                        }

                        $post_detail['tag_list']=$list_slug;
                        $post_detail['tag_str']=implode(",",$list_slug);
                        $post_detail['tag_list_en']=$list_slug_en;
                        $post_detail['tag_str_en']=implode(",",$list_slug_en);
                        if($post_detail['img_type']=="1")
                        {
                            $posts_img[]=$post_detail;
                        }else{
                            $posts_tatto[]=$post_detail;
                        }
                        $posts[]=$post_detail;
                    } */

                    $image_names = explode(",", $post_id['image_name']);
                    $image_ids   = explode(",", $post_id['image_id']);

                    // Determine multiple
                    $is_multiple = count($image_names) > 1 ? "1" : "0";

                    if($post_id['img_type']=="1")
                    {
                        // $posts_img[]=$post_id;
                        $post_id['image_name'] = $image_names[0];
                        $post_id['image_id']   = $image_ids[0];
                        $post_id['is_multiple_image'] = $is_multiple;
                        $posts_img[] = $post_id;
                    }else{
                        // $posts_tatto[]=$post_id;
                        $post_id['image_name'] = $image_names[0];
                        $post_id['image_id']   = $image_ids[0];
                        $post_id['is_multiple_image'] = $is_multiple;
                        $posts_tatto[] = $post_id;
                    }
                    /* if($total_post === 0)
                    {
                        $total_post = $post_id['total_posts'];
                    } */
                    $plist[$key]['image_name'] = $image_names[0];
                    $plist[$key]['image_id']   = $image_ids[0];
                    $plist[$key]['is_multiple_image'] = $is_multiple;
                }
                $posts=$plist;
            }
        }

        // $new_posts = [];
        // foreach ($posts as $value) {
        //     # code...
        //     if(!in_array($value,$new_posts)){
        //         $new_posts[] = $value;
        //     }
        // }
        // $posts = $new_posts;
        
        // /* for posts tattoo */
        // $new_posts_tatto = [];
        // foreach ($posts_tatto as $value) {
        //     # code...
        //     if(!in_array($value,$new_posts_tatto)){
        //         $new_posts_tatto[] = $value;
        //     }
        // }
        // $posts_tatto = $new_posts_tatto;

        // /* for posts tattoo */
        // $new_posts_img = [];
        // foreach ($posts_img as $value) {
        //     # code...
        //     if(!in_array($value,$new_posts_img)){
        //         $new_posts_img[] = $value;
        //     }
        // }
        // $posts_img = $new_posts_img;

        /* if(isset($post['is_random']) && $post['is_random'] == "1"){
            shuffle($posts);
        } */
        $data['posts']=$posts;
        // $data['total_post_count'] = $total_post;
        if(isset($post['my']))
        {
            if($post['my']!=""){
                $data['tatto']=$posts_tatto;
                $data['sketch']=$posts_img;
                $data['posts']=[];
            }
        }
        
    }
} else {
    $status = 0;
    $msg = $gbl_msg_invalid_args;
}