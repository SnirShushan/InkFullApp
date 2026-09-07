<?php
header('Content-Type: application/json');

$draw = $_POST['draw'] ?? 1;
$start = $_POST['start'] ?? 0;
$length = $_POST['length'] ?? 10;
$searchValue = $_POST['search']['value'] ?? '';

$orderColumnIndex = $_POST['order'][0]['column'] ?? 0;
$orderDirection = $_POST['order'][0]['dir'] ?? 'desc';
$orderDirection = strtolower($orderDirection) === 'asc' ? 'ASC' : 'DESC';

$columns = ['id', 'action', 'req', 'res', 'date_added'];
$orderColumn = $columns[$orderColumnIndex] ?? 'id';

$db_name=date('m-Y').'.db';
if(isset($_REQUEST['db_name']))
{
    $db_name=$_REQUEST['db_name'].".db";
}

try {
    $db = new PDO('sqlite:../assets/uploads/local_db/'.$db_name);
    $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    // Total records
    $total = $db->query("SELECT COUNT(*) FROM tbl_action_log")->fetchColumn();

    // Filtered count
    $filterQuery = "SELECT COUNT(*) FROM tbl_action_log";
    $params = [];
    if (!empty($searchValue)) {
        $filterQuery .= " WHERE action LIKE :search OR date_added LIKE :search";
        $params[':search'] = "%$searchValue%";
    }
    $filtered = $db->prepare($filterQuery);
    $filtered->execute($params);
    $recordsFiltered = $filtered->fetchColumn();

    // Fetch paginated data
    $dataQuery = "SELECT id, action, req, res, date_added FROM tbl_action_log";
    if (!empty($searchValue)) {
        $dataQuery .= " WHERE action LIKE :search OR date_added LIKE :search";
    }
    $dataQuery .= " ORDER BY $orderColumn $orderDirection LIMIT :start, :length";

    $stmt = $db->prepare($dataQuery);
    if (!empty($searchValue)) {
        $stmt->bindValue(':search', "%$searchValue%", PDO::PARAM_STR);
    }
    $stmt->bindValue(':start', (int)$start, PDO::PARAM_INT);
    $stmt->bindValue(':length', (int)$length, PDO::PARAM_INT);
    $stmt->execute();

    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
    foreach ($rows as &$row) {
        $row['req_preview'] = substr($row['req'], 0, 60) . (strlen($row['req']) > 60 ? '...' : '');
        $row['res_preview'] = substr($row['res'], 0, 60) . (strlen($row['res']) > 60 ? '...' : '');
        unset($row['req'], $row['res']);
    }

    echo json_encode([
        "draw" => intval($draw),
        "recordsTotal" => intval($total),
        "recordsFiltered" => intval($recordsFiltered),
        "data" => $rows
    ]);

} catch (Exception $e) {
    echo json_encode([
        "draw" => intval($draw),
        "recordsTotal" => 0,
        "recordsFiltered" => 0,
        "data" => [],
        "error" => $e->getMessage()
    ]);
}
?>