<?php
$fields = ['uid','login_token','app_token','device_type','app_version','pid'];
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
        $list_styles_hw=[];
        $list_styles_en=[];
        $styles=get_style_list();
        foreach($styles as $s){
            $list_styles_hw[$s['slug']]=$s['name'];
            $list_styles_en[$s['slug']]=$s['name_en'];
        }
        $post_detail=get_post_detail($post['pid'],$post['uid']);
        if(count($post_detail)>0){

            $view_count = $post_detail['view_count'] + 1;

            $upd=[];
            $upd['view_count'] = $view_count;
            update('tbl_post', $upd,['id'=>$post['pid']]);

            $msg="success";
            $status=1;
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

            $filter = [];
            $filter['uid'] = $post['uid'];
            $filter['styles'] = $post_detail['styles'];
            $filter['start'] = "0";
            $filter['limit'] = 4;
            $filter['is_random'] = '1';
            $filter['not_in'] = $post['pid'];
            $related_posts=[];
            $posts_tatto=[];
            $posts_img=[];
            $plist=search_posts($filter);
            if($plist){
                // if($plist->num_rows()>0){
                if(count($plist)>0){
                    // foreach($plist->result() as $post_id){
                    foreach($plist as $post_id){
                        
                        // $related_post_detail=get_post_detail($post_id->id,$post['uid']);
                        $related_post_detail=get_post_detail($post_id['id'],$post['uid']);
                        if(count($related_post_detail)>0){
    
                            $single_post = [];
                            $single_post['id'] = $related_post_detail['id'];
                            $single_post['uid'] = $related_post_detail['uid'];
                            $single_post['img_type'] = $related_post_detail['img_type'];
                            $single_post['styles'] = $related_post_detail['styles'];
                            $single_post['description'] = $related_post_detail['description'];
                            $single_post['image_name'] = explode(",",$related_post_detail['image_name'])[0];
                            $single_post['image_id'] = explode(",",$related_post_detail['image_id'])[0];
                            $single_post['is_multiple_image'] = count(explode(",",$related_post_detail['image_name'])) > 1 ? "1" : "0";

                            $related_posts[] = $single_post;
                            
                        }
                        
                    }
                }
            }
            $new_posts = [];
            foreach ($related_posts as $value) {
                # code...
                if(!in_array($value,$new_posts)){
                    $new_posts[] = $value;
                }
            }
            $related_posts = $new_posts;
            
            $post_detail['related_posts'] = $related_posts;
            $post_detail['image_name'] = explode(",",$post_detail['image_name']);
            $post_detail['image_id'] = explode(",",$post_detail['image_id']);
            $post_detail['is_multiple_image'] = count($post_detail['image_name']) > 1 ? "1" : "0";
            $data['detail']=$post_detail;

        }else{
            $status=0;
            // $msg="post not found";
            $msg="הפוסט לא נמצא";
        }
        
    }
} else {
    $status = 0;
    $msg = $gbl_msg_invalid_args;
}