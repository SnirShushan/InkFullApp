<style type="text/css">
	.border {
		border: 1px solid #e7ecf1 !important;
	}

	.img-container img {
		max-width: 100%;
	}

	#kg_jump,
	#pcs_jump {
		/*margin-bottom: 10px;*/
	}

	.container_offer {
		display: none;
	}

	#tag_list,
	#tag_offer_list {
		overflow-x: hidden;
		overflow-y: scroll;
		max-height: 200px;
	}

	.select2-container {
		width: 100% !important;
	}

	.errorClass {
		border: 1px solid red;
		border-radius: 4px;
		padding-left: 10px;
	}
</style>

<div class="portlet light bordered">
	<div class="portlet-title">
		<div class="caption">
			<i class="icon-plus font-blue-sharp"></i>
			<span class="caption-subject font-blue-sharp bold uppercase"><?= $page_heading; ?></span>
		</div>
	</div>


	<div class="portlet-body form">
		<form method="POST" class="form-horizontal" id="form_product">
			<div class="uploaded_image_name">

			</div>

			<input type="hidden" name="pid" id="pid" value="<?php echo $row->id; ?>">
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
			//print_r($this->session->userdata());
			?>


			<div class="form-group">
				<div class="col-lg-6"></div>
				<div class="col-lg-4">
					<input class="form-control" type="text" id="name" name="name_edit" placeholder="<?= $this->settings['hebrew_text']['name']; ?>" value="<?php echo htmlentities($row->name); ?>">
				</div>
				<label class="col-lg-2 control-label"><?= $this->settings['hebrew_text']['name']; ?></label>
			</div>


			<div class="form-group">
				<div class="col-lg-6"></div>
				<div class="col-lg-4">
					<select class="form-control" type="text" id="category" name="category_edit">
						<option value=""><?= $this->settings['hebrew_text']['category_name']; ?></option>
						<?php
						foreach ($category_list as $key => $value) {
							$selected = "";
							if ($row->category_id == $key)
								$selected = " selected ";


							echo "<option value='$key' $selected > $value</option>";
						} ?>
					</select>
				</div>
				<label class="col-lg-2 control-label"><?= $this->settings['hebrew_text']['category_name']; ?></label>
			</div>

			<div class="form-group">

				<label><?= $this->settings['hebrew_text']['click_to_select_category']; ?></label>

				<select class="form-control" name="select_category[]" id="select_category" multiple='multiple'>



					<?php $category_list = GetFrontCategoryList();

					$child_list = $mapping_category['child_list'];

					$parent_list = $mapping_category['parent_list'];
					if (isset($category_list) && !empty($category_list)) {
						foreach ($category_list as $single) {

							$parent_allow = 1;

							if (in_array($single['id'], $selected_category)) {

								$parent_allow = 0;
							}



							$link = base_url("Category/") . $single['slug'];

							if (count($single['sub_list']) > 0) {

								$parent_select = "";

								if (in_array($single['id'], $parent_list))

									$parent_select = " selected ";



								if ($parent_allow == 1 || $parent_select != "") {

					?>

									<option <?php echo $parent_select; ?> value="1_<?php echo $single['id']; ?>"><?php echo $single['name']; ?></option>

									<?php foreach ($single['sub_list'] as $sub_single) {



										$child_allow = 1;

										if (in_array($sub_single['id'], $selected_category)) {

											$child_allow = 0;
										}



										$link1 = base_url("Category/") . $sub_single['slug'];

										$child_select = "";

										if (in_array($sub_single['id'], $child_list))

											$child_select = " selected ";



										if ($child_allow == 1 || $child_select != "") {

									?>

											<option <?php echo $child_select; ?> value="0_<?php echo $sub_single['id']; ?>"> <?php echo $sub_single['name']; ?> <== </option>

											<?php }
									} ?>



										<?php

									}
								} else {

									$parent_select = "";

									if (in_array($single['id'], $parent_list))

										$parent_select = " selected ";



									if ($parent_allow == 1 || $parent_select != "") {

										?>

											<option <?php echo $parent_select; ?> value="1_<?php echo $single['id']; ?>"><?php echo $single['name']; ?></option>

							<?php }
								}
							}
						}	?>



				</select>

			</div>

			<div class="form-group">
				<div class="col-lg-6"></div>
				<div class="col-lg-4">
					<input class="form-control" type="text" id="product_id" name="product_id_edit" placeholder="<?= $this->settings['hebrew_text']['product_id']; ?>" value="<?php echo $row->product_id; ?>">
				</div>
				<label class="col-lg-2 control-label"><?= $this->settings['hebrew_text']['product_id']; ?></label>
			</div>


			<div class="form-group">
				<div class="col-lg-6"></div>
				<div class="col-lg-4">
					<input class="form-control" type="text" id="barcode" name="barcode_edit" placeholder="<?= $this->settings['hebrew_text']['barcode']; ?>" value="<?php echo $row->barcode; ?>">
				</div>
				<label class="col-lg-2 control-label"><?= $this->settings['hebrew_text']['barcode']; ?></label>
			</div>


			<div class="form-group">
				<div class="col-lg-6"></div>
				<div class="col-lg-4">
					<input class="form-control" type="text" id="stock" name="stock_edit" placeholder="<?= $this->settings['hebrew_text']['stock']; ?>" value="<?php echo $row->stock; ?>">
				</div>
				<label class="col-lg-2 control-label"><?= $this->settings['hebrew_text']['stock']; ?></label>
			</div>


			<div class="form-group">
				<div class="col-lg-6"></div>
				<div class="col-lg-4">
					<label>
						<input type="checkbox" name="enable_detail_view" id="enable_detail_view" value="1" data-toggle="switch" data-on-color="primary" data-off-color="default" <?php if ($row->enable_detail_view == "1") {
																																														echo "checked";
																																													} ?>>
						<span class="toggle"></span>
					</label>


				</div>
				<label class="col-lg-2 control-label"><?= $this->settings['hebrew_text']['enable_detail_view']; ?></label>
			</div>

			<div class="form-group">
				<div class="col-lg-8"></div>
				<div class="col-lg-2">
					<input class="form-control" readonly type="text" id="price" name="price_edit" placeholder="<?= $this->settings['hebrew_text']['price']; ?>" value="<?php echo $row->price; ?>">
				</div>
				<label class="col-lg-2 control-label"><?= $this->settings['hebrew_text']['price']; ?></label>
			</div>

			<div class="form-group">
				<div class="col-lg-8"></div>
				<div class="col-lg-2">
					<input class="form-control" readonly type="text" id="price1" name="price1" placeholder="<?= $this->settings['hebrew_text']['price1']; ?>" value="<?php echo $row->price1; ?>">
				</div>
				<label class="col-lg-2 control-label"><?= $this->settings['hebrew_text']['price1']; ?></label>
			</div>


			<input type="hidden" id="price_kg" name="price_kg_edit" value="0">
			<input type="hidden" name="unit_weight_edit" id="unit_weight" value="0" />
			<input type="hidden" name="pcs_in_kg" id="pcs_in_kg_edit" value="0" />
			<input type="hidden" id="price_unit" name="price_unit_edit" value="0" />
			<input type="hidden" id="curr_retail" name="curr_retail_edit" value="<?php echo $row->curr_retail; ?>" />





			<div class="form-group">
				<div class="col-lg-6"></div>
				<div class="col-lg-4">
					<input type="text" class="form-control" maxlength="32" name="product_sub_title_edit" id="product_sub_title" value="<?php echo htmlspecialchars($row->product_sub_title); ?>" />
				</div>
				<label class="col-lg-2 control-label"><?= $this->settings['hebrew_text']['product_sub_title']; ?></label>
			</div>

			<div class="form-group">
				<div class="col-lg-6"></div>
				<div class="col-lg-4">
					<textarea class="form-control" name="comment_edit" id="comment"><?php echo $row->short_desc; ?></textarea>
				</div>
				<label class="col-lg-2 control-label"><?= $this->settings['hebrew_text']['remarks']; ?></label>
			</div>

			<div class="form-group">

				<div class="col-lg-10">
					<textarea class="form-control" name="product_spec" id="product_spec"><?php echo $row->product_spec; ?></textarea>
				</div>
				<label class="col-lg-2 control-label"><?= $this->settings['hebrew_text']['product_spec']; ?></label>
			</div>


			<div class="form-group">

				<div class="col-lg-10">
					<textarea class="form-control" name="product_detail" id="product_detail"><?php echo $row->product_detail; ?></textarea>
				</div>
				<label class="col-lg-2 control-label"><?= $this->settings['hebrew_text']['product_detail']; ?></label>
			</div>

			<div class="form-group">
				<div class="col-lg-6">
				</div>
				<div class="col-lg-2">

				</div>
				<div class="col-lg-2">
					<label>
						<input type="checkbox" name="status_edit" id="status" data-toggle="switch" <?php if ($row->status == "1") {
																										echo "checked";
																									} ?> data-on-color="primary" data-off-color="danger" data-on-text="<?= $this->settings['hebrew_text']['active']; ?>" data-off-text="<?= $this->settings['hebrew_text']['inactive']; ?>">
						<span class="toggle"></span>
					</label>
				</div>
				<label class="col-lg-2 control-label"><?= $this->settings['hebrew_text']['status']; ?></label>
			</div>









			<div class="form-group">
				<div class="col-lg-6"></div>
				<div class="col-lg-4">
					<input type="text" class="form-control" onkeypress="return onlyNumberKey(event)" name="pcs_jump_edit" id="pcs_jump" value="<?php echo $row->pcs_jump; ?>" />

				</div>
				<label class="col-lg-2 control-label"><?= $this->settings['hebrew_text']['pcs_jump']; ?></label>
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
				<label class="col-lg-2 control-label"><?= $this->settings['hebrew_text']['min_u']; ?></label>
			</div>

			<div class="form-group">
				<div class="col-lg-6"></div>
				<div class="col-lg-4">
					<div class="input-group input-large">
						<span class="input-group-btn">
							<button class="btn default qty-down-u" data-field="max_u" type="button"><i class="fa fa-minus"></i></button>
						</span>
						<input type="text" class="form-control" onkeypress="return onlyNumberKey(event)" name="max_u_edit" id="max_u" value="<?php echo $row->max_u; ?>" />
						<span class="input-group-btn">
							<button class="btn default qty-up-u" data-field="max_u" type="button"><i class="fa fa-plus"></i></button>
						</span>
					</div>
					<!-- /input-group -->
					<span class="label label-danger error_pcs_calc"></span>

				</div>
				<label class="col-lg-2 control-label"><?= $this->settings['hebrew_text']['max_u']; ?></label>
			</div>








			<div class="form-group" style="display: none;">
				<div class="col-lg-6"></div>
				<div class="col-lg-4">
					<input type="text" class="form-control" name="how_sold_edit" id="how_sold_edit" value="<?php echo $row->how_sold; ?>" />
				</div>
				<label class="col-lg-2 control-label"><?= $this->settings['hebrew_text']['how_sold']; ?></label>
			</div>

			<div class="form-group">
				<div class="col-lg-6"></div>
				<div class="col-lg-4">
					<input type="text" class="form-control" name="out_of_stock_edit" id="out_of_stock_edit" value="<?php echo $row->out_of_stock; ?>" />
				</div>
				<label class="col-lg-2 control-label"><?= $this->settings['hebrew_text']['out_of_stock']; ?></label>
			</div>

			<div class="form-group">
				<div class="col-lg-6"></div>
				<div class="col-lg-4">
					<label>
						<input type="checkbox" name="ref_to_inv_edit" value="1" id="ref_to_inv" data-toggle="switch" data-on-color="primary" data-off-color="danger" data-on-text="<?= $this->settings['hebrew_text']['yes']; ?>" data-off-text="<?= $this->settings['hebrew_text']['no']; ?>" <?php if ($row->ref_to_inv == "1") {
																																																																									echo "checked=''";
																																																																								} ?>>
						<span class="toggle"></span>
					</label>


				</div>
				<label class="col-lg-2 control-label"><?= $this->settings['hebrew_text']['ref_to_inv']; ?></label>
			</div>




			<div class="form-group">
				<div class="col-lg-4">
				</div>
				<div class="col-lg-2">
					<button type="button" id="btn-add-p-comment" name="btn-add-p-comment" class="btn btn-primary btn-sm"><?= $this->settings['hebrew_text']['Add']; ?></button>
				</div>
				<div class="col-lg-4">
					<input class="form-control" type="text" id="add_product_addon_comment" name="add_product_addon_comment" value="" placeholder="<?= $this->settings['hebrew_text']['add_product_comment_and_click']; ?>" maxlength="45">
				</div>
				<label class="col-lg-2 control-label"><?= $this->settings['hebrew_text']['product_comment']; ?></label>
			</div>

			<div class="form-group">
				<div class="col-lg-10">
					<ul class="list-group comment-list-container">

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
						<option <?php if ($row->offer_id == "offer_a") {
									echo "selected";
								} ?> value="offer_a">Fixed Price Based Sale</option>
						<option <?php if ($row->offer_id == "offer_b") {
									echo "selected";
								} ?> value="offer_b">Buy X Get Y Free</option>

					</select>
				</div>
				<label class="col-lg-2 control-label"><?= $this->settings['hebrew_text']['select_offer_type']; ?></label>
			</div>

			<div class="form-group container_offer container_offer_a container_offer_a_unit">
				<div class="col-lg-4" style="display:none;">
					<label class="control-label">Select Sell Product</label>
					<select class="form-control" id="offer_a_sell_product" name="offer_a_sell_product">
						<?php $sell_products = GetSellProducts();
						foreach ($sell_products as $row_p) {
							$selected = "";
							if ($row_p['id'] == $row->offer_a_sell_product)
								$selected = " selected ";
							echo "<option " . $selected . " data-price='" . $row_p['price'] . "' value='" . $row_p['id'] . "'>" . $row_p['name'] . " ( " . $row_p['price'] . $this->config->item('cur_symbol') . " )" . "</option>";
						}
						?>
					</select>
				</div>
				<div class="col-lg-2" style="display:none;">
					<label class="control-label lbl_amt_per">Amount / Percentage</label>
					<input type="text" placeholder="Enter Amount/Percentage" readonly name="offer_a_amt" id="offer_a_amt" value="<?php echo $row->offer_a_amt; ?>" class="form-control">
				</div>
				<div class="col-lg-4">
				</div>
				<div class="col-lg-2">
					<label class="control-label ">Enter Offer Price</label>
					<input type="text" placeholder="Enter Offer Price" name="offer_a_price" id="offer_a_price" value="<?php echo $row->offer_a_price; ?>" class="form-control">
				</div>
				<div class="col-lg-2">
					<label class="control-label">Qty to get this offer</label>
					<input type="number" placeholder="Enter Qty to get this offer" name="offer_a_qty" id="offer_a_qty" class="form-control" value="<?php echo $row->offer_a_qty; ?>"><br>

				</div>

				<div class="col-lg-2">
					<label class="control-label">Offer Price Type</label>
					<select class="form-control" name="offer_a_type" id="offer_a_type">
						<option <?php if ($row->offer_a_type == "fix") {
									echo "selected";
								} ?> value="fix">Fix Amount</option>
						<!--<option <?php if ($row->offer_a_type == "per") {
										echo "selected";
									} ?> value="per">Percentage (%)</option>-->

					</select>
				</div>
				<label class="col-lg-2 control-label">Fixed Price Based Sale</label>
			</div>











			<div class="form-group container_offer container_offer_b container_offer_b_unit">
				<div class="col-lg-9"></div>
				<div class="col-lg-3">
					<input type="text" placeholder="Enter Unit Qty of free product" name="offer_b_free_qty_unit" id="offer_b_free_qty_unit" class="form-control" value="<?php echo $row->offer_b_free_qty_unit; ?>"><br>
					<span class="label label-danger" style="white-space: inherit;">Enter Unit Qty of free product</span>
				</div>
				<div class="col-lg-3" style="display: none;">
					<input type="number" placeholder="Enter Unit Qty when free product available" name="offer_b_avail_qty_unit" id="offer_b_avail_qty_unit" class="form-control" value="<?php echo $row->offer_b_avail_qty_unit; ?>"><Br>
					<span class="label label-danger" style="white-space: inherit;">Enter Unit Qty when free product available</span>
				</div>

			</div>

			<div class="form-group container_offer container_offer_b container_offer_b_unit">
				<div class="col-lg-8">
					<table class="table">
						<thrad>
							<tr>
								<td>Name</td>
								<td>Price</td>
								<td>Sale Price</td>
								<td></td>
							</tr>
						</thrad>
						<tbody id="sale_product_table_container">

						</tbody>
					</table>
				</div>
				<div class="col-lg-4">
					<input type="hidden" name="offer_b_pid_unit" id="offer_b_pid_unit" />
					<input type="hidden" name="offer_b_opid_unit" id="offer_b_opid_unit" />
					<?php
					$selected_list = [];
					foreach ($selected_sale_products as $single_sel) {
						$selected_list[] = $single_sel->pid;
					}

					?>

					Sale Product
					<select class="form-control" name="sale_products[]" id="sale_products" multiple='multiple'>
						<?php

						foreach ($plist as $single_p) {
							$selected = "";
							if (in_array($single_p['id'], $selected_list))
								$selected = " selected ";
							echo "<option " . $selected . " value='" . $single_p['id'] . "'>" . $single_p['name'] . " (" . $single_p['product_id'] . ")</option>";
						} ?>
					</select>

				</div>
			</div>







			<div class="form-group container_offer container_offer_c">
				<div class="col-lg-3">
				</div>
				<div class="col-lg-3">
					<input type="text" placeholder="Enter Total Offer Amount" name="offer_c_total_amt" id="offer_c_total_amt" class="form-control" value="<?php echo $row->offer_c_total_amt; ?>"><Br>
					<span class="label label-danger">Enter Total Offer Amount</span>
				</div>
				<div class="col-lg-4">
					<input type="text" placeholder="Enter Offer Qty" name="offer_c_qty" id="offer_c_qty" class="form-control" value="<?php echo $row->offer_c_qty; ?>"><br>
					<span class="label label-danger">Enter Offer Qty</span>
				</div>

				<label class="col-lg-2 control-label">Buy X Qty , Get it for Y total</label>
			</div>


			<div class="form-group container_offer_tag">
				<div class="col-lg-10">

					<input type="hidden" name="offer_tag_id" id="offer_tag_id" value="<?php echo $row->offer_tag_id; ?>" />

					<div class="row " data-toggle="modal" data-target="#tags_offer_modal">
						<div class="col-lg-11">
						</div>
						<div class="col-lg-1 card_tag ">
							<div class="tag_img_border">
								<?php if ($row->offer_tag_id == 0) { ?>
									<img id="selected_tag_offer_image" src="<?php echo config("site_url"); ?>/assets/upload/tags/none.png" class='img-responsive'>
								<?php } else { ?>
									<img id="selected_tag_offer_image" src="<?php echo config("site_url"); ?>/assets/upload/tags/<?php echo GetTagImage($row->offer_tag_id); ?>" class='img-responsive'>

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
					<div class="row " data-toggle="modal" data-target="#tags_modal">
						<div class="col-lg-11">
						</div>
						<div class="col-lg-1 card_tag ">
							<div class="tag_img_border">
								<?php if ($row->tag_id == 0) { ?>
									<img id="selected_tag_image" src="<?php echo config("site_url"); ?>/assets/upload/tags/none.png" class='img-responsive'>
								<?php } else { ?>
									<img id="selected_tag_image" src="<?php echo config("site_url"); ?>/assets/upload/tags/<?php echo GetTagImage($row->tag_id); ?>" class='img-responsive'>

								<?php } ?>


							</div>
						</div>

					</div>
				</div>
				<label class="col-lg-2 control-label">Select Tag Image</label>
			</div>

			<div class="form-group">
				<div class="col-lg-6"></div>
				<div class="col-lg-4">
					<input class="form-control" type="text" name="meta_title" placeholder="<?= $this->settings['hebrew_text']['product_add_meta_title_placeholder']; ?>" value="<?php echo $row->meta_title; ?>">
				</div>
				<label class="col-lg-2 control-label"><?= $this->settings['hebrew_text']['product_add_meta_title_lbl']; ?></label>
			</div>


			<div class="form-group">
				<div class="col-lg-6"></div>
				<div class="col-lg-4">
					<textarea class="form-control" name="meta_desc" cols="35" rows="7"><?php echo $row->meta_desc; ?></textarea>
				</div>
				<label class="col-lg-2 control-label"><?= $this->settings['hebrew_text']['product_add_meta_desc_lbl']; ?></label>
			</div>

			<div class="form-group">
				<div class="col-lg-6"></div>
				<div class="col-lg-4">
					<input class="form-control" type="text" name="meta_keyword" placeholder="<?= $this->settings['hebrew_text']['product_add_meta_keyword_placeholder']; ?>" value="<?php echo $row->meta_keyword; ?>">
				</div>
				<label class="col-lg-2 control-label"><?= $this->settings['hebrew_text']['product_add_meta_keyword_lbl']; ?></label>
			</div>

			<div class="form-group">

				<div class="col-lg-6"></div>
				<div class="col-lg-4">
					<input class="form-control" type="text" id="page_url_edit" name="page_url" placeholder="<?= $this->settings['hebrew_text']['product_page_url_placeholder']; ?>" aria-describedby="basic-addon1" value="<?php echo $row->page_url; ?>">
					<input type="hidden" name="edit_id" id="edit_id" value="<?php echo $row->id; ?>">
					<span style="color:red"><?= $this->settings['hebrew_text']['product_dis_wa_msg_lbl']; ?></span>

				</div>
				<label class="col-lg-2 control-label"><?= $this->settings['hebrew_text']['product_page_url_lbl']; ?></label>
			</div>

			<div class="form-group error_cls_edit" style="display: none;">

				<div class="col-lg-10">
					<div class='alert alert-danger'><?= $this->settings['hebrew_text']['product_already_exists_lbl']; ?></div>
				</div>
			</div>

			<div class="form-group">
				<div class="col-sm-10">
					<input class="btn <?= $this->settings['success_color']; ?>" type="submit" name="btn_update" id="btn_update" value="<?= $this->settings['hebrew_text']['Update']; ?>" />
				</div>
			</div>

		</form>

	</div><!-- panel body -->






	<div class="portlet-title">
		<div class="caption">
			<i class="icon-image font-blue-sharp"></i>
			<span class="caption-subject font-blue-sharp bold uppercase"><?= $this->settings['hebrew_text']['image_gallery']; ?></span>
		</div>
	</div>

	<div class="portlet-body form">
		<form method="POST" class="form-horizontal" id="form_product1">
			<div class="form-group">
				<div class="col-lg-6">
				</div>
				<div class="col-lg-2">

				</div>
				<div class="col-lg-2">
					<label class="label" data-toggle="tooltip" style="cursor: pointer;" title="<?= $this->settings['hebrew_text']['select_product_image']; ?>">
						<img style="display: none;" class="img-square" id="avatar" src="<?php echo base_url("assets/img-placeholder.jpg"); ?>" alt="avatar">

						<input type="file" class="sr-only" id="input" name="image_person" accept="image/*">
						<button type="button" id="btn-add-p-image" name="btn-add-p-image" class="btn btn-primary btn-sm">
							<?= $this->settings['hebrew_text']['select_product_image']; ?>
						</button>
					</label>

				</div>
				<label class="col-lg-2 control-label"><?= $this->settings['hebrew_text']['product_image']; ?></label>

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




	<div class="portlet-title">
		<div class="caption">
			<i class="icon-image font-blue-sharp"></i>
			<span class="caption-subject font-blue-sharp bold uppercase"><?= $this->settings['hebrew_text']['video_gallery']; ?></span>
		</div>
	</div>

	<div class="portlet-body form">
		<form method="POST" class="form-horizontal" id="form_product_video">
			<input type="hidden" name="hidden_pid" id="hidden_pid" value="" />
			<div class="form-group">
				<div class="col-lg-6"></div>
				<div class="col-lg-4">
					<input type="radio" id="youtub_link" name="type_data" class="radio_sel" value="1" checked>
					<label for="Youtub Link"><?= $this->settings['hebrew_text']['youtub_link_lbl']; ?></label></br>
					<input type="radio" id="file_upload" name="type_data" class="radio_sel" value="2">
					<label for="File Upload"><?= $this->settings['hebrew_text']['file_upload_lbl']; ?></label>
				</div>
				<label class="col-lg-2 control-label"><?= $this->settings['hebrew_text']['type_data_lbl']; ?></label>
			</div>
			<div class="form-group youtub_texbox">
				<div class="col-lg-6"></div>
				<div class="col-lg-4">
					<input type="text" name="youtube_link" id="youtube_link" class="form-control" placeholder="<?= $this->settings['hebrew_text']['youtub_link_placeholder']; ?>">
				</div>
				<label class="col-lg-2 control-label"><?= $this->settings['hebrew_text']['youtube_link']; ?></label>
			</div>
			<div class="form-group video_file_upload" style="display: none;">
				<div class="col-lg-6"></div>
				<div class="col-lg-4">
					<div id="drag-and-drop-zone" class="dm-uploader p-5">
						<div class="btn btn-primary btn-block mb-5">
							<span><?= $this->settings['hebrew_text']['open_file_brower']; ?></span>
							<input type="file" name="filename" id="filename" title='<?= $this->settings['hebrew_text']['click_to_add_video_file']; ?>' accept=".mp4,.webm,.mov" />
							<input type="hidden" name="hidden_filename" id="hidden_filename" value="">
						</div>
					</div>
				</div>
				<label class="col-lg-2 control-label"><?= $this->settings['hebrew_text']['product_video']; ?></label>
			</div>

			<div class="form-group">
				<div class="col-lg-6"></div>
				<div class="col-lg-4">
					<input type="text" name="title" id="title" class="form-control" placeholder="<?= $this->settings['hebrew_text']['video_title_placeholder']; ?>">
				</div>
				<label class="col-lg-2 control-label"><?= $this->settings['hebrew_text']['video_title_lbl']; ?></label>
			</div>

			<div class="form-group">
				<div class="col-sm-10">
					<input class="btn <?= $this->settings['success_color']; ?>" type="button" name="btn_update_video" id="btn_update_video" value="<?= $this->settings['hebrew_text']['Update']; ?>" />
				</div>
			</div>

			<div class="form-group">
				<div class="col-lg-12">
					<div class="display_error"></div>
				</div>
			</div><!-- form group -->

			<div class="form-group" id="video_list">

			</div><!-- form group -->

		</form>


		</br>
		<div class="form-group seq_cls">
			<button class="btn btn-success btn-block" type="button" id="save_seq"><?= $this->settings['hebrew_text']['seq_btn_lbl']; ?></button>
			<input type="hidden" name="seq" id="seq" />
		</div><!-- form group -->

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
				</br>
				<div class="row">
					<div class="col-lg-10">
						<input type="text" class="form-control" name="alt_text" id="alt_text_val" placeholder="<?= $this->settings['hebrew_text']['alt_text_placeholder']; ?>" />
					</div>
					<label class="col-lg-2 control-label"><?= $this->settings['hebrew_text']['alt_text']; ?></label>
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

<!-- Modal modal track detail -->
<div class="modal fade" id="edit_alt_text_modal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-header">
				<button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">X</span></button>
				<h4 class="modal-title" id="myModalLabel"><?= $this->settings['hebrew_text']['edit_alt_text_title']; ?></h4>
			</div>

			<div class="modal-body">

				<div class="row">
					<div class="col-md-12">
						<form class="form-horizontal" id="form_tracking_link_name">
							<input type="hidden" name="hidden_id" id="hidden_id" value="" />
							<input type="hidden" name="hidden_pid" id="hidden_pid" value="" />

							<div class="form-group">
								<div class="col-md-10">
									<label class="control-label"><?= $this->settings['hebrew_text']['alt_text']; ?></label>
									<input type="text" class="form-control" name="alt_text" id="edit_alt_text" placeholder="<?= $this->settings['hebrew_text']['alt_text_placeholder']; ?>" value="" />
								</div>


								<div class="col-md-2">
									<label class="control-label">&nbsp;</label><br>
									<button class="btn btn-sm btn-success" type="button" id="update_alt_text_val"> <?= $this->settings['hebrew_text']['update_text']; ?></button>
								</div>

							</div>
							<!--form-group-->
						</form>
					</div><!-- col-md-12 -->


				</div><!-- row -->

			</div><!-- modal-body -->
			<div class="modal-footer">
				<button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
			</div>
		</div>
	</div>
</div>
<!-- modal track detail-->

<script type="text/javascript">
	function onlyNumberKey(evt) {

		// Only ASCII charactar in that range allowed 
		var ASCIICode = (evt.which) ? evt.which : evt.keyCode
		if (ASCIICode > 31 && (ASCIICode < 48 || ASCIICode > 57))
			return false;
		return true;
	}

	document.addEventListener('DOMContentLoaded', function() {


		$(document).on("click", ".tag_img_offer", function() {
			var id = $(this).data("id");
			$(".tag_img_offer").removeClass("active_tag");
			$(this).addClass("active_tag");
			$("#offer_tag_id").val(id);
			var row = $(this).data("row");
			$("#selected_tag_offer_image").attr("src", "<?php echo config("site_url"); ?>/assets/upload/tags/" + row.image_name);
		});

		function load_tag_offer_images() {
			$('#tag_offer_list').block({
				message: "Searching..."
			});
			var search_tag = $("#search_tag_offer").val();
			$.ajax({
				url: '<?php echo base_url("Ajax_controller/load_tag_offer_images"); ?>',
				data: {
					"search_tag": search_tag
				},
				type: 'POST',
				success: function(data) {
					//var res=$.parseJSON(data);
					$("#tag_offer_list").html(data);
					$('#tag_offer_list').unblock();
				},
				error: function(data) {
					$('#tag_offer_list').unblock();
				}
			});
		} // load tag images

		$("#search_tag_offer").keyup(function() {
			load_tag_offer_images();
		});
		load_tag_offer_images();







		$(document).on("click", ".tag_img_id", function() {
			var id = $(this).data("id");
			$(".tag_img_id").removeClass("active_tag");
			$(this).addClass("active_tag");
			$("#tag_id").val(id);
			var row = $(this).data("row");
			$("#selected_tag_image").attr("src", "<?php echo config("site_url"); ?>/assets/upload/tags/" + row.image_name);
		});


		function load_tag_images() {
			$('#tag_list').block({
				message: "Searching..."
			});
			var search_tag = $("#search_tag").val();
			$.ajax({
				url: '<?php echo base_url("Ajax_controller/load_tag_images"); ?>',
				data: {
					"search_tag": search_tag
				},
				type: 'POST',
				success: function(data) {
					//var res=$.parseJSON(data);
					$("#tag_list").html(data);
					$('#tag_list').unblock();
				},
				error: function(data) {
					$('#tag_list').unblock();
				}
			});
		} // load tag images

		$("#search_tag").keyup(function() {
			load_tag_images();
		});
		load_tag_images();



		$("#offer_a_type").change(function() {
			var vl = $(this).val();
			if (vl == "per") {
				$(".lbl_amt_per").html("Percentage");
			} else {
				$(".lbl_amt_per").html("Amount");
			}
		});

		$("#offer_a_type").trigger("change");

		$("#btn-add-p-image").click(function() {
			$("#avatar").trigger("click");
		});

		$("#offer").change(function() {
			$(".container_offer").css("display", "none");
			var vl = $(this).val();
			if (vl == "") {
				$(".container_offer_tag").css("display", "none");
			} else {
				$(".container_offer_tag").css("display", "block");
			}

			$(".container_" + vl).css("display", "block");

			if (vl == "offer_a") {

				$(".container_offer_a_unit").css("display", "block");

			}

			if (vl == "offer_b") {
				$(".container_offer_b_unit").css("display", "block");
			}

			//$("#unit").
		});



		if ($("[data-toggle='switch']").length != 0) {
			$("[data-toggle='switch']").bootstrapSwitch();
		}



		function validate_pcs_jump() {
			var has_error = 0;
			var max_u = $("#max_u").val();
			var min_u = $("#min_u").val();
			var pcs_jump = $("#pcs_jump").val();

			if (max_u == "")
				max_u = 0;
			if (min_u == "")
				min_u = 0;
			if (pcs_jump == "")
				pcs_jump = 0;

			max_u = parseInt(max_u);
			min_u = parseInt(min_u);
			pcs_jump = parseInt(pcs_jump);

			if (pcs_jump <= 0) {
				has_error = 1;
			}

			if (min_u > max_u) {
				has_error = 1;
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


			if (has_error == 1) {
				$(".error_pcs_calc").html("Wrong Value Entered.").removeClass("label-success").addClass("label-danger");
			} else {
				$(".error_pcs_calc").html("");
			}

			if (has_error == 1)
				return false;
			else
				return true;

		} //validate_pcs_jump





		$("#min_u,#max_u,#pcs_jump").keyup(function() {
			validate_pcs_jump();
		});








		$(document).on("click", ".qty-up-u", function(event) {
			event.preventDefault();
			var field = $(this).data('field');
			var qtyval = parseFloat($("#" + field).val());
			var pcs_jump = parseFloat($("#pcs_jump").val());
			if (pcs_jump <= 0)
				pcs_jump = 1;
			qtyval = qtyval + pcs_jump;
			$("#" + field).val(qtyval);
			validate_pcs_jump();
		}); // qty up click
		$(document).on("click", ".qty-down-u", function(event) {
			event.preventDefault();
			var field = $(this).data('field');
			var qtyval = parseFloat($("#" + field).val());
			var pcs_jump = parseFloat($("#pcs_jump").val());
			if (pcs_jump <= 0)
				pcs_jump = 1;
			qtyval = qtyval - pcs_jump;
			qtyval = parseFloat(qtyval);
			if (qtyval <= 0)
				qtyval = 0;
			$("#" + field).val(qtyval);
			validate_pcs_jump();
		}); // qty down click




		$("#offer_a_sell_product").change(function() {
			var pr = $(this).find(':selected').attr('data-price');
			var offer_a_qty = $("#offer_a_qty").val();
			var price_unit = $("#price_unit").val();
			var offer_a_amt = $("#offer_a_amt").val();

			var offer_a_amt = parseFloat(offer_a_qty) * parseFloat(price_unit);
			offer_a_amt = offer_a_amt + parseFloat(pr);
			$("#offer_a_amt").val(offer_a_amt);
		});

		$("#offer_a_qty").keyup(function() {
			var pr = $("#offer_a_sell_product").find(':selected').attr('data-price');
			var offer_a_qty = $("#offer_a_qty").val();
			var price_unit = $("#price_unit").val();
			var offer_a_amt = $("#offer_a_amt").val();

			var offer_a_amt = parseFloat(offer_a_qty) * parseFloat(price_unit);
			offer_a_amt = offer_a_amt + parseFloat(pr);
			$("#offer_a_amt").val(offer_a_amt);
		});








		<?php if ($row != false) { ?>
			load_images("<?php echo $row->id; ?>");
			load_video("<?php echo $row->id; ?>");

			$("#status").bootstrapSwitch('state', <?php if ($row->status == "1") {
														echo "true";
													} else {
														echo "false";
													} ?>);
			$("#withvat").bootstrapSwitch('state', <?php if ($row->withvat == "1") {
														echo "true";
													} else {
														echo "false";
													} ?>);
			$("#ref_to_inv").bootstrapSwitch('state', <?php if ($row->ref_to_inv == "1") {
															echo "true";
														} else {
															echo "false";
														} ?>);

			$(".container_offer_a_unit").css("display", "none");
			$(".container_offer_b_unit").css("display", "none");
			$(".container_offer_a_unit").css("display", "block");
			$(".container_offer_b_unit").css("display", "block");

		<?php } ?>

		$("#form_product").submit(function() {
			//$("#unit").bootstrapSwitch('disabled',false);
			//$("#weight").bootstrapSwitch('disabled',false);

			// var count = $("#select_category :selected").length;

			// count = parseInt(count);

			// if (count <= 0)

			// {

			// 	bootbox.alert("Please select Category");

			// 	return false;

			// }

			var is_valid = validate_pcs_jump();
			if (is_valid == false) {
				return false;
			}


		});


		$(document).on("click", ".remove_img", function() {
			//remove_uploaded_image
			var id = $(this).data("id");
			var name = $(this).data("name");
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
							url: '<?php echo base_url("Ajax_controller/remove_uploaded_image"); ?>',
							data: {
								id: id,
								name: name
							},
							type: "POST",
							success: function(data) {
								swal("Deleted!", "Product image file has been deleted.", "success");
								$("#tr_image_" + id).slideUp("slow");
								$("#image_names_" + id).remove();
							},
							error: function(data) {
								swal("Cancelled", "Operation Cancelled", "error");
							}
						});

					} else {
						swal("Cancelled", "Operation Cancelled", "error");
					}
				});
		}); // click on remove image

		var avatar = document.getElementById('avatar');
		var image = document.getElementById('image');
		var input = document.getElementById('input');
		var $modal = $('#modal');
		var cropper;

		input.addEventListener('change', function(e) {
			var files = e.target.files;
			var done = function(url) {
				input.value = '';
				image.src = url;
				$modal.modal('show');
			};
			var reader;
			var file;
			var url;

			if (files && files.length > 0) {
				file = files[0];
				var fileType = file.type;
				var validImageTypes = ['image/gif', 'image/jpeg', 'image/png'];
				if (!validImageTypes.includes(fileType)) {
					// invalid file type code goes here.
					$('.display_error').html('<div class="alert alert-danger">Please select valid Image</div>').show();
					window.scrollTo(0, 0);
					setTimeout(function() {
						$('.display_error').hide();
					}, 7000);

				} else {

					if (URL) {
						done(URL.createObjectURL(file));
					} else if (FileReader) {
						reader = new FileReader();
						reader.onload = function(e) {
							done(reader.result);
						};
						reader.readAsDataURL(file);
					}

				}

			}
		}); //file input change

		var cropBoxData;
		var canvasData;
		var cropper;

		$('#modal').on('shown.bs.modal', function() {
			cropper = new Cropper(image, {
				autoCropArea: 1,
				aspectRatio: 1,
				ready: function() {
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
		}).on('hidden.bs.modal', function() {
			cropBoxData = cropper.getCropBoxData();
			canvasData = cropper.getCanvasData();
			cropper.destroy();
		});


		document.getElementById('crop').addEventListener('click', function() {
			var initialAvatarURL;
			var canvas;
			var pid = $("#pid").val();
			var alt_text = $("#alt_text_val").val();
			$(".display_error").html("<div class='alert alert-info'>Uploading..</div>");
			$modal.modal('hide');
			if (cropper) {
				canvas = cropper.getCroppedCanvas({
					width: 660,
					height: 660,
					minWidth: 600,
					minHeight: 600
				});
				var croppng = canvas.toDataURL();

				//avatar.src=croppng;
				$.ajax({
					url: '<?php echo base_url("Ajax_controller/product_image_crop"); ?>',
					data: {
						pngimageData: croppng,
						pid: pid,
						alt_text: alt_text
					},
					type: 'POST',
					success: function(data) {
						console.log(data);
						$('.display_error').show();
						$(".display_error").html("<div class='alert alert-success'>Uploaded successfully.</div>");
						setTimeout(function() {
							$('.display_error').hide();
						}, 7000);
						var res = $.parseJSON(data);
						if (res.status == 1) {
							$(".uploaded_image_name").append(res.img_tag_name);
							$("#image_list").append(res.html);
							$("#alt_text_val").val('');
						}
					},
					error: function(data) {
						console.log(data);
					}
				})
			}
		}); // click on crop button and save to db


		function load_images(pid) {
			$.ajax({
				url: "<?php echo base_url("Ajax_controller/load_images");  ?>",
				data: {
					pid: pid
				},
				type: "POST",
				success: function(data) {
					var res = $.parseJSON(data);
					$("#image_list").html(res.html);
				}
			});
		}

		function load_p_comment(pid = "", add = "", comment = "") {
			var ele = $("#btn-add-p-comment");
			ele.attr("disabled", "disabled");
			if (pid == 0)
				pid = "";
			$.ajax({
				url: "<?php echo base_url("Ajax_controller/load_p_comment");  ?>",
				data: {
					pid: pid,
					add: add,
					comment: comment
				},
				type: "POST",
				success: function(data) {
					ele.removeAttr("disabled");
					var res = $.parseJSON(data);
					$("#add_product_addon_comment").val("");
					if (res.append == "1")
						$(".comment-list-container").append(res.html);
					else
						$(".comment-list-container").html(res.html);
				},
				error: function(data) {
					ele.removeAttr("disabled");
				}
			});


		}

		$("#btn-add-p-comment").click(function() {
			var ele = $(this);
			var pid = $("#pid").val();
			var vl = $("#add_product_addon_comment").val();
			var add = "";
			if (pid != "" && pid != 0) {
				add = "1";
			}
			load_p_comment(pid, add, vl);
		});




		$(document).on("click", ".remove-p-comment", function() {
			var id = $(this).data("id");
			var ele = $(this);

			var pid = $("#pid").val();
			var local = $(this).data("data-local");
			$.ajax({
				url: "<?php echo base_url("Ajax_controller/remove_p_comment");  ?>",
				data: {
					id: id
				},
				type: "POST",
				success: function(data) {
					var res = $.parseJSON(data);
					ele.parent("li").remove();
					if (pid != 0)
						load_p_comment(pid, "", "");
				}
			});
		});

		<?php if (!empty($row->id)) {
		?>
			load_p_comment(<?php echo $row->id; ?>, "", "");
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
						<?php if ($row->offer_b_pid != "") { ?>
								$("#sel_pro").val("<?php echo $row->offer_b_pid; ?>");
								$("#sel_pro").trigger("change");
						<?php } ?>
					}
				});
		});//select change event
		*/

		$("#offer").trigger("change");


		var config_ck = defaultConfig_ckeditor();
		/*config_ck.toolbar.forEach(function(obj,i){
		    if( typeof obj === 'object' ){
		        if( config_ck.toolbar[i].name == "colors" ){
		            config_ck.toolbar[i].items = [];
		        }
		    }
		});*/

		config_ck.height = 250;
		config_ck.autoParagraph = false;
		var editor1 = CKEDITOR.replace('product_spec', config_ck);
		var editor2 = CKEDITOR.replace('product_detail', config_ck);
		/*
		var config = {
		                height: 250,
		                extraPlugins: 'colorbutton,colordialog,tabletools,image',
		                allowedContent:true,
		                extraAllowedContent:"*",
		                removeDialogTabs: 'image:advanced;link:advanced',
		                toolbar : [
		                        { name: 'tools', items: [ 'Maximize' ] },
		                        { name: 'document', items: [ 'Source' ] },
		                        { name: 'basicstyles', items: [ 'Bold', 'Italic', 'Underline', 'Strike' ] },
		                        { name: 'paragraph', items: [  'JustifyLeft', 'JustifyCenter', 'JustifyRight' ,'JustifyBlock'] },
		                        { name: 'insert', items: [ 'Table','Image' ] },//'Image',
		                        { name: 'colors', items: [ 'TextColor' , 'BGColor' ] }, //'BGColor'
		                        { name: 'styles', items: [ 'Format', 'FontSize'] },//'Styles'
		                        {
						          name: 'links',
						          items: ['Link', 'Unlink']
						        },
		                        
		                    ]
		            };


					config.contentsLangDirection = 'rtl';
		            config.defaultLanguage = 'he';
		            config.language = 'he';
		            
		    var editor1 = CKEDITOR.replace('product_spec',config);

		*/


		//$("#offer_b_pid_unit").select2({ placeholder: "Select Product will be free"});






		$('#sale_products').multiSelect({

			dblClick: true,

			selectableHeader: "<input type='text' class='search-input' autocomplete='off' placeholder='<?= $this->settings['hebrew_text']['search_products']; ?>'>",

			selectionHeader: "<input type='text' class='search-input' autocomplete='off' placeholder='<?= $this->settings['hebrew_text']['search_products']; ?>'>",

			afterInit: function(ms) {

				var that = this,

					$selectableSearch = that.$selectableUl.prev(),

					$selectionSearch = that.$selectionUl.prev(),

					selectableSearchString = '#' + that.$container.attr('id') + ' .ms-elem-selectable:not(.ms-selected)',

					selectionSearchString = '#' + that.$container.attr('id') + ' .ms-elem-selection.ms-selected';



				that.qs1 = $selectableSearch.quicksearch(selectableSearchString)

					.on('keydown', function(e) {

						if (e.which === 40) {

							that.$selectableUl.focus();

							return false;

						}

					});



				that.qs2 = $selectionSearch.quicksearch(selectionSearchString)

					.on('keydown', function(e) {

						if (e.which == 40) {

							that.$selectionUl.focus();

							return false;

						}

					});

			},

			afterSelect: function(data) {

				console.log(data);

				this.qs1.cache();

				this.qs2.cache();
				add_update_sale_products(data, "add");


			},

			afterDeselect: function(data) {

				this.qs1.cache();

				this.qs2.cache();
				console.log(data);
				add_update_sale_products(data, "remove");
			}

		});




		function add_update_sale_products(id_data, action) {
			var pid = $("#pid").val();
			$.ajax({
				url: '<?= base_url("Ajax_controller/add_update_sale_products") ?>',
				type: 'POST',
				data: {
					parent_pid: pid,
					id_data: id_data,
					action: action
				},
				success: function(data) {
					console.log(data);
					load_sale_products();
				},
				error: function(data) {
					console.log(data);
				}
			});
		}

		function load_sale_products() {
			var pid = $("#pid").val();
			$.ajax({
				url: '<?= base_url("Ajax_controller/get_sale_products") ?>',
				type: 'POST',
				data: {
					pid: pid
				},
				success: function(data) {
					console.log(data);
					var res = $.parseJSON(data);
					$("#sale_product_table_container").html(res.html);
				},
				error: function(data) {
					console.log(data);
				}
			});
		} //load_sale_products


		$(document).on("click", ".btn-update-sale-price", function(data) {
			var ele = $(this);
			var id = $(this).data("id");
			var pid = $(this).data("pid");
			var parent_pid = $(this).data("parent_pid");
			var vl = $("#sale_price_" + id).val();

			if (vl == "") {
				return false;
			}

			if (parseFloat(vl) < 0) {
				return false;
			}

			$("#sale_price_" + id).attr("disabled", "disabled");
			ele.attr("disabled", "disabled");
			$.ajax({
				url: '<?= base_url("Ajax_controller/update_sale_price_products") ?>',
				type: 'POST',
				data: {
					pid: pid,
					id: id,
					parent_pid: parent_pid,
					price: vl
				},
				success: function(data) {
					console.log(data);
					var res = $.parseJSON(data);
					$("#sale_price_" + id).removeAttr("disabled");
					ele.removeAttr("disabled");
					load_sale_products();
				},
				error: function(data) {
					$("#sale_price_" + id).removeAttr("disabled");
					ele.removeAttr("disabled");
				}
			});

		});

		load_sale_products();


		$('#select_category').multiSelect({

			dblClick: true,

			selectableHeader: "<input type='text' class='search-input' autocomplete='off' placeholder='<?= $this->settings['hebrew_text']['search_category']; ?>'>",

			selectionHeader: "<input type='text' class='search-input' autocomplete='off' placeholder='<?= $this->settings['hebrew_text']['search_category']; ?>'>",

			afterInit: function(ms) {

				var that = this,

					$selectableSearch = that.$selectableUl.prev(),

					$selectionSearch = that.$selectionUl.prev(),

					selectableSearchString = '#' + that.$container.attr('id') + ' .ms-elem-selectable:not(.ms-selected)',

					selectionSearchString = '#' + that.$container.attr('id') + ' .ms-elem-selection.ms-selected';



				that.qs1 = $selectableSearch.quicksearch(selectableSearchString)

					.on('keydown', function(e) {

						if (e.which === 40) {

							that.$selectableUl.focus();

							return false;

						}

					});



				that.qs2 = $selectionSearch.quicksearch(selectionSearchString)

					.on('keydown', function(e) {

						if (e.which == 40) {

							that.$selectionUl.focus();

							return false;

						}

					});

			},

			afterSelect: function(data) {

				console.log(data);

				this.qs1.cache();

				this.qs2.cache();

			},

			afterDeselect: function() {

				this.qs1.cache();

				this.qs2.cache();

			}

		});


		$("#page_url_edit").focusout(function() {
			var ele = $(this);
			var txt = $(this).val();
			var id = $('#edit_id').val();

			if (!$(this).val()) {
				$(this).focus();
				$(this).css("border-color", "red");
				$('#btn_update').attr('disabled', 'disabled');
				return false;
			}

			var re = /^[A-Za-z\u0590-\u05fe0-9_@.#&-]*$/
			if (!re.test(txt)) {
				$(this).focus();
				$(this).css("border-color", "red");
				$('#btn_update').attr('disabled', 'disabled');
				return false;
			}


			if (txt || re) {
				$('#btn_update').attr('disabled', 'disabled');
				//ele.attr("disabled", "disabled");

				$.ajax({
					url: '<?php echo base_url("Ajax_controller/product_page_check_page_url_for_edit"); ?>',
					data: {
						id: id,
						txt: txt,
					},
					type: 'POST',
					success: function(data) {
						res = $.parseJSON(data);

						if (res.status == true && res.error == 1) {
							$('.error_cls_edit').css("display", "block");
							$('#btn_update').attr('disabled', 'disabled');

						} else {
							$('.error_cls_edit').css("display", "none");
							$('#btn_update').removeAttr('disabled');
						}


					},
					error: function(data) {
						$('#btn_update').attr('disabled', 'disabled');

					}
				});
			}
			$(this).css("border-color", "green");
		});

		$(document).on("click", ".edit_alt_text", function() {
			var ele = $(this);
			var pid = $(this).data("pid");
			var id = $(this).data("id");
			var alt_text = $(this).data("alt_text");

			$('#hidden_pid').val(pid);
			$('#hidden_id').val(id);
			$('#edit_alt_text').val(alt_text);

			$("#edit_alt_text_modal").modal("show");

		});

		$(document).on("click", "#update_alt_text_val", function() {
			var ele = $(this);
			var pid = $('#hidden_pid').val();
			var id = $('#hidden_id').val();
			var alt_text = $('#edit_alt_text').val();

			$.ajax({
				url: '<?php echo base_url("Ajax_controller/update_alt_text"); ?>',
				data: {
					id: id,
					alt_text: alt_text,
				},
				type: 'POST',
				success: function(data) {
					res = $.parseJSON(data);
					if (res.status == true && res.error == 1) {
						$("#edit_alt_text_modal").modal("hide");
						load_images(pid);
					}

				},
				error: function(data) {


				}
			});
		});


		$(".radio_sel").change(function() {

			var sel_val = $("input[name='type_data']:checked").val();
			console.log(sel_val);
			if (sel_val == '1') {
				$('.youtub_texbox').show();
				$('.video_file_upload').hide();
			} else {
				$('.video_file_upload').show();
				$('.youtub_texbox').hide();
			}
		});

		$('#drag-and-drop-zone').dmUploader({ //


			url: '<?php echo base_url("Ajax_controller/video_file_upload"); ?>',
			maxFileSize: 20000000, // 20 MB max
			multiple: false,
			acceptedFiles: 'webm|mov|mp4',

			onDragEnter: function() {
				// Happens when dragging something over the DnD area
				this.addClass('active');
				$('#btn_update_video').attr("disabled", "disabled");
			},
			onDragLeave: function() {
				// Happens when dragging something OUT of the DnD area
				this.removeClass('active');
			},
			onInit: function() {
				// Plugin is ready to use
				// ui_add_log('Penguin initialized :)', 'info');


			},

			onUploadProgress: function(id, percent) {
				$('#btn_update_video').attr("disabled", "disabled");
				// Updating file progress
				//ui_single_update_progress(this, percent);
			},
			onUploadSuccess: function(id, data) {
				$('#btn_update_video').attr("disabled", "disabled");
				var response = JSON.stringify(data);
				// You should probably do something with the response data, we just show it
				$('.display_error').show();
				// $(".display_error").html("<div class='alert alert-success'>Uploaded successfully.</div>");
				setTimeout(function() {
					$('.display_error').hide();
				}, 7000);
				var res = $.parseJSON(data);
				if (res.status == 1) {
					$("#btn_update_video").removeAttr("disabled");
					$('#hidden_filename').val(res.filename);
					$(".display_error").html("<div class='alert alert-success'>Uploaded successfully.</div>");
				} else {
					$("#btn_update_video").removeAttr("disabled");
					$(".display_error").html("<div class='alert alert-danger'>" + res.error + "</div>");
					console.log(res.error);
				}

			},
			onUploadError: function(id, xhr, status, message) {
				bootbox.alert('Error: ' + message);
				//$('.image_container_2').unblock();
			},
			onFallbackMode: function() {},
			onFileSizeError: function(file) {
				bootbox.alert("<?= $this->settings['hebrew_text']['upload_video_file_size_error_msg']; ?>");
			},
			onFileTypeError: function(file) {
				bootbox.alert("<?= $this->settings['hebrew_text']['upload_video_file_error_msg']; ?>");
			}
		});

		$(document).on("click", "#btn_update_video", function() {
			$('#btn_update_video').attr("disabled", "disabled");
			var pid = $("#pid").val();
			$('#hidden_pid').val(pid);
			var type_data = $("input[name='type_data']:checked").val();
			if (type_data == '1') {
				var error = 0;
				var youtube_link = $("#youtube_link").val();
				if (youtube_link == '' || youtube_link == 'undefined') {
					$("#btn_update_video").removeAttr("disabled");
					bootbox.alert("<?= $this->settings['hebrew_text']['youtub_link_valdation_msg']; ?>");
					$("#youtube_link").addClass('errorClass');
					error = 1;
					return false;
				}
			}
			if (type_data == '2') {
				var error = 0;
				var hidden_filename = $("#hidden_filename").val();
				if (hidden_filename == '' || hidden_filename == 'undefined') {
					$("#btn_update_video").removeAttr("disabled");
					bootbox.alert("<?= $this->settings['hebrew_text']['upload_video_file_validation_msg']; ?>");
					error = 1;
					return false;
				}
			}

			if (error == 0) {
				$.ajax({
					url: '<?php echo base_url("Ajax_controller/ajax_add_product_video_data"); ?>',
					type: 'POST',
					data: $("#form_product_video").serialize(),
					success: function(data) {
						$("#btn_update_video").removeAttr("disabled");
						$("#video_list").append(data.html);
						load_video("<?php echo $row->id; ?>");
						$("#youtube_link").val('');
						$("#hidden_filename").val('');
						$("#title").val('');
						$('#youtub_link').trigger('click');
					}
				});
			}


		});


		function load_video(pid) {
			$.ajax({
				url: "<?php echo base_url("Ajax_controller/load_videos");  ?>",
				data: {
					pid: pid
				},
				type: "POST",
				success: function(data) {
					var res = $.parseJSON(data);
					if (res.html == '') {
						$('.seq_cls').hide();
					} else {
						//$('#btn_update_video').attr("disabled", "disabled");
						$("#video_list").html(res.html);
						$('.seq_cls').show();
					}
				}
			});
		}


		$(document).on("click", ".remove_video", function() {
			//remove_uploaded_image
			var id = $(this).data("id");
			var name = $(this).data("name");

			swal({
					title: "<?= $this->settings['hebrew_text']['are_you_sure_msg_title']; ?>",
					text: "<?= $this->settings['hebrew_text']['are_you_sure_msg_text']; ?>",
					type: "warning",
					showCancelButton: true,
					confirmButtonClass: "btn-danger",
					confirmButtonText: "<?= $this->settings['hebrew_text']['yes_btn_text']; ?>",
					cancelButtonText: "<?= $this->settings['hebrew_text']['no_btn_text']; ?>",
					closeOnConfirm: false,
					closeOnCancel: false
				},
				function(isConfirm) {
					if (isConfirm) {
						$.ajax({
							url: '<?php echo base_url("Ajax_controller/remove_uploaded_video"); ?>',
							data: {
								id: id,
								name: name
							},
							type: "POST",
							success: function(data) {
								swal("<?= $this->settings['hebrew_text']['video_del_suc_msg']; ?>", "<?= $this->settings['hebrew_text']['video_del_suc_sub_msg']; ?>", "success");
								$(".tr_video_" + id).slideUp("slow");
								load_video("<?php echo $row->id; ?>");
							},
							error: function(data) {
								swal("<?= $this->settings['hebrew_text']['video_del_cancel_msg']; ?>", "<?= $this->settings['hebrew_text']['video_del_cancel_sub_msg']; ?>", "error");
							}
						});

					} else {
						swal("<?= $this->settings['hebrew_text']['video_del_cancel_msg']; ?>", "<?= $this->settings['hebrew_text']['video_del_cancel_sub_msg']; ?>", "error");
					}
				});
		}); // click on remove image

		$("#video_list").sortable({
			update: function(event, ui) {}
		});
		$("#video_list").disableSelection();

		$("#save_seq").click(function() {

			var itemOrder = $('#video_list').sortable("toArray");

			// console.log(itemOrder);
			// console.log(JSON.stringify(itemOrder));

			var re1 = JSON.stringify(itemOrder);
			$("#seq").val(re1);
			var ele = $(this);
			ele.attr("disabled", "disabled");
			$.ajax({
				url: '<?php echo base_url("Ajax_controller/product_video_seq"); ?>',
				data: {
					seq: re1
				},
				type: "POST",
				success: function(data) {
					swal("<?= $this->settings['hebrew_text']['seq_success_title_msg']; ?>", "<?= $this->settings['hebrew_text']['seq_success_msg']; ?>", "success");
					ele.removeAttr("disabled");
				},
				error: function(data) {
					swal("<?= $this->settings['hebrew_text']['seq_cancell_title_msg']; ?>", "<?= $this->settings['hebrew_text']['seq_cancell_msg']; ?>", "error");
					ele.removeAttr("disabled");
				}
			})

		});


		$(document).on("click", ".view_video", function() {
			var type = $(this).data("type");
			var url_link = $(this).data("url");

			window.open(url_link, '_blank');

			//console.log(url_link);
		});

	}); //document load
</script>