<?php
header('Content-Type: application/json');
include 'db.php';
$payload = json_decode(file_get_contents('php://input'), true);
$name = $payload['class_name'] ?? null;
$teacher = $payload['teacher'] ?? null;
if (!$name) { http_response_code(400); echo json_encode(["error"=>"missing class_name"]); exit(); }
$stmt = $conn->prepare("INSERT INTO classes (class_name, teacher) VALUES (?, ?)");
$stmt->bind_param("ss", $name, $teacher);
$ok = $stmt->execute();
echo json_encode(["ok"=>$ok, "id"=>$conn->insert_id]);
$conn->close();
?>