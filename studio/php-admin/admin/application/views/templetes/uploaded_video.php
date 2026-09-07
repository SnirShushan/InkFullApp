<div class="col-md-2 tr_video_<?php echo $id; ?>" id="<?php echo $id; ?>">
    <img class="img-thumbnail" src="<?php echo $icon_name; ?>" />
    <div style="margin-top: 10px;">
        <label class="control-label"><?php echo $title; ?></label>
    </div>
    <div style="margin-top: 10px;" class="cc">
        <CENTER>
            <button class="btn btn-danger remove_video" type="button" data-toggle='tooltip' title='Delete' data-id="<?php echo $id; ?>" data-name="<?php echo $name; ?>"><i class="fa fa-trash"></i></button>
            <button class="btn btn-primary view_video" type="button" data-toggle='tooltip' title='View Video' data-id="<?php echo $id; ?>" data-type="<?php echo $type; ?>" data-url="<?php echo $url_link; ?>"><i class="fa fa-eye"></i></button>
        </CENTER>
    </div>
</div>