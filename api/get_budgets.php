<?php
include 'db_config.php';

// Retrieve the user id
$user_id = $_GET['user_id'];

// Fetch budgets and calculate spent amount for each budget
$query = "
    SELECT 
        b.budget_id, 
        b.user_id, 
        b.category_id, 
        b.amount, 
        b.start_date, 
        b.end_date, 
        c.category_name,
        IFNULL(SUM(e.amount), 0) as spent
    FROM Budgets b
    LEFT JOIN Expenses e ON b.user_id = e.user_id AND b.category_id = e.category_id AND e.date BETWEEN b.start_date AND b.end_date
    JOIN Categories c ON b.category_id = c.category_id
    WHERE b.user_id = ?
    GROUP BY b.budget_id
";
$stmt = $mysqli->prepare($query);
$stmt->bind_param("i", $user_id);
$stmt->execute();
$result = $stmt->get_result();
$budgets = [];
while ($row = $result->fetch_assoc()) {
    $budgets[] = $row;
}
$stmt->close();
$mysqli->close();

echo json_encode($budgets);
?>