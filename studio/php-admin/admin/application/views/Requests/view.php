<style type="text/css">
    .noborder{
        border:none !important;
    }
</style>

<div class="portlet light bordered">
    <div class="portlet-body form">
        <div class="portlet box blue">
            <div class="portlet-title">
                <div class="caption">
                    <i class="fa fa-list"></i><?= $this->settings['hebrew_text']['Request Details']; ?> </div>
                <div class="tools">
                </div>
            </div>
            <div class="portlet-body" >
                <div class="row" style="margin-bottom: 15px;">
                    <div class="col-md-8"><?=$row->name?></div>
                    <div class="col-md-1"> : </div>
                    <div class="col-md-3">Name</div>
                </div>
                <div class="row" style="margin-bottom: 15px;">
                    <div class="col-md-8"><?=($row->cust_phone!="")?$row->cnt_code.$row->cust_phone:""?></div>
                    <div class="col-md-1"> : </div>
                    <div class="col-md-3">Phone</div>
                </div>
                <div class="row" style="margin-bottom: 15px;">
                    <div class="col-md-8"><?=$row->email?></div>
                    <div class="col-md-1"> : </div>
                    <div class="col-md-3">Email</div>
                </div>
                <div class="row" style="margin-bottom: 15px;">
                    <div class="col-md-8"><?=$row->tattoo_size?></div>
                    <div class="col-md-1"> : </div>
                    <div class="col-md-3">Tattoo Size</div>
                </div>
                <div class="row" style="margin-bottom: 15px;">
                    <div class="col-md-8"><?=$row->styles?></div>
                    <div class="col-md-1"> : </div>
                    <div class="col-md-3">Styles</div>
                </div>
                <!-- <div class="row" style="margin-bottom: 15px;">
                    <div class="col-md-8">
                        <?php
                            if(isset($row->back_data_image) && $row->back_data_image != ""){
                                echo '<img src="'.$row->back_data_image.'" alt="">';
                            }
                        ?>
                    </div>
                    <div class="col-md-1"> : </div>
                    <div class="col-md-3">Back Data Image</div>
                </div>
                <div class="row" style="margin-bottom: 15px;">
                    <div class="col-md-8">
                        <?php
                            if(isset($row->front_data_image) && $row->front_data_image != ""){
                                echo '<img src="'.$row->front_data_image.'" alt="">';
                            }
                        ?>
                    </div>
                    <div class="col-md-1"> : </div>
                    <div class="col-md-3">Front Data Image</div>
                </div> -->
                <div class="row" style="margin-bottom: 15px;">
                    <div class="col-md-8"><?=$row->description?></div>
                    <div class="col-md-1"> : </div>
                    <div class="col-md-3">Description</div>
                </div>
                <div class="row" style="margin-bottom: 15px;">
                    <div class="col-md-8"><?=$row->artists_uid?></div>
                    <div class="col-md-1"> : </div>
                    <div class="col-md-3">Artists</div>
                </div>
                <div class="row" style="margin-bottom: 15px;">
                    <div class="col-md-8"><?=$row->business_id?></div>
                    <div class="col-md-1"> : </div>
                    <div class="col-md-3">Business</div>
                </div>
                <div class="row" style="margin-bottom: 15px;">
                    <div class="col-md-8"><?=$row->uid?></div>
                    <div class="col-md-1"> : </div>
                    <div class="col-md-3">User</div>
                </div>
                <div class="row" style="margin-bottom: 15px;">
                    <div class="col-md-8"><?=date('d/m/y',strtotime($row->date_added));?></div>
                    <div class="col-md-1"> : </div>
                    <div class="col-md-3">Date Added</div>
                </div>
            </div>
        </div><!-- END SAMPLE TABLE PORTLET-->
    </div><!-- portlet body -->
</div><!-- prtlet border -->

<div class="portlet light bordered">
    <div class="portlet-body form">
        <div class="portlet box blue">
            <div class="portlet-title">
                <div class="caption">
                    <i class="fa fa-list"></i><?= $this->settings['hebrew_text']['Request Images']; ?> </div>
                <div class="tools">
                </div>
            </div>
            <div class="portlet-body">
                <div class="row" style="margin-bottom: 15px;">
                    <div class="col-md-4">
                        <div>
                            <?php
                                if(isset($row->image3_name) && $row->image3_name != ""){
                                    echo '<img src="'.$row->image3_name.'" alt="" style="width:100%">';
                                }
                            ?>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div>
                            <?php
                                if(isset($row->image2_name) && $row->image2_name != ""){
                                    echo '<img src="'.$row->image2_name.'" alt="" style="width:100%">';
                                }
                            ?>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div>
                            <?php
                                if(isset($row->image1_name) && $row->image1_name != ""){
                                    echo '<img src="'.$row->image1_name.'" alt="" style="width:100%">';
                                }
                            ?>
                        </div>
                    </div>
                </div>
                <?php
                    if(isset($row->front_data_image) && $row->front_data_image != ""){
                ?>
                <div class="row" style="margin-bottom: 15px;">
                    <div class="col-md-8">
                        <?php
                            echo '<img src="'.base_url("../assets/uploads/body_images/".$row->front_data_image).'" alt="" style="width:100%">';
                        ?>
                    </div>                    
                    <div class="col-md-1"> : </div>
                    <div class="col-md-3">Front Data Image</div>
                </div>
                <?php
                    }
                    if(isset($row->back_data_image) && $row->back_data_image != ""){
                ?>
                <div class="row" style="margin-bottom: 15px;">
                    <div class="col-md-8">
                        <?php
                            echo '<img src="'.base_url("../assets/uploads/body_images/".$row->back_data_image).'" alt="" style="width:100%">';
                        ?>
                    </div>
                    <div class="col-md-1"> : </div>
                    <div class="col-md-3">Back Data Image</div>
                </div>
                <?php
                    }
                ?>
            </div>
        </div><!-- END SAMPLE TABLE PORTLET-->
    </div><!-- portlet body -->
</div><!-- prtlet border -->

<script type="text/javascript">
    document.addEventListener('DOMContentLoaded', function() {

    }); //document load
</script>