<?php
    $main_url=base_url("assets/");
?>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="utf-8" />
        <title><?php echo $this->settings['name']; ?> - <?php if(($title)){ echo $title; } ?></title>
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta content="width=device-width, initial-scale=1" name="viewport" />
        <link href="<?php echo $main_url; ?>global/plugins/font-awesome/css/font-awesome.min.css" rel="stylesheet" type="text/css" />
        <link href="<?php echo $main_url; ?>global/plugins/simple-line-icons/simple-line-icons.min.css" rel="stylesheet" type="text/css" />
        <link href="<?php echo $main_url; ?>global/plugins/bootstrap/css/bootstrap.min.css" rel="stylesheet" type="text/css" />
        <link href="<?php echo $main_url; ?>global/plugins/bootstrap-switch/css/bootstrap-switch.min.css" rel="stylesheet" type="text/css" />
        <!-- END GLOBAL MANDATORY STYLES -->
        <!-- BEGIN THEME GLOBAL STYLES -->
        <link href="<?php echo $main_url; ?>global/css/components.min.css" rel="stylesheet" id="style_components" type="text/css" />
        <link href="<?php echo $main_url; ?>global/css/plugins.min.css" rel="stylesheet" type="text/css" />
        <!-- END THEME GLOBAL STYLES -->
        <!-- BEGIN PAGE LEVEL STYLES -->
        <link href="<?php echo $main_url; ?>pages/css/lock.min.css" rel="stylesheet" type="text/css" />
        <link href="https://fonts.googleapis.com/css2?family=Heebo:wght@400;500;600;700;800&family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet" type="text/css" />
        <link href="<?php echo $main_url; ?>layouts/layout/css/modern-admin.css" rel="stylesheet" type="text/css" />
        <!-- END PAGE LEVEL STYLES -->
        <!-- BEGIN THEME LAYOUT STYLES -->
        <!-- END THEME LAYOUT STYLES -->
        <link rel="shortcut icon" href="<?php echo $main_url; ?>upload/<?=$this->settings['favicon'];?>" /> </head>
    <!-- END HEAD -->

    <body class="">
        <?php echo $data; ?>
        <!--[if lt IE 9]>
<script src="../global/plugins/respond.min.js"></script>
<script src="../global/plugins/excanvas.min.js"></script> 
<script src="../global/plugins/ie8.fix.min.js"></script> 
<![endif]-->
        <!-- BEGIN CORE PLUGINS -->
        <script src="<?php echo $main_url; ?>global/plugins/jquery.min.js" type="text/javascript"></script>
        <script src="<?php echo $main_url; ?>global/plugins/bootstrap/js/bootstrap.min.js" type="text/javascript"></script>
        <script src="<?php echo $main_url; ?>global/plugins/js.cookie.min.js" type="text/javascript"></script>
        <script src="<?php echo $main_url; ?>global/plugins/jquery-slimscroll/jquery.slimscroll.min.js" type="text/javascript"></script>
        <script src="<?php echo $main_url; ?>global/plugins/jquery.blockui.min.js" type="text/javascript"></script>
        <script src="<?php echo $main_url; ?>global/plugins/bootstrap-switch/js/bootstrap-switch.min.js" type="text/javascript"></script>
        <!-- END CORE PLUGINS -->
        <!-- BEGIN THEME GLOBAL SCRIPTS -->
        <script src="<?php echo $main_url; ?>global/scripts/app.min.js" type="text/javascript"></script>
        <!-- END THEME GLOBAL SCRIPTS -->
        <!-- BEGIN PAGE LEVEL SCRIPTS -->
        <script src="<?php echo $main_url; ?>pages/scripts/lock.min.js" type="text/javascript"></script>
        <!-- END PAGE LEVEL SCRIPTS -->
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