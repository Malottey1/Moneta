<?php
include 'db_config.php';

$user_id = $_GET['user_id'];

$query = "
    SELECT 
        DATE_FORMAT(date, '%Y-%m') as month, 
        SUM(amount) as total_amount 
    FROM Expenses 
    WHERE user_id = ?
    GROUP BY DATE_FORMAT(date, '%Y-%m')
    ORDER BY date";

$stmt = $mysqli->prepare($query);
$stmt->bind_param('i', $user_id);
$stmt->execute();
$result = $stmt->get_result();

$response = [];
while ($row = $result->fetch_assoc()) {
    $response[] = $row;
}

echo json_encode($response);

$mysqli->close();
?>