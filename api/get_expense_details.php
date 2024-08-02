<?php
include 'db_config.php';

$expenseId = $_GET['expense_id'];
$userId = $_GET['user_id'];

$stmt = $mysqli->prepare("SELECT e.*, c.category_name FROM Expenses e JOIN Categories c ON e.category_id = c.id WHERE e.id = ? AND e.user_id = ?");
$stmt->bind_param("ii", $expenseId, $userId);
$stmt->execute();
$result = $stmt->get_result();
$expense = $result->fetch_assoc();

if ($expense) {
    $response = array('status' => 'success', 'expense' => $expense);
} else {
    $response = array('status' => 'error', 'message' => 'Expense not found.');
}

$stmt->close();
$mysqli->close();

echo json_encode($response);
?>