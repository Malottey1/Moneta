<?php
include 'db_config.php';

$user_id = $_GET['user_id'];
$sort = isset($_GET['sort']) ? $_GET['sort'] : 'date_desc';
$search = isset($_GET['search']) ? $_GET['search'] : '';

// Base query
$query = "SELECT e.*, c.category_name 
          FROM Expenses e 
          JOIN Categories c ON e.category_id = c.category_id 
          WHERE e.user_id = ?";

// Add search condition
if ($search) {
    $query .= " AND (c.category_name LIKE ? OR e.description LIKE ?)";
    $search = "%" . $search . "%";
}

// Add sorting
switch ($sort) {
    case 'date_asc':
        $query .= " ORDER BY e.date ASC";
        break;
    case 'date_desc':
        $query .= " ORDER BY e.date DESC";
        break;
    case 'amount_asc':
        $query .= " ORDER BY e.amount ASC";
        break;
    case 'amount_desc':
        $query .= " ORDER BY e.amount DESC";
        break;
    default:
        $query .= " ORDER BY e.date DESC";
}

$stmt = $mysqli->prepare($query);

if ($search) {
    $stmt->bind_param("isss", $user_id, $search, $search);
} else {
    $stmt->bind_param("i", $user_id);
}

$stmt->execute();
$result = $stmt->get_result();
$expenses = $result->fetch_all(MYSQLI_ASSOC);

$stmt->close();
$mysqli->close();

echo json_encode($expenses);
?>