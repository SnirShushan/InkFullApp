<div class="portlet light bordered">
    <div class="portlet-body form">
        <div class="row" style="margin-bottom: 10px;">
            <div class="col-md-12">
            </div>
        </div>
        <div class="table-responsive">
            <table class="table ink-table regular_user_list" id="regular_user_list">
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

<script type="text/javascript">
    document.addEventListener('DOMContentLoaded', function() {

        var q_id = [];
        search_param = {};
        var check_select_arr=[];
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
            if ($.fn.dataTable.isDataTable('#regular_user_list')) {
                $('#regular_user_list').DataTable().destroy();  // Destroy existing DataTable instance
            }
            table = $('#regular_user_list').DataTable({
                processing: true,
                serverSide: true,

                orderCellsTop: true,
                //fixedHeader: true,
                //scrollY: true,

                ajax: function(data, callback) {
                    data['user_type'] = "regular";

                    $.each(search_param, function(k, v) {
                        data[k] = v;
                    });

                    $.ajax({
                        url: BASE_URL + "/ajax_ssp/getUsersList",
                        data: data,
                        type: "post",
                        dataType: 'json',
                        beforeSend: function() {},
                        success: function(res) {
                            access = GetACL(res.access);
                            callback(res);
                            intialize_xeditable();
                        }
                    });
                },

                // language: {customLanguageData},  // Use the modified language data
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
                    [11, "desc"]
                ],
                columnDefs: [
                    {
                        render: ActionBar_render_checkbox,
                        orderable:false,
                        targets: 0
                    },
                ],

                createdRow: function(row, data, dataIndex) {
                    //$( row ).find('td:eq('+dataIndex+')').addClass("red");
                    //parseInt(data[6])
                },


                buttons: [],

            });
        }

        // table = $('#regular_user_list').DataTable({
        //     processing: true,
        //     serverSide: true,

        //     orderCellsTop: true,
        //     //fixedHeader: true,
        //     //scrollY: true,

        //     ajax: function(data, callback) {
        //         data['user_type'] = "regular";

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
        //             }
        //         });
        //     },

        //     language: {
        //         processing: '<i class="fa fa-spinner fa-spin fa-3x fa-fw"></i><span class="sr-only">Loading...</span>',
        //         url: "//cdn.datatables.net/plug-ins/9dcbecd42ad/i18n/Hebrew.json"
        //         /*emptyTable :    "No student available",
        //         zeroRecords :   "No matching student found",
        //         info :  "Showing _START_ to _END_ of _TOTAL_ students",
        //         infoEmpty : "Showing 0 to 0 of 0 students",
        //         infoFiltered :  "(filtered from _MAX_ total students)",*/
        //     },

        //     lengthMenu: [
        //         [10, 25, 50, -1],
        //         [10, 25, 50, "All"]
        //     ],
        //     order: [
        //         [11, "desc"]
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
                    // $('#regular_user_list').DataTable().ajax.reload();
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
                    // url: "<?php echo base_url("Ajax_controller/store_regular_user_ids"); ?>",
                    url: "<?php echo base_url("Ajax_controller/store_business_user_ids"); ?>",
                    async:false,
                    data:{
                        type:1,
                        'search_param': search_value
                    },
                    type:'POST',
                    success:function(res){
                        var data = $.parseJSON(res);
                        //console.log(data.s_id);
                        check_select_arr = data.s_id;
                    },
                    error:function(data){}
                });
            }else{
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

    }); //document load
</script>