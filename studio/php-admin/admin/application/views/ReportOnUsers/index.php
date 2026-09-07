<div class="portlet light bordered">

    <div class="portlet-body form">
        <div class="row" style="margin-bottom: 10px;">
            <div class="col-md-12">

            </div>
        </div>

        <div class="table-responsive">
            <table class="table ink-table report_user_list" id="report_user_list">
                <thead>
                    <tr>
                        <th><?= $this->settings['hebrew_text']['cust_name']; ?></th>
                        <th><?= $this->settings['hebrew_text']['reported_by_user']; ?></th>
                        <th><?= $this->settings['hebrew_text']['comment']; ?></th>
                        <th><?= $this->settings['hebrew_text']['cust_status']; ?></th>
                    </tr>
                </thead>
            </table>
        </div>

    </div><!-- panel body -->
</div>

<script type="text/javascript">
    document.addEventListener('DOMContentLoaded', function() {

        <?php 
            $arr_status=array('0'=>'Request Pending','1'=>'User Blocked','2'=>'Keep User');
        ?>

        search_param = {};

        table = $('#report_user_list').DataTable({
            processing: true,
            serverSide: true,

            orderCellsTop: true,
            //fixedHeader: true,
            //scrollY: true,

            ajax: function(data, callback) {

                $.each(search_param, function(k, v) {
                    data[k] = v;
                });

                $.ajax({
                    url: BASE_URL + "/ajax_ssp/getReortedUsersList",
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

            // language: {
            //     processing: '<i class="fa fa-spinner fa-spin fa-3x fa-fw"></i><span class="sr-only">Loading...</span>',
            //     url: "//cdn.datatables.net/plug-ins/9dcbecd42ad/i18n/Hebrew.json"
            //     /*emptyTable :    "No student available",
            //     zeroRecords :   "No matching student found",
            //     info :  "Showing _START_ to _END_ of _TOTAL_ students",
            //     infoEmpty : "Showing 0 to 0 of 0 students",
            //     infoFiltered :  "(filtered from _MAX_ total students)",*/
            // },

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
                [0, "desc"]
            ],
            columnDefs: [],

            createdRow: function(row, data, dataIndex) {
                //$( row ).find('td:eq('+dataIndex+')').addClass("red");
                //parseInt(data[6])
            },

            /*dom: `<'row'<'col-md-7' <'row'<'col-md-3'l > <'col-md-9' 
                <'row' <'col-md-6' B > <'col-md-6' <'toolbar'> > >
             > > > <'col-md-5'f>r>t<'row'<'col-md-12'p i>>`,*/

            buttons: [],

        });

        function intialize_xeditable(){

            $('.status').editable({

                source: <?php echo json_encode($arr_status); ?>,
                url:base_url + "Ajax_controller/report_status",
                ajaxOptions: {
                    dataType: 'json' //assuming json response
                },
                success: function(data, config) {
                    $('#report_user_list').DataTable().ajax.reload();
                    // document.location.reload();
                },
                error: function(errors) {
                    var msg = '';
                    if(errors && errors.responseText) { //ajax error, errors = xhr object
                        msg = errors.responseText;
                    } else { //validation error (client-side or server-side)
                        $.each(errors, function(k, v) { msg += k+": "+v+"<br>"; });
                    } 
                    //$('#msg').removeClass('alert-success').addClass('alert-error').html(msg).show();
                }
            }).on('save', function(e, params) {
                    //alert('Saved value: ' + params.newValue);
                    //$(this).data('editable');
            });
        }//intialize_xeditable

    }); //document load
</script>