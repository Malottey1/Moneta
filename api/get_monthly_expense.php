<?php
include 'db_config.php';

$user_id = $_GET['user_id'];
$current_month = date('Y-m');
$first_day = $current_month . '-01';
$last_day = date('Y-m-t', strtotime($first_day));

$query = "SELECT COALESCE(SUM(amount), 0) as total_spent 
          FROM Expenses 
          WHERE user_id = ? 
          AND date BETWEEN ? AND ?";

$stmt = $mysqli->prepare($query);
$stmt->bind_param('iss', $user_id, $first_day, $last_day);
$stmt->execute();
$result = $stmt->get_result();

$total_spent = $result->fetch_assoc()['total_spent'];

echo json_encode(['total_spent' => $total_spent]);

$stmt->close();
$mysqli->close();
?>