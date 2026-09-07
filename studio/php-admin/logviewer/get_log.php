<?php
header('Content-Type: application/json');

if (!isset($_GET['id'])) {
    echo json_encode(['error' => 'Missing id parameter']);
    exit;
}

$id = (int) $_GET['id'];
$db_name=date('m-Y').'.db';
if(isset($_REQUEST['db_name']))
{
    $db_name=$_REQUEST['db_name'].".db";
}
try {
    $db = new PDO('sqlite:../assets/uploads/local_db/'.$db_name);
    $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    $stmt = $db->prepare("SELECT id, action, req, res, date_added FROM tbl_action_log WHERE id = ?");
    $stmt->execute([$id]);
    $row = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$row) {
        echo json_encode(['error' => 'Record not found']);
        exit;
    }

    echo json_encode(['data' => $row]);
} catch (Exception $e) {
    echo json_encode(['error' => $e->getMessage()]);
}
?>
