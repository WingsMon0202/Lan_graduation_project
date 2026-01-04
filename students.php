<?php
header('Content-Type: application/json');
include 'db.php';
$res = $conn->query("SELECT student_id, name, class_id FROM students");
$data = [];
while ($row = $res->fetch_assoc()) { $data[] = $row; }
echo json_encode($data);
$conn->close();
?>