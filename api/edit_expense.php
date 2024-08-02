<?php
include 'db_config.php';

$expenseId = $_POST['expense_id'];
$userId = $_POST['user_id'];
$categoryId = $_POST['category_id'];
$amount = $_POST['amount'];
$date = $_POST['date'];
$description = $_POST['description'];

$receiptImage = '';
if (isset($_FILES['receipt_image']) && $_FILES['receipt_image']['error'] == 0) {
    $targetDir = "/home/u831477405/domains/moneta.icu/public_html/api/receipts/";
    $imageName = time() . '_' . basename($_FILES['receipt_image']['name']);
    $targetFile = $targetDir . $imageName;

    // Ensure the target directory exists and has the right permissions
    if (!is_dir($targetDir)) {
        if (!mkdir($targetDir, 0755, true)) {
            error_log("Failed to create directory: $targetDir");
            echo json_encode(array('status' => 'error', 'message' => 'Failed to create directory for receipt images.'));
            exit();
        }
    }

    if (!move_uploaded_file($_FILES['receipt_image']['tmp_name'], $targetFile)) {
        error_log("Failed to move uploaded file to: $targetFile");
        echo json_encode(array('status' => 'error', 'message' => 'Failed to upload receipt image.'));
        exit();
    }
    $receiptImage = $imageName;
}

// Prepare the update query
$query = "UPDATE Expenses SET user_id = ?, category_id = ?, amount = ?, date = ?, description = ?";
if ($receiptImage) {
    $query .= ", receipt_image = ?";
}
$query .= " WHERE expense_id = ?";

$stmt = $mysqli->prepare($query);

if ($receiptImage) {
    $stmt->bind_param("iissssi", $userId, $categoryId, $amount, $date, $description, $receiptImage, $expenseId);
} else {
    $stmt->bind_param("iisssi", $userId, $categoryId, $amount, $date, $description, $expenseId);
}

// Execute the query and handle errors
if ($stmt->execute()) {
    $response = array('status' => 'success', 'message' => 'Expense updated successfully.');
} else {
    error_log("Failed to update expense: " . $stmt->error);
    $response = array('status' => 'error', 'message' => 'Failed to update expense.');
}

$stmt->close();
$mysqli->close();

echo json_encode($response);
?>