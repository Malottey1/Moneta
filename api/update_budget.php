<?php
include 'db_config.php';

// Check if all required parameters are present
if (isset($_POST['id']) && isset($_POST['user_id']) && isset($_POST['category_id']) && isset($_POST['amount']) && isset($_POST['start_date']) && isset($_POST['end_date'])) {
    $id = $_POST['id'];
    $user_id = $_POST['user_id'];
    $category_id = $_POST['category_id'];
    $amount = $_POST['amount'];
    $start_date = $_POST['start_date'];
    $end_date = $_POST['end_date'];

    // Prepare the SQL query
    $stmt = $mysqli->prepare("UPDATE Budgets SET category_id = ?, amount = ?, start_date = ?, end_date = ? WHERE budget_id = ? AND user_id = ?");
    $stmt->bind_param("isssii", $category_id, $amount, $start_date, $end_date, $id, $user_id);

    // Execute the query and check if it was successful
    if ($stmt->execute()) {
        $response = array('status' => 'success', 'message' => 'Budget updated successfully.');
    } else {
        $response = array('status' => 'error', 'message' => 'Failed to update budget.');
    }

    // Close the statement
    $stmt->close();
} else {
    $response = array('status' => 'error', 'message' => 'Invalid parameters.');
}

// Close the database connection
$mysqli->close();

// Return the response as JSON
echo json_encode($response);
?>