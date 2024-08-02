<?php
include 'db_config.php';

$user_id = $_GET['user_id'];
$current_month = date('Y-m');

$query = "
    SELECT 
        category_name, 
        SUM(amount) as total_amount, 
        (SUM(amount) / (SELECT SUM(amount) FROM Expenses WHERE user_id = ? AND DATE_FORMAT(date, '%Y-%m') = ?)) * 100 as percentage 
    FROM Expenses 
    JOIN Categories ON Expenses.category_id = Categories.category_id 
    WHERE user_id = ? AND DATE_FORMAT(date, '%Y-%m') = ?
    GROUP BY category_name";

$stmt = $mysqli->prepare($query);
$stmt->bind_param('isis', $user_id, $current_month, $user_id, $current_month);
$stmt->execute();
$result = $stmt->get_result();

$response = [];
while ($row = $result->fetch_assoc()) {
    $response[] = $row;
}

echo json_encode($response);

$mysqli->close();
?>