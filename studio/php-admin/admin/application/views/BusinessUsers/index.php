
<style>
    .datepicker-inline {
        width: auto;
    }
    .modal-body {
        background-color: #fff;
    }
</style>

<div class="portlet light bordered">
    <div class="portlet-body form">
        <div class="row" style="margin-bottom: 10px;">
            <div class="col-md-12">
            </div>
        </div>
        <div class="table-responsive">
            <table class="table ink-table business_user_list" id="business_user_list">
                <thead>
                    <tr>
                        <th>
                            <input type="checkbox" id="selectall"><span class="total_cust_record"></span>
                        </th>
                        <th><?= $this->settings['hebrew_text']['cust_name']; ?></th>
                        <th><?= $this->settings['hebrew_text']['cust_email']; ?></th>
                        <th><?= $this->settings['hebrew_text']['cust_phone']; ?></th>
                        <th><?= $this->settings['hebrew_text']['cust_register_type']; ?></th>
                        <th><?= $this->settings['hebrew_text']['cust_user_type']; ?></th>
                        <th><?= $this->settings['hebrew_text']['cust_status']; ?></th>
                        <th><?= $this->settings['hebrew_text']['subscription_plan']; ?></th>
                        <th><?= $this->settings['hebrew_text']['exp_date']; ?></th>
                        <th><?= $this->settings['hebrew_text']['plan_status']; ?></th>
                        <th><?= $this->settings['hebrew_text']['image_limit']; ?></th>
                        <th><?= $this->settings['hebrew_text']['view_signature']; ?></th>
                        <th style="display:none;"></th>
                    </tr>
                </thead>
            </table>
        </div>
    </div><!-- panel body -->
</div>

<div class="portlet light bordered">
    <div class="portlet-body form">
        <div class="row" style="margin-bottom: 10px;">
            <div class="col-md-12">
                <h4><?= $this->settings['hebrew_text']['Send Push Notification']; ?></h4>
            </div>
        </div>
        <div class="row">
            <div class="col-md-12">
                <form method="POST" id="frm_send_data" name="frm_send_data" enctype="multipart/form-data">
                    <div class="form-group row">
                        <input type="hidden" name="cid" id="cid" value="">
                        <input type="hidden" name="send_type" id="send_type" value="">
                        <div class="col-md-10">
                            <input type="text" class="form-control" name="title" id="title">
                        </div>
                        <label class="col-md-2 col-form-label"><?= $this->settings['hebrew_text']['Title']; ?></label>
                    </div>
                    <div class="form-group row">
                        <div class="col-md-10">
                            <textarea rows="5" cols="5" name="description" id="description" class="form-control" placeholder=""></textarea>
                        </div>
                        <label class="col-md-2 col-form-label"><?= $this->settings['hebrew_text']['Description']; ?></label>
                    </div>
                    <div class="form-group">
                        <input type="button" name="btn_send_push_notification" id="btn_send_push_notification" class="btn btn-info" value="<?= $this->settings['hebrew_text']['Send Push Notification']; ?>">
                    </div>
                </form> 
            </div>
        </div>
    </div><!-- panel body -->
</div>

<!-- Add Remark modal start -->
<div class="modal fade" id="md_view_signature" tabindex="-1" aria-labelledby="exampleModalLabel" aria-hidden="true">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-header">
				<h5 class="modal-title" id="exampleModalLabel"><?= $this->settings['hebrew_text']['view_signature']; ?></h5>
				<!-- <button type="button" class="close" data-dismiss="modal" aria-label="Close">
					<span aria-hidden="true">&times;</span>
				</button> -->
			</div>
			<div class="modal-body">
                <div class="text-center">
                    <img src="" alt="" name="signature" id="signature" height="200px" width="200px">
                </div>
			</div>
			<div class="modal-footer">
				<button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
			</div>
		</div>
	</div>
</div>
<!-- Add Remark modal end -->

<script type="text/javascript">
    document.addEventListener('DOMContentLoaded', function() {

        var q_id = [];
        search_param = {};
        var check_select_arr=[];
        var signature_img_path = "<?=BASE_URL('../assets/uploads/signature_images/');?>";
        var table = "";

        var ActionBar_render_checkbox = function(data, type, row)
        {
            var u_checked="";
            $.map(check_select_arr, function(elementOfArray, indexInArray) {
                if (elementOfArray == row[0]) {
                    u_checked = "checked";
                }
            });
            var html= "<input style='margin: 0px 8px;' type='checkbox' " + u_checked + " class='checkbox' id='check_" + row[0] + "' data-id='" + row[0] + "'>";
            return html;
        };

        // Define the variable outside of getJSON
        let customLanguageData = {};  // This will store the modified language data

        // Fetch the Hebrew localization data
        /* $.getJSON("//cdn.datatables.net/plug-ins/9dcbecd42ad/i18n/Hebrew.json", function(languageData) {
            // Modify the language data and store it in the external variable
            customLanguageData = languageData;
            customLanguageData.sInfoFiltered = ""; // Remove the filtered message

            // Initialize DataTable inside the callback to ensure language data is loaded
            initializeDataTable();
        }); */
        initializeDataTable();

        // Function to initialize DataTable using the modified language data
        function initializeDataTable() {
            if ($.fn.dataTable.isDataTable('#business_user_list')) {
                $('#business_user_list').DataTable().destroy();  // Destroy existing DataTable instance
            }
            table = $('#business_user_list').DataTable({
                processing: true,
                serverSide: true,

                ajax: function(data, callback) {
                    data['user_type'] = "business";
                    $.each(search_param, function(k, v) {
                        data[k] = v;
                    });

                    $.ajax({
                        url: BASE_URL + "/ajax_ssp/getUsersList",
                        data: data,
                        type: "post",
                        dataType: 'json',
                        success: function(res) {
                            access = GetACL(res.access);
                            callback(res);
                            intialize_xeditable();
                        }
                    });
                },

                // language: customLanguageData,  // Use the modified language data
                language: {
                    processing: "מעבד...",
                    search: "חיפוש:",
                    lengthMenu: "הצג _MENU_ רשומות",
                    info: "מציג _START_ עד _END_ מתוך _TOTAL_ רשומות",
                    // infoEmpty: "מציג 0 עד 0 מתוך 0 רשומות",
                    infoFiltered: "",
                    loadingRecords: "טוען...",
                    zeroRecords: "לא נמצאו רשומות מתאימות",
                    emptyTable: "אין נתונים בטבלה",
                },

                lengthMenu: [
                    [10, 25, 50, -1],
                    [10, 25, 50, "All"]
                ],
                order: [
                    [12, "desc"]
                ],
                columnDefs: [
                    {
                        render: ActionBar_render_checkbox,
                        orderable: false,
                        targets: 0
                    },
                ],

                createdRow: function(row, data, dataIndex) {
                    // Custom row behavior here
                },

                buttons: [],

            });
        }

        // table = $('#business_user_list').DataTable({
        //     processing: true,
        //     serverSide: true,

        //     orderCellsTop: true,
        //     //fixedHeader: true,
        //     //scrollY: true,

        //     ajax: function(data, callback) {
        //         data['user_type'] = "business";

        //         $.each(search_param, function(k, v) {
        //             data[k] = v;
        //         });

        //         $.ajax({
        //             url: BASE_URL + "/ajax_ssp/getUsersList",
        //             data: data,
        //             type: "post",
        //             dataType: 'json',
        //             beforeSend: function() {},
        //             success: function(res) {
        //                 access = GetACL(res.access);
        //                 callback(res);
        //                 intialize_xeditable();
        //                 /* $(".exp_change").datepicker({
        //                     format: "d-m-yyyy",
        //                 }); */
        //             }
        //         });
        //     },

        //     language: {
        //         processing: '<i class="fa fa-spinner fa-spin fa-3x fa-fw"></i><span class="sr-only">Loading...</span>',
        //         url: "//cdn.datatables.net/plug-ins/9dcbecd42ad/i18n/Hebrew.json",
        //         /*emptyTable :    "No student available",
        //         zeroRecords :   "No matching student found",
        //         info :  "Showing _START_ to _END_ of _TOTAL_ students",
        //         infoEmpty : "Showing 0 to 0 of 0 students",
        //         infoFiltered :  "(filtered from _MAX_ total students)",*/
        //         sInfoFiltered: "",
        //     },

        //     lengthMenu: [
        //         [10, 25, 50, -1],
        //         [10, 25, 50, "All"]
        //     ],
        //     order: [
        //         [12, "desc"]
        //     ],
        //     columnDefs: [
        //         {
        //             render: ActionBar_render_checkbox,
        //             orderable:false,
        //             targets: 0
        //         },
        //     ],

        //     createdRow: function(row, data, dataIndex) {
        //         //$( row ).find('td:eq('+dataIndex+')').addClass("red");
        //         //parseInt(data[6])
        //     },


        //     buttons: [],

        // });

        function intialize_xeditable()
        {

            $('.post-limit').on('shown', function(e, editable) {
                editable.input.$input.keypress(function (e) {
                    var chCode = ('charCode' in e) ? e.charCode : e.keyCode;
                    if(!( chCode < 46 || chCode > 57  ))
                        return(true);
                    else
                        return(false);
                });
            })
            .editable({
                source: '',
                url: base_url + "Ajax_controller/change_user_post_limit",
                ajaxOptions: {
                    dataType: 'json' //assuming json response
                },
                success: function(data, config) {
                    // $('#business_user_list').DataTable().ajax.reload();
                    initializeDataTable();
                },
                error: function(errors) {
                    var msg = '';
                    if (errors && errors.responseText) { 
                        msg = errors.responseText;
                    } else { 
                        $.each(errors, function(k, v) {
                            msg += k + ": " + v + "<br>";
                        });
                    }
                }
            }).on('save', function(e, params) {
            });

            $('.exp_change').each(function() {
                var exp_date = $(this).data('value'); // Get the expiry date from the data attribute
                // console.log("Initial Expiry Date:", exp_date);

                // Ensure the date is in the correct format: dd/mm/yyyy
                var dateObj = new Date(exp_date);
                if (isNaN(dateObj.getTime())) {
                    console.error("Invalid Date:", exp_date);
                    return; // Skip if date is invalid
                }

                var day = String(dateObj.getDate()).padStart(2, '0');
                var month = String(dateObj.getMonth() + 1).padStart(2, '0');
                var year = dateObj.getFullYear();
                
                var formattedExpDate = `${day}/${month}/${year}`; // Format: dd/mm/yyyy
                exp_date = `${year}-${month}-${day}`; // Format: dd/mm/yyyy
                // console.log("Formatted Expiry Date:", formattedExpDate);

                // Initialize the editable field
                $(this).editable({
                    type: 'date',
                    placement: 'top',
                    format: "dd-mm-yyyy",       // Date format stored in the database
                    viewformat: 'dd/mm/yyyy',   // Date format displayed to users
                    defaultValue: formattedExpDate, // Set the dynamically formatted default value
                    datepicker: {
                        weekStart: 1,
                        autoclose: true,
                        clearBtn: false,
                    },
                    url: base_url + "Ajax_controller/change_user_expire_date",
                    ajaxOptions: {
                        dataType: 'json',
                    },
                    title: 'Select a date',
                    success: function(data, config) {
                        // $('#business_user_list').DataTable().ajax.reload();
                        initializeDataTable();
                    },
                    validate: function(value) {
                        // Parse and compare dates for validation
                        var dateObj = new Date(value);
                        var day = String(dateObj.getDate()).padStart(2, '0'); // Ensure 2-digit day
                        var month = String(dateObj.getMonth() + 1).padStart(2, '0'); // Ensure 2-digit month
                        var year = dateObj.getFullYear();

                        sel_date = `${year}-${month}-${day}`;
                        // console.log("selected date : " + sel_date);
                        // console.log("exp date : " + exp_date);
                        
                        const selected_date = new Date(sel_date);
                        const current_date = new Date(exp_date);

                        if (selected_date < current_date) {
                            // console.log("Date1 is before Date2");
                            return "Date must be after the expiry date.";
                        }
                    },
                    error: function(errors) {
                        var msg = '';
                        if (errors && errors.responseText) {
                            msg = errors.responseText;
                        } else {
                            $.each(errors, function(k, v) {
                                msg += k + ": " + v + "<br>";
                            });
                        }
                        $('.editable-error-block').html(msg).show(); // Display errors if any
                    }
                }).on('shown', function(e, editable) {
                    // document.querySelector('.editable-clear a').click(); 

                    document.querySelector('.editable-clear a').addEventListener('click', function (event) {
                        event.preventDefault(); // Prevent the default action of the link

                        // Option 1: Clear the text inside the error block
                        document.querySelector('.editable-error-block').textContent = ''; 

                        // Option 2: Hide the error block
                        document.querySelector('.editable-error-block').style.display = 'none'; 

                        // Reset the datepicker to the original expiry date
                        $(editable).datepicker('update', exp_date); // Update the internal datepicker value
                        $(editable).datepicker('setDate', new Date(exp_date)); // Set the datepicker UI to the new date
                        $(editable).find('input').val(formattedExpDate).trigger('change'); // Update the input value too
                        console.log("Date reset to:", formattedExpDate); // Debug log
                    });
                });
            });
            
        } //intialize_xeditable

        $("#btn_send_push_notification").prop('disabled',true);
        var title = $("#title").val();
        var description = $("#description").val();
        
        $("#title,#description").keyup(function(){
            if($(this).val() != ""){
                $("#btn_send_push_notification").removeAttr('disabled');
            }
            else{
                $("#btn_send_push_notification").prop('disabled',true);
            }
        });

        $(document).on('click', '.checkbox', function() { 
            var id = $(this).data("id");
            if($("#check_"+id+"").prop('checked') == true){
                check_select_arr.push(id);
            }else{
                check_select_arr = $.grep(check_select_arr, function(value) {
                    return value != id;
                });
            }
            if(check_select_arr.length > 0){
                // var checkbox_html=" <strong>"+check_select_arr.length+"</strong> selected";
                // $(".total_cust_record").html(checkbox_html);
                $("#cid").val(check_select_arr);
            }else{
                // $(".total_cust_record").html("");
            }
        });

        $(document).on('click', '#selectall', function() {            
            $(".checkbox").prop("checked", this.checked);
            search_value = table.search();
            if($("#selectall").prop('checked') == true){
                $.ajax({
                    url: "<?php echo base_url("Ajax_controller/store_business_user_ids"); ?>",
                    async:false,
                    data:{
                        'type':2,
                        'search_param': search_value
                    },
                    type:'POST',
                    success:function(res){
                        var data = $.parseJSON(res);
                        check_select_arr = data.s_id;
                    },
                    error:function(data){}
                });
            }else {
                check_select_arr = [];
            }
            if(check_select_arr.length > 0){
                // var checkbox_html = " <strong>"+check_select_arr.length+"</strong> selected";
                // $(".total_cust_record").html(checkbox_html);
                $("#cid").val(check_select_arr);
            }else{
                // $(".total_cust_record").html("");
                $("#cid").val(check_select_arr);
            }
        });

        $("#btn_send_push_notification").on("click",function(){
            //console.log("send push notification button is click");
            $("#send_type").val("push").appendTo($('#frm_send_data'));
            var cid = $("#cid").val();
            var error = 0;
            if(cid == ""){
                error = 1;
                swal("<?= $this->settings['hebrew_text']['Please select user for send push notification']; ?>");
                return false;
            }
            else{
                error = 0;
            }

            if(error == 1){
                $('body').scrollTop(0);
                return false;
            }
            else{
                var form_data = $("#frm_send_data").serialize();
                $("#btn_send_push_notification").prop('disabled',true);
                $.ajax({
                    url: "<?=base_url('Ajax_controller/send_notification')?>",
                    data: form_data,
                    type: "post",
                    success: function(data) {
                        var notification_json = $.parseJSON(data);
                        if(notification_json.status == 1){
                            swal("<?= $this->settings['hebrew_text']['Push Notification send Successfully']; ?>");
                            $("#title").val("");
                            $("#description").val("");
                            $("#btn_send_push_notification").prop('disabled',true);
                            $(".checkbox").each(function(){
                                this.checked = false;
                            });
                            check_select_arr = [];
                            $("#cid").val("");
                        }
                    }
                });
            }
        });

        $(document).on("click",".btn_view_signature",function(){
            var img_name = $(this).data("img_name");
            $("#md_view_signature").modal("show");
            $("#signature").attr("src", signature_img_path+img_name);
        });

        /* $(document).on('changeDate', ".exp_change", function() {
            var sub_id = $(this).data("sub_id");
            selected_date = $(this).datepicker('getFormattedDate');
            console.log("selected date : " + selected_date);
            
            bootbox.confirm({
                message: "האם אתה משנה את תאריך התפוגה?",
                closeButton: false,
                buttons: {
                    confirm: {
                        label: 'כן',
                    },
                    cancel: {
                        label: 'לא',
                    }
                },
                callback: function (result) {
                    if(result){
                        $.ajax({
                            url: base_url + "Ajax_controller/change_user_expire_date",
                            type: 'POST',
                            data: {
                                "sub_id": sub_id,
                                "exp_date": selected_date
                            },
                            success: function(response) {
                                var data = JSON.parse(response);
                                if (data.status == 1) {
                                    bootbox.alert({
                                        message: "Expire date Changed Successfully",
                                        closeButton: false,
                                        buttons: {
                                            ok: {
                                                className: 'btn-cyan'
                                            }
                                        },
                                    });
                                    $('#business_user_list').DataTable().ajax.reload();
                                }
                            }
                        });
                    }
                }
            });
        }); */

    }); //document load
</script>