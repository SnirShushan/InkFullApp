<div class="portlet light bordered">

  <div class="portlet-body form">



    <form method="POST" class="form-horizontal" id="form_city">
      <?php if (isset($msg_error)) { ?>
        <div class="alert alert-danger alert-dismissable">
          <button type="button" class="close" data-dismiss="alert" aria-hidden="true">×</button>
          <strong> <?= $msg_error ?> </strong>
        </div>
        <br>
      <?php } ?>

      <?php if (isset($msg_success)) { ?>
        <div class="alert alert-success alert-dismissable">
          <button type="button" class="close" data-dismiss="alert" aria-hidden="true">×</button>
          <strong> <?= $msg_success ?> </strong>
        </div>
        <br>
      <?php }

      ?>

      <?php

      foreach ($sliders as $key1 => $value) {

        $key = $value['id'];
      ?>




        <h3 class="form-section"> Slider <?php echo $key ?></h3>

        <div class="form-group">
          <div class="col-lg-5"></div>
          <div class="col-lg-5">
            <input class="form-control" type="text" id="heading1_<?php echo $key; ?>" name="heading1_<?php echo $key; ?>" placeholder="Heading 1" value="<?php echo $value['heading1']; ?>">
          </div>
          <label class="col-lg-2 control-label">Heading 1</label>
        </div>

        <div class="form-group">
          <div class="col-lg-5"></div>
          <div class="col-lg-5">
            <input class="form-control" type="text" id="heading2_<?php echo $key; ?>" name="heading2_<?php echo $key; ?>" placeholder="Heading 2" value="<?php echo $value['heading2']; ?>">
          </div>
          <label class="col-lg-2 control-label">Heading 2</label>
        </div>

        <div class="form-group">
          <div class="col-lg-5"></div>
          <div class="col-lg-5">
            <input class="form-control" type="text" id="heading3_<?php echo $key; ?>" name="heading3_<?php echo $key; ?>" placeholder="Heading 3" value="<?php echo $value['heading3']; ?>">
          </div>
          <label class="col-lg-2 control-label">Heading 3</label>
        </div>

        <div class="form-group">

          <div class="col-lg-5">
            <input class="form-control" type="text" id="btn_url_<?php echo $key; ?>" name="btn_url_<?php echo $key; ?>" placeholder="Button URL" value="<?php echo $value['btn_url']; ?>">
          </div>

          <label class="col-lg-2 control-label">Button URL</label>
          <div class="col-lg-3">
            <input class="form-control" type="text" id="btn_text_<?php echo $key; ?>" name="btn_text_<?php echo $key; ?>" placeholder="Button Text" value="<?php echo $value['btn_text']; ?>">
          </div>
          <label class="col-lg-2 control-label">Button Text</label>
        </div>


        <div class="form-group">
          <div class="col-lg-5">
          </div>
          <div class="col-lg-2">

          </div>
          <div class="col-lg-3">
            <label>
              <input type="checkbox" name="status_<?php echo $key; ?>" id="status_<?php echo $key; ?>" data-toggle="switch" <?php if ($value['status'] == "1") {
                                                                                                                              echo "checked";
                                                                                                                            } ?> data-on-color="primary" data-off-color="danger" data-on-text="<?= $this->settings['hebrew_text']['active']; ?>" data-off-text="<?= $this->settings['hebrew_text']['inactive']; ?>">
              <span class="toggle"></span>
            </label>
          </div>
          <label class="col-lg-2 control-label"><?= $this->settings['hebrew_text']['status']; ?></label>
        </div>

        <div class="form-group">

          <input type="hidden" name="back_image_<?php echo $key; ?>" id="back_image_<?php echo $key; ?>" value="<?= $value['back_image'] ?>" />
          <input type="hidden" name="back_image_small_<?php echo $key; ?>" id="back_image_small_<?php echo $key; ?>" value="<?= $value['back_image_small'] ?>" />
          <div class="col-lg-3">
            <div id="fileuploader_<?php echo $key; ?>" class="fileuploader">Upload</div>
            <b id="uploaded_tags_<?php echo $key; ?>" style="<?php if ($value['back_image'] == "") { ?>display:none;<?php } ?> "><button type="button" id="uploaded_tags_button_<?php echo $key; ?>" data-id="small_<?= $key ?>" class='btn btn-danger btn-sm remove_uploaded_image' style="<?php if ($value['back_image'] == "") {
                                                                                                                                                                                                                                                                                              echo "display:none;";
                                                                                                                                                                                                                                                                                            } ?>"><i class='fa fa-trash'></i></button>
              <div id="uploaded_tags_div_<?php echo $key; ?>" class="error1"><?php if ($value['back_image'] != "") {
                                                                                echo "<span class='label label-success'>" . $value['back_image'] . "</span><a href='" . config("site_url") . "/assets/images/slider/" . $value['back_image'] . "' target='_blank' data-filetype='' data-file='" . $value['back_image'] . "' class='btn btn-primary '><i class='fa fa-eye'></i></a>";
                                                                              } ?></div>
            </b>
            <p id='eventsmessage_<?php echo $key; ?>'></p>
          </div>
          <label class="col-lg-2 control-label">Desktop Image<br> Image size 1920 PX X 240 PX</label>


          <div class="col-lg-3">
            <div id="fileuploader_small_<?php echo $key; ?>" class="fileuploader">Upload</div>
            <b id="uploaded_tags_small_<?php echo $key; ?>" style="<?php if ($value['back_image_small'] == "") { ?>display:none;<?php } ?> "><button type="button" data-id="<?= $key ?>" id="uploaded_tags_button_small_<?php echo $key; ?>" class='btn btn-danger btn-sm remove_uploaded_image' style="<?php if ($value['back_image_small'] == "") {
                                                                                                                                                                                                                                                                                                          echo "display:none;";
                                                                                                                                                                                                                                                                                                        } ?>"><i class='fa fa-trash'></i></button>
              <div id="uploaded_tags_div_small_<?php echo $key; ?>" class="error1"><?php if ($value['back_image_small'] != "") {
                                                                                      echo "<span class='label label-success'>" . $value['back_image_small'] . "</span><a href='" . config("site_url") . "/assets/images/slider/" . $value['back_image_small'] . "' target='_blank' data-filetype='' data-file='" . $value['back_image_small'] . "' class='btn btn-primary '><i class='fa fa-eye'></i></a>";
                                                                                    } ?></div>
            </b>
            <p id='eventsmessage_small_<?php echo $key; ?>'></p>
          </div>
          <label class="col-lg-2 control-label">Mobile Image<br> Image size 742 PX X 269 PX</label>

          <label class="col-lg-2 control-label">Slider Image</label>
        </div>


        <div class="form-group">
          <div class="col-lg-5"></div>
          <div class="col-lg-5">
            <input class="form-control" type="text" id="alt_text_<?php echo $key; ?>" name="alt_text_<?php echo $key; ?>" placeholder="ALT Text" value="<?php echo $value['alt_text']; ?>">
          </div>
          <label class="col-lg-2 control-label">ALT Text</label>
        </div>


      <?php } ?>






      <div class="form-group">
        <div class="col-sm-10">
          <input class="btn <?= $this->settings['success_color']; ?>" type="submit" name="btn_update" value="<?= $this->settings['hebrew_text']['Update']; ?>" />
        </div>
      </div>
    </form>

  </div><!-- panel body -->
</div>

<script type="text/javascript">
  document.addEventListener('DOMContentLoaded', function() {
    //order_limit_time
    $('.order_limit_time').timepicker({
      minuteStep: 1,
      secondStep: 5,
      showInputs: false,
      showSeconds: true,
      showMeridian: false
    });

    $("#admin_email").tagsinput();
    $("#admin_phone").tagsinput();


    <?php

    $k_arr = [0 => '', 1 => "small_"];
    for ($i = 1; $i <= 4; $i++) {

      for ($k = 0; $k <= 1; $k++) {
        $key_1 = $k_arr[$k] . $i;
    ?>

        var uploadObj_<?= $key_1 ?> = $("#fileuploader_<?= $key_1 ?>").uploadFile({
          url: "<?= base_url('ajax_controller/') ?>upload_slider_image",
          fileName: "image_file",
          multiple: false,
          dragDrop: false,
          maxFileCount: 1,
          returnType: "json",
          onLoad: function(obj) {
            //console.log(obj.selector);
            //$("#eventsmessage").html($("#eventsmessage").html()+"<br/>Widget Loaded:");
          },
          onSubmit: function(files) {
            //$("#eventsmessage").html($("#eventsmessage").html()+"<br/>Submitting:"+JSON.stringify(files));
            //return false;

          },
          onSuccess: function(files, data, xhr, pd) {

            if (data.data.status == 1) {
              // $("#file_name").val(data.data.filename);
              // $("#file_type").val(data.data.file_type);
              $("#back_image_<?= $key_1 ?>").val(data.data.filename);
              $("#uploaded_tags_<?= $key_1 ?>").css("display", "block");
              $("#uploaded_tags_div_<?= $key_1 ?>").html("<span class='label label-success'> " + data.data.filename + "</span> <a href='" + data.data.full_path + "' target='_blank' data-filetype='" + data.data.file_type + "' data-file='" + data.data.filename + "' class='btn btn-primary btn_view_video'><i class='fa fa-eye'></i></a>");
              $("#uploaded_tags_button_<?= $key_1 ?>").css("display", "block");

            } else {
              $("#uploaded_tags_button_<?= $key_1 ?>").css("display", "none");
              $("#uploaded_tags_div_<?= $key_1 ?>").html("<span class='label label-danger'> " + jquery - upload - file - error + "</span>");
            }

            //console.log(pd);

            uploadObj_<?= $key_1 ?>.reset();



            //$("#eventsmessage").html($("#eventsmessage").html()+"<br/>Success for: "+JSON.stringify(data));

          },
          afterUploadAll: function(obj) {
            console.log("Test");
            console.log(obj.selector);
            //$("#eventsmessage").html($("#eventsmessage").html()+"<br/>All files are uploaded");
          },
          onError: function(files, status, errMsg, pd) {
            //$("#eventsmessage").html($("#eventsmessage").html()+"<br/>Error for: "+JSON.stringify(files));
          },
          onCancel: function(files, pd) {
            //$("#eventsmessage").html($("#eventsmessage").html()+"<br/>Canceled  files: "+JSON.stringify(files));
          }
        });

    <?php }
    } ?>



    $(document).on("click", ".remove_uploaded_image", function() {
      var id = $(this).data("id");
      $
      $("#back_image_" + id).val("");
      $("#uploaded_tags_" + id).css("display", "none");
      $("#uploaded_tags_button_" + id).css("display", "none");
      $("#uploaded_tags_div_" + id).html("");
      // uploadObj.reset();

    });



  });
</script>