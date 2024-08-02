<?php
include 'db_config.php';

// Retrieve the form data
$user_id = $_POST['user_id'];
$category_id = $_POST['category_id'];
$amount = $_POST['amount'];
$start_date = $_POST['start_date'];
$end_date = $_POST['end_date'];

// Insert the budget data into the database
$stmt = $mysqli->prepare("INSERT INTO Budgets (user_id, category_id, amount, start_date, end_date) VALUES (?, ?, ?, ?, ?)");
$stmt->bind_param("iisss", $user_id, $category_id, $amount, $start_date, $end_date);

if ($stmt->execute()) {
    $response = array('status' => 'success', 'message' => 'Budget saved successfully.');
} else {
    $response = array('status' => 'error', 'message' => 'Failed to save budget.');
}

$stmt->close();
$mysqli->close();

echo json_encode($response);
?>