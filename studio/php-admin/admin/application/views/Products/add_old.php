<style type="text/css">
    .border{
        border: 1px solid #e7ecf1 !important;
    }
    .img-container img {
      max-width: 100%;
    }
    #kg_jump,#pcs_jump{
    	/*margin-bottom: 10px;*/
    }
    .container_offer{
    	display: none;
    }
    #tag_list,#tag_offer_list{
	    overflow-x: hidden;
	    overflow-y: scroll;
	    max-height: 200px;
	}
</style>
<div class="portlet light bordered">
	<div class="portlet-title">
		<div class="caption">
			<i class="icon-plus font-blue-sharp"></i>
			<span class="caption-subject font-blue-sharp bold uppercase"><?=$page_heading;?></span>
		</div>
	</div>
	
<?php if($row==false){ ?>
	<div class="portlet-body form">
		<form method="POST" class="form-horizontal" id="form_product" >
			<div class="uploaded_image_name">

			</div>
			<input type="hidden" name="pid" id="pid" value="0">
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
				<div class="col-lg-6"></div>
				<div class="col-lg-4">
					<input class="form-control" type="text" id="name" name="name" placeholder="<?=$this->settings['hebrew_text']['name'];?>"   >
                </div>
				<label class="col-lg-2 control-label"><?=$this->settings['hebrew_text']['name'];?></label>
			</div>


			<div class="form-group">
				<div class="col-lg-6"></div>
				<div class="col-lg-4">
					<select class="form-control" type="text" id="category" name="category">
						<option value=""><?=$this->settings['hebrew_text']['category_name'];?></option>
						<?php 
						foreach ($category_list as $key => $value) {


						 	echo "<option value='$key' > $value</option>";
						 } ?>
					</select>
                </div>
				<label class="col-lg-2 control-label"><?=$this->settings['hebrew_text']['category_name'];?></label>
			</div>

			<div class="form-group">
				<div class="col-lg-6"></div>
				<div class="col-lg-4">
					<input class="form-control" type="text" id="product_id" name="product_id" placeholder="<?=$this->settings['hebrew_text']['product_id'];?>"   >
                </div>
				<label class="col-lg-2 control-label"><?=$this->settings['hebrew_text']['product_id'];?></label>
			</div>


			<div class="form-group">
				<div class="col-lg-6"></div>
				<div class="col-lg-4">
					<input class="form-control" type="text" id="barcode" name="barcode" placeholder="<?=$this->settings['hebrew_text']['barcode'];?>"   >
                </div>
				<label class="col-lg-2 control-label"><?=$this->settings['hebrew_text']['barcode'];?></label>
			</div>


			<div class="form-group">
				<div class="col-lg-6"></div>
				<div class="col-lg-4">
					<input class="form-control" type="text" id="stock" name="stock" placeholder="<?=$this->settings['hebrew_text']['stock'];?>"   >
                </div>
				<label class="col-lg-2 control-label"><?=$this->settings['hebrew_text']['stock'];?></label>
			</div>


			

			<div class="form-group">
				<div class="col-lg-6">
				</div>
				<div class="col-lg-2" id="container_price_kg">
					<input class="form-control" type="text" id="price_kg" name="price_kg" placeholder="<?=$this->settings['hebrew_text']['kg_price'];?>"   >
                </div>
				<div class="col-lg-2" >
					<label>
					    <input type="checkbox" name="weight" id="weight" data-toggle="switch" checked="" data-on-color="primary" data-off-color="default">
					    <span class="toggle"></span>
					</label>
                </div>
				<label class="col-lg-2 control-label"><?=$this->settings['hebrew_text']['kg_price'];?></label>
			</div>


			<div class="form-group">
				<div class="col-lg-6">
				</div>
				<div class="col-lg-2"  >
					<input type="hidden" name="unit_weight" id="unit_weight" value="" />
					<input class="form-control"  type="text" id="pcs_in_kg" name="pcs_in_kg"  value="" placeholder="<?=$this->settings['hebrew_text']['unit_weight'];?>"   >

                </div>
				<div class="col-lg-2" >
					<label>
					   <input type="checkbox" name="is_pcs_in_kg" id="is_pcs_in_kg"  /> 
					    <b id="lbl_unit_weight" ><?=$this->settings['hebrew_text']['unit_weight'];?></b>
					</label>


					
					
                </div>
				<label class="col-lg-2 control-label"><?=$this->settings['hebrew_text']['pcs_in_kg'];?></label>
			</div>



			<div class="form-group">
				<div class="col-lg-6">
				</div>
				<div class="col-lg-2" id="container_price_unit">
					<input class="form-control"  type="text" id="price_unit" name="price_unit" placeholder="<?=$this->settings['hebrew_text']['unit_price'];?>"   >
                </div>
				<div class="col-lg-2">
					<label>
					    <input type="checkbox" name="unit" id="unit" data-toggle="switch" checked="" data-on-color="primary" data-off-color="default">
					    <span class="toggle"></span>
					</label>
                </div>
				<label class="col-lg-2 control-label"><?=$this->settings['hebrew_text']['unit_price'];?></label>
			</div>

			<div class="form-group" style="display: none;">
				<div class="col-lg-6">
				</div>
				<div class="col-lg-2">
					
                </div>
				<div class="col-lg-2">
					<label>
					    <input type="checkbox" name="withvat" id="withvat" data-toggle="switch" checked="" data-on-color="primary" data-off-color="danger"  data-on-text="Yes" data-off-text="No">
					    <span class="toggle"></span>
					</label>
                </div>
				<label class="col-lg-2 control-label"><?=$this->settings['hebrew_text']['with_vat'];?></label>
			</div>

			<div class="form-group">
				<div class="col-lg-6"></div>
				<div class="col-lg-4">
					<textarea class="form-control" name="comment" id="comment" ></textarea>
                </div>
				<label class="col-lg-2 control-label"><?=$this->settings['hebrew_text']['remarks'];?></label>
			</div>

			<div class="form-group">
				<div class="col-lg-6">
				</div>
				<div class="col-lg-2">
					
                </div>
				<div class="col-lg-2">
					<label>
					    <input type="checkbox" name="status" id="status" data-toggle="switch" checked="" data-on-color="primary" data-off-color="danger"  data-on-text="<?=$this->settings['hebrew_text']['active'];?>" data-off-text="<?=$this->settings['hebrew_text']['inactive'];?>">
					    <span class="toggle"></span>
					</label>
                </div>
				<label class="col-lg-2 control-label"><?=$this->settings['hebrew_text']['status'];?></label>
			</div>
			
			<div class="form-group">
				<div class="col-lg-6"></div>
				<div class="col-lg-4">
					<input type="text" class="form-control" name="kg_jump" id="kg_jump" value="" />
                </div>
				<label class="col-lg-2 control-label"><?=$this->settings['hebrew_text']['kg_jump'];?></label>
			</div>



			

			<div class="form-group">
				<div class="col-lg-6"></div>
				<div class="col-lg-4">
					<div class="input-group input-large">
                        <span class="input-group-btn">
                            <button class="btn default qty-down-w" data-field="min_w" type="button"><i class="fa fa-minus"></i></button>
                        </span>
                        <input type="text" class="form-control" name="min_w" id="min_w"  />
                        <span class="input-group-btn">
                            <button class="btn default qty-up-w" data-field="min_w" type="button"><i class="fa fa-plus"></i></button>
                        </span>
                    </div>
                    <!-- /input-group -->
					
                </div>
				<label class="col-lg-2 control-label"><?=$this->settings['hebrew_text']['min_w'];?></label>
			</div>


			
			<div class="form-group">
				<div class="col-lg-6"></div>
				<div class="col-lg-4">

					<div class="input-group input-large">
                        <span class="input-group-btn">
                            <button class="btn default qty-down-w" data-field="max_w" type="button"><i class="fa fa-minus"></i></button>
                        </span>
                        <input type="text" class="form-control" name="max_w" id="max_w"  />
                        <span class="input-group-btn">
                            <button class="btn default qty-up-w" data-field="max_w" type="button"><i class="fa fa-plus"></i></button>
                        </span>
                    </div>
                    <!-- /input-group -->

					<span class="label label-danger error_kg_calc"></span>
                </div>
				<label class="col-lg-2 control-label"><?=$this->settings['hebrew_text']['max_w'];?></label>
			</div>

			


			<div class="form-group">
				<div class="col-lg-6"></div>
				<div class="col-lg-4">
					<input type="text"  class="form-control" onkeypress="return onlyNumberKey(event)" name="pcs_jump" id="pcs_jump" value="0" />
					
                </div>
				<label class="col-lg-2 control-label"><?=$this->settings['hebrew_text']['pcs_jump'];?></label>
			</div>

			

			<div class="form-group">
				<div class="col-lg-6"></div>
				<div class="col-lg-4">

					<div class="input-group input-large">
                        <span class="input-group-btn">
                            <button class="btn default qty-down-u" data-field="min_u" type="button"><i class="fa fa-minus"></i></button>
                        </span>
                        <input type="text" class="form-control" onkeypress="return onlyNumberKey(event)" name="min_u" id="min_u" />
                        <span class="input-group-btn">
                            <button class="btn default qty-up-u" data-field="min_u" type="button"><i class="fa fa-plus"></i></button>
                        </span>
                    </div>
                    <!-- /input-group -->

					
                </div>
				<label class="col-lg-2 control-label"><?=$this->settings['hebrew_text']['min_u'];?></label>
			</div>



			<div class="form-group">
				<div class="col-lg-6"></div>
				<div class="col-lg-4">
					<div class="input-group input-large">
                        <span class="input-group-btn">
                            <button class="btn default qty-down-u" data-field="max_u" type="button"><i class="fa fa-minus"></i></button>
                        </span>
                        <input type="text"  class="form-control" onkeypress="return onlyNumberKey(event)" name="max_u" id="max_u" />
                        <span class="input-group-btn">
                            <button class="btn default qty-up-u" data-field="max_u" type="button"><i class="fa fa-plus"></i></button>
                        </span>
                    </div>
                    <!-- /input-group -->
                    <span class="label label-danger error_pcs_calc"></span>
					
                </div>
				<label class="col-lg-2 control-label"><?=$this->settings['hebrew_text']['max_u'];?></label>
			</div>


			

			

			<div class="form-group" style="display: none;">
				<div class="col-lg-6"></div>
				<div class="col-lg-4">
					<input type="text" class="form-control" name="how_sold" id="how_sold" />
                </div>
				<label class="col-lg-2 control-label"><?=$this->settings['hebrew_text']['how_sold'];?></label>
			</div>

			<div class="form-group">
				<div class="col-lg-6"></div>
				<div class="col-lg-4">
					<input type="text" class="form-control" name="out_of_stock" id="out_of_stock"  />
                </div>
				<label class="col-lg-2 control-label"><?=$this->settings['hebrew_text']['out_of_stock'];?></label>
			</div>

			<div class="form-group">
				<div class="col-lg-6"></div>
				<div class="col-lg-4">
					<label>
					    <input type="checkbox" name="ref_to_inv" value="1" id="ref_to_inv" data-toggle="switch"  data-on-color="primary" data-off-color="danger"  data-on-text="<?=$this->settings['hebrew_text']['yes'];?>" data-off-text="<?=$this->settings['hebrew_text']['no'];?>">
					    <span class="toggle"></span>
					</label>

					
                </div>
				<label class="col-lg-2 control-label"><?=$this->settings['hebrew_text']['ref_to_inv'];?></label>
			</div>


			<div class="form-group">
				<div class="col-lg-4">
				</div>
				<div class="col-lg-2">
					<button type="button" id="btn-add-p-comment" name="btn-add-p-comment" class="btn btn-primary btn-sm" ><?=$this->settings['hebrew_text']['Add'];?></button>
                </div>
				<div class="col-lg-4">
					<input class="form-control"  type="text" id="add_product_addon_comment" name="add_product_addon_comment"  value="" placeholder="<?=$this->settings['hebrew_text']['add_product_comment_and_click'];?>"  maxlength="45"   >
                </div>
				<label class="col-lg-2 control-label"><?=$this->settings['hebrew_text']['product_comment'];?></label>
			</div>

			<div class="form-group">
				<div class="col-lg-10">
					<ul class="list-group comment-list-container" >
					  
					</ul>
                </div><!-- col-lg-10 -->
				<label class="col-lg-2 control-label"></label>
			</div>
			   

			
			<div class="form-group">
				<div class="col-sm-10" >
					<input class="btn <?=$this->settings['success_color'];?>" type="submit" name="btn_add" value="<?=$this->settings['hebrew_text']['add_product'];?>" />
				</div>	
			</div>

</form>

	</div><!-- panel body -->
<?php  }// if its add
else{
 ?>
 	<div class="portlet-body form">
		<form method="POST" class="form-horizontal" id="form_product" >
			<div class="uploaded_image_name">

			</div>
			
			<input type="hidden" name="pid" id="pid" value="<?php echo $row->id; ?>">
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
				<div class="col-lg-6"></div>
				<div class="col-lg-4">
					<input class="form-control" type="text" id="name" name="name_edit" placeholder="<?=$this->settings['hebrew_text']['name'];?>" value="<?php echo htmlentities($row->name); ?>"  >
                </div>
				<label class="col-lg-2 control-label"><?=$this->settings['hebrew_text']['name'];?></label>
			</div>


			<div class="form-group">
				<div class="col-lg-6"></div>
				<div class="col-lg-4">
					<select class="form-control" type="text" id="category" name="category_edit">
						<option value=""><?=$this->settings['hebrew_text']['category_name'];?></option>
						<?php 
						foreach ($category_list as $key => $value) {
							$selected="";
							if($row->category_id==$key)
								$selected=" selected ";


						 	echo "<option value='$key' $selected > $value</option>";
						 } ?>
					</select>
                </div>
				<label class="col-lg-2 control-label"><?=$this->settings['hebrew_text']['category_name'];?></label>
			</div>

			<div class="form-group">
				<div class="col-lg-6"></div>
				<div class="col-lg-4">
					<input class="form-control" type="text" id="product_id" name="product_id_edit" placeholder="<?=$this->settings['hebrew_text']['product_id'];?>"  value="<?php echo $row->product_id; ?>"  >
                </div>
				<label class="col-lg-2 control-label"><?=$this->settings['hebrew_text']['product_id'];?></label>
			</div>


			<div class="form-group">
				<div class="col-lg-6"></div>
				<div class="col-lg-4">
					<input class="form-control" type="text" id="barcode" name="barcode_edit" placeholder="<?=$this->settings['hebrew_text']['barcode'];?>"  value="<?php echo $row->barcode; ?>"  >
                </div>
				<label class="col-lg-2 control-label"><?=$this->settings['hebrew_text']['barcode'];?></label>
			</div>


			<div class="form-group">
				<div class="col-lg-6"></div>
				<div class="col-lg-4">
					<input class="form-control" type="text" id="stock" name="stock_edit" placeholder="<?=$this->settings['hebrew_text']['stock'];?>"  value="<?php echo $row->stock; ?>"  >
                </div>
				<label class="col-lg-2 control-label"><?=$this->settings['hebrew_text']['stock'];?></label>
			</div>


			<div class="form-group">
				<div class="col-lg-6"></div>
				<div class="col-lg-4">
					<label>
					    <input type="checkbox" name="enable_detail_view" id="enable_detail_view" value="1"  data-toggle="switch"  data-on-color="primary" data-off-color="default" <?php if($row->enable_detail_view=="1"){ echo "checked"; } ?>>
					    <span class="toggle"></span>
					</label>

					
                </div>
				<label class="col-lg-2 control-label"><?=$this->settings['hebrew_text']['enable_detail_view'];?></label>
			</div>


			<div class="form-group">
				<div class="col-lg-6">
				</div>
				<div class="col-lg-2" id="container_price_kg"  >
					<input class="form-control" readonly type="text" id="price_kg" name="price_kg_edit"  value="<?php echo $row->price_kg; ?>" placeholder="<?=$this->settings['hebrew_text']['kg_price'];?>"   >

                </div>
				<div class="col-lg-2" >
					<label>
						<?php if($row->import_weight=="0"){ ?>
								-
						<?php }else{ ?>
					    	<input type="checkbox" name="weight_edit" id="weight"   data-toggle="switch" checked="" data-on-color="primary" data-off-color="default" 	<?php if($row->weight=="1"){ echo "checked"; } ?>  >
					    	<span class="toggle"></span>
						<?php } ?>

					</label>
					
                </div>
				<label class="col-lg-2 control-label"><?=$this->settings['hebrew_text']['kg_price'];?></label>
			</div>

			<div class="form-group" >
				<div class="col-lg-6">
				</div>
				<div class="col-lg-2"  >
					<input type="hidden" name="unit_weight_edit" id="unit_weight" value="<?php echo $row->unit_weight; ?>" />
					<input class="form-control" <?php if($row->is_pcs_in_kg=="0"){ echo "style='visibility:hidden;'"; } ?> type="text" id="pcs_in_kg" name="pcs_in_kg_edit"  value="<?php echo $row->unit_weight; ?>" placeholder="<?=$this->settings['hebrew_text']['unit_weight'];?>"   >

                </div>
				<div class="col-lg-2" >
					<label>

					   <input type="checkbox" name="is_pcs_in_kg_edit" id="is_pcs_in_kg" <?php if($row->is_pcs_in_kg=="1"){ echo "checked"; } ?> /> 

					   <b id="lbl_unit_weight" <?php if($row->is_pcs_in_kg=="0"){ echo "style='visibility:hidden;'"; } ?> ><?=$this->settings['hebrew_text']['unit_weight'];?></b>
					</label>
					
					
                </div>
				<label class="col-lg-2 control-label"><?=$this->settings['hebrew_text']['pcs_in_kg'];?></label>
			</div>


			<div class="form-group">
				<div class="col-lg-6">
				</div>
				<div class="col-lg-2" id="container_price_unit" >
					<input class="form-control"  type="text" id="price_unit" name="price_unit_edit"  value="<?php echo $row->price_unit; ?>" readonly placeholder="<?=$this->settings['hebrew_text']['unit_price'];?>"   >
                </div>
				<div class="col-lg-2">
					<label>
					    <input type="checkbox" name="unit_edit" id="unit"  data-toggle="switch" checked="" data-on-color="primary" data-off-color="default" <?php if($row->unit=="1"){ echo "checked"; } ?>>
					    <span class="toggle"></span>
					</label>
                </div>
				<label class="col-lg-2 control-label"><?=$this->settings['hebrew_text']['unit_price'];?></label>
			</div>

			<div class="form-group" style="display: none;">
				<div class="col-lg-6">
				</div>
				<div class="col-lg-2">
					
                </div>
				<div class="col-lg-2">
					<label>
					    <input type="checkbox" name="withvat_edit" id="withvat" data-toggle="switch" checked="" data-on-color="primary" data-off-color="danger"  data-on-text="Yes" data-off-text="No" <?php if($row->withvat=="1"){ echo "checked"; } ?>>
					    <span class="toggle"></span>
					</label>
                </div>
				<label class="col-lg-2 control-label"><?=$this->settings['hebrew_text']['with_vat'];?></label>
			</div>


			<div class="form-group">
				<div class="col-lg-6"></div>
				<div class="col-lg-4">
					<input type="text" class="form-control" maxlength="32" name="product_sub_title_edit" id="product_sub_title" value="<?php echo htmlspecialchars($row->product_sub_title); ?>" />
                </div>
				<label class="col-lg-2 control-label"><?=$this->settings['hebrew_text']['product_sub_title'];?></label>
			</div>

			<div class="form-group">
				<div class="col-lg-6"></div>
				<div class="col-lg-4">
					<textarea class="form-control" name="comment_edit" id="comment" ><?php echo $row->short_desc; ?></textarea>
                </div>
				<label class="col-lg-2 control-label"><?=$this->settings['hebrew_text']['remarks'];?></label>
			</div>

			<div class="form-group">
				<div class="col-lg-6">
				</div>
				<div class="col-lg-2">
					
                </div>
				<div class="col-lg-2">
					<label>
					    <input type="checkbox" name="status_edit" id="status" data-toggle="switch"  <?php if($row->status=="1"){ echo "checked"; } ?> data-on-color="primary" data-off-color="danger"  data-on-text="<?=$this->settings['hebrew_text']['active'];?>" data-off-text="<?=$this->settings['hebrew_text']['inactive'];?>">
					    <span class="toggle"></span>
					</label>
                </div>
				<label class="col-lg-2 control-label"><?=$this->settings['hebrew_text']['status'];?></label>
			</div>
			
			<div class="form-group">
				<div class="col-lg-6"></div>
				<div class="col-lg-4">
					<input type="text" class="form-control" name="kg_jump_edit" id="kg_jump" value="<?php echo $row->kg_jump; ?>" />
					
                </div>
				<label class="col-lg-2 control-label"><?=$this->settings['hebrew_text']['kg_jump'];?></label>
			</div>


			<div class="form-group">
				<div class="col-lg-6"></div>
				<div class="col-lg-4">
					<div class="input-group input-large">
                        <span class="input-group-btn">
                            <button class="btn default qty-down-w" data-field="min_w" type="button"><i class="fa fa-minus"></i></button>
                        </span>
                        <input type="text" class="form-control" name="min_w_edit" id="min_w" value="<?php echo $row->min_w; ?>" />
                        <span class="input-group-btn">
                            <button class="btn default qty-up-w" data-field="min_w" type="button"><i class="fa fa-plus"></i></button>
                        </span>
                    </div>
                    <!-- /input-group -->
					
                </div>
				<label class="col-lg-2 control-label"><?=$this->settings['hebrew_text']['min_w'];?></label>
			</div>

			<div class="form-group">
				<div class="col-lg-6"></div>
				<div class="col-lg-4">

					<div class="input-group input-large">
                        <span class="input-group-btn">
                            <button class="btn default qty-down-w" data-field="max_w" type="button"><i class="fa fa-minus"></i></button>
                        </span>
                        <input type="text" class="form-control" name="max_w_edit" id="max_w" value="<?php echo $row->max_w; ?>" />
                        <span class="input-group-btn">
                            <button class="btn default qty-up-w" data-field="max_w" type="button"><i class="fa fa-plus"></i></button>
                        </span>
                    </div>
                    <!-- /input-group -->

					<span class="label label-danger error_kg_calc"></span>
                </div>
				<label class="col-lg-2 control-label"><?=$this->settings['hebrew_text']['max_w'];?></label>
			</div>


			<div class="form-group">
				<div class="col-lg-6"></div>
				<div class="col-lg-4">
					<input type="text"  class="form-control" onkeypress="return onlyNumberKey(event)" name="pcs_jump_edit" id="pcs_jump" value="<?php echo $row->pcs_jump; ?>" />
					
                </div>
				<label class="col-lg-2 control-label"><?=$this->settings['hebrew_text']['pcs_jump'];?></label>
			</div>


			<div class="form-group">
				<div class="col-lg-6"></div>
				<div class="col-lg-4">

					<div class="input-group input-large">
                        <span class="input-group-btn">
                            <button class="btn default qty-down-u" data-field="min_u" type="button"><i class="fa fa-minus"></i></button>
                        </span>
                        <input type="text" class="form-control" onkeypress="return onlyNumberKey(event)" name="min_u_edit" id="min_u" value="<?php echo $row->min_u; ?>" />
                        <span class="input-group-btn">
                            <button class="btn default qty-up-u" data-field="min_u" type="button"><i class="fa fa-plus"></i></button>
                        </span>
                    </div>
                    <!-- /input-group -->

					
                </div>
				<label class="col-lg-2 control-label"><?=$this->settings['hebrew_text']['min_u'];?></label>
			</div>

			<div class="form-group">
				<div class="col-lg-6"></div>
				<div class="col-lg-4">
					<div class="input-group input-large">
                        <span class="input-group-btn">
                            <button class="btn default qty-down-u" data-field="max_u" type="button"><i class="fa fa-minus"></i></button>
                        </span>
                        <input type="text"  class="form-control" onkeypress="return onlyNumberKey(event)" name="max_u_edit" id="max_u" value="<?php echo $row->max_u; ?>" />
                        <span class="input-group-btn">
                            <button class="btn default qty-up-u" data-field="max_u" type="button"><i class="fa fa-plus"></i></button>
                        </span>
                    </div>
                    <!-- /input-group -->
                    <span class="label label-danger error_pcs_calc"></span>
					
                </div>
				<label class="col-lg-2 control-label"><?=$this->settings['hebrew_text']['max_u'];?></label>
			</div>

			

			

			
			

			<div class="form-group" style="display: none;">
				<div class="col-lg-6"></div>
				<div class="col-lg-4">
					<input type="text" class="form-control" name="how_sold_edit" id="how_sold_edit" value="<?php echo $row->how_sold; ?>" />
                </div>
				<label class="col-lg-2 control-label"><?=$this->settings['hebrew_text']['how_sold'];?></label>
			</div>

			<div class="form-group">
				<div class="col-lg-6"></div>
				<div class="col-lg-4">
					<input type="text" class="form-control" name="out_of_stock_edit" id="out_of_stock_edit" value="<?php echo $row->out_of_stock; ?>" />
                </div>
				<label class="col-lg-2 control-label"><?=$this->settings['hebrew_text']['out_of_stock'];?></label>
			</div>

			<div class="form-group">
				<div class="col-lg-6"></div>
				<div class="col-lg-4">
					<label>
					    <input type="checkbox" name="ref_to_inv_edit" value="1" id="ref_to_inv" data-toggle="switch"  data-on-color="primary" data-off-color="danger"  data-on-text="<?=$this->settings['hebrew_text']['yes'];?>" data-off-text="<?=$this->settings['hebrew_text']['no'];?>" <?php if($row->ref_to_inv=="1"){ echo "checked=''"; } ?>  >
					    <span class="toggle"></span>
					</label>

					
                </div>
				<label class="col-lg-2 control-label"><?=$this->settings['hebrew_text']['ref_to_inv'];?></label>
			</div>



			
			<div class="form-group">
				<div class="col-lg-4">
				</div>
				<div class="col-lg-2">
					<button type="button" id="btn-add-p-comment" name="btn-add-p-comment" class="btn btn-primary btn-sm" ><?=$this->settings['hebrew_text']['Add'];?></button>
                </div>
				<div class="col-lg-4">
					<input class="form-control"  type="text" id="add_product_addon_comment" name="add_product_addon_comment"  value="" placeholder="<?=$this->settings['hebrew_text']['add_product_comment_and_click'];?>" maxlength="45"   >
                </div>
				<label class="col-lg-2 control-label"><?=$this->settings['hebrew_text']['product_comment'];?></label>
			</div>

			<div class="form-group">
				<div class="col-lg-10">
					<ul class="list-group comment-list-container" >
					  
					</ul>
                </div><!-- col-lg-10 -->
				<label class="col-lg-2 control-label"></label>
			</div>
			   

			
			<div class="form-group">
				<div class="col-lg-4">
				</div>
				<div class="col-lg-2">
					
                </div>
				<div class="col-lg-4">
					<select class="form-control" name="offer" id="offer">
						<option value="">No Offer</option>
						<option <?php if($row->offer_id=="offer_a"){ echo "selected"; } ?> value="offer_a">Fixed Price Based Sale</option>
						<option <?php if($row->offer_id=="offer_b"){ echo "selected"; } ?>  value="offer_b">Buy X Get Y Free</option>
						
					</select>
                </div>
				<label class="col-lg-2 control-label"><?=$this->settings['hebrew_text']['select_offer_type'];?></label>
			</div>

			<div class="form-group container_offer container_offer_a container_offer_a_unit">
				<div class="col-lg-4">
					<label class="control-label">Select Sell Product</label>
					<select class="form-control" id="offer_a_sell_product" name="offer_a_sell_product">
						<?php $sell_products=GetSellProducts();
						foreach ($sell_products as $row_p) {
							$selected="";
							if($row_p['id']==$row->offer_a_sell_product)
								$selected=" selected ";
							echo "<option ".$selected." data-price='".$row_p['price']."' value='".$row_p['id']."'>".$row_p['name']." ( ".$row_p['price'].$this->config->item( 'cur_symbol' )." )"."</option>";
						}
						 ?>
					</select>
				</div>
				<div class="col-lg-2">
					<label class="control-label lbl_amt_per">Amount / Percentage</label>
					<input type="text" placeholder="Enter Amount/Percentage" readonly name="offer_a_amt" id="offer_a_amt" value="<?php echo $row->offer_a_amt; ?>" class="form-control">
                </div>
                <div class="col-lg-2">
                	<label class="control-label">Qty to get this offer</label>
					<input type="number" placeholder="Enter Qty to get this offer" name="offer_a_qty" id="offer_a_qty" class="form-control"  value="<?php echo $row->offer_a_qty; ?>" ><br>
					
				</div>

				<div class="col-lg-2">
					<label class="control-label">Offer Price Type</label>
					<select class="form-control" name="offer_a_type" id="offer_a_type">
						<option <?php if($row->offer_a_type=="fix"){ echo "selected"; } ?> value="fix">Fix Amount</option>
						<!--<option <?php if($row->offer_a_type=="per"){ echo "selected"; } ?> value="per">Percentage (%)</option>-->
						
					</select>
                </div>
				<label class="col-lg-2 control-label">Fixed Price Based Sale</label>
			</div>

			<div class="form-group container_offer container_offer_a container_offer_a_kg">
				<div class="col-lg-4">
					<label class="control-label">Select Sell Product</label>
					<select class="form-control" id="offer_a_sell_product_kg" name="offer_a_sell_product_kg">
						<?php $sell_products=GetSellProducts();
						foreach ($sell_products as $row_p) {
							$selected="";
							if($row_p['id']==$row->offer_a_sell_product_kg)
								$selected=" selected ";
							echo "<option ".$selected." data-price='".$row_p['price']."' value='".$row_p['id']."'>".$row_p['name']." ( ".$row_p['price'].$this->config->item( 'cur_symbol' )." )"."</option>";
						}
						 ?>
					</select>
				</div>
				<div class="col-lg-2">
					<label class="control-label lbl_amt_per">Amount / Percentage</label>
					<input type="text" placeholder="Enter Amount/Percentage" name="offer_a_amt_kg" readonly id="offer_a_amt_kg" value="<?php echo $row->offer_a_amt_kg; ?>" class="form-control">
                </div>
                <div class="col-lg-2">
                	<label class="control-label">Weight to get this offer</label>
					<input type="text" placeholder="Enter Weight to get this offer" name="offer_a_qty_kg" id="offer_a_qty_kg" class="form-control"  value="<?php echo $row->offer_a_qty_kg; ?>" ><br>
					
				</div>

				<div class="col-lg-2">
                </div>
				<label class="col-lg-2 control-label"></label>
			</div>







			<div class="form-group container_offer container_offer_b container_offer_b_kg">
				<div class="col-lg-1">
				</div>
				<div class="col-lg-3">
					<input type="text" placeholder="Enter KG Qty of free product" name="offer_b_free_qty_kg" id="offer_b_free_qty_kg" class="form-control"  value="<?php echo $row->offer_b_free_qty_kg; ?>"  ><br>
					<span class="label label-danger" style="white-space: inherit;">Enter KG Qty of free product</span>
				</div>
				<div class="col-lg-3">
					<input type="text" placeholder="Enter KG Qty when free product available" name="offer_b_avail_qty_kg" id="offer_b_avail_qty_kg" class="form-control"  value="<?php echo $row->offer_b_avail_qty_kg; ?>" ><Br>
					<span class="label label-danger" style="white-space: inherit;">Enter KG Qty when free product available</span>
                </div>
				<div class="col-lg-3">
					Free Product
						<select class="form-control" name="offer_b_pid_kg" id="sel_pro">
							<option>Select Product will be free</option>
							<?php $sell_products=GetSellProducts();
									foreach ($sell_products as $row_p) {
										$selected="";
										if($row_p['id']==$row->offer_b_pid_kg)
											$selected=" selected ";
										echo "<option ".$selected." value='".$row_p['id']."'>".$row_p['name']." ( ".$row_p['price'].$this->config->item( 'cur_symbol' )." )"."</option>";
									}
						 ?>
						</select>

						Offer Product
						<select class="form-control" name="offer_b_opid_kg" id="offer_b_opid_kg">
							<option>Select Product </option>
							<?php $sell_products=GetSimpleProducts();
									foreach ($sell_products as $row_p) {
										$selected="";
										if($row_p['id']==$row->offer_b_opid_kg)
											$selected=" selected ";
										echo "<option ".$selected." value='".$row_p['id']."'>".$row_p['name']." ( ".$row_p['price_kg'].$this->config->item( 'cur_symbol' )." )"."</option>";
									}
						 ?>
						</select>
                </div>
				<label class="col-lg-2 control-label">Buy X Get Y Free</label>
			</div>


			<div class="form-group container_offer container_offer_b container_offer_b_unit">
				<div class="col-lg-1">
				</div>
				<div class="col-lg-3">
					<input type="text" placeholder="Enter Unit Qty of free product" name="offer_b_free_qty_unit" id="offer_b_free_qty_unit" class="form-control"  value="<?php echo $row->offer_b_free_qty_unit; ?>"  ><br>
					<span class="label label-danger" style="white-space: inherit;">Enter Unit Qty of free product</span>
				</div>
				<div class="col-lg-3">
					<input type="number" placeholder="Enter Unit Qty when free product available" name="offer_b_avail_qty_unit" id="offer_b_avail_qty_unit" class="form-control"  value="<?php echo $row->offer_b_avail_qty_unit; ?>" ><Br>
					<span class="label label-danger" style="white-space: inherit;">Enter Unit Qty when free product available</span>
                </div>
				<div class="col-lg-3">
					Free Product
						<select class="form-control" name="offer_b_pid_unit" >
							<option>Select Product will be free</option>
							<?php $sell_products=GetSellProducts();
									foreach ($sell_products as $row_p) {
										$selected="";
										if($row_p['id']==$row->offer_b_pid_unit)
											$selected=" selected ";
										echo "<option ".$selected." value='".$row_p['id']."'>".$row_p['name']." ( ".$row_p['price'].$this->config->item( 'cur_symbol' )." )"."</option>";
									}
						 ?>
						</select>

						Offer Product
						<select class="form-control" name="offer_b_opid_unit" id="offer_b_opid_unit">
							<option>Select Product </option>
							<?php $sell_products=GetSimpleProducts();
									foreach ($sell_products as $row_p) {
										$selected="";
										if($row_p['id']==$row->offer_b_opid_unit)
											$selected=" selected ";
										echo "<option ".$selected." value='".$row_p['id']."'>".$row_p['name']." ( ".$row_p['price_unit'].$this->config->item( 'cur_symbol' )." )"."</option>";
									}
						 ?>
						</select>
                </div>
				<label class="col-lg-2 control-label"></label>
			</div>







			<div class="form-group container_offer container_offer_c">
				<div class="col-lg-3">
				</div>
				<div class="col-lg-3">
					<input type="text" placeholder="Enter Total Offer Amount" name="offer_c_total_amt" id="offer_c_total_amt" class="form-control" value="<?php echo $row->offer_c_total_amt; ?>"  ><Br>
					<span class="label label-danger">Enter Total Offer Amount</span>
                </div>
                <div class="col-lg-4">
					<input type="text" placeholder="Enter Offer Qty" name="offer_c_qty" id="offer_c_qty" class="form-control" value="<?php echo $row->offer_c_qty; ?>"  ><br>
					<span class="label label-danger">Enter Offer Qty</span>
				</div>
				
				<label class="col-lg-2 control-label">Buy X Qty , Get it for Y total</label>
			</div>


			<div class="form-group container_offer_tag">
				<div class="col-lg-10">
					
						<input type="hidden" name="offer_tag_id" id="offer_tag_id" value="<?php echo $row->offer_tag_id; ?>" />
						
						<div class="row "  data-toggle="modal" data-target="#tags_offer_modal">
						<div class="col-lg-11">
						</div>
						<div class="col-lg-1 card_tag ">
							<div class="tag_img_border" >
								<?php if($row->offer_tag_id==0){ ?>
								<img  id="selected_tag_offer_image" src="<?php echo config("site_url"); ?>/assets/upload/tags/none.png" class='img-responsive'>
							<?php } else{ ?>
									<img  id="selected_tag_offer_image" src="<?php echo config("site_url"); ?>/assets/upload/tags/<?php echo GetTagImage($row->offer_tag_id); ?>" class='img-responsive'>

							<?php } ?>


							</div>
						</div>

					

					</div>
				</div>
				<label class="col-lg-2 control-label">Select Offer Image</label>
			</div>




			<div class="form-group ">
				<div class="col-lg-10">
					<input type="hidden" name="tag_id" id="tag_id" value="<?php echo $row->tag_id; ?>" />
					<div class="row "  data-toggle="modal" data-target="#tags_modal">
						<div class="col-lg-11">
						</div>
						<div class="col-lg-1 card_tag ">
							<div class="tag_img_border" >
								<?php if($row->tag_id==0){ ?>
								<img  id="selected_tag_image" src="<?php echo config("site_url"); ?>/assets/upload/tags/none.png" class='img-responsive'>
							<?php } else{ ?>
									<img  id="selected_tag_image" src="<?php echo config("site_url"); ?>/assets/upload/tags/<?php echo GetTagImage($row->tag_id); ?>" class='img-responsive'>

							<?php } ?>


							</div>
						</div>

					</div>
				</div>
				<label class="col-lg-2 control-label">Select Tag Image</label>
			</div>


			


			<div class="form-group">
				<div class="col-sm-10" >
					<input class="btn <?=$this->settings['success_color'];?>" type="submit" name="btn_update" value="<?=$this->settings['hebrew_text']['Update'];?>" />
				</div>	
			</div>

</form>

	</div><!-- panel body -->
<?php }?>





	<div class="portlet-title">
		<div class="caption">
			<i class="icon-image font-blue-sharp"></i>
			<span class="caption-subject font-blue-sharp bold uppercase"><?=$this->settings['hebrew_text']['image_gallery'];?></span>
		</div>
	</div>
	
	<div class="portlet-body form">
		<form method="POST" class="form-horizontal" id="form_product1" >
			<div class="form-group">
				<div class="col-lg-6">
				</div>
				<div class="col-lg-2">
					
                </div>
				<div class="col-lg-2">
					<label class="label" data-toggle="tooltip" style="cursor: pointer;" title="<?=$this->settings['hebrew_text']['select_product_image'];?>">
                      <img style="display: none;" class="img-square"  id="avatar" src="<?php echo base_url("assets/img-placeholder.jpg"); ?>" alt="avatar">

                      <input type="file" class="sr-only" id="input" name="image_person" accept="image/*">
             			<button type="button" id="btn-add-p-image" name="btn-add-p-image" class="btn btn-primary btn-sm">
             				<?=$this->settings['hebrew_text']['select_product_image'];?>
             			</button>
                    </label>
                	
                </div>
				<label class="col-lg-2 control-label"><?=$this->settings['hebrew_text']['product_image'];?></label>
				
			</div>
			<div class="form-group">
				<div class="col-lg-12">
					<div class="display_error"></div>
				</div>
			</div><!-- form group -->
			<div class="form-group" id="image_list">

			</div><!-- form group -->
		</form>
	</div><!-- panel body -->



</div>

<div class="modal fade" id="modal" tabindex="-1" role="dialog" aria-labelledby="modalLabel" aria-hidden="true">
    <div class="modal-dialog" role="document">
      <div class="modal-content">
        <div class="modal-header">
          <h5 class="modal-title" id="modalLabel">Crop Image</h5>
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
          <button type="button" class="btn btn-primary" id="crop">Crop and Save Image</button>
        </div>
      </div>
    </div>
</div>


<div class="modal fade" id="tags_modal" tabindex="-1" role="dialog">
  <div class="modal-dialog" role="document">
    <div class="modal-content">
      <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
        <h4 class="modal-title">Tags</h4>
      </div>
      <div class="modal-body">
      	<div class="row">
      			<div class="col-lg-10">
					<input type="text" class="form-control" name="search_tag" id="search_tag" />
				</div>
				<label class="col-lg-2 control-label">Search</label>
      	</div>
      	<br>
        <div class="row" id="tag_list">
						
		</div>
      </div><!-- modal -body -->
      <div class="modal-footer">
        <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
        
      </div>
    </div><!-- /.modal-content -->
  </div><!-- /.modal-dialog -->
</div><!-- /.modal -->



<div class="modal fade" id="tags_offer_modal" tabindex="-1" role="dialog">
  <div class="modal-dialog" role="document">
    <div class="modal-content">
      <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
        <h4 class="modal-title">Tags</h4>
      </div>
      <div class="modal-body">
      	<div class="row">
      			<div class="col-lg-10">
					<input type="text" class="form-control" name="search_tag_offer" id="search_tag_offer" />
				</div>
				<label class="col-lg-2 control-label">Search</label>
      	</div>
      	<br>
        <div class="row" id="tag_offer_list">
						
		</div>
      </div><!-- modal -body -->
      <div class="modal-footer">
        <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
        
      </div>
    </div><!-- /.modal-content -->
  </div><!-- /.modal-dialog -->
</div><!-- /.modal -->

<script type="text/javascript">
	function onlyNumberKey(evt) 
	{ 
          
        // Only ASCII charactar in that range allowed 
        var ASCIICode = (evt.which) ? evt.which : evt.keyCode 
        if (ASCIICode > 31 && (ASCIICode < 48 || ASCIICode > 57)) 
            return false; 
        return true; 
    }

document.addEventListener('DOMContentLoaded', function()
{


$(document).on("click",".tag_img_offer",function(){
	var id=$(this).data("id");
	$(".tag_img_offer").removeClass("active_tag");
	$(this).addClass("active_tag");
	$("#offer_tag_id").val(id);
	var row=$(this).data("row");
	$("#selected_tag_offer_image").attr("src","<?php echo config("site_url"); ?>/assets/upload/tags/"+row.image_name);
});

function load_tag_offer_images()
{
	 $('#tag_offer_list').block({ message: "Searching..." }); 
	 var search_tag=$("#search_tag_offer").val();
	 $.ajax({
	 	url:'<?php echo base_url("Ajax_controller/load_tag_offer_images"); ?>',
	 	data:{"search_tag":search_tag},
	 	type:'POST',
	 	success:function(data){
	 		//var res=$.parseJSON(data);
	 		$("#tag_offer_list").html(data);
	 		$('#tag_offer_list').unblock();
	 	},
	 	error:function(data){
	 		$('#tag_offer_list').unblock();
	 	}
	 });
}// load tag images

$("#search_tag_offer").keyup(function(){
	load_tag_offer_images();
});
load_tag_offer_images();







$(document).on("click",".tag_img_id",function(){
	var id=$(this).data("id");
	$(".tag_img_id").removeClass("active_tag");
	$(this).addClass("active_tag");
	$("#tag_id").val(id);
	var row=$(this).data("row");
	$("#selected_tag_image").attr("src","<?php echo config("site_url"); ?>/assets/upload/tags/"+row.image_name);
});


function load_tag_images()
{
	 $('#tag_list').block({ message: "Searching..." }); 
	 var search_tag=$("#search_tag").val();
	 $.ajax({
	 	url:'<?php echo base_url("Ajax_controller/load_tag_images"); ?>',
	 	data:{"search_tag":search_tag},
	 	type:'POST',
	 	success:function(data){
	 		//var res=$.parseJSON(data);
	 		$("#tag_list").html(data);
	 		$('#tag_list').unblock();
	 	},
	 	error:function(data){
	 		$('#tag_list').unblock();
	 	}
	 });
}// load tag images

$("#search_tag").keyup(function(){
	load_tag_images();
});
load_tag_images();



$("#offer_a_type").change(function(){
	var vl=$(this).val();
	if(vl=="per")
	{
		$(".lbl_amt_per").html("Percentage");
	}else{
		$(".lbl_amt_per").html("Amount");
	}
});

$("#offer_a_type").trigger("change");

$("#btn-add-p-image").click(function(){
	$("#avatar").trigger("click");
});

$("#offer").change(function(){
	$(".container_offer").css("display","none");
	var vl=$(this).val();
	if(vl=="")
	{
		$(".container_offer_tag").css("display","none");
	}else{
		$(".container_offer_tag").css("display","block");
	}

	$(".container_"+vl).css("display","block");

	if(vl=="offer_a")
	{
		$(".container_offer_a_kg").css("display","none");
		$(".container_offer_a_unit").css("display","none");
		<?php if($row->weight=="1"){ ?>
		$(".container_offer_a_kg").css("display","block");
		<?php } ?>

		 <?php if($row->unit=="1"){ ?>
			$(".container_offer_a_unit").css("display","block");
		 <?php } ?>	
	}

	if(vl=="offer_b")
	{
		$(".container_offer_b_kg").css("display","none");
		$(".container_offer_b_unit").css("display","none");
		<?php if($row->weight=="1"){ ?>
		$(".container_offer_b_kg").css("display","block");
		<?php } ?>

		 <?php if($row->unit=="1"){ ?>
			$(".container_offer_b_unit").css("display","block");
		 <?php } ?>	
	}
	
	//$("#unit").
});

 

	if($("[data-toggle='switch']").length != 0){
     $("[data-toggle='switch']").bootstrapSwitch();
}

function validate_kg_jump()
{
	var has_error=0;
	var max_w=$("#max_w").val();
	var min_w=$("#min_w").val();
	var kg_jump=$("#kg_jump").val();

	if(max_w=="")
		max_w=0;
	if(min_w=="")
		min_w=0;
	if(kg_jump=="")
		kg_jump=0;

	max_w=parseFloat(max_w);
	min_w=parseFloat(min_w);
	kg_jump=parseFloat(kg_jump);

	if(kg_jump<=0)
	{
		has_error=1;
	}
	
	if(min_w>max_w)
	{
		has_error=1;
	}

	/*if(has_error==0)
	{
		var dif=max_w-min_w;
		var r=dif%kg_jump;
		
		if(r>0){
			has_error=1;
		}else{
			has_error=0;
		}
	}//has error*/
	

	if(has_error==1){
		$(".error_kg_calc").html("Wrong Value Entered.").removeClass("label-success").addClass("label-danger");
	}else{
		$(".error_kg_calc").html("");
	}

	if(has_error==1)
		return false;
	else
		return true;

}//validate_kg_jump


function validate_pcs_jump()
{
	var has_error=0;
	var max_u=$("#max_u").val();
	var min_u=$("#min_u").val();
	var pcs_jump=$("#pcs_jump").val();

	if(max_u=="")
		max_u=0;
	if(min_u=="")
		min_u=0;
	if(pcs_jump=="")
		pcs_jump=0;

	max_u=parseInt(max_u);
	min_u=parseInt(min_u);
	pcs_jump=parseInt(pcs_jump);

	if(pcs_jump<=0)
	{
		has_error=1;
	}
	
	if(min_u>max_u)
	{
		has_error=1;
	}

	/*if(has_error==0)
	{
		var dif=max_u-min_u;
		var r=dif%pcs_jump;
		
		if(r>0){
			has_error=1;
		}else{
			has_error=0;
		}
	}//has error*/
	

	if(has_error==1){
		$(".error_pcs_calc").html("Wrong Value Entered.").removeClass("label-success").addClass("label-danger");
	}else{
		$(".error_pcs_calc").html("");
	}

	if(has_error==1)
		return false;
	else
		return true;

}//validate_pcs_jump



$("#min_w,#max_w,#kg_jump").keyup(function(){
	validate_kg_jump();
});

$("#min_u,#max_u,#pcs_jump").keyup(function(){
	validate_pcs_jump();
});






/*

 $("#min_w,#max_w,#kg_jump").TouchSpin({
      decimals: 3,
      step: 0.100,
      min:0
    });
$('#kg_jump').on('touchspin.on.startspin', function () {
	var vl=$(this).val();
  	console.log(vl);
  	vl=parseFloat(vl);
  	if(vl>0)
  		$("#min_w,#max_w").trigger("touchspin.updatesettings", {step: vl});
});

$('#max_w').on('touchspin.on.startspin', function () {
	var vl=$(this).val();
	$(this).css("border-color","");
	$("#min_w").css("border-color","");
	var min_w=$("#min_w").val();
  	vl=parseFloat(vl);
  	min_w=parseFloat(min_w);
  	if(min_w>vl && vl>0)
  	{
  		$(this).css("border-color","red");
  	}	
});
$('#min_w').on('touchspin.on.startspin', function () {
	var vl=$(this).val();
	$(this).css("border-color","");
	$("#max_w").css("border-color","");
	var max_w=$("#max_w").val();
  	vl=parseFloat(vl);
  	max_w=parseFloat(max_w);
  	if(max_w<vl && max_w>0)
  	{
  		$(this).css("border-color","red");
  	}
});

 $("#min_u,#max_u,#pcs_jump").TouchSpin({
      step: 1,
      min:0
    });

$('#pcs_jump').on('touchspin.on.startspin', function () {
	var vl=$(this).val();
  	console.log(vl);
  	vl=parseInt(vl);
  	if(vl>0)
  	{
  		$("#min_u,#max_u").trigger("touchspin.updatesettings", {step: vl});	
  	}
  	
});
$('#max_u').on('touchspin.on.startspin', function () {
	var vl=$(this).val();
	$(this).css("border-color","");
	$("#min_u").css("border-color","");
	var min_u=$("#min_u").val();
  	vl=parseInt(vl);
  	min_u=parseInt(min_u);
  	if(min_u>vl && vl>0)
  	{
  		$(this).css("border-color","red");
  	}
});
$('#min_u').on('touchspin.on.startspin', function () {
	var vl=$(this).val();
	$(this).css("border-color","");
	$("#max_u").css("border-color","");
	var max_u=$("#max_u").val();
  	vl=parseInt(vl);
  	max_u=parseInt(max_u);
  	if(max_u<vl && max_u>0)
  	{
  		$(this).css("border-color","red");
  	}
});

*/

 $(document).on("click",".qty-up-w",function(event){
    event.preventDefault();
    var field=$(this).data('field');
    var qtyval = parseFloat($("#"+field).val());
    var kg_jump=parseFloat($("#kg_jump").val());
    if(kg_jump<=0)
    	kg_jump=1;
    qtyval=qtyval+kg_jump;
    $("#"+field).val(qtyval);
    validate_kg_jump();
});// qty up click
$(document).on("click",".qty-down-w",function(event){
    event.preventDefault();
    var field=$(this).data('field');
    var qtyval = parseFloat($("#"+field).val());
    var kg_jump=parseFloat($("#kg_jump").val());
    if(kg_jump<=0)
    	kg_jump=1;

    qtyval=qtyval-kg_jump;
    qtyval=parseFloat(qtyval);
    if(qtyval<=0)
    	qtyval=0;
    $("#"+field).val(qtyval);
    validate_kg_jump();
    
});// qty down click


 $(document).on("click",".qty-up-u",function(event){
    event.preventDefault();
    var field=$(this).data('field');
    var qtyval = parseFloat($("#"+field).val());
    var pcs_jump=parseFloat($("#pcs_jump").val());
    if(pcs_jump<=0)
    	pcs_jump=1;
    qtyval=qtyval+pcs_jump;
    $("#"+field).val(qtyval);
    validate_pcs_jump();
});// qty up click
$(document).on("click",".qty-down-u",function(event){
    event.preventDefault();
    var field=$(this).data('field');
    var qtyval = parseFloat($("#"+field).val());
    var pcs_jump=parseFloat($("#pcs_jump").val());
    if(pcs_jump<=0)
    	pcs_jump=1;
    qtyval=qtyval-pcs_jump;
    qtyval=parseFloat(qtyval);
    if(qtyval<=0)
    	qtyval=0;
    $("#"+field).val(qtyval);
    validate_pcs_jump();
});// qty down click




$("#unit").on("change",function(){
	var r=$(this).is(":checked");
	console.log(r);
});





$('#unit').on('switchChange.bootstrapSwitch', function (event, state) {
	console.log(state);
	if(state){
		$(".container_offer_a_unit").css("display","block");
		$(".container_offer_b_unit").css("display","block");
		//$("#container_price_unit").css("visibility","visible");
	}else{
		$(".container_offer_a_unit").css("display","none");
		$(".container_offer_b_unit").css("display","none");
		//$("#container_price_unit").css("visibility","hidden");
	}
}); 


$('#weight').on('switchChange.bootstrapSwitch', function (event, state) {
	console.log(state);
	if(state){
		$(".container_offer_a_kg").css("display","block");
		$(".container_offer_b_kg").css("display","block");
		//$("#container_price_kg").css("visibility","visible");
		//$("#is_pcs_in_kg").css("visibility","visible");
		

		//$("#pcs_in_kg").css("visibility","visible");
		
		
	}else{
		$(".container_offer_a_kg").css("display","none");
		$(".container_offer_b_kg").css("display","none");
		//$("#container_price_kg").css("visibility","hidden");
		//$("#is_pcs_in_kg").css("visibility","hidden");
		

		//$("#pcs_in_kg").css("visibility","hidden");
	}
}); 

$("#is_pcs_in_kg").click(function(){
	var state=$(this).is(":checked");
	if(state){
		//$("#container_price_unit").css("visibility","visible");
		$("#pcs_in_kg").css("visibility","visible");
		$("#lbl_unit_weight").css("visibility","visible");
		//$("#unit").bootstrapSwitch('state', true);


		//$("#unit").bootstrapSwitch('disabled',false);
		//$("#unit").bootstrapSwitch('disabled',true);
		
	}else{
		//$("#container_price_unit").css("visibility","hidden");
		$("#pcs_in_kg").css("visibility","hidden");
		$("#lbl_unit_weight").css("visibility","hidden");
		//$("#unit").bootstrapSwitch('state', false);

		//$("#unit").bootstrapSwitch('disabled',false);
		//$("#unit").bootstrapSwitch('disabled',true);
	}
});

$("#pcs_in_kg").keyup(function(){
	//this is actually weight of single unit so we can find price per unit from price fo weight in 1000gram
	// and the price will be always in weight of 1000grams.
	var single_unit_weight=$(this).val();
	if(single_unit_weight=="")
		single_unit_weight=0;
	var price_kg=$("#price_kg").val();
	$("#unit_weight").val(single_unit_weight);
	single_unit_weight=parseFloat(single_unit_weight);
	price_kg=parseFloat(price_kg);
	if(price_kg<=0 || single_unit_weight<=0)
	{
		$("#price_unit").val(0);
	}else{
		single_unit_price=((single_unit_weight*price_kg)/1000);
		single_unit_price=parseFloat(single_unit_price);
		$("#price_unit").val(single_unit_price.toFixed(2));
	}
	
	/*var pcs=$(this).val();
	if(pcs=="")
		pcs=0;
	var price_kg=$("#price_kg").val();
	pcs=parseFloat(pcs);
	price_kg=parseFloat(price_kg);
	var per_pcs_price=parseFloat(price_kg/pcs);
	
	$("#price_unit").val(per_pcs_price.toFixed(2));*/
});

$("#offer_a_sell_product").change(function(){
	var pr=$(this).find(':selected').attr('data-price');
	var offer_a_qty=$("#offer_a_qty").val();
	var price_unit=$("#price_unit").val();
	var offer_a_amt=$("#offer_a_amt").val();

	var offer_a_amt=parseFloat(offer_a_qty)*parseFloat(price_unit);
	offer_a_amt=offer_a_amt+parseFloat(pr);
	$("#offer_a_amt").val(offer_a_amt);	
});

$("#offer_a_qty").keyup(function(){
	var pr=$("#offer_a_sell_product").find(':selected').attr('data-price');
	var offer_a_qty=$("#offer_a_qty").val();
	var price_unit=$("#price_unit").val();
	var offer_a_amt=$("#offer_a_amt").val();

	var offer_a_amt=parseFloat(offer_a_qty)*parseFloat(price_unit);
	offer_a_amt=offer_a_amt+parseFloat(pr);
	$("#offer_a_amt").val(offer_a_amt);	
});



$("#offer_a_sell_product_kg").change(function(){
	var pr=$(this).find(':selected').attr('data-price');
	var offer_a_qty_kg=$("#offer_a_qty_kg").val();
	var price_kg=$("#price_kg").val();
	var offer_a_amt_kg=$("#offer_a_amt_kg").val();

	var offer_a_amt_kg=parseFloat(offer_a_qty_kg)*parseFloat(price_kg);
	offer_a_amt_kg=offer_a_amt_kg+parseFloat(pr);
	$("#offer_a_amt_kg").val(offer_a_amt_kg);	
});

$("#offer_a_qty_kg").keyup(function(){
	var pr=$("#offer_a_sell_product_kg").find(':selected').attr('data-price');
	var offer_a_qty_kg=$("#offer_a_qty_kg").val();
	var price_kg=$("#price_kg").val();
	var offer_a_amt_kg=$("#offer_a_amt_kg").val();

	var offer_a_amt_kg=parseFloat(offer_a_qty_kg)*parseFloat(price_kg);
	offer_a_amt_kg=offer_a_amt_kg+parseFloat(pr);
	$("#offer_a_amt_kg").val(offer_a_amt_kg);	
});







<?php if($row!=false){ ?>
load_images("<?php echo $row->id; ?>");
$("#unit").bootstrapSwitch('state', <?php if($row->unit=="1"){ echo "true"; }else{ echo "false"; } ?>);
$("#weight").bootstrapSwitch('state', <?php if($row->weight=="1"){ echo "true"; }else{ echo "false"; } ?>);
$("#status").bootstrapSwitch('state', <?php if($row->status=="1"){ echo "true"; }else{ echo "false"; } ?>);
$("#withvat").bootstrapSwitch('state', <?php if($row->withvat=="1"){ echo "true"; }else{ echo "false"; } ?>);
$("#ref_to_inv").bootstrapSwitch('state', <?php if($row->ref_to_inv=="1"){ echo "true"; }else{ echo "false"; } ?>);

$(".container_offer_a_kg").css("display","none");
$(".container_offer_a_unit").css("display","none");

$(".container_offer_b_kg").css("display","none");
$(".container_offer_b_unit").css("display","none");

<?php if($row->weight=="1"){ ?>
	$(".container_offer_a_kg").css("display","block");
	$(".container_offer_b_kg").css("display","block");
 <?php } ?>

 <?php if($row->unit=="1"){ ?>
	$(".container_offer_a_unit").css("display","block");
	$(".container_offer_b_unit").css("display","block");
 <?php } ?>
//$("#unit").bootstrapSwitch('disabled',true);
//$("#weight").bootstrapSwitch('disabled',true);
//bootstrapSwitch('toggleDisabled',true,true);
//bootstrapSwitch('disabled',true);

<?php } ?>

$("#form_product").submit(function(){
	//$("#unit").bootstrapSwitch('disabled',false);
	//$("#weight").bootstrapSwitch('disabled',false);

	var is_valid=validate_pcs_jump();
	if(is_valid==false)
	{
		return false;
	}
	is_valid=validate_kg_jump();
	if(is_valid==false)
	{
		return false;
	}

});


$(document).on("click",".remove_img",function(){
	//remove_uploaded_image
	var id=$(this).data("id");
	var name=$(this).data("name");
	swal({
	  title: "Are you sure?",
	  text: "It will remove product image file!",
	  type: "warning",
	  showCancelButton: true,
	  confirmButtonClass: "btn-danger",
	  confirmButtonText: "Yes, delete it!",
	  cancelButtonText: "No, cancel!",
	  closeOnConfirm: false,
	  closeOnCancel: false
	},
	function(isConfirm) {
	  if (isConfirm) {
	  	$.ajax({
	  		url:'<?php echo base_url("Ajax_controller/remove_uploaded_image");?>',
	  		data:{id:id,name:name},
	  		type:"POST",
	  		success:function(data){
	  			swal("Deleted!", "Product image file has been deleted.", "success");
	  			$("#tr_image_"+id).slideUp("slow");
	  			$("#image_names_"+id).remove();
	  		},
	  		error:function(data){
	  			swal("Cancelled", "Operation Cancelled", "error");
	  		}
	  	});
	    
	  } else {
	    swal("Cancelled", "Operation Cancelled", "error");
	  }
	});
});// click on remove image

var avatar = document.getElementById('avatar');
      var image = document.getElementById('image');
      var input = document.getElementById('input');
      var $modal = $('#modal');
      var cropper;

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
	           var  fileType = file.type;
	            var validImageTypes = ['image/gif', 'image/jpeg', 'image/png'];
	            if (!validImageTypes.includes(fileType)) {
	                        // invalid file type code goes here.
	                    $('.display_error').html('<div class="alert alert-danger">Please select valid Image</div>').show();
	                    window.scrollTo(0,0);
	                    setTimeout(function(){ $('.display_error').hide(); }, 7000);

	            }else{

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

	        }
	      });//file input change

    	  var cropBoxData;
	      var canvasData;
	      var cropper;

	      $('#modal').on('shown.bs.modal', function () {
	        cropper = new Cropper(image, {
	          autoCropArea: 1,
	           aspectRatio:1,
	          ready: function () {
	            //Should set crop box data first here
	            cropper.setCropBoxData(cropBoxData).setCanvasData(canvasData);
	          },
	           cropmove: function(event) {
		      /*  var data = cropper.getData();

		        if (data.width < 660) {
		            event.preventDefault();

		            data.width = 660;

		            cropper.setData(data);
		        }

		        if (data.height < 660) {
		            event.preventDefault();

		            data.height = 660;

		            cropper.setData(data);
		        }*/
		    }
	        });
	      }).on('hidden.bs.modal', function () {
	        cropBoxData = cropper.getCropBoxData();
	        canvasData = cropper.getCanvasData();
	        cropper.destroy();
	      });


      document.getElementById('crop').addEventListener('click', function () {
        	var initialAvatarURL;
        	var canvas;
        	var pid=$("#pid").val();
        	$(".display_error").html("<div class='alert alert-info'>Uploading..</div>");
        	$modal.modal('hide');
	        if (cropper) {
	          canvas = cropper.getCroppedCanvas({
	            width: 660,
	            height: 660,
	            minWidth:600,
	            minHeight:600
	          });
	          var croppng =canvas.toDataURL();

	          //avatar.src=croppng;
	          $.ajax({
	          	url:'<?php echo base_url("Ajax_controller/product_image_crop"); ?>',
	          	data:{pngimageData:croppng,pid:pid},
	          	type: 'POST',
	          	success:function(data){console.log(data);
	          		 $('.display_error').show();
	          		$(".display_error").html("<div class='alert alert-success'>Uploaded successfully.</div>");
	          		setTimeout(function(){ $('.display_error').hide(); }, 7000);
	          		var res=$.parseJSON(data);
	          		if(res.status==1)
	          		{
	          			$(".uploaded_image_name").append(res.img_tag_name);
	          			$("#image_list").append(res.html);
	          		}
	          	},
	          	error:function(data){console.log(data);}
	          })
	        }
      });// click on crop button and save to db


	function load_images(pid)
	{
		$.ajax({
			url:"<?php echo base_url("Ajax_controller/load_images");  ?>",
			data:{pid:pid},
			type:"POST",
			success:function(data){
				var res=$.parseJSON(data);
				$("#image_list").html(res.html);
			}
		});
	}

	function load_p_comment(pid="",add="",comment="")
	{
		var ele=$("#btn-add-p-comment");
		ele.attr("disabled","disabled");
		if(pid==0)
			pid="";
		$.ajax({
			url:"<?php echo base_url("Ajax_controller/load_p_comment");  ?>",
			data:{pid:pid,add:add,comment:comment},
			type:"POST",
			success:function(data){
				ele.removeAttr("disabled");
				var res=$.parseJSON(data);
				$("#add_product_addon_comment").val("");
				if(res.append=="1")
					$(".comment-list-container").append(res.html);	
				else
					$(".comment-list-container").html(res.html);	
			},
			error:function(data){
				ele.removeAttr("disabled");
			}
		});

		
	}

	$("#btn-add-p-comment").click(function(){
		var ele=$(this);
		var pid=$("#pid").val();
		var vl=$("#add_product_addon_comment").val();
		var add="";
		if(pid!="" && pid!=0)
		{
			add="1";
		}
		load_p_comment(pid,add,vl);
	});




	$(document).on("click",".remove-p-comment",function(){
		var  id=$(this).data("id");
		var  ele=$(this);

		var pid=$("#pid").val();
		var local=$(this).data("data-local");
		$.ajax({
			url:"<?php echo base_url("Ajax_controller/remove_p_comment");  ?>",
			data:{id:id},
			type:"POST",
			success:function(data){
				var res=$.parseJSON(data);
				ele.parent("li").remove();
				if(pid!=0)
					load_p_comment(pid,"","");
			}
		});
	});
	
	<?php if(!empty($row->id)){
			?>
			load_p_comment(<?php echo $row->id; ?>,"","");
	<?php } ?>


/*
$("#sel_cat").change(function(){	
	var  id=$(this).val();
	var  ele=$(this);
		$.ajax({
			url:"<?php echo base_url("Ajax_controller/get_product_by_category");  ?>",
			data:{category_id:id},
			type:"POST",
			success:function(data){
				var res=$.parseJSON(data);
				$("#sel_pro").html(res.html);
				<?php if($row->offer_b_pid!=""){ ?>
						$("#sel_pro").val("<?php echo $row->offer_b_pid; ?>");
						$("#sel_pro").trigger("change");
				<?php }?>
			}
		});
});//select change event
*/

$("#offer").trigger("change");


	
});//document load
</script>
