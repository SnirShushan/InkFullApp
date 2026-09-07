<style type="text/css">
  #image_crop{
    width: 100%;
  }
  .img-container img {
      max-width: 100%;
    }
</style>
<div class="row">
   <div class="col-md-12 ">
      <!-- BEGIN SAMPLE FORM PORTLET-->
      <div class="portlet light bordered">
         <!-- <div class="portlet-title">
            <div class="caption">
               <span class="caption-subject font-blue-sharp bold uppercase">System Setting</span>
            </div>
         </div> -->
         <div class="portlet-body form">
               <style type="text/css">
                  .well-primary {
                color: rgb(255, 255, 255);
                background-color: rgb(66, 139, 202);
                border-color: rgb(53, 126, 189);
                }
               </style>
                <div class="panel panel-default">
                    <div class="panel-heading">
                        <h4 class="panel-title">
                            <i class="fa fa-cog" aria-hidden="true"></i>

                            </span> Profile Settings
                        </h4>
                    </div>
                    <div id="collapseTwo" class="">
                        <div class="panel-body">
                            <div class="row">
                                <div class="col-md-4">
                                    <div class="form-group">
                                        <h4>Profile Image
                                        <?php
                                          if($profile->profile_image=="")
                                          {
                                            $profile->profile_image="assets/profile_img/default.png";
                                          }
                                          ?>
                                        </h4>
                                    </div>
                                </div>
                                <div class="col-md-8">
                                <label class="label" data-toggle="tooltip" title="Change your avatar">
                                  <img class="rounded" id="avatar" src="<?php echo base_url('assets/profile_img/').$profile->profile_image; ?>" alt="avatar">
                                  <input type="file" class="sr-only" id="input" name="image" accept="image/*">
                                  <input type="hidden" name="image_data" id="image_data_64">
                                  <input type="hidden" name="action" id="action" value="Image_change">
                                </label>
                                </div>
                               
                              <!-- div And model -->
                            </div>
                            <div class="row">
                              &nbsp;
                            </div>
                            <form method="post">
                            <div class="row">
                            <div class="col-md-4">
                                <div class="form-group">
                                    <h4>Profile Name</h4>
                                </div>
                            </div>
                            <div class="col-md-4">
                                <input type="text" class="form-control" name="profile_name" id="profile_name" placeholder="Profile Name" value="<?php if(!empty($profile->name)){ echo $profile->name; } ?>" />
                            </div>
                            </div>
                            <div class="row">
                                <div class="col-md-4">
                                    <div class="form-group">
                                    </div>
                                </div>
                                <div class="col-md-4">
                                    <input type="submit" value="Update" id="submit_logo_uplode1" class="btn <?=$this->settings['success_color'];?>" name="logo_save">
                                </div>
                            </div>
                            </form>
                  
                        </div>
                    </div>
                </div>
            
         </div>
         <!-- panel body -->
 
          
      </div>
      <!-- panel-->
      <!-- END SAMPLE FORM PORTLET-->
   </div>
</div>
  <div class="modal fade" id="modal" tabindex="-1" role="dialog" aria-labelledby="modalLabel" aria-hidden="true">
    <div class="modal-dialog" role="document">
      <div class="modal-content">
        <div class="modal-header">
          <h5 class="modal-title" id="modalLabel">Select Profanity</h5>
          <button type="button" class="close" data-dismiss="modal" aria-label="Close">
            <span aria-hidden="true">&times;</span>
          </button>
        </div>
        <div class="modal-body">
          <div class="img-container">
            <img id="image" src="">
          </div>
        </div>
        <div class="modal-footer">
          <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
          <button type="button" class="btn btn-primary" id="crop">Crop</button>
        </div>
      </div>
    </div>
  </div>
<!-- <script src="<?=base_url();?>assets/global/plugins/crop_image/js/upload_image.js"></script> -->
<script type="text/javascript">
   document.addEventListener('DOMContentLoaded', function()
   {
      $(document).on("click",".save_data",function()
     {
      var ele=$(this);
      ele.attr("disabled", 'disabled');
          $.ajax({
               url:"<?=base_url("ajax_controller/update_role");?>",
               type: "POST",
               data:$("#role_data").serialize(),
               dataType : "json",
               success:function(data){
                console.log(data);
                if(data.status=1)
                {
                  location.reload();
                }
             },
               error:function(data){ 
                   console.log(data);
               }
           });//ajax
      });
      ///
    });
  
</script>

<script>
    window.addEventListener('DOMContentLoaded', function () 
    {
      var avatar = document.getElementById('avatar');
      var image = document.getElementById('image');
      var input = document.getElementById('input');
      var $modal = $('#modal');
      var cropper;

      // $('[data-toggle="tooltip"]').tooltip();

      input.addEventListener('change', function (e) {
        var files = e.target.files;
        var done = function (url) {
          input.value = '';
          image.src = url;
          $modal.modal('show');
        };
        var reader;
        var file;
        var url;

        if (files && files.length > 0) {
          file = files[0];
          if (URL) {
            done(URL.createObjectURL(file));
          } else if (FileReader) {
            reader = new FileReader();
            reader.onload = function (e) {
              done(reader.result);
            };
            reader.readAsDataURL(file);
          }
        }
      });

      $modal.on('shown.bs.modal', function () {
        cropper = new Cropper(image, {
          aspectRatio: 1,
          viewMode: 3,
        });
      }).on('hidden.bs.modal', function () {
        cropper.destroy();
        cropper = null;
      });

      document.getElementById('crop').addEventListener('click', function () {
        var initialAvatarURL;
        var canvas;
        $modal.modal('hide');
        if (cropper) {
          canvas = cropper.getCroppedCanvas({
            width: 200,
            height: 200,
          });
          initialAvatarURL = avatar.src;
          avatar.src = canvas.toDataURL();
          canvas.toBlob(function (blob) {
            var formData = new FormData();
            var url_file_upload="<?=base_url('ajax_controller/upload_profile');?>";
            formData.append('avatar', blob, 'avatar.jpg');
            var are=$("#avatar").attr("src");
                var res = are.replace("data:image/png;base64,", "");
                var url_file_upload="<?=base_url('ajax_controller/upload_crop_file');?>";
                var action =$("#action").val();
                $.ajax({
                  url:url_file_upload,
                  type: "POST",
                  data: {image_data: res, action: action},
                  success:function(data){
                },
                error:function(data){ 
                  avatar.src = initialAvatarURL;
                  console.log("Upload error");
                }
              });//ajax
          });
        }
      });
    });
  </script>