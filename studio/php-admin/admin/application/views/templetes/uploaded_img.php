<div class="col-md-2" id="tr_image_<?php echo $id; ?>">
	<img class="img-thumbnail" src="<?php echo $img; ?>" />
	<div style="margin-top: 10px;">
		<label class="control-label"><?php echo $alt_text; ?></label>
	</div>
	<div style="margin-top: 10px;" class="cc">
		<CENTER>
			<button class="btn btn-danger remove_img" type="button" data-toggle='tooltip' title='Delete' data-name="<?php echo $name; ?>" data-id="<?php echo $id; ?>" data-pid='<?php echo $pid; ?>'><i class="fa fa-trash"></i></button>
			<button class="btn btn-success edit_alt_text" type="button" data-toggle='tooltip' title='Edit' data-alt_text="<?php echo $alt_text; ?>" data-id="<?php echo $id; ?>" data-pid='<?php echo $pid; ?>'><i class="fa fa-pencil"></i></button>
		</CENTER>
	</div>
</div>