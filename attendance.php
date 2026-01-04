<?php
header('Content-Type: application/json');
include 'db.php';

if ($_SERVER['REQUEST_METHOD'] === 'GET') {
  $sql = "SELECT id, student_id, class_id, timestamp, status FROM attendance ORDER BY timestamp DESC LIMIT 500";
  $res = $conn->query($sql);
  $data = [];
  while ($row = $res->fetch_assoc()) { $data[] = $row; }
  echo json_encode($data);
  $conn->close();
  exit();
}

$payload = json_decode(file_get_contents('php://input'), true);
$student_id = $payload['student_id'] ?? null;
$class_id = $payload['class_id'] ?? null;
$status = $payload['status'] ?? null;
if (!$student_id || !$status) { http_response_code(400); echo json_encode(["error"=>"missing fields"]); exit(); }

$stmt = $conn->prepare("INSERT INTO attendance (student_id, class_id, status) VALUES (?, ?, ?)");
$stmt->bind_param("sis", $student_id, $class_id, $status);
$ok = $stmt->execute();

# log
$desc = "Student $student_id - class $class_id - status $status";
$stmt2 = $conn->prepare("INSERT INTO logs (action, description) VALUES ('push_attendance', ?)");
$stmt2->bind_param("s", $desc);
$stmt2->execute();

echo json_encode(["ok"=>$ok, "id"=>$conn->insert_id]);
$conn->close();
?>