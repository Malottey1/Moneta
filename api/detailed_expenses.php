<?php
include 'db_config.php';

$user_id = $_GET['user_id'];
$current_month = date('Y-m');

$query = "
    SELECT 
        date, 
        category_name, 
        amount, 
        description 
    FROM Expenses 
    JOIN Categories ON Expenses.category_id = Categories.category_id 
    WHERE user_id = ? AND DATE_FORMAT(date, '%Y-%m') = ?";

$stmt = $mysqli->prepare($query);
$stmt->bind_param('is', $user_id, $current_month);
$stmt->execute();
$result = $stmt->get_result();

$response = [];
while ($row = $result->fetch_assoc()) {
    $response[] = $row;
}

echo json_encode($response);

$mysqli->close();
?>