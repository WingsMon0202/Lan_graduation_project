<?php
header('Content-Type: application/json');
include 'db.php';
$payload = json_decode(file_get_contents('php://input'), true);
$student_id = $payload['student_id'] ?? null;
$name = $payload['name'] ?? null;
$class_id = $payload['class_id'] ?? null;
if (!$student_id || !$name) { http_response_code(400); echo json_encode(["error"=>"missing fields"]); exit(); }

$stmt = $conn->prepare("INSERT INTO students (student_id, name, class_id) VALUES (?, ?, ?)");
$stmt->bind_param("ssi", $student_id, $name, $class_id);
$ok = $stmt->execute();
echo json_encode(["ok"=>$ok]);
$conn->close();
?>