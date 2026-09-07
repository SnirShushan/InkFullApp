<?php
    $main_url=base_url("assets/");
    define("MAIN_URL",$main_url);
?>
<!DOCTYPE html>

<!--[if IE 8]> <html lang="en" class="ie8 no-js"> <![endif]-->
<!--[if IE 9]> <html lang="en" class="ie9 no-js"> <![endif]-->
<!--[if !IE]><!-->
<html lang="en">
    <!--<![endif]-->
    <!-- BEGIN HEAD -->

    <head>
        <meta charset="utf-8" />
        <title><?php echo $this->settings['name']; ?> - <?php if(($title)){ echo $title; } ?></title>
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta content="width=device-width, initial-scale=1" name="viewport" />
        <meta content="Smart WebTech is the India based offshore development company pioneer in website development, mobile application development and web data scraping" name="description" />
        <meta content="Mr Jasmin Shukal" name="author" />
        <link href="https://fonts.googleapis.com/css2?family=Heebo:wght@400;500;600;700;800&family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
        <link href="https://fonts.googleapis.com/css?family=Noto+Serif&display=swap" rel="stylesheet">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap-colorpicker/2.5.3/css/bootstrap-colorpicker.css.map" rel="stylesheet">
        <!-- BEGIN include file local STYLE -->
        <?php foreach($include_css as $key=>$value)
        {   ?>
                <link href="<?=MAIN_URL.$value; ?>" rel="stylesheet" type="text/css" content="THIS CSS COME FROM CORE/MY_CONTROLLER <?=$key+1;?> " />    
            <?php 
        }
        ?>
        <link href="<?=base_url("assets/global/css/jquery-file-upload.css")?>" rel="stylesheet" type="text/css" content="" />
        <link href="<?=base_url("assets/layouts/layout/css/modern-admin.css?v=20260907")?>" rel="stylesheet" type="text/css" />    
        
        <link rel="shortcut icon" href="<?php echo $main_url;?>/upload/<?=$this->settings['favicon'];?>" /> 
        <style type="text/css">
            input::-webkit-outer-spin-button,
            input::-webkit-inner-spin-button {
            -webkit-appearance: none;
            margin: 0;
            }

            /* Firefox */
            input[type=number] {
            -moz-appearance:textfield;
            }
            .loader {
                position: fixed;
                left: 0px;
                top: 0px;
                width: 100%;
                height: 100%;
                z-index: 9999;
                background: url('<?php echo $main_url; ?>/loder/new3.gif') 50% 50% no-repeat rgb(249,249,249);
                opacity: .8;
            }
            .bike_loader1 {
                display:none;
                position: fixed;
                left: 0px;
                top: 0px;
                width: 100%;
                height: 100%;
                z-index: 11050;
                background: url('<?php echo $main_url; ?>/loder/bike.gif') 50% 50% no-repeat #f7ea08;
                opacity: .8;
            }
            .bike_loader1 h1 {
                position: fixed;
                left: 0px;
                text-align: center;
                top: 70%;
                bottom: 0px;
                width: 100%;
                height: 100%;
            }
            .pdf_generate
            {
                display:none;
                position: fixed;
                left: 0px;
                top: 0px;
                width: 100%;
                height: 100%;
                z-index: 11050;
                background: url('<?php echo $main_url; ?>/loder/gunrate_pdf.gif') 50% 50% no-repeat #ffffff;
                opacity: 1;
            }
            .pdf_generate h1
            {
                position: fixed;
                left: 0px;
                text-align: center;
                top: 70%;
                bottom: 0px;
                width: 100%;
                height: 100%;
            }
            .error
            {
                border: solid 1px red;
            }
        </style>
    </head>
    <!-- END HEAD -->
    <!-- <body class="page-header-fixed page-sidebar-closed-hide-logo"> -->
    <body class="page-header-fixed page-sidebar-closed-hide-logo ink-modern">
    <!-- <body class="page-header-fixed page-sidebar-closed-hide-logo page-content-white page-sidebar-reversed"> -->
        <div class="loader"></div>
        <div class="bike_loader1">
            <h1>Updating.. <br>Don’t Cancel.. Or Page Refresh <br> Untill Prosess Not Done ..  </h1>
        </div>
        <div class="pdf_generate">
            <h1>Generate PDF.. <br>Don’t Cancel.. Or Page Refresh <br> Untill Prosess Not Done ..  </h1>
        </div>
        

        <div class="page-wrapper">
            <!-- BEGIN HEADER -->
            <div class="page-header navbar navbar-fixed-top">
                <!-- BEGIN HEADER INNER -->
                <div class="page-header-inner ">
                    <!-- BEGIN LOGO -->
                    <div class="page-logo">
                        <a href="<?=base_url();?>">
                        <p alt="logo" class="logo-default ink-brand-name">
                            <?php echo $this->settings['name']; ?>
                        </p> </a> 
                            <!-- <img src="<?php echo $main_url; ?>layouts/layout/img/logo.png" alt="logo" class="logo-default" /> </a> -->
                        <div class="menu-toggler sidebar-toggler">
                            <span></span>
                        </div>
                    </div>
                    <!-- END LOGO -->
                    <!-- BEGIN RESPONSIVE MENU TOGGLER -->
                    <a href="javascript:;" class="menu-toggler responsive-toggler" data-toggle="collapse" data-target=".navbar-collapse">
                        <span></span>
                    </a>
                    <!-- END RESPONSIVE MENU TOGGLER -->
                    <!-- BEGIN TOP NAVIGATION MENU -->
                    <div class="top-menu">
                        <ul class="nav navbar-nav pull-right">
                            <li class="dropdown dropdown-user">
                                <a href="javascript:void(0);" class="dropdown-toggle" data-toggle="dropdown" data-hover="dropdown" data-close-others="true" aria-expanded="false">
                                    <img alt="" class="img-circle img-circle_avatar_profile" src="<?php echo base_url("assets/profile_img/");
                                    $res=$this->session->userdata("profile_image");
                                    if(isset($res) && $res!="")
                                    {
                                        echo $this->session->userdata("profile_image"); 
                                    }
                                    else
                                    {
                                        echo "assets/profile_img/default.png";
                                    }
                                    ?>">

                                    <span class="username username-hide-on-mobile"> <?php echo $this->session->userdata("profile_name"); ?> </span>
                                    <i class="fa fa-angle-down"></i>
                                </a>
                                <ul class="dropdown-menu dropdown-menu-default">
                                    <li>
                                        <a href="<?php echo base_url("Setting/Personal"); ?>">
                                            <i class="icon-user"></i> Personal Info </a>
                                    </li>
                                    <li>
                                        <a href="<?=base_url("ChangePassword")?>">
                                            <i class="icon-calendar"></i>Change Password</a>
                                    </li>
                                    <li>
                                        <a href="<?=base_url("logout")?>">
                                            <i class="icon-key"></i> Log Out </a>
                                    </li>
                                </ul>
                            </li>
                        </ul>
                    </div>
                    <!-- END TOP NAVIGATION MENU -->
                </div>
                <!-- END HEADER INNER -->
            </div>

            <?php
            $per_arr=array(); 
            $per_arr=$this->session->userdata("access");

            ?>
            <!-- END HEADER -->
            <!-- BEGIN HEADER & CONTENT DIVIDER -->
            <div class="clearfix"> </div>
            <!-- END HEADER & CONTENT DIVIDER -->
            <!-- BEGIN CONTAINER -->
            <div class="page-container">
                <!-- slider jess -->
                <?php
                    print($side_list);
                ?>
                <!-- slider end jess -->
                <!-- BEGIN CONTENT -->
                <div class="page-content-wrapper">
                    <!-- BEGIN CONTENT BODY -->
                    <div class="page-content">
                        <!-- BEGIN PAGE HEADER-->
                       
                        <!-- BEGIN PAGE TITLE-->
                       <?php
                        if(!isset($Breadcrumb))
                        {
                        ?>
                        <h1 class="page-title"> <?php if(!empty($page_heading)){ echo $page_heading; } ?>
                            <small><?php if(!empty($page_sub_heading)){ echo $page_sub_heading; } ?></small>
                        </h1>
                        <!-- END PAGE TITLE-->
                        <!-- BEGIN PAGE BAR -->
                        <div class="page-bar">
                            <ul class="page-breadcrumb">
                                <?php if(!empty($breadcrumb_home_logo)){ echo $breadcrumb_home_logo; } ?>
                                <?php if(!empty($arr_breadcrumb)){
                                    foreach($arr_breadcrumb as $key=> $value){ ?>
                                            <li>

                                                <a href="<?php echo $value; ?>"><?php echo $key; ?></a>
                                                <i class="fa fa-angle-right"></i>
                                            </li>        
                                   <?php }
                                    } ?>
                                
                                <li>
                                    <span><?php if(!empty($page_heading)){ echo $page_heading; } ?></span>
                                </li>
                            </ul>
                            <div class="page-toolbar">

                                <a class="btn <?=$this->settings['danger_color'];?>" href="<?php if(!empty($back_button)){ echo $back_button; }else{ echo base_url();} ?>">Back</a>
                                <div style="display: none;" class="btn-group pull-right">
                                    <button type="button" class="btn btn-fit-height default dropdown-toggle" data-toggle="dropdown"> Actions
                                        <i class="fa fa-angle-down"></i>
                                    </button>
                                    <ul class="dropdown-menu pull-right" role="menu">
                                        <li>
                                            <a href="#">
                                                <i class="icon-bell"></i> Action</a>
                                        </li>
                                        <li>
                                            <a href="#">
                                                <i class="icon-shield"></i> Another action</a>
                                        </li>
                                        <li>
                                            <a href="#">
                                                <i class="icon-user"></i> Something else here</a>
                                        </li>
                                        <li class="divider"> </li>
                                        <li>
                                            <a href="#">
                                                <i class="icon-bag"></i> Separated link</a>
                                        </li>
                                    </ul>
                                </div>
                            </div>
                        </div>
                        <?php
                            }
                            ?>

                    <?php
                        if($this->session->flashdata('message')) 
                        {
                            echo "<div class='form-group'><div class='col-md-12'><div class='alert alert-info'>";
                            echo $this->session->flashdata('message');;
                            echo "</div></div></div>";
                        }
                        if(!empty($error))
                        {
                            echo '<div class="form-group">
                        <div class="col-md-12">
                        <div class="alert alert-danger">';
                            echo $error;
                            echo "</div></div></div>";
                        }

                    ?>

                    <?php  echo validation_errors('<div class="alert alert-danger">', '</div>'); ?>

                    <?php if($this->session->flashdata('msg')): ?>
                    <div class="alert alert-success">
                      <strong><?php echo $this->session->flashdata('msg'); ?></strong>
                    </div>
                    <?php endif; ?>
                    <?php if($this->session->flashdata('Error')): ?>
                    <div class="alert alert-danger">
                      <strong><?php echo $this->session->flashdata('Error'); ?></strong>
                    </div>
                    <?php endif; ?>
                            <?php echo $data; ?>
                    </div>
                    <!-- END CONTENT BODY -->
                </div>
                <!-- END CONTENT -->
               
            </div>
            <!-- END CONTAINER -->
            <!-- BEGIN FOOTER -->
            <div class="page-footer">
                <div class="page-footer-inner"><?php echo $this->settings['footer_text']; ?>
                <!-- &nbsp;|&nbsp; <a target="_blank" href="http://www.smart-webtech.com/">Smart-Webtech</a> -->
                </div>
                <div class="scroll-to-top">
                    <i class="icon-arrow-up"></i>
                </div>
            </div>
            <!-- END FOOTER -->
        </div>
       
        
        <!-- BEGIN CORE PLUGINS -->
        <?php foreach($include_js as $key=>$value)
        {   ?>
                <!-- <link href="<?=MAIN_URL.$value; ?>" rel="stylesheet" type="text/css" content="THIS JS COME FROM CORE/MY_CONTROLLER <?=$key+1;?> " />     -->
                <script src="<?=MAIN_URL.$value; ?>" type="text/javascript" content="THIS JS COME FROM CORE/MY_CONTROLLER <?=$key+1;?> "></script>
            <?php 
        }
        ?>
        <script src="<?=base_url("assets/global/scripts/jquery-file-upload.js")?>" type="text/javascript" content=" "></script>

        

        <script>
            $(document).ready(function()
            {
                var ready = false;
                $(document).ready(function () {
                    $(".loader").fadeOut("slow");
                });


            });



            document.addEventListener("contextmenu", function(e){
    e.preventDefault();
}, false);

        </script>
    </body>

</html>