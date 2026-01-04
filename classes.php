<?php
header('Content-Type: application/json');
include 'db.php';
$res = $conn->query("SELECT id, class_name, teacher FROM classes");
$data = [];
while ($row = $res->fetch_assoc()) { $data[] = $row; }
echo json_encode($data);
$conn->close();
?>