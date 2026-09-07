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
        $style_arr=[];
        $start = 0;
        $limit = 6;
        $params['uid']=$post['uid'];
        /* if(isset($post['styles']))
        {
            if($post['styles']!=""){
                $style_arr = explode(",",$post['styles']);
                // $params['styles']=$post['styles'];
            }
        } */

        if(isset($post['is_random']))
        {
            if($post['is_random'] == "1"){
                $params['is_random']=$post['is_random'];
            }
        }

        /* if(isset($post['start']))
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
        } */
        $params['start']=$start;
        $params['limit']=$limit;

        /* if(!empty($style_arr)){
            foreach($style_arr as $key=>$val){
                $style_name=$val;
                $params['styles'] = $style_name;
                $plist = get_home_posts($params);
                $data['q'] = $db->last_query();
                
                $posts = []; // Reset posts for each style

                if (!empty($plist)) {
                    foreach ($plist as $pk => $pv) {
                        $plist[$pk]['style_name_hw'] = isset($list_styles_hw[$style_name]) 
                            ? $list_styles_hw[$style_name] 
                            : '';
                        $plist[$pk]['style_name'] = $style_name; // ✅ Add style name explicitly
                    }
                    $posts = $plist;
                }
                $data['posts'][$val] = $posts;
            }
        }
        else{
            $status = 0;
            $msg = "Please provide valid styles parameter.";
        } */
        
        if (!empty($user_styles)) {
            $style_arr = explode(",", $user_styles);
        } else {
            $style_arr = array_column($styles, 'slug');
        }

        // Clean and ensure uniqueness
        $style_arr = array_unique(array_map('trim', $style_arr));

        // Fill up to 3 if user has less
        if (count($style_arr) < 3) {
            $all_slugs = array_column($styles, 'slug');
            $remaining_styles = array_diff($all_slugs, $style_arr);
            shuffle($remaining_styles);
            $needed = 3 - count($style_arr);
            $style_arr = array_merge($style_arr, array_slice($remaining_styles, 0, $needed));
        }

        // Shuffle and prepare
        shuffle($style_arr);
        $used_styles = [];
        $data['selected_styles'] = [];
        $data['posts'] = [];

        // Keep looping until we have 3 valid styles (or run out)
        foreach ($style_arr as $style_name) {
            if (count($data['selected_styles']) >= 3) break;

            $params['styles'] = $style_name;
            $plist = get_home_posts($params);

            // Skip if empty
            if (empty($plist)) continue;

            // Add info
            foreach ($plist as $pk => $pv) {
                $plist[$pk]['is_multiple_image'] = count(explode(",",$plist[$pk]['image_name'])) > 1 ? "1" : "0";
                $plist[$pk]['image_name'] = explode(",",$plist[$pk]['image_name'])[0];
                $plist[$pk]['image_id'] = explode(",",$plist[$pk]['image_id'])[0];
                $plist[$pk]['style_name'] = $list_styles_hw[$style_name] ?? '';
            }

            $data['selected_styles'][] = $style_name;
            $data['posts'][$style_name] = $plist;
            $used_styles[] = $style_name;
            // $data['q'][] = $db->last_query();
        }

        // Fallback — if we still don’t have 3, try from all available styles
        if (count($data['selected_styles']) < 3) {
            $available_styles = array_diff(array_column($styles, 'slug'), $used_styles);
            shuffle($available_styles);

            foreach ($available_styles as $alt_style) {
                if (count($data['selected_styles']) >= 3) break;

                $params['styles'] = $alt_style;
                $plist = get_home_posts($params);
                if (empty($plist)) continue;

                foreach ($plist as $pk => $pv) {
                    $plist[$pk]['is_multiple_image'] = count(explode(",",$plist[$pk]['image_name'])) > 1 ? "1" : "0";
                    $plist[$pk]['image_name'] = explode(",",$plist[$pk]['image_name'])[0];
                    $plist[$pk]['image_id'] = explode(",",$plist[$pk]['image_id'])[0];
                    $plist[$pk]['style_name'] = $list_styles_hw[$alt_style] ?? '';
                }

                $data['selected_styles'][] = $alt_style;
                $data['posts'][$alt_style] = $plist;
                // $data['q'][] = $db->last_query();
            }
        }

    }
} else {
    $status = 0;
    $msg = $gbl_msg_invalid_args;
}