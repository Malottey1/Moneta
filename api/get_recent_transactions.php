<?php
include 'db_config.php';

$user_id = $_GET['user_id'];

$query = "SELECT e.date, c.category_name as category, e.amount 
          FROM Expenses e 
          JOIN Categories c ON e.category_id = c.category_id 
          WHERE e.user_id = ? 
          ORDER BY e.date DESC 
          LIMIT 4";

$stmt = $mysqli->prepare($query);
$stmt->bind_param('i', $user_id);
$stmt->execute();
$result = $stmt->get_result();

$transactions = array();
while ($row = $result->fetch_assoc()) {
    $transactions[] = $row;
}

echo json_encode($transactions);

$stmt->close();
$mysqli->close();
?>