<?php
header('Content-Type: application/json');
include 'db.php';
$res = $conn->query("SELECT id, action, description, timestamp FROM logs ORDER BY timestamp DESC LIMIT 100");
$data = [];
while ($row = $res->fetch_assoc()) { $data[] = $row; }
echo json_encode($data);
$conn->close();
?>