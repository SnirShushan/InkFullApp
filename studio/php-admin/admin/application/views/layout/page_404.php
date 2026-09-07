<?php
    $main_url=base_url("assets/");
?>
<!DOCTYPE html>
<html lang="en">
    <!--<![endif]-->
    <!-- BEGIN HEAD -->

    <head>
        <meta charset="utf-8" />
        <title>Metronic Admin Theme #1 | 404 Page Option 3</title>
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta content="width=device-width, initial-scale=1" name="viewport" />
        <meta content="Preview page of Metronic Admin Theme #1 for 404 page option 3" name="description" />
        <meta content="" name="author" />
        <!-- BEGIN GLOBAL MANDATORY STYLES -->
        <link href="https://fonts.googleapis.com/css2?family=Heebo:wght@400;500;600;700;800&family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet" type="text/css" />
        <link href="<?= $main_url?>global/plugins/font-awesome/css/font-awesome.min.css" rel="stylesheet" type="text/css" />
        <link href="<?= $main_url?>global/plugins/simple-line-icons/simple-line-icons.min.css" rel="stylesheet" type="text/css" />
        <link href="<?= $main_url?>global/plugins/bootstrap/css/bootstrap.min.css" rel="stylesheet" type="text/css" />
        <link href="<?= $main_url?>global/plugins/bootstrap-switch/css/bootstrap-switch.min.css" rel="stylesheet" type="text/css" />
        <!-- END GLOBAL MANDATORY STYLES -->
        <!-- BEGIN THEME GLOBAL STYLES -->
        <link href="<?= $main_url?>global/css/components.min.css" rel="stylesheet" id="style_components" type="text/css" />
        <link href="<?= $main_url?>global/css/plugins.min.css" rel="stylesheet" type="text/css" />
        <!-- END THEME GLOBAL STYLES -->
        <!-- BEGIN PAGE LEVEL STYLES -->
        <link href="<?= $main_url?>pages/css/error.min.css" rel="stylesheet" type="text/css" />
        <link href="<?= $main_url?>layouts/layout/css/modern-admin.css" rel="stylesheet" type="text/css" />
        <!-- END PAGE LEVEL STYLES -->
        <!-- BEGIN THEME LAYOUT STYLES -->
        <!-- END THEME LAYOUT STYLES -->
        <link rel="shortcut icon" href="favicon.ico" /> </head>
    <!-- END HEAD -->

    <body class=" page-404-3">
        <div class="page-inner">
            <img src="<?= $main_url?>pages/img/earth.jpg" class="img-responsive" alt=""> </div>
        <div class="container error-404">
            <h1>404</h1>
            <h2>Houston, we have a problem.</h2>
            <p> Actually, the page you are looking for does not exist. </p>
            <p>
                <a href="<?=base_url();?>" class="btn red btn-outline"> Return home </a>
                <br> </p>
        </div>
        <!--[if lt IE 9]>
<script src="<?= $main_url?>global/plugins/respond.min.js"></script>
<script src="<?= $main_url?>global/plugins/excanvas.min.js"></script> 
<script src="<?= $main_url?>global/plugins/ie8.fix.min.js"></script> 
<![endif]-->
        <!-- BEGIN CORE PLUGINS -->
        <script src="<?= $main_url?>global/plugins/jquery.min.js" type="text/javascript"></script>
        <script src="<?= $main_url?>global/plugins/bootstrap/js/bootstrap.min.js" type="text/javascript"></script>
        <script src="<?= $main_url?>global/plugins/js.cookie.min.js" type="text/javascript"></script>
        <script src="<?= $main_url?>global/plugins/jquery-slimscroll/jquery.slimscroll.min.js" type="text/javascript"></script>
        <script src="<?= $main_url?>global/plugins/jquery.blockui.min.js" type="text/javascript"></script>
        <script src="<?= $main_url?>global/plugins/bootstrap-switch/js/bootstrap-switch.min.js" type="text/javascript"></script>
        <!-- END CORE PLUGINS -->
        <!-- BEGIN THEME GLOBAL SCRIPTS -->
        <script src="<?= $main_url?>global/scripts/app.min.js" type="text/javascript"></script>
        <!-- END THEME GLOBAL SCRIPTS -->
        <!-- BEGIN THEME LAYOUT SCRIPTS -->
        <!-- END THEME LAYOUT SCRIPTS -->
        <script>
            $(document).ready(function()
            {
                $('#clickmewow').click(function()
                {
                    $('#radio1003').attr('checked', 'checked');
                });
            })
        </script>
    <!-- Google Code for Universal Analytics -->
</body>


</html>