<?php 
    $main_url=base_url("assets/");
//    echo $main_url;
 //   echo "<br>".config("base_url");
?>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="utf-8" />
        <title><?php echo $this->settings['name']; ?> - <?php if(($title)){ echo $title; } ?></title>
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta content="width=device-width, initial-scale=1" name="viewport" />
        <meta content="Preview page of Metronic Admin Theme #1 for " name="description" />
        <meta content="" name="author" />
        <link href="https://fonts.googleapis.com/css2?family=Heebo:wght@400;500;600;700;800&family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet" type="text/css" />
        <link href="<?php echo $main_url; ?>global/plugins/font-awesome/css/font-awesome.min.css" rel="stylesheet" type="text/css" />
        <link href="<?php echo $main_url; ?>global/plugins/simple-line-icons/simple-line-icons.min.css" rel="stylesheet" type="text/css" />
        <link href="<?php echo $main_url; ?>global/plugins/bootstrap/css/bootstrap.min.css" rel="stylesheet" type="text/css" />
        <link href="<?php echo $main_url; ?>global/plugins/bootstrap-switch/css/bootstrap-switch.min.css" rel="stylesheet" type="text/css" />
        <!-- END GLOBAL MANDATORY STYLES -->
        <!-- BEGIN PAGE LEVEL PLUGINS -->
        <link href="<?php echo $main_url; ?>global/plugins/select2/css/select2.min.css" rel="stylesheet" type="text/css" />
        <link href="<?php echo $main_url; ?>global/plugins/select2/css/select2-bootstrap.min.css" rel="stylesheet" type="text/css" />
        <!-- END PAGE LEVEL PLUGINS -->
        <!-- BEGIN THEME GLOBAL STYLES -->
        <link href="<?php echo $main_url; ?>global/css/components.min.css" rel="stylesheet" id="style_components" type="text/css" />
        <link href="<?php echo $main_url; ?>global/css/plugins.min.css" rel="stylesheet" type="text/css" />
        <!-- END THEME GLOBAL STYLES -->
        <!-- BEGIN PAGE LEVEL STYLES -->
        <link href="<?php echo $main_url; ?>pages/css/login-4.min.css" rel="stylesheet" type="text/css" />
        <link href="<?php echo $main_url; ?>layouts/layout/css/modern-admin.css?v=20260907" rel="stylesheet" type="text/css" />
        <!-- END PAGE LEVEL STYLES -->
        <!-- BEGIN THEME LAYOUT STYLES -->
        <!-- END THEME LAYOUT STYLES -->
        <link rel="shortcut icon" href="<?php echo $main_url; ?>upload/<?=$this->settings['favicon'];?>" /> </head>
    <!-- END HEAD -->

    <body class="login ink-modern">
        <!-- BEGIN LOGO -->
        <div class="logo">
                <span class="ink-wordmark">INK</span>
        </div>
        <!-- END LOGO -->
        <!-- BEGIN LOGIN -->
        <div class="content">
            <?php echo $data; ?>
        </div>
        <!-- END LOGIN -->
        <!-- BEGIN COPYRIGHT -->
        <div class="copyright"><?php echo $this->settings['footer_text']; ?></div>
        <!-- END COPYRIGHT -->
        <!--[if lt IE 9]>
<script src="<?php echo $main_url; ?>global/plugins/respond.min.js"></script>
<script src="<?php echo $main_url; ?>global/plugins/excanvas.min.js"></script> 
<script src="<?php echo $main_url; ?>global/plugins/ie8.fix.min.js"></script> 
<![endif]-->
        <!-- BEGIN CORE PLUGINS -->
        <script src="<?php echo $main_url; ?>global/plugins/jquery.min.js" type="text/javascript"></script>
        <script src="<?php echo $main_url; ?>global/plugins/bootstrap/js/bootstrap.min.js" type="text/javascript"></script>
        <script src="<?php echo $main_url; ?>global/plugins/js.cookie.min.js" type="text/javascript"></script>
        <script src="<?php echo $main_url; ?>global/plugins/jquery-slimscroll/jquery.slimscroll.min.js" type="text/javascript"></script>
        <script src="<?php echo $main_url; ?>global/plugins/jquery.blockui.min.js" type="text/javascript"></script>
        <script src="<?php echo $main_url; ?>global/plugins/bootstrap-switch/js/bootstrap-switch.min.js" type="text/javascript"></script>
        <!-- END CORE PLUGINS -->
        <!-- BEGIN PAGE LEVEL PLUGINS -->
        <script src="<?php echo $main_url; ?>global/plugins/jquery-validation/js/jquery.validate.min.js" type="text/javascript"></script>
        <script src="<?php echo $main_url; ?>global/plugins/jquery-validation/js/additional-methods.min.js" type="text/javascript"></script>
        <script src="<?php echo $main_url; ?>global/plugins/select2/js/select2.full.min.js" type="text/javascript"></script>
        <script src="<?php echo $main_url; ?>global/plugins/backstretch/jquery.backstretch.min.js" type="text/javascript"></script>
        <!-- END PAGE LEVEL PLUGINS -->
        <!-- BEGIN THEME GLOBAL SCRIPTS -->
        <script src="<?php echo $main_url; ?>global/scripts/app.min.js" type="text/javascript"></script>
        <!-- END THEME GLOBAL SCRIPTS -->
        <!-- BEGIN PAGE LEVEL SCRIPTS -->
        <script src="<?php echo $main_url; ?>pages/scripts/login-4.min.js" type="text/javascript"></script>
        <!-- END PAGE LEVEL SCRIPTS -->
        <!-- BEGIN THEME LAYOUT SCRIPTS -->
        <!-- END THEME LAYOUT SCRIPTS -->
        <script>
            $(document).ready(function()
            {
                if ($.backstretch && $('.backstretch').length) {
                    $('body').backstretch('destroy');
                    $('.backstretch').remove();
                }
                $('#clickmewow').click(function()
                {
                    $('#radio1003').attr('checked', 'checked');
                });
            })
        </script>
    <!-- Google Code for Universal Analytics -->
<script>
 </script>
<!-- End -->
</body>


</html>
