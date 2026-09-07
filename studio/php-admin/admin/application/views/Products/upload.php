<div class="portlet light bordered">
	<div class="portlet-body form">
			<form method="POST"  enctype="multipart/form-data" class="form-horizontal" id="form_import" >
			
			
			<div class="form-group"  style="display: none;">
				<div class="col-lg-10">
					<input type="file" name="file_upload" id="file_upload" />
                </div>
				<label class="col-lg-2 control-label"><?=$this->settings['hebrew_text']['upload_product'];?></label>
			</div>
			
			
			
			<div class="form-group">
				<div class="col-sm-10" >
					<button class="btn <?=$this->settings['success_color'];?>" type="button" value="1" name="btn_upload" id="btn_upload"  ><?=$this->settings['hebrew_text']['upload_product'];?></button>
				</div>	
			</div>


			<div class="form-group">
				<div class="col-sm-10" >
					<p id="upload_error"></p>
				
				</div>	
			</div>
		</form>
	</div><!-- panel body -->
</div>

<script type="text/javascript">
document.addEventListener('DOMContentLoaded', function()
{

if (!("FormData" in window)) {
    // FormData is not supported; degrade gracefully/ alert the user as appropiate
    console.log("Form not supported");
}

	$('#btn_upload').on('click', function(e){ 
		//e.preventDefault();
		attachment_upload();
		/*var ele=$(this);
		ele.attr("disabled","disabled");
		var form = $('#form_import')[0];
		var fd = new FormData(form);
		 var file =document.getElementById("file_upload").files[0];
		 console.log(file);
		fd.append("file_upload", file);       
        fd.append("btn_upload", "1");
        $.ajax({
            url: '<?php echo base_url("Ajax_controller/upload_products_excel"); ?>',  
            type: 'post',
            data: fd,
            timeout: 1000000,
            success:function(data){
                console.log(data);
                var res=$.parseJSON(data);
                var cls="danger";
                if(res.status==1)
                {
                	cls="success";
                }
                $("#upload_error").html("<div class='alert alert-"+cls+"'>"+res.msg+"</div>");
                ele.removeAttr("disabled");

            },
            error:function(data){
            	console.log(data);
            },
            cache: false,
            contentType: false,
            processData: false
        });*/
    });






function attachment_upload(){
//  var file = document.getElementById("file_upload").files[0];
  

  
  var fd = new FormData();
//fd.append("file_upload", file);       
fd.append("btn_upload", "1");

  var ajax = new XMLHttpRequest();
  ajax.upload.addEventListener("progress", attachment_progressHandler, false);
  ajax.addEventListener("load", attachment_completeHandler, false);
  ajax.addEventListener("error", attachment_errorHandler, false);
  ajax.addEventListener("abort", attachment_abortHandler, false);
  ajax.open("POST", "<?php echo base_url("Ajax_controller/upload_product_csv_file"); ?>");
  //ajax.open("POST", "<?php echo base_url("Ajax_controller/upload_products_excel"); ?>");
  //ajax.open("POST", "<?php echo base_url("Ajax_controller/upload_product_csv_file"); ?>");
  //ajax.open("POST", "<?php echo base_url("Ajax_controller/upload_test_csv"); ?>");
  ajax.send(fd);

//e.preventDefault();
var ele=$("#btn_upload");
ele.attr("disabled","disabled");

  //$("#upload_attachment").attr("disabled","disabled");
  //$("#upload_attachment").html("Uploading.....");
  //$("#progressbar_attachment").css("display","block");
  
 
}
function attachment_progressHandler(event){
 // var percent = (event.loaded / event.total) * 100;
 // document.getElementById("progressBar_attachment").style.width = Math.round(percent)+"%";
   //$("#thank_image_show").html( Math.round(percent)+"% Completed..");
  
}
function attachment_completeHandler(event){
 // document.getElementById("progressBar_attachment").style.width = "0%";
  console.log(event.target.responseText);
  var res=$.parseJSON(event.target.responseText);
  var ele=$("#btn_upload");
                var cls="danger";
                if(res.status==1)
                {
                	cls="success";
                }
                $("#upload_error").html("<div class='alert alert-"+cls+"'>"+res.msg+"</div>");
                ele.removeAttr("disabled");

  //if(data.status==1){
  //  $("#attachment_name").val(data.msg);
  //  $("#logo_text").html(data.file_icon);
 // }
 // else 
  //  alert(data.msg); 
  
 // $("#thank_image_show").html(event.target.responseText);
 // $("#upload_attachment").removeAttr("disabled");
 // $("#upload_attachment").html("Upload");
 // $("#progressbar_attachment").css("display","none");
  
}
function attachment_errorHandler(event){
  alert("Error Occurs ! Please try again later");
}
function attachment_abortHandler(event){
  alert("Aborted ! Please try again later");
}




});//document load


</script>
