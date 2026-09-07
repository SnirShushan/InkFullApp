<?php
$main_url = base_url("");
$main_url1 = base_url("assets/");
define("MAIN_URL", $main_url1);
?>
<!DOCTYPE html>
<!-- 
Template Name: Metronic - Responsive Admin Dashboard Template build with Twitter Bootstrap 3.3.7
Version: 4.7.5
Author: KeenThemes
Website: http://www.keenthemes.com/
Contact: support@keenthemes.com
Follow: www.twitter.com/keenthemes
Dribbble: www.dribbble.com/keenthemes
Like: www.facebook.com/keenthemes
Purchase: http://themeforest.net/item/metronic-responsive-admin-dashboard-template/4021469?ref=keenthemes
Renew Support: http://themeforest.net/item/metronic-responsive-admin-dashboard-template/4021469?ref=keenthemes
License: You must have a valid license purchased only from themeforest(the above link) in order to legally use the theme for your project.
-->
<!--[if IE 8]> <html lang="en" class="ie8 no-js"> <![endif]-->
<!--[if IE 9]> <html lang="en" class="ie9 no-js"> <![endif]-->
<!--[if !IE]><!-->
<html lang="en">
<!--<![endif]-->
<!-- BEGIN HEAD -->

<head>

    <meta charset="utf-8" />
    <title><?php echo $this->settings['name']; ?> - <?php if (($title)) {
                                                        echo $title;
                                                    } ?></title>
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta content="width=device-width, initial-scale=1" name="viewport" />
    <meta content="Preview page of Metronic Admin Theme #1 for reversed sidebar option" name="description" />
    <meta content="" name="author" />
    <!-- BEGIN GLOBAL MANDATORY STYLES -->
    <?php foreach ($include_css as $key => $value) {   ?>
    <link href="<?= MAIN_URL . $value; ?>" rel="stylesheet" type="text/css"
        content="THIS CSS COME FROM CORE/MY_CONTROLLER <?= $key + 1; ?> " />
    <?php
    }
    ?>
    <link href="https://fonts.googleapis.com/css2?family=Heebo:wght@400;500;600;700;800&family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet"
        type="text/css" />
    <link href="<?= $main_url; ?>assets/global/plugins/font-awesome/css/font-awesome.min.css" rel="stylesheet"
        type="text/css" />
    <link href="<?= $main_url; ?>assets/global/plugins/simple-line-icons/simple-line-icons.min.css" rel="stylesheet"
        type="text/css" />
    <link href="<?= $main_url; ?>assets/global/plugins/bootstrap/css/bootstrap.min.css" rel="stylesheet"
        type="text/css" />
    <link href="<?= $main_url; ?>assets/global/plugins/bootstrap-switch/css/bootstrap-switch.min.css" rel="stylesheet"
        type="text/css" />
    <!-- END GLOBAL MANDATORY STYLES -->
    <!-- BEGIN THEME GLOBAL STYLES -->
    <link href="<?= $main_url; ?>assets/global/css/components.min.css" rel="stylesheet" id="style_components"
        type="text/css" />
    <link href="<?= $main_url; ?>assets/global/css/plugins.min.css" rel="stylesheet" type="text/css" />
    <!-- END THEME GLOBAL STYLES -->
    <!-- BEGIN THEME LAYOUT STYLES -->
    <link href="<?= $main_url; ?>assets/layouts/layout/css/layout.min.css" rel="stylesheet" type="text/css" />

    <link href="<?= $main_url; ?>assets/global/plugins/bootstrap-timepicker/css/bootstrap-timepicker.min.css"
        rel="stylesheet" type="text/css" />

    <!-- <link href="<?= $main_url; ?>assets/global/plugins/bootstrap-datepicker/css/bootstrap-datepicker3.min.css" rel="stylesheet"
        type="text/css" /> -->
    <link href="<?= $main_url; ?>assets/global/plugins/bootstrap-touchspin/bootstrap.touchspin.css" rel="stylesheet"
        type="text/css" />


    <link href="<?= $main_url; ?>assets/layouts/layout/css/themes/<?= $this->settings['theam_color']; ?>.min.css"
        rel="stylesheet" type="text/css" id="style_color" />
    <link href="<?= $main_url; ?>assets/layouts/layout/css/custom.min.css" rel="stylesheet" type="text/css" />
    <link rel="stylesheet" href="<?= base_url(); ?>assets/global/plugins/crop_image/css/cropper.css">

    <link rel="stylesheet"
        href="<?= base_url(); ?>assets/global/plugins/bootstrap-multiselect/css/bootstrap-multiselect.css">

    <link href="<?= base_url(); ?>assets/global/plugins/bootstrap-select/css/bootstrap-select.css" rel="stylesheet"
        type="text/css" />
    <link href="<?= base_url(); ?>assets/global/plugins/jquery-multi-select/css/multi-select.css" rel="stylesheet"
        type="text/css" />
    <link href="<?= base_url(); ?>assets/global/plugins/select2/css/select2.min.css" rel="stylesheet" type="text/css" />
    <link href="<?= base_url(); ?>assets/global/plugins/select2/css/select2-bootstrap.min.css" rel="stylesheet"
        type="text/css" />

    <link href="<?= base_url(); ?>assets/jquery.dm-uploader.css" rel="stylesheet" type="text/css" />
    <!-- <link href="<?= base_url(); ?>assets/global/plugins/bootstrap-datetimepicker/css/bootstrap-datetimepicker.min.css"
        rel="stylesheet" type="text/css" /> -->

    <!--<link href="<?= base_url(); ?>assets/global/plugins/ckeditor/contents.css" rel="stylesheet" type="text/css" />-->

    <link rel="stylesheet" type="text/css"
        href="<?= base_url(); ?>assets/global/plugins/ckeditor/plugins/scayt/skins/moono-lisa/scayt.css">
    <link rel="stylesheet" type="text/css"
        href="<?= base_url(); ?>assets/global/plugins/ckeditor/plugins/scayt/dialogs/dialog.css">
    <link rel="stylesheet" type="text/css"
        href="<?= base_url(); ?>assets/global/plugins/ckeditor/plugins/tableselection/styles/tableselection.css">
    <link rel="stylesheet" type="text/css"
        href="<?= base_url(); ?>assets/global/plugins/ckeditor/plugins/wsc/skins/moono-lisa/wsc.css">
    <link rel="stylesheet" type="text/css"
        href="<?= base_url(); ?>assets/global/plugins/bootstrap-editable/bootstrap-editable/css/bootstrap-editable-rtl.css">
    <link rel="stylesheet" type="text/css"
        href="<?= base_url(); ?>assets/global/global/plugins/bootstrap-colorpicker/css/colorpicker.css">
    <link href="https://code.jquery.com/ui/1.10.4/themes/ui-lightness/jquery-ui.css" rel="stylesheet">


    <link href="https://cdn.datatables.net/buttons/1.6.4/css/buttons.dataTables.min.css" rel="stylesheet"
        type="text/css" />

    <link href="<?= base_url("assets/global/css/jquery-file-upload.css") ?>" rel="stylesheet" type="text/css"
        content="" />
    <link href="<?= $main_url; ?>assets/layouts/layout/css/modern-admin.css?v=20260907t" rel="stylesheet" type="text/css" />

    <!-- END THEME LAYOUT STYLES -->
    <link rel="shortcut icon" href="<?php echo $main_url; ?>assets/upload/<?= $this->settings['favicon']; ?>" />
    <style type="text/css">
    .form-horizontal1 {
        direction: rtl;
    }

    .card_tag {
        float: right;
        min-height: 100px;
    }

    .tag_img_border {
        border: 1px solid #eadbdb;
    }

    .active_tag {
        border: 3px solid #de1212;
    }

    input::-webkit-outer-spin-button,
    input::-webkit-inner-spin-button {
        -webkit-appearance: none;
        margin: 0;
    }

    /* Firefox */
    input[type=number] {
        -moz-appearance: textfield;
    }

    html {
        direction: rtl;
        /* overflow-x: hidden;  */
        /* overflow-y: hidden;  */

    }

    ::-webkit-scrollbar {
        width: 5px;
    }

    .error {
        border: solid 1px red;
    }

    /* Track */
    ::-webkit-scrollbar-track {
        box-shadow: inset 0 0 5px grey;
        border-radius: 5px;
    }

    /* Handle */
    ::-webkit-scrollbar-thumb {
        background: #c8c2d2;
    }

    /* Handle on hover */
    ::-webkit-scrollbar-thumb:hover {
        background: #9792e8;
    }

    .page-logo {
        float: right !important;
    }

    .page-sidebar-menu-closed>.nav-link {
        padding-right: 11px !important;
        padding-left: 11px !important;
    }

    .page-content-wrapper {
        overflow: hidden;
    }

    .loader {
        position: fixed;
        left: 0px;
        top: 0px;
        width: 100%;
        height: 100%;
        z-index: 9999;
        background: url('<?php echo $main_url; ?>assets/loder/new3.gif') 50% 50% no-repeat rgb(249, 249, 249);
        opacity: .8;
    }

    .bike_loader1 {
        display: none;
        position: fixed;
        left: 0px;
        top: 0px;
        width: 100%;
        height: 100%;
        z-index: 11050;
        background: url('<?php echo $main_url; ?>assets/loder/bike.gif') 50% 50% no-repeat #f7ea08;
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

    .pdf_generate {
        display: none;
        position: fixed;
        left: 0px;
        top: 0px;
        width: 100%;
        height: 100%;
        z-index: 11050;
        background: url('<?php echo $main_url; ?>assets/loder/gunrate_pdf.gif') 50% 50% no-repeat #ffffff;
        opacity: 1;
    }

    .ajaxloader {
        display: none;
        position: fixed;
        left: 0px;
        top: 0px;
        width: 100%;
        height: 100%;
        z-index: 11050;
        background: url('<?php echo $main_url; ?>assets/loder/ajaxloader.gif') 50% 50% no-repeat #ffffff;
        opacity: 0.5;
    }

    .pdf_generate h1 {
        position: fixed;
        left: 0px;
        text-align: center;
        top: 70%;
        bottom: 0px;
        width: 100%;
        height: 100%;
    }

    .caption {
        float: right !important;
    }

    .actions {
        float: left !important;
    }

    table th {
        text-align: right;
    }

    .select2-container--bootstrap .select2-selection--multiple .select2-selection__choice {
        float: right;
    }

    .select2-container--bootstrap .select2-selection,
    .select2-container--bootstrap.select2-container--focus .select2-selection {
        padding-right: 12px;
    }

    .text-align {
        text-align: right;
    }

    .dropdown-menu li>a>i {
        margin-left: 13px;
    }

    .nav-link i {
        margin-right: 0;
         !important;
    }

    .input-group-addon:last-child {
        border-left: none;
    }

    @media only screen and (max-width:768px) {
        .multiselect {
            width: 438px !important;
        }
    }

    .icon-box {
        margin: 1px 3px 1px 3px;
    }

    .icon-box img {
        border: 1px solid #c4baba;
    }

    .icon-box img.selected {
        border: 2px solid black;
    }
    .datepicker-dropdown{
        right: unset !important;
    }
    .datepicker-menu{
        min-width:295px !important;
    }
    </style>
    <script type="text/javascript">
    var BASE_URL = "<?php echo base_url(); ?>";
    var base_url = BASE_URL;
    </script>
</head>

<!-- END HEAD -->

<body class="page-header-fixed page-sidebar-reversed ink-modern">
    <!-- <body class="page-header-fixed page-sidebar-closed-hide-logo page-content-white page-sidebar-reversed"> -->
    <div class="loader"></div>
    <div class="bike_loader1">
        <!-- <h1>Updating.. <br>Don’t Cancel.. Or Page Refresh <br> Untill Prosess Not Done ..  </h1> -->
        <h1>
            מעדכן...
            <br>
            נא לא לצאת, או לרענן את הדף עד הסיום
        </h1>
    </div>
    <div class="pdf_generate">
        <h1>Generating PDF.. </h1>
    </div>
    <div class="ajaxloader"></div>
    <div class="page-wrapper">
        <!-- BEGIN HEADER -->
        <div class="page-header navbar navbar-fixed-top">
            <!-- BEGIN HEADER INNER -->
            <div class="page-header-inner ">
                <!-- BEGIN LOGO -->
                <div class="page-logo">
                    <a href="<?= base_url(); ?>">
                        <p alt="logo" class="logo-default ink-brand-name">
                            <?php echo $this->settings['name']; ?>
                        </p>
                    </a>
                    <!-- <img src="<?php echo $main_url; ?>layouts/layout/img/logo.png" alt="logo" class="logo-default" /> </a> -->
                    <div class="menu-toggler sidebar-toggler">
                        <span></span>
                    </div>
                </div>
                <!-- <div class="page-logo">
                        <a href="<?= base_url(); ?>" class="logo-default" style="margin: 12px 0 0; color: #fff; font-weight: bold; font-size: larger; text-decoration: none;">
                            <?= $this->settings['name']; ?>
                        </a>
                    </div> -->
                <!-- END LOGO -->
                <!-- BEGIN RESPONSIVE MENU TOGGLER -->
                <a href="javascript:;" class="menu-toggler responsive-toggler" data-toggle="collapse"
                    data-target=".navbar-collapse">
                    <span></span>
                </a>
                <!-- END RESPONSIVE MENU TOGGLER -->
                <!-- BEGIN TOP NAVIGATION MENU -->
                <div class="top-menu">
                    <ul class="nav navbar-nav">
                        <!-- BEGIN USER LOGIN DROPDOWN -->
                        <!-- DOC: Apply "dropdown-dark" class after below "dropdown-extended" to change the dropdown styte -->
                        <li class="dropdown dropdown-user">
                            <a href="javascript:void(0);" class="dropdown-toggle" data-toggle="dropdown"
                                data-hover="dropdown" data-close-others="true" aria-expanded="false">
                                <img alt="" class="img-circle img-circle_avatar_profile" src="<?php echo base_url("assets/profile_img/");
                                                                                                $res = $this->session->userdata("profile_image");
                                                                                                if (isset($res) && $res != "") {
                                                                                                    echo $this->session->userdata("profile_image");
                                                                                                } else {
                                                                                                    echo "assets/profile_img/default.png";
                                                                                                }
                                                                                                ?>">

                                <span class="username username-hide-on-mobile">
                                    <?php echo $this->session->userdata("profile_name"); ?> </span>
                                <i class="fa fa-angle-down"></i>
                            </a>
                            <ul class="dropdown-menu dropdown-menu-default">

                                <li class="text-align">
                                    <a href="<?= base_url("ChangePassword") ?>">
                                        <i
                                            class="icon-calendar"></i><?= $this->settings['hebrew_text']['change_password']; ?></a>
                                </li>
                                <li class="divider"> </li>
                                <li class="text-align">
                                    <a href="<?= base_url("logout") ?>">
                                        <i class="icon-key"></i> <?= $this->settings['hebrew_text']['logout']; ?> </a>
                                </li>
                            </ul>
                        </li>
                        <!-- END USER LOGIN DROPDOWN -->
                        <!-- BEGIN QUICK SIDEBAR TOGGLER -->
                        <!-- DOC: Apply "dropdown-dark" class after below "dropdown-extended" to change the dropdown styte -->
                        <!-- END QUICK SIDEBAR TOGGLER -->
                    </ul>
                </div>
                <!-- END TOP NAVIGATION MENU -->
            </div>
            <!-- END HEADER INNER -->
        </div>
        <!-- END HEADER -->
        <!-- BEGIN HEADER & CONTENT DIVIDER -->
        <?php
        $per_arr = array();
        $per_arr = $this->session->userdata("access");

        ?>
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
                <div class="page-content" style="min-height: 425px;">
                    <?php
                    if (!isset($Breadcrumb)) {
                    ?>
                    <h1 class="page-title"> <?php if (!empty($page_heading)) {
                                                    echo $page_heading;
                                                } ?>
                        <small><?php if (!empty($page_sub_heading)) {
                                        echo $page_sub_heading;
                                    } ?></small>
                    </h1>
                    <!-- END PAGE TITLE-->
                    <!-- BEGIN PAGE BAR -->
                    <div class="page-bar">
                        <ul class="page-breadcrumb pull-right">
                            <?php if (!empty($breadcrumb_home_logo)) {
                                    echo $breadcrumb_home_logo;
                                } ?>
                            <?php if (!empty($arr_breadcrumb)) {
                                    foreach ($arr_breadcrumb as $key => $value) { ?>
                            <li>
                                <a href="<?php echo $value; ?>"><?php echo $key; ?></a>
                                <i class="fa fa-angle-left"></i>
                            </li>
                            <?php }
                                } ?>

                            <li>
                                <span><?php if (!empty($page_heading)) {
                                                echo $page_heading;
                                            } ?></span>
                            </li>
                        </ul>
                        <div class="page-toolbar" style="float: left;">

                            <a class="btn <?= $this->settings['danger_color']; ?>" href="<?php if (!empty($back_button)) {
                                                                                                    echo $back_button;
                                                                                                } else {
                                                                                                    echo base_url();
                                                                                                } ?>" title="back">
                                <?= $this->settings['hebrew_text']['back']; ?>
                            </a>
                            <div style="display: none;" class="btn-group pull-right">
                                <button type="button" class="btn btn-fit-height default dropdown-toggle"
                                    data-toggle="dropdown"> Actions
                                    <i class="fa fa-angle-down"></i>
                                </button>
                                <ul class="dropdown-menu" role="menu">
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
                    if ($this->session->flashdata('message')) {
                        echo "<div class='form-group'><div class='col-md-12'><div class='alert alert-info'>";
                        echo $this->session->flashdata('message');;
                        echo "</div></div></div>";
                    }
                    if ($this->session->flashdata('Error')) {
                        echo "<div class='form-group'><div class='col-md-12'><div class='alert alert-danger'>";
                        echo $this->session->flashdata('Error');;
                        echo "</div></div></div>";
                    }
                    if (!empty($error)) {
                        echo '<div class="form-group">
                        <div class="col-md-12">
                        <div class="alert alert-danger">';
                        echo $error;
                        echo "</div></div></div>";
                    }
                    ?>
                    <?php echo validation_errors('<div class="alert alert-danger">', '</div>'); ?>


                    <?php if ($this->session->flashdata('msg')) : ?>
                    <div class="alert alert-success">
                        <strong><?php echo $this->session->flashdata('msg'); ?></strong>
                    </div>
                    <?php endif; ?>
                    <?php echo $data; ?>
                </div>
                <!-- END CONTENT BODY -->
            </div>
            <!-- END CONTENT -->
            <!-- BEGIN QUICK SIDEBAR -->
            <a href="javascript:;" class="page-quick-sidebar-toggler">
                <i class="icon-login"></i>
            </a>
            <div class="page-quick-sidebar-wrapper" data-close-on-body-click="false">
                <div class="page-quick-sidebar">
                    <ul class="nav nav-tabs">
                        <li class="active">
                            <a href="javascript:;" data-target="#quick_sidebar_tab_1" data-toggle="tab"> Users
                                <span class="badge badge-danger">2</span>
                            </a>
                        </li>
                        <li>
                            <a href="javascript:;" data-target="#quick_sidebar_tab_2" data-toggle="tab"> Alerts
                                <span class="badge badge-success">7</span>
                            </a>
                        </li>
                        <li class="dropdown">
                            <a href="javascript:;" class="dropdown-toggle" data-toggle="dropdown"> More
                                <i class="fa fa-angle-down"></i>
                            </a>
                            <ul class="dropdown-menu pull-right">
                                <li>
                                    <a href="javascript:;" data-target="#quick_sidebar_tab_3" data-toggle="tab">
                                        <i class="icon-bell"></i> Alerts </a>
                                </li>
                                <li>
                                    <a href="javascript:;" data-target="#quick_sidebar_tab_3" data-toggle="tab">
                                        <i class="icon-info"></i> Notifications </a>
                                </li>
                                <li>
                                    <a href="javascript:;" data-target="#quick_sidebar_tab_3" data-toggle="tab">
                                        <i class="icon-speech"></i> Activities </a>
                                </li>
                                <li class="divider"></li>
                                <li>
                                    <a href="javascript:;" data-target="#quick_sidebar_tab_3" data-toggle="tab">
                                        <i class="icon-settings"></i> Settings </a>
                                </li>
                            </ul>
                        </li>
                    </ul>
                </div>
            </div>
            <!-- END QUICK SIDEBAR -->
        </div>
        <!-- END CONTAINER -->
        <!-- BEGIN FOOTER -->
        <div class="page-footer">
            <div class="page-footer-inner pull-right">
                <?php echo $this->settings['footer_text']; ?>
                <!-- &nbsp;|&nbsp; <a target="_blank" href="http://www.smart-webtech.com/">Smart-Webtech</a> -->
            </div>
            <div class="scroll-to-top">
                <i class="icon-arrow-up"></i>
            </div>
        </div>
        <!-- END FOOTER -->
    </div>
    <!--[if lt IE 9]>
<script src="<?= $main_url; ?>assets/global/plugins/respond.min.js"></script>
<script src="<?= $main_url; ?>assets/global/plugins/excanvas.min.js"></script> 
<script src="<?= $main_url; ?>assets/global/plugins/ie8.fix.min.js"></script> 
<![endif]-->
    <?php foreach ($include_js as $key => $value) {   ?>
    <!-- <link href="<?= MAIN_URL . $value; ?>" rel="stylesheet" type="text/css" content="THIS JS COME FROM CORE/MY_CONTROLLER <?= $key + 1; ?> " />     -->
    <script src="<?= MAIN_URL . $value; ?>" type="text/javascript" content="MY_CONTROLLER <?= $key + 1; ?> "></script>
    <?php
    }
    ?>
    <!-- BEGIN CORE PLUGINS -->
    <!-- <script src="<?= $main_url; ?>assets/global/plugins/jquery.min.js" type="text/javascript"></script> -->
    <!-- <script src="<?= $main_url; ?>assets/global/plugins/bootstrap/js/bootstrap.min.js" type="text/javascript"></script> -->
    <!-- <script src="<?= $main_url; ?>assets/global/plugins/js.cookie.min.js" type="text/javascript"></script> -->
    <!-- <script src="<?= $main_url; ?>assets/global/plugins/jquery-slimscroll/jquery.slimscroll.min.js" type="text/javascript"></script> -->
    <!-- <script src="<?= $main_url; ?>assets/global/plugins/jquery.blockui.min.js" type="text/javascript"></script> -->
    <!-- <script src="<?= $main_url; ?>assets/global/plugins/bootstrap-switch/js/bootstrap-switch.min.js" type="text/javascript"></script> -->
    <!-- END CORE PLUGINS -->
    <!-- BEGIN THEME GLOBAL SCRIPTS -->
    <!-- <script src="<?= $main_url; ?>assets/global/scripts/app.min.js" type="text/javascript"></script> -->
    <!-- END THEME GLOBAL SCRIPTS -->
    <!-- BEGIN THEME LAYOUT SCRIPTS -->
    <!-- <script src="<?= $main_url; ?>assets/layouts/layout/scripts/layout.min.js" type="text/javascript"></script> -->
    <!-- <script src="<?= $main_url; ?>assets/layouts/layout/scripts/demo.min.js" type="text/javascript"></script> -->
    <!-- <script src="<?= $main_url; ?>assets/layouts/global/scripts/quick-sidebar.min.js" type="text/javascript"></script> -->
    <script src="<?= $main_url; ?>assets/layouts/global/scripts/quick-nav.min.js" type="text/javascript"></script>
    <!-- <script src="<?= $main_url; ?>assets/global/plugins/jquery-ui/jquery-ui.min.js" type="text/javascript"></script> -->
    <script src="<?= base_url(); ?>assets/bootbox.all.min.js"></script>
    <!-- <script src="<?= base_url(); ?>assets/global/plugins/bootstrap-timepicker/js/bootstrap-timepicker.min.js"></script> -->
    <!-- <script src="<?= base_url(); ?>assets/global/plugins/bootstrap-multiselect/js/    bootstrap-multiselect.js"></script> -->

    <!-- Bootstrap Date picker -->
    <!-- <script src="<?= $main_url ?>vendor/moment/moment.js"></script> -->
    <!-- <script src="<?= base_url(); ?>assets/global/plugins/bootstrap-datepicker/js/bootstrap-datepicker.min.js"> -->
    </script>


    <script src="<?= base_url(); ?>assets/global/plugins/fuelux/js/spinner.min.js" type="text/javascript"></script>
    <script src="<?= base_url(); ?>assets/global/plugins/bootstrap-touchspin/bootstrap.touchspin.js"
        type="text/javascript"></script>
    <script src="<?= base_url(); ?>assets/pages/scripts/components-bootstrap-touchspin.min.js" type="text/javascript">
    </script>


    <script src="<?= base_url(); ?>/assets/jquery.quicksearch.js" type="text/javascript"></script>

    <script src="<?= base_url(); ?>/assets/global/plugins/bootstrap-select/js/bootstrap-select.min.js"
        type="text/javascript"></script>
    <script src="<?= base_url(); ?>/assets/global/plugins/jquery-multi-select/js/jquery.multi-select.js"
        type="text/javascript"></script>
    <script src="<?= base_url(); ?>/assets/pages/scripts/components-multi-select.min.js" type="text/javascript">
    </script>


    <script src="<?= base_url(); ?>/assets/ui-main.js" type="text/javascript"></script>
    <script src="<?= base_url(); ?>/assets/ui-multiple.js" type="text/javascript"></script>
    <script src="<?= base_url(); ?>/assets/ui-single.js" type="text/javascript"></script>

    <!-- <script src="<?= base_url(); ?>assets/global/plugins/bootstrap-datetimepicker/js/bootstrap-datetimepicker.min.js"   type="text/javascript"></script> -->
    <script src="<?= base_url(); ?>assets/jquery.dm-uploader.js" type="text/javascript"></script>

    <script src="<?= base_url(); ?>assets/global/plugins/ckeditor/ckeditor.js"></script>
    <script src="<?= base_url(); ?>assets/global/plugins/ckeditor/lang/he.js" type="text/javascript"></script>

    <script
        src="<?= base_url(); ?>assets/global/plugins/bootstrap-editable/bootstrap-editable/js/bootstrap-editable.min.js"
        type="text/javascript"></script>
    <script src="<?= base_url(); ?>assets/global/global/plugins/bootstrap-colorpicker/js/bootstrap-colorpicker.js"
        type="text/javascript"></script>


    <script src="https://cdn.datatables.net/buttons/1.6.4/js/dataTables.buttons.min.js" type="text/javascript"></script>
    <script src="https://cdn.datatables.net/buttons/1.6.4/js/buttons.flash.min.js" type="text/javascript"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jszip/3.1.3/jszip.min.js" type="text/javascript"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/pdfmake/0.1.53/pdfmake.min.js" type="text/javascript"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/pdfmake/0.1.53/vfs_fonts.js" type="text/javascript"></script>
    <script src="https://cdn.datatables.net/buttons/1.6.4/js/buttons.html5.min.js" type="text/javascript"></script>
    <script src="https://cdn.datatables.net/buttons/1.6.4/js/buttons.print.min.js" type="text/javascript"></script>
    <script src="<?= base_url("assets/global/scripts/jquery-file-upload.js") ?>" type="text/javascript" content=" ">
    </script>
    <!-- <script src="https://maps.googleapis.com/maps/api/js?key=AIzaSyBr1P74H10JCffjxwqSPdeExVTHOw0qCoQ&libraries=places&v=weekly" defer></script> -->

    <!-- <script src="<?= base_url(); ?>assets/global/plugins/crop_image/js/cropper.js"></script> -->
    <!-- END THEME LAYOUT SCRIPTS -->
    <script>
    $(document).ready(function() {

        bootbox.setDefaults({
            locale: "he",
        });
        var ready = false;
        $(document).ready(function() {
            $(".loader").fadeOut("slow");
        });
        var BASE_URL = "<?php echo base_url(); ?>";

        if ($("[data-toggle='switch']").length != 0) {
            $("[data-toggle='switch']").bootstrapSwitch();
        }




    })

    $('body').tooltip({
        selector: '[data-toggle="tooltip"]'
    });

    <?php if (!empty($extra_js)) {
            echo $extra_js;
        } ?>


    $('body').tooltip({
        selector: '[data-toggle="tooltip"]'
    });


    function defaultConfig_ckeditor_he() {

        var config = {
            height: 250,
            extraPlugins: 'colorbutton,colordialog,tabletools',
            allowedContent: true,
            extraAllowedContent: "*",

            /*fontFamily: {
                options: [
                    'default',
                    'Ubuntu, Arial, sans-serif',
                    'Ubuntu Mono, Courier New, Courier, monospace'
                ]
            },*/

            toolbar: [{
                    name: 'clipboard',
                    items: ['Cut', 'Copy', 'Paste', 'PasteText', '-', 'Undo', 'Redo']
                }, //'PasteFromWord'
                {
                    name: 'editing',
                    items: ['Find', 'Replace']
                },

                {
                    name: 'forms',
                    items: []
                },

                {
                    name: 'links',
                    items: ['Link', 'Unlink']
                }, //, 'Anchor' 

                {
                    name: 'tools',
                    items: ['Maximize']
                },
                {
                    name: 'document',
                    items: ['Source']
                },
                //{ name: 'about', items: [ 'About' ] },
                '/',
                {
                    name: 'basicstyles',
                    items: ['Bold', 'Italic', 'Underline', 'Strike']
                },
                {
                    name: 'paragraph',
                    items: ['NumberedList', 'BulletedList', '-', 'JustifyLeft', 'JustifyCenter', 'JustifyRight',
                        'JustifyBlock', '-', 'BidiLtr', 'BidiRtl'
                    ]
                },
                //'Outdent', 'Indent',

                {
                    name: 'insert',
                    items: ['Table', 'HorizontalRule']
                }, //'Image',
                {
                    name: 'colors',
                    items: ['TextColor']
                }, //'BGColor'
                '/',
                {
                    name: 'styles',
                    items: ['Format', 'FontSize']
                } //'Styles'
            ]
        };
        //config.stylesSet = 'my_styles';

        config.format_p = {
            element: "p",
            name: "Normal" /*, styles:{ 'color': 'red'}*/
        };

       /* config.coreStyles_bold = {
            element: 'b',
            overrides: 'strong'
        };*/

        var tagForH = "span";

       /* config.format_h1 = {
            element: tagForH,
            name: "Headline 1",
            styles: {
                'font-size': '32px'
            },
            attributes: {
                'class': 'mbc-h1'
            }
        };
        config.format_h2 = {
            element: tagForH,
            name: "Headline 2",
            styles: {
                'font-size': '24px'
            },
            attributes: {
                'class': 'mbc-h2'
            }
        };
        config.format_h3 = {
            element: tagForH,
            name: "Headline 3",
            styles: {
                'font-size': '18.72px'
            },
            attributes: {
                'class': 'mbc-h3'
            }
        };
        config.format_h4 = {
            element: tagForH,
            name: "Headline 4",
            styles: {
                'font-size': '16px'
            },
            attributes: {
                'class': 'mbc-h4'
            }
        };
        config.format_h5 = {
            element: tagForH,
            name: "Headline 5",
            styles: {
                'font-size': '13.28px'
            },
            attributes: {
                'class': 'mbc-h5'
            }
        };
        config.format_h6 = {
            element: tagForH,
            name: "Headline 6<div>Hi</div>",
            styles: {
                'font-size': '10.72px'
            },
            attributes: {
                'class': 'mbc-h6'
            }
        };*/

        //config.format_tags = 'p;h1;h2;h3;h4;h5;h6;address;div';

        //config.contentsCss = "<?= base_url('../assets/mobile.css') ?>";
        //CKEDITOR.addCss( '.cke_editable h1,.cke_editable h2,.cke_editable h3 { border-bottom: 1px dotted red }' );

        config.extraPlugins = 'language,ckeditor-gwf-plugin,font,colorbutton,justify,colordialog';
        config.contentsLangDirection = 'rtl';
        config.defaultLanguage = 'he';
        config.language = 'he';
        //config.font_names="GoogleWebFonts";

        //var myFonts = get_google_myFonts();

        //serif;sans serif;monospace;cursive;fantasy;Courier New;



        /*config.font_names= "" + init_font_names;
        for(var i = 0; i<myFonts.length; i++){
            config.font_names = config.font_names+';'+myFonts[i];
        }*/


        //'http://fonts.googleapis.com/css?family='+myFonts.join("|") 



        config.fontSize_defaultLabel = '14px';

       /* config.coreStyles_bold = {
            element: 'span',
            attributes: {
                'class': 'text-bold'
            }
        };*/


        return config;
    }

    function defaultConfig_ckeditor_en() {

        var config = {
            height: 250,
            extraPlugins: 'colorbutton,colordialog,tabletools',
            allowedContent: true,
            extraAllowedContent: "*",

            /*fontFamily: {
                options: [
                    'default',
                    'Ubuntu, Arial, sans-serif',
                    'Ubuntu Mono, Courier New, Courier, monospace'
                ]
            },*/

            toolbar: [{
                    name: 'clipboard',
                    items: ['Cut', 'Copy', 'Paste', 'PasteText', '-', 'Undo', 'Redo']
                }, //'PasteFromWord'
                {
                    name: 'editing',
                    items: ['Find', 'Replace']
                },

                {
                    name: 'forms',
                    items: []
                },

                {
                    name: 'links',
                    items: ['Link', 'Unlink']
                }, //, 'Anchor' 

                {
                    name: 'tools',
                    items: ['Maximize']
                },
                {
                    name: 'document',
                    items: ['Source']
                },
                //{ name: 'about', items: [ 'About' ] },
                '/',
                {
                    name: 'basicstyles',
                    items: ['Bold', 'Italic', 'Underline', 'Strike']
                },
                {
                    name: 'paragraph',
                    items: ['NumberedList', 'BulletedList', '-', 'JustifyLeft', 'JustifyCenter', 'JustifyRight',
                        'JustifyBlock', '-', 'BidiLtr', 'BidiRtl'
                    ]
                },
                //'Outdent', 'Indent',

                {
                    name: 'insert',
                    items: ['Table', 'HorizontalRule']
                }, //'Image',
                {
                    name: 'colors',
                    items: ['TextColor']
                }, //'BGColor'
                '/',
                {
                    name: 'styles',
                    items: ['Format', 'Font', 'FontSize']
                } //'Styles'
            ]
        };

        //config.stylesSet = 'my_styles';
        //config.stylesSet = 'my_styles';


        config.format_p = {
            element: "p",
            name: "Normal" /*, styles:{ 'color': 'red'}*/
        };

        config.coreStyles_bold = {
            element: 'b',
            overrides: 'strong'
        };

        var tagForH = "span";

        config.format_h1 = {
            element: tagForH,
            name: "Headline 1",
            styles: {
                'font-size': '32px'
            },
            attributes: {
                'class': 'mbc-h1'
            }
        };
        config.format_h2 = {
            element: tagForH,
            name: "Headline 2",
            styles: {
                'font-size': '24px'
            },
            attributes: {
                'class': 'mbc-h2'
            }
        };
        config.format_h3 = {
            element: tagForH,
            name: "Headline 3",
            styles: {
                'font-size': '18.72px'
            },
            attributes: {
                'class': 'mbc-h3'
            }
        };
        config.format_h4 = {
            element: tagForH,
            name: "Headline 4",
            styles: {
                'font-size': '16px'
            },
            attributes: {
                'class': 'mbc-h4'
            }
        };
        config.format_h5 = {
            element: tagForH,
            name: "Headline 5",
            styles: {
                'font-size': '13.28px'
            },
            attributes: {
                'class': 'mbc-h5'
            }
        };
        config.format_h6 = {
            element: tagForH,
            name: "Headline 6<div>Hi</div>",
            styles: {
                'font-size': '10.72px'
            },
            attributes: {
                'class': 'mbc-h6'
            }
        };

        //config.format_tags = 'p;h1;h2;h3;h4;h5;h6;address;div';

        //config.contentsCss = "<?= base_url('../assets/mobile.css') ?>";
        //CKEDITOR.addCss( '.cke_editable h1,.cke_editable h2,.cke_editable h3 { border-bottom: 1px dotted red }' );

        config.extraPlugins = 'language,ckeditor-gwf-plugin,font,colorbutton,justify,colordialog'; //
        config.contentsLangDirection = 'rtl';
        //config.defaultLanguage = 'he';
        //config.language = 'he';
        //config.font_names="GoogleWebFonts";

        //var myFonts = get_google_myFonts();

        //serif;sans serif;monospace;cursive;fantasy;Courier New;

        config.font_names = init_font_names;

        /*config.font_names= "" + init_font_names;
        for(var i = 0; i<myFonts.length; i++){
            config.font_names = config.font_names+';'+myFonts[i];
        }*/




        //'http://fonts.googleapis.com/css?family='+myFonts.join("|")


        config.fontSize_defaultLabel = '14px';

        config.colorButton_enableAutomatic = false;


        // config.coreStyles_bold = {
        //     element: 'span',
        //     attributes: { 'class': 'text-bold' }
        // };


        return config;
    }

    function defaultConfig_ckeditor() {


        return defaultConfig_ckeditor_he();
    }

    function isNumberKey(event)
    {
        var chCode = ('charCode' in event) ? event.charCode : event.keyCode;
        //     alert(chCode);
        if(!( chCode < 46 || chCode > 57  ))
            return(true);
        else
            return(false);
    }
    </script>
    <!-- Google Code for Universal Analytics -->
</body>


</html>