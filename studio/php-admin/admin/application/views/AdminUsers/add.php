<div class="page-content0">

    <div class="row">
        <div class="col-md-12">
            <?php 
                if($error != ""){
                    ?>
                    <div class="alert alert-danger">
                        <?=$error?>
                    </div>
                    <?php 
                }

                $success_msg = get_flashdata("msg_success");
                if($success_msg){ ?>
                <div class="alert alert-success">
                    <?=$success_msg?>
                </div>
            <?php } ?>
        </div>
        <div class="col-md-12">

            <form enctype="multipart/form-data" method="POST" action="" id="form_add_admin_user">
            <div class="portlet light bordered">
                <div class="portlet-title">
                    <div class="caption font-red-sunglo0" style="0color: #008000c7;">
                        <div class="row">
                            <div class="col-md-12">
                                <div class="form-g-title">
                                    <h4>Add Admin User</h4>
                                </div>
                            </div>
                        </div>
                    </div>

                </div>
                <div class="portlet-body form">
                    <div class="form-body">


                        <div class="row">
                            <div class="col-md-6">
                                <div class="form-group">
                                    <label>Name <span class="required">*</span></label>
                                    <input type="text" class="form-control" placeholder="Name" name="name" data-msg-required="Please enter name" value="<?=_value($row->name)?>" >                                
                                </div>
                            </div>
                        </div>

                      
                        <div class="row">
                            <div class="col-md-6">
                                <div class="form-group">
                                    <label>Email <span class="required">*</span></label>
                                    <div class="input-group input-icon right">
                                        <span class="input-group-addon">
                                            <i class="fa fa-envelope font-purple"></i>
                                        </span>

                                        <input type="text" class="form-control" placeholder="Email" name="email" autocomplete="off"  data-msg-required="Please enter emial" data-msg-remote="This email is already existed, please enter other email" value="" >
                                    </div>
                                </div>
                            </div>
                          
                        </div>



                        <div class="row">
                            <div class="col-md-12">
                                <br>
                            </div>
                        </div>

                        <div class="form-actions">
                            <button type="submit" class="btn blue">Submit</button>
                            <button type="button" class="btn default">Cancel</button>
                        </div>

                    </div>
                </div>

            </div>
            </form>

        </div>
    </div>

</div>
    
<script type="text/javascript">
window.addEventListener('DOMContentLoaded',function(event){

    $('#frmNewInstitute').myvalidate({
        rules: {
            name: {
                minlength: 2,
                maxlength: 255,
                required: true
            },
            country_id:{
                required: true
            },
            phone_number:{
                required: true
            },
            email: {
                required: true,
                myemail:true,
                /*remote: {
                  url: base_url + "ajax_service/email_existed/",
                  type: "post",
                  data: { email: function() { return $("#frmNewInstitute").find("input[name='email']").val(); }, skip_id:'<?=$row->id?>' }
                }*/
            },
        },

        messages: {
            payment: {
                maxlength: jQuery.validator.format("Max {0} items allowed for selection"),
                minlength: jQuery.validator.format("At least {0} items must be selected")
            }
        },

        errorPlacement: function(error, element) {
            var group = element.closest(".form-group");
            if (element.attr("name") == "email") {
                error.insertAfter(element.parent());
            }else {
                error.insertAfter(element);
            }
        },

        submitHandler: function(form) {
            form.submit();
        }
    });

});
function submit_form(){
    $('#frmNewInstitute').submit();
}
</script>