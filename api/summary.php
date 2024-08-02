<?php
include 'db_config.php';

$user_id = $_GET['user_id'];
$current_month = date('Y-m');

$query = "
    SELECT 
        SUM(amount) as total_expenses, 
        GROUP_CONCAT(DISTINCT category_name) as categories 
    FROM Expenses 
    JOIN Categories ON Expenses.category_id = Categories.category_id 
    WHERE user_id = ? AND DATE_FORMAT(date, '%Y-%m') = ?";

$stmt = $mysqli->prepare($query);
$stmt->bind_param('is', $user_id, $current_month);
$stmt->execute();
$result = $stmt->get_result();

$response = $result->fetch_assoc();
$response['time_period'] = 'monthly';

echo json_encode($response);

$mysqli->close();
?>