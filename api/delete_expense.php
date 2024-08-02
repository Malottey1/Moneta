<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

include 'db_config.php'; // Include your database configuration

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $expense_id = $_POST['id'];
    $user_id = $_POST['user_id'];

    // Log the received parameters
    error_log("Received expense_id: $expense_id");
    error_log("Received user_id: $user_id");

    // Perform a query to delete the expense
    $stmt = $mysqli->prepare("DELETE FROM Expenses WHERE expense_id = ? AND user_id = ?");
    if ($stmt === false) {
        error_log("Prepare failed: (" . $mysqli->errno . ") " . $mysqli->error);
        echo json_encode(["status" => "error", "message" => "Failed to prepare statement"]);
        exit();
    }

    $stmt->bind_param("ii", $expense_id, $user_id);
    if (!$stmt->execute()) {
        error_log("Execute failed: (" . $stmt->errno . ") " . $stmt->error);
        echo json_encode(["status" => "error", "message" => "Failed to delete expense"]);
    } else {
        if ($stmt->affected_rows > 0) {
            echo json_encode(["status" => "success", "message" => "Expense deleted successfully"]);
        } else {
            error_log("No rows affected");
            echo json_encode(["status" => "error", "message" => "Expense not found or user not authorized"]);
        }
    }

    $stmt->close();
    $mysqli->close();
} else {
    echo json_encode(["status" => "error", "message" => "Invalid request method"]);
}
?>