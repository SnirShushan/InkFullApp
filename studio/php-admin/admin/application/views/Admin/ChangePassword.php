<div class="portlet light bordered">
	<div class="portlet-title">
		<div class="caption">
			<i class="icon-key font-blue-sharp"></i>
			<span class="caption-subject font-blue-sharp bold uppercase"><?=$page_heading;?></span>
		</div>
	</div>
	
	<div class="portlet-body form">
		<form method="POST" class="form-horizontal" id = "frm_change_password" >
			<?php if( isset($msg_error) ) { ?>
				<div class="alert alert-danger alert-dismissable">
				    <button type="button" class="close" data-dismiss="alert" aria-hidden="true">×</button>
				    <strong> <?=$msg_error?> </strong>
				</div>
				<br>
			<?php } ?>

			<?php if( isset($msg_success) ) { ?>
				<div class="alert alert-success alert-dismissable">
				    <button type="button" class="close" data-dismiss="alert" aria-hidden="true">×</button>
				    <strong> <?=$msg_success?> </strong>
				</div>
				<br>
			<?php }
			//print_r($this->session->userdata());
			?>


			<div class="form-group">
				<div class="col-lg-10">
					<input class="form-control" type="password" name="old_password" placeholder="<?=$this->settings['hebrew_text']['current_password'];?>" id = "old_password" data-msg-required ="<?=$this->settings['hebrew_text']['current_password'];?>" >
                </div>
				<label class="col-lg-2 control-label"><?=$this->settings['hebrew_text']['current_password'];?></label>
			</div>
			
			<div class="form-group">
				<div class="col-lg-10">
					<input class="form-control" type="password" name="new_password" placeholder="<?=$this->settings['hebrew_text']['new_password'];?>" id="new_password" data-msg-required ="<?=$this->settings['hebrew_text']['new_password'];?>" >
                </div>
				<label class="col-lg-2 control-label"><?=$this->settings['hebrew_text']['new_password'];?></label>
			</div>
			
			<div class="form-group">
				<div class="col-lg-10">
					<input class="form-control" type="password" name="new_conf_password" placeholder="<?=$this->settings['hebrew_text']['confirm_password'];?>" id= "new_conf_password" data-msg-required ="<?=$this->settings['hebrew_text']['confirm_password'];?>" data-msg-equalTo = "Password does not match the new password" >
				</div>
				<label class="col-lg-2 control-label"><?=$this->settings['hebrew_text']['confirm_password'];?></label>
			</div>
			
			<div class="form-group">
				<div class="col-sm-10" >
					<input class="btn <?=$this->settings['success_color'];?>" type="submit" name="change_pwd" value="<?=$page_heading;?>" />
				</div>	
			</div>
	</div><!-- panel body -->
</div>

<script type="text/javascript">
document.addEventListener('DOMContentLoaded', function()
{

    $("#frm_change_password").validate({
        rules: {
            old_password: {
                required: true
            },
            new_password: {
                required: true
            },
            new_conf_password: {
                required: true,
                equalTo: "#new_password"
            }
        },
        submitHandler: function(form) {
            form.submit();
        }
    });

});
</script>
