<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Action Log Viewer</title>

  <!-- Bootstrap CSS -->
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
  <link rel="stylesheet" href="https://cdn.datatables.net/1.13.8/css/dataTables.bootstrap5.min.css">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/abodelot/jquery.json-viewer@latest/json-viewer/jquery.json-viewer.css">

  <style>
    #jsonContent {
      background-color: #f8f9fa;
      padding: 15px;
      border-radius: 5px;
      max-height: 500px;
      overflow: auto;
    }
  </style>
</head>
<body class="p-4">
  <div class="container">
    <h2 class="mb-4">Action Log Viewer</h2>
<?php 
$start_month = 10; // October
$start_year = 2025;

$current_month = (int)date('n'); // 'n' gives month number (1-12)
$current_year = (int)date('Y'); // 'Y' gives 4-digit year

$month_names = [
    1 => 'January', 2 => 'February', 3 => 'March', 4 => 'April',
    5 => 'May', 6 => 'June', 7 => 'July', 8 => 'August',
    9 => 'September', 10 => 'October', 11 => 'November', 12 => 'December'
];

?>

<div class="row">
    <div class="col-md-3">
      <select id="year" name="year" class="form-control"  >
            <?php
            for ($y = $start_year; $y <= $current_year; $y++) {
                $selected = ($y == $current_year) ? 'selected' : '';
                echo "<option value=\"$y\" $selected>$y</option>\n";
            }
            ?>
      </select>
    </div>

  <div class="col-md-3">
    <select id="month" name="month" class="form-control" >
        <?php for ($m = 1; $m <= 12; $m++) {
            $selected = ($m == $current_month) ? 'selected' : '';
            $m_formatted = sprintf('%02d', $m);
            echo "<option value='$m_formatted' $selected>{$month_names[$m]}</option>\n";
        } ?>
    </select>
  </div>

</div>

    <table id="logTable" class="table table-bordered table-striped align-middle">
      <thead>
        <tr>
          <th>ID</th>
          <th>Action</th>
          <th>Request</th>
          <th>Response</th>
          <th>Date Added</th>
        </tr>
      </thead>
    </table>
  </div>

  <!-- Modal -->
  <div class="modal fade" id="jsonModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-scrollable">
      <div class="modal-content">
        <div class="modal-header">
          <h5 class="modal-title">JSON Data</h5>
          <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
        </div>
        <div class="modal-body">
          <div id="jsonContent"></div>
        </div>
      </div>
    </div>
  </div>

  <!-- JS Libraries -->
  <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
  <script src="https://cdn.datatables.net/1.13.8/js/jquery.dataTables.min.js"></script>
  <script src="https://cdn.datatables.net/1.13.8/js/dataTables.bootstrap5.min.js"></script>
  <script src="https://cdn.jsdelivr.net/gh/abodelot/jquery.json-viewer@latest/json-viewer/jquery.json-viewer.js"></script>

  <script>
    $(document).ready(function() {
      const table = $('#logTable').DataTable({
            serverSide: true,       // enable server-side
            processing: true,       // show "processing" indicator
            ajax: {
                url: 'fetch_logs.php',
                type: 'POST',
                data: function (d) {
                    d.db_name = $("#month").val().trim()+"-"+$("#year").val().trim();
                    
                }
            },
            columns: [
                { data: 'id' },
                { data: 'action' },
                {
                    data: 'req_preview',
                    orderable: false,
                    searchable: false,
                    render: function(data, type, row) {
                        return `<button class="btn btn-sm btn-primary view-json" data-id="${row.id}" data-type="req">View</button>`;
                    }
                },
                {
                    data: 'res_preview',
                    orderable: false,
                    searchable: false,
                    render: function(data, type, row) {
                        return `<button class="btn btn-sm btn-success view-json" data-id="${row.id}" data-type="res">View</button>`;
                    }
                },
                { data: 'date_added' },
                
            ],
            order: [[4, 'desc']],
            "pageLength" : 25,
        });

      
      $(document).on('change', '#year,#month', function() {
        console.log($("#month").val().trim()+"-"+$("#year").val().trim());
          table.ajax.reload();
      });
      
      // Handle button click to fetch full JSON
      $('#logTable').on('click', '.view-json', function() {
        const id = $(this).data('id');
        const type = $(this).data('type');
        const modal = new bootstrap.Modal(document.getElementById('jsonModal'));

        $('#jsonContent').html('<div class="text-center text-muted">Loading...</div>');
        $('#jsonModal .modal-title').text(type.toUpperCase() + ' JSON Data');
        modal.show();

        $.ajax({
          url: 'get_log.php',
          data: { id },
          dataType: 'json',
          success: function(res) {
            if (res.data) {
              let jsonString = res.data[type];
              try {
                let obj = JSON.parse(jsonString);
                $('#jsonContent').jsonViewer(obj, {
                  collapsed: false,
                  withQuotes: true,
                  withLinks: true
                });
              } catch (e) {
                $('#jsonContent').text(jsonString);
              }
            } else {
              $('#jsonContent').html('<div class="text-danger">Failed to load JSON</div>');
            }
          },
          error: function() {
            $('#jsonContent').html('<div class="text-danger">Error fetching data</div>');
          }
        });
      });
    });
  </script>
</body>
</html>
