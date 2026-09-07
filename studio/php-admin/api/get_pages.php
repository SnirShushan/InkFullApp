<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css" rel="stylesheet"
        integrity="sha384-rbsA2VBKQhggwzxH7pPCaAqO46MgnOM80zW1RWuH61DGLwZJEdK2Kadq2F9CUG65" crossorigin="anonymous">
    <title>Document</title>
</head>
    <body dir="rtl">
<?php
$fields = ["page_name"];
$check = check_isset($fields);
$job_list = [];
if ($check) {
    $post = get_all_data_protected($_REQUEST);
        $output_type = 0;
        $status=1;
        $page_name=$_REQUEST['page_name'];
        $result=$db->query("select * from tbl_pages where page_name='".$page_name."' LIMIT 1");
        if($result){
            if($result->num_rows()>0){
                $rw=$result->result();
                $row=$rw[0];
                echo $row->page_desc;
            }
        }
    
} else {
    $status = 0;
    $msg = $gbl_msg_invalid_args;
}
?>
    </body>
</html>