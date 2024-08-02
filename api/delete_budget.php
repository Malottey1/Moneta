<?php
include 'db_config.php';

// Retrieve the budget id
$budget_id = $_POST['id'];

// Logging to check the received id
error_log("Budget ID received for deletion: " . $budget_id);

// Delete the budget from the database
$stmt = $mysqli->prepare("DELETE FROM Budgets WHERE budget_id = ?");
if (!$stmt) {
    error_log("Prepare failed: (" . $mysqli->errno . ") " . $mysqli->error);
}

$stmt->bind_param("i", $budget_id);

if ($stmt->execute()) {
    $response = array('status' => 'success', 'message' => 'Budget deleted successfully.');
} else {
    error_log("Execute failed: (" . $stmt->errno . ") " . $stmt->error);
    $response = array('status' => 'error', 'message' => 'Failed to delete budget.');
}

$stmt->close();
$mysqli->close();

echo json_encode($response);
?>