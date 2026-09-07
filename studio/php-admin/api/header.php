<?php
session_start();
function get_header($param = [])
{
?>
<!doctype html>
<html lang="en">

<head>
    <!-- Required meta tags -->
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">

    <!-- Bootstrap CSS -->
    <link rel="stylesheet" href="assets/css/bootstrap.min.css">

    <link rel="stylesheet" href="assets/css/jquery.json-viewer.css">

    <link rel="stylesheet"
        href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap-datepicker/1.9.0/css/bootstrap-datepicker.min.css"
        integrity="sha512-mSYUmp1HYZDFaVKK//63EcZq4iFWFjxSL+Z3T/aCt4IO9Cejm03q3NKKYN6pFQzY0SBOr8h+eCIAZHPXcpZaNw=="
        crossorigin="anonymous" referrerpolicy="no-referrer" />

    <!-- Optional JavaScript -->
    <!-- jQuery first, then Popper.js, then Bootstrap JS -->
    <script src="assets/js/jquery-3.1.1.js"></script>
    <script src="assets/js/popper.min.js"></script>
    <script src="assets/js/bootstrap.min.js"></script>
    <script src="assets/js/jquery.json-viewer.js"></script>
    <script src="assets/js/bootbox.min.js"></script>
    <script src="assets/js/bootstrap-datetimepicker.min.js"></script>
    <script src="assets/js/jquery.blockUI.js"></script>

    <script src="https://cdnjs.cloudflare.com/ajax/libs/bootstrap-datepicker/1.9.0/js/bootstrap-datepicker.min.js"
        integrity="sha512-T/tUfKSV1bihCnd+MxKD0Hm1uBBroVYBOYSk1knyvQ9VyZJpc/ALb4P0r6ubwVPSGB2GvjeoMAJJImBG12TiaQ=="
        crossorigin="anonymous" referrerpolicy="no-referrer"></script>


    <link rel="stylesheet" href="https://use.fontawesome.com/releases/v5.7.0/css/all.css"
        integrity="sha384-lZN37f5QGtY3VHgisS14W3ExzMWZxybE1SJSEsQp9S+oqd12jhcu+A56Ebc1zFSJ" crossorigin="anonymous">

    <title><?= (isset($param['title'])) ? $param['title'] : "Log Viewer" ?></title>


    <style>
    .navbar-light .navbar-nav .nav-link {
        color: rgb(0 0 0 / 95%);
    }

    .bg-light {
        background-color: #ccad66 !important;
    }

    .btn-xs {
        padding: 1px 5px !important;
        font-size: 12px !important;
        line-height: 1.5 !important;
        border-radius: 3px !important;
    }

    .btn_open_log {
        float: right;
    }
    </style>
</head>


<body>
    <?php

        if (isset($_SESSION['email']) && !empty($_SESSION['email'])) {
            $menu_selected = "";
            if (isset($param['menu']))
                $menu_selected = $param['menu'];
        ?>
   
    <?php } ?>


    <?php } ?>