<?php
include 'db_config.php';

$user_id = $_GET['user_id'];
$search = isset($_GET['search']) ? $_GET['search'] : '';
$filter = isset($_GET['filter']) ? $_GET['filter'] : 'all';

// Base query
$query = "SELECT c.category_id, c.category_name, 
                 IFNULL(SUM(e.amount), 0) AS total_amount, 
                 IFNULL(COUNT(e.expense_id), 0) AS expense_count 
          FROM Categories c 
          LEFT JOIN Expenses e ON c.category_id = e.category_id AND e.user_id = ? 
          WHERE c.category_name LIKE ?";

// Add filter condition
if ($filter == 'active') {
    $query .= " AND e.expense_id IS NOT NULL";
} else if ($filter == 'inactive') {
    $query .= " AND e.expense_id IS NULL";
}

$query .= " GROUP BY c.category_id ORDER BY c.category_name ASC";

$stmt = $mysqli->prepare($query);
$search = "%" . $search . "%";
$stmt->bind_param('is', $user_id, $search);
$stmt->execute();
$result = $stmt->get_result();

$categories = array();
while ($row = $result->fetch_assoc()) {
    $categories[] = $row;
}

echo json_encode($categories);

$stmt->close();
$mysqli->close();
?>