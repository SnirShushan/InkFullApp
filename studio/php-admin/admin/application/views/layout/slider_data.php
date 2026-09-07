<?php
$per_arr = array();
$per_arr = $this->session->userdata("access");
if (isset($menu)) {
} else {
    $menu = "Bike";
}

//     print_r($this->settings['hebrew_text']['Manage Pricing']);
// die();

?>

<!-- BEGIN SIDEBAR -->

<div class="page-sidebar-wrapper">
    <!-- BEGIN SIDEBAR -->
    <!-- DOC: Set data-auto-scroll="false" to disable the sidebar from auto scrolling/focusing -->
    <!-- DOC: Change data-auto-speed="200" to adjust the sub menu slide up/down speed -->
    <div class="page-sidebar navbar-collapse collapse">
        <!-- BEGIN SIDEBAR MENU -->
        <!-- DOC: Apply "page-sidebar-menu-light" class right after "page-sidebar-menu" to enable light sidebar menu style(without borders) -->
        <!-- DOC: Apply "page-sidebar-menu-hover-submenu" class right after "page-sidebar-menu" to enable hoverable(hover vs accordion) sub menu mode -->
        <!-- DOC: Apply "page-sidebar-menu-closed" class right after "page-sidebar-menu" to collapse("page-sidebar-closed" class must be applied to the body element) the sidebar sub menu mode -->
        <!-- DOC: Set data-auto-scroll="false" to disable the sidebar from auto scrolling/focusing -->
        <!-- DOC: Set data-keep-expand="true" to keep the submenues expanded -->
        <!-- DOC: Set data-auto-speed="200" to adjust the sub menu slide up/down speed -->
        <ul class="page-sidebar-menu  page-header-fixed " data-keep-expanded="false" data-auto-scroll="true" data-slide-speed="200">
            <!-- DOC: To remove the sidebar toggler from the sidebar you just need to completely remove the below "sidebar-toggler-wrapper" LI element -->
            <!-- BEGIN SIDEBAR TOGGLER BUTTON -->
            <!-- <li class="sidebar-toggler-wrapper ">
                                <div class="sidebar-toggler">
                                    <span></span>
                                </div>
                            </li> -->
            <!-- END SIDEBAR TOGGLER BUTTON -->
            <!-- DOC: To remove the search box from the sidebar you just need to completely remove the below "sidebar-search-wrapper" LI element -->
            <li class="nav-item start ink-sidebar-brand">
                <a href="<?= base_url() ?>" class="nav-link ">
                    <span class="ink-wordmark">INK</span>
                </a>
            </li>

            <!-- <li class="nav-item <?php if ($menu == "Manage Customers") {
                                    echo "active";
                                } ?> ">
                <a href="<?= base_url("ManageCustomers") ?>" class="nav-link ">
                    <i class="fa fa-users "></i> <span class="title">
                        <?= $this->settings['hebrew_text']['Manage Customers']; ?>

                    </span>
                </a>
            </li> -->
            
            <li class="nav-item <?php if ($menu == "Regular Users") {
                                    echo "active";
                                } ?> ">
                <a href="<?= base_url("RegularUsers") ?>" class="nav-link ">
                    <span class="title">
                        <?= $this->settings['hebrew_text']['Regular Users']; ?>

                    </span>
                </a>
            </li>

            <li class="nav-item <?php if ($menu == "Business Users") {
                                    echo "active";
                                } ?> ">
                <a href="<?= base_url("BusinessUsers") ?>" class="nav-link ">
                    <span class="title">
                        <?= $this->settings['hebrew_text']['Business Users']; ?>

                    </span>
                </a>
            </li>

            <li class="nav-item <?php if ($menu == "Report on User") {
                                    echo "active";
                                } ?> ">
                <a href="<?= base_url("ReportOnUsers") ?>" class="nav-link ">
                    <span class="title">
                        <?= $this->settings['hebrew_text']['Report on User']; ?>

                    </span>
                </a>
            </li>

            <li class="nav-item <?php if ($menu == "Report on Post") {
                                    echo "active";
                                } ?> ">
                <a href="<?= base_url("ReportOnPosts") ?>" class="nav-link ">
                    <span class="title">
                        <?= $this->settings['hebrew_text']['Report on Post']; ?>

                    </span>
                </a>
            </li>

            <li class="nav-item <?php if ($menu == "Requests") {
                                    echo "active";
                                } ?> ">
                <a href="<?= base_url("Requests") ?>" class="nav-link ">
                    <span class="title">
                        <?= $this->settings['hebrew_text']['Requests']; ?>

                    </span>
                </a>
            </li>

            <!-- <li class="nav-item <?php if ($menu == "Products") {
                                    echo "active";
                                } ?> ">
                <a href="<?= base_url("Products") ?>" class="nav-link ">
                    <i class="fa fa-list "></i> <span class="title">
                        <?= $this->settings['hebrew_text']['Products']; ?>

                    </span>
                </a>
            </li> -->

            <li class="nav-item  <?php if ($menu == "Setting") {
                                        echo "active";
                                    } ?>">
                <a href="<?php echo base_url("Setting") ?>" class="nav-link ">
                    <span class="title">
                        <!-- Edit Profile -->
                        <?= $this->settings['hebrew_text']['settings']; ?>
                    </span>
                </a>
            </li>
            <?php if (!function_exists('is_local_admin_request') || !is_local_admin_request()) { ?>
            <li class="nav-item ink-nav-logout">
                <a href="<?php echo base_url("logout") ?>" class="nav-link ">
                    <span class="title">
                        <?= $this->settings['hebrew_text']['logout']; ?>
                    </span>
                </a>
            </li>
            <?php } ?>





        </ul>
        <!-- END SIDEBAR MENU -->
        <!-- END SIDEBAR MENU -->
    </div>
    <!-- END SIDEBAR -->
</div>
<!-- END SIDEBAR -->