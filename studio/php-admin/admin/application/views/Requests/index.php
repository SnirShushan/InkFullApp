<div class="portlet light bordered">

    <div class="portlet-body form">
        <div class="row" style="margin-bottom: 10px;">
            <div class="col-md-12">

            </div>
        </div>

        <div class="row">
            <div class="col-md-3"></div>
            <div class="col-md-3">
                <div class="form-group">
                    <br>
                    <input type="button" name="btn_reset" id="btn_reset" class="btn btn-danger" value="<?= $this->settings['hebrew_text']['Reset Filter']; ?>">
                </div>
            </div>
            <div class="col-md-3">
                <div class="form-group">
                    <label for=""><?= $this->settings['hebrew_text']['End Date']; ?> :</label>
                    <input type="text" class="form-control" name="end_datepicker" id="end_datepicker" autocomplete="off">
                    <input type="hidden" id="end_date">
                </div>
            </div>
            <div class="col-md-3">
                <div class="form-group">
                    <label for=""><?= $this->settings['hebrew_text']['Start Date']; ?> :</label>
                    <input type="text" class="form-control" name="start_datepicker" id="start_datepicker" autocomplete="off">
                    <input type="hidden" id="start_date">
                </div>
            </div>
        </div>
        <div class="table-responsive">
            <table class="table ink-table" id="request_list">
                <thead>
                    <tr>                        
                        <th><?= $this->settings['hebrew_text']['cust_name']; ?></th>
                        <th><?= $this->settings['hebrew_text']['cust_phone']; ?></th>
                        <th><?= $this->settings['hebrew_text']['Tattoo Size']; ?></th>
                        <th><?= $this->settings['hebrew_text']['User Name']; ?></th>
                        <th><?= $this->settings['hebrew_text']['Artist']; ?></th>
                        <th><?= $this->settings['hebrew_text']['Business']; ?></th>
                        <th><?= $this->settings['hebrew_text']['Request Addedd']; ?></th>
                        <th><?= $this->settings['hebrew_text']['Action']; ?></th>
                    </tr>
                </thead>
            </table>
        </div>

    </div><!-- panel body -->
</div>

<script type="text/javascript">
    document.addEventListener('DOMContentLoaded', function() {

        var start_date = '';
        var end_date = '';
        // start date picker
        $('#start_datepicker').datepicker({})
        .on('changeDate', function() {
            $('#request_list').dataTable().fnDestroy();
            $('#start_date').val(
                $('#start_datepicker').datepicker('getFormattedDate')
            );
            $(this).datepicker('hide');

            start_date = $('#start_date').val();
            request_data();
        });

        // end date picker
        $('#end_datepicker').datepicker({})
        .on('changeDate', function() {
            $('#request_list').dataTable().fnDestroy();
            $('#end_date').val(
                $('#end_datepicker').datepicker('getFormattedDate')
            );
            $(this).datepicker('hide');

            end_date = $('#end_date').val();
            request_data();
        });

        search_param = {};

        function request_data(){
            start_datepicker = $("#start_datepicker").val();
            end_datepicker = $("#end_datepicker").val();

            table = $('#request_list').DataTable({
                processing: true,
                serverSide: true,
    
                orderCellsTop: true,
                //fixedHeader: true,
                //scrollY: true,
    
                ajax: function(data, callback) {
    
                    $.each(search_param, function(k, v) {
                        data[k] = v;
                    });
    
                    data['start_date'] = start_datepicker;
                    data['end_date'] = end_datepicker;
                    $.ajax({
                        url: BASE_URL + "/ajax_ssp/getRequestsList",
                        data: data,
                        type: "post",
                        dataType: 'json',
                        beforeSend: function() {},
                        success: function(res) {
                            access = GetACL(res.access);
                            callback(res);
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
                    [7, "desc"]
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
        }

        request_data();

        $(document).on("click","#btn_reset",function(){
            $('#request_list').dataTable().fnDestroy();
            $("#start_datepicker").datepicker().val("");
            $("#end_datepicker").datepicker().val("");
            $("#start_date").val("");
            $("#end_date").val("");
            request_data();
        });

    }); //document load
</script>