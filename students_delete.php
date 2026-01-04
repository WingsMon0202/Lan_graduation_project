<?php
header('Content-Type: application/json');
include 'db.php';
$payload = json_decode(file_get_contents('php://input'), true);
$student_id = $payload['student_id'] ?? null;
if (!$student_id) { http_response_code(400); echo json_encode(["error"=>"missing student_id"]); exit(); }
$stmt = $conn->prepare("DELETE FROM students WHERE student_id=?");
$stmt->bind_param("s", $student_id);
$ok = $stmt->execute();
echo json_encode(["ok"=>$ok]);
$conn->close();
?>