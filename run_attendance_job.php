<?php
include 'db.php';

// Xác định ca chạy
$hour = date('H');

if ($hour < 12) {
    // Ca sáng
    $start = date('Y-m-d 00:00:00');
    $end   = date('Y-m-d 11:59:59');
} else {
    // Ca chiều
// 	$start = '2025-8-17 00:00:00';
// $end   = '2025-8-17 23:59:59';
   $start = date('Y-m-d 12:00:00');
   $end   = date('Y-m-d 23:59:59');
}

// Gọi stored procedure
$sql = "CALL calc_attendance_summary(?, ?)";
$stmt = $conn->prepare($sql);
$stmt->bind_param("ss", $start, $end);
$stmt->execute();

echo "Attendance summary updated";

$conn->close();
?>
