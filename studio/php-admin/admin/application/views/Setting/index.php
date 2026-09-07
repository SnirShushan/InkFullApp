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

      <div class="form-group">
        <div class="col-lg-6"></div>
        <div class="col-lg-4">
          <input class="form-control" type="text" id="admin_email" name="admin_email" placeholder=" אימייל של האדמין " value="<?= $setting['admin_email']; ?>">
        </div>
        <label class="col-lg-2 control-label"> אימייל של האדמין </label>
      </div>

      <div class="form-group">
        <div class="col-lg-6"></div>
        <div class="col-lg-4">
          <input class="form-control" type="text" id="admin_phone" name="admin_phone" placeholder=" מספר טלפון של האדמין " value="<?= $setting['admin_phone']; ?>">
        </div>
        <label class="col-lg-2 control-label"> מספר טלפון של האדמין </label>
      </div>

      <div class="form-group">
        <div class="col-sm-10">
          <input class="btn <?= $this->settings['success_color']; ?>" type="submit" name="btn_update" value="<?= $this->settings['hebrew_text']['Add']; ?>" />
        </div>
      </div>
    </form>

  </div><!-- panel body -->
</div>

<div class="portlet light bordered">

  <div class="portlet-body form">
    <form method="POST" class="form-horizontal" id="frm_image_upload" enctype="multipart/form-data">

      <div class="form-group">
        <div class="col-lg-6"></div>
        <div class="col-lg-4">
          <div class="form-group">
            <input type="file" name="startup_image" class="form-control" id="startup_image" accept="image/*">
          </div>
        </div>
        <label class="col-lg-2 control-label"> העלה תמונה </label>
      </div>
      
      <div class="col-lg-10 text-right" style="margin-bottom:15px;">
        <img class="img-responsive" src="<?=base_url('../assets/uploads/'.$setting['startup_image']);?>" alt="startup image" >
      </div>
      <div class="col-lg-2"></div>

      <div class="form-group">
        <div class="col-sm-10">
          <input class="btn <?= $this->settings['success_color']; ?>" type="submit" name="btn_image_update" value="<?= $this->settings['hebrew_text']['Update']; ?>" />
        </div>
      </div>
    </form>

  </div><!-- panel body -->
</div>

<div class="portlet light bordered">

  <div class="portlet-body form">
    <form method="POST" class="form-horizontal" id="frm_trial_subscription" enctype="multipart/form-data">

      <div class="form-group">
        <div class="col-lg-6"></div>
        <div class="col-lg-4">
          <div class="form-group">
            <select class="form-control" name="package_name" id="package_name" >
              <option value="">---Select trial days---</option>
              <option value="subscription_premium_5day,subscription_basic_5day" <?= ($setting['package_name'] == 'subscription_premium_5day,subscription_basic_5day')?'selected':'' ?>> 5 Days Trail</option>
              <option value="subscription_premium_10day,subscription_basic_10day" <?= ($setting['package_name'] == 'subscription_premium_10day,subscription_basic_10day')?'selected':'' ?>> 10 Days Trail</option>
              <option value="subscription_premium_15day,subscription_basic_15day" <?= ($setting['package_name'] == 'subscription_premium_15day,subscription_basic_15day')?'selected':'' ?>> 15 Days Trail</option>
              <option value="subscription_premium_20day,subscription_basic_20day" <?= ($setting['package_name'] == 'subscription_premium_20day,subscription_basic_20day')?'selected':'' ?>> 20 Days Trail</option>
            </select>
          </div>
        </div>
        <label class="col-lg-2 control-label"> ימי ניסיון </label>
      </div>

      <div class="form-group">
        <div class="col-sm-10">
          <input class="btn <?= $this->settings['success_color']; ?>" type="submit" name="btn_update_package_name" value="<?= $this->settings['hebrew_text']['Update']; ?>" />
        </div>
      </div>
    </form>

  </div><!-- panel body -->
</div>

<div class="portlet light bordered">

  <div class="portlet-body form">
    <form method="POST" class="form-horizontal" id="frm_trial_subscription" enctype="multipart/form-data">

      <div class="form-group">
        <div class="col-lg-6"></div>
        <div class="col-lg-4">
          <input class="form-control" onkeypress="return isNumberKey(event)" type="text" id="post_limit" name="post_limit" value="<?= $setting['post_limit']; ?>">
        </div>
        <label class="col-lg-2 control-label"> מגבלת פוסטים </label>
      </div>

      <div class="form-group">
        <div class="col-sm-10">
          <input class="btn <?= $this->settings['success_color']; ?>" type="submit" name="btn_update_post_limit" value="<?= $this->settings['hebrew_text']['Update']; ?>" />
        </div>
      </div>
    </form>
  </div><!-- panel body -->
</div>


<script type="text/javascript">
  document.addEventListener('DOMContentLoaded', function() {

    $("#admin_email").tagsinput();
    $("#admin_phone").tagsinput();
    $("#package_name").select2({
      dir: "rtl",
      language: "he",
      placeholder: "Select a Package Name",
    });

    $("#remove_image").click(function(){
      console.log("remove_image");
      $("#currunt_image").hide();
      $("#remove_image").hide();
    });
    
  });
</script>