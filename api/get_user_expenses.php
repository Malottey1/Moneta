<?php
header('Content-Type: application/json');

include 'db_config.php';

if ($_SERVER['REQUEST_METHOD'] === 'GET' && isset($_GET['user_id'])) {
    $userId = $_GET['user_id'];
    
    $query = "SELECT category, amount FROM expenses WHERE user_id = ?";
    $stmt = $mysqli->prepare($query);
    $stmt->bind_param("i", $userId);
    $stmt->execute();
    $result = $stmt->get_result();

    $expenses = [];
    while ($row = $result->fetch_assoc()) {
        $expenses[] = $row;
    }

    echo json_encode(['expenses' => $expenses]);

    $stmt->close();
    $mysqli->close();
} else {
    echo json_encode(["status" => "error", "message" => "Invalid request"]);
}
?>