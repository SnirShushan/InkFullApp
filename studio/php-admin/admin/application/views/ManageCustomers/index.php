<div class="portlet light bordered">


    <div class="portlet-body form">
        <div class="row" style="margin-bottom: 10px;">
            <div class="col-md-12">

            </div>
        </div>

        <div class="table-responsive">
            <table class="table ink-table customers_list" id="customers_list">
                <thead>
                    <tr>
                        <th><?= $this->settings['hebrew_text']['cust_name']; ?></th>
                        <th><?= $this->settings['hebrew_text']['cust_email']; ?></th>
                        <th><?= $this->settings['hebrew_text']['cust_phone']; ?></th>
                        <th><?= $this->settings['hebrew_text']['cust_register_type']; ?></th>
                        <th><?= $this->settings['hebrew_text']['cust_user_type']; ?></th>
                        <th><?= $this->settings['hebrew_text']['cust_status']; ?></th>
                    </tr>
                </thead>
            </table>
        </div>


    </div><!-- panel body -->
</div>

<script type="text/javascript">
    document.addEventListener('DOMContentLoaded', function() {



        search_param = {};

        table = $('#customers_list').DataTable({
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
                    url: BASE_URL + "/ajax_ssp/getCustomersList",
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

            language: {
                processing: '<i class="fa fa-spinner fa-spin fa-3x fa-fw"></i><span class="sr-only">Loading...</span>',
                url: "//cdn.datatables.net/plug-ins/9dcbecd42ad/i18n/Hebrew.json"
                /*emptyTable :    "No student available",
                zeroRecords :   "No matching student found",
                info :  "Showing _START_ to _END_ of _TOTAL_ students",
                infoEmpty : "Showing 0 to 0 of 0 students",
                infoFiltered :  "(filtered from _MAX_ total students)",*/
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


    }); //document load
</script>