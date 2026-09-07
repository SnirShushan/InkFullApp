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
            width: 160,
            height: 160,
          });
          initialAvatarURL = avatar.src;
          avatar.src = canvas.toDataURL();
          canvas.toBlob(function (blob) {
            var formData = new FormData();
            console.log(formData);
            var url_file_upload="<?=base_url('ajax_controller/upload_profile');?>";
            formData.append('avatar', blob, 'avatar.jpg');
            var are=$("#avatar").attr("src");
                var res = are.replace("data:image/png;base64,", "");
                var url_file_upload="<?=base_url('ajax_controller/upload_crop_file');?>";
                var action =$("input['action']").val();
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