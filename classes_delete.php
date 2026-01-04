<?php
header('Content-Type: application/json');
include 'db.php';
$payload = json_decode(file_get_contents('php://input'), true);
$id = $payload['id'] ?? null;
if (!$id) { http_response_code(400); echo json_encode(["error"=>"missing id"]); exit(); }
$stmt = $conn->prepare("DELETE FROM classes WHERE id=?");
$stmt->bind_param("i", $id);
$ok = $stmt->execute();
echo json_encode(["ok"=>$ok]);
$conn->close();
?>