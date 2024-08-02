<?php
header('Content-Type: application/json');

// Enable error reporting for debugging
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

// Include the database connection file
include 'db_config.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Check if the necessary data is provided
    if (!isset($_POST['user_id'])) {
        echo json_encode(["status" => "error", "message" => "Missing required fields"]);
        exit();
    }

    // Extract data from the POST request
    $user_id = $_POST['user_id'];

    // Start a transaction to ensure all related data is deleted
    $mysqli->begin_transaction();

    try {
        // Delete user's feedback
        $stmt = $mysqli->prepare("DELETE FROM Feedback WHERE user_id = ?");
        $stmt->bind_param("i", $user_id);
        $stmt->execute();
        $stmt->close();

        // Delete user's notifications
        $stmt = $mysqli->prepare("DELETE FROM Notifications WHERE user_id = ?");
        $stmt->bind_param("i", $user_id);
        $stmt->execute();
        $stmt->close();

        // Delete user's expenses
        $stmt = $mysqli->prepare("DELETE FROM Expenses WHERE user_id = ?");
        $stmt->bind_param("i", $user_id);
        $stmt->execute();
        $stmt->close();

        // Delete user's budgets
        $stmt = $mysqli->prepare("DELETE FROM Budgets WHERE user_id = ?");
        $stmt->bind_param("i", $user_id);
        $stmt->execute();
        $stmt->close();

        // Delete user's settings
        $stmt = $mysqli->prepare("DELETE FROM User_Settings WHERE user_id = ?");
        $stmt->bind_param("i", $user_id);
        $stmt->execute();
        $stmt->close();

        // Delete user's categories
        $stmt = $mysqli->prepare("DELETE FROM User_Categories WHERE user_id = ?");
        $stmt->bind_param("i", $user_id);
        $stmt->execute();
        $stmt->close();

        // Finally, delete the user
        $stmt = $mysqli->prepare("DELETE FROM Users WHERE user_id = ?");
        $stmt->bind_param("i", $user_id);
        $stmt->execute();
        $stmt->close();

        // Commit the transaction
        $mysqli->commit();

        echo json_encode(["status" => "success", "message" => "User account deleted successfully"]);
    } catch (Exception $e) {
        // Rollback the transaction if any delete operation fails
        $mysqli->rollback();

        echo json_encode(["status" => "error", "message" => "Failed to delete user account: " . $e->getMessage()]);
    }

    $mysqli->close();
} else {
    echo json_encode(["status" => "error", "message" => "Invalid request method"]);
}
?>