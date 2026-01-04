<?php
header('Content-Type: application/json');
include 'db.php';

// Query thống kê
$total_students = $conn->query("SELECT COUNT(*) as c FROM students")->fetch_assoc()['c'];
$total_classes = $conn->query("SELECT COUNT(*) as c FROM classes")->fetch_assoc()['c'];

// Học sinh đi học hôm nay
$today = date("Y-m-d");
$present = $conn->query("SELECT COUNT(DISTINCT student_id) as c 
                         FROM attendance 
                         WHERE DATE(timestamp)='$today' AND status='present'")
                ->fetch_assoc()['c'];


// Học sinh vắng hôm nay = tổng - đi học
$absent = $total_students - $present;

echo json_encode([
    "total_students" => $total_students,
    "today_present" => $present,
    "today_absent" => $absent,
    "total_classes" => $total_classes
]);
