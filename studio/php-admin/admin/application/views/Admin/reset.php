<style type="text/css">
	.hide
	{
		display: none;
	}
	.error_list
	{
		border: solid red 1px !important;
	}
	.form-group
	{
		margin-top : 12px !important;
	}
	.font_liable
	{
		color: #fff;
	}
</style>         
<div class="page-lock">
            <div class="page-logo">
         	 
                <a class="brand" href="index.html">
                    <!-- <img src="<?=base_url();?> assets/pages/img/logo-big.png" alt="logo" />  -->
                    <img src="<?=base_url();?>assets/upload/<?=$this->settings['app_logo'];?>" alt="" width="100px" />
                </a>
            </div>
            <div class="page-body">
                <div class="lock-head"> Lock </div>
                <div class="lock-body">
                    <div class="lock-cont">
                        <div class="lock-item">
                            <div class="pull-left lock-avatar-block">
                                <img src="<?=base_url();?>assets/profile_img/default.png" class="lock-avatar"> </div>
                        </div>
                        <div class="lock-item lock-item-full">
                            <form class="lock-form pull-left" method="post" autocomplete="off">
                                <div class="form-group" id="email_content">
									<lebel class="font_liable">Email</lebel>
                                    <input class="form-control" type="email" placeholder="Enter Email Hear" name="email" /> 
                                </div>
                                <div class="form-group" id="key_content">
									<lebel class="font_liable">Key</lebel>
                                    <input class="form-control placeholder-no-fix" type="password" placeholder="Enter Key Hear" name="key" /> 
                                </div>
                                <div class="form-actions">
                                    <a href="javascript:void(0);" id="save_key" class="btn red uppercase">Save</a>
                                </div>
                                <div style="display: none;" id="new_content">
                                	<h4 class="font-red-thunderbird" id="divCheckPasswordMatch"></h4>
		                            <div class="form-group" id="123">
										<lebel class="font_liable">Password</lebel>
		                                <input class="form-control" type="password" placeholder="Enter New Password Hear" id="txtNewPassword" name="password" required> 
		                            </div>
		                            <div class="form-group" id="789">
										<lebel class="font_liable">Confirm Password</lebel>
		                                <input class="form-control" type="password" placeholder="confirm Password Hear" id="txtConfirmPassword" name="password1" required> 
		                            </div>
		                            <!-- txtConfirmPassword -->
		                            <div class="form-actions" id="submit_content">
		                            	<button type="submit" id="btn_submit" class="btn red uppercase">Login</button>
		                            </div>
                            	</div>
                            </form>
                        </div>
                    </div>
                </div>
                <div class="lock-bottom">
                    <span id="error_msg" class="font-red-thunderbird"></span>
	<?php $msg = get_flashdata('msg'); if($msg): ?>
    <div class="alert alert-success">
      <strong><?php echo $msg; ?></strong>
    </div>
    <?php endif; ?>
    <span id="error_msg" class="font-red-thunderbird">
    <?php $error = get_flashdata('error');  if($error!=''): ?>
      <?php echo $error; ?>
    <?php endif; ?>
    </span>

    <!-- error -->
                </div>
            </div>
            <!-- <div class="page-footer-custom"> 2014 &copy; Metronic. Admin Dashboard Template. </div> -->
            <div class="page-footer-custom"><?php echo $this->settings['footer_text']; ?></div>
        </div>
        <script type="text/javascript">
		   document.addEventListener('DOMContentLoaded', function()
		   {
		   	$("#btn_submit").attr("disabled", true); 
		   	$("#save_key").click(function(){
		   		var error=0;
			if($("input[name=email]").val()=="")
        	{
            	$("input[name=email]").addClass('error_list');
            	error=1;
        	}
        	if($("input[name=key]").val()=="")
        	{
            	$("input[name=key]").addClass('error_list');
            	error=1;
        	}
           if(error==1)
           {
              $("#error_msg").html("* fields are mandatory please enter a value");
              console.log("fields are mandatory please enter a value");
              return false;
           }
		   		$("#email_content").hide("slow");
		   		$("#key_content").hide("slow");
		   		$("#save_key").hide();
		   		$("#new_content").show("slow");
		   	});

		   	$(document).ready(function () {
			   $("#txtConfirmPassword").keyup(checkPasswordMatch);
			});

			function checkPasswordMatch() {
			var password = $("#txtNewPassword").val();
			var confirmPassword = $("#txtConfirmPassword").val();

			if (password != confirmPassword)
			    $("#divCheckPasswordMatch").html("Passwords do not match!");
			else
			{
				$("#divCheckPasswordMatch").html("");
			    $("#btn_submit").attr("disabled", false); 
			}




			// if (password != confirmPassword)
			//     $("#divCheckPasswordMatch").html("Passwords do not match!");
			// else
			//     $("#divCheckPasswordMatch").html("Passwords match.");
			}
		   });
		</script>
