<?php
$output_type = 0;
$fields = ['pid'];
$check = check_isset($fields);
$job_list = [];
if ($check) {
    $post = get_all_data_protected($_REQUEST);
    
        
        $post_detail=get_post_detail($_REQUEST['pid'],0);
        if(count($post_detail)>0){

            
            $id=$post['pid'];
            
            $description=$post_detail['description'];

            $image="";
            if($post_detail['image_name']!="")
            {
                $images=explode(",",$post_detail['image_name']);
                if(count($images)>0){
                    $image=$images[0];
                }
            }
            
           echo '<!DOCTYPE html>
            <html>
                <head>
                    <meta property="og:title" content="'.$description.'" />
                    <meta property="og:description" content="'.$description.'" />
                    <meta property="og:image" content="'.$image.'" />
                    <meta property="og:url" content="https://yourdomain.com/share?id='.$id.'" />
                    <meta property="og:type" content="website" />
                </head>
            <body></body>
            </html>';

        }
        
    
}