<?php
include 'db_config.php';

$userId = $_POST['user_id'];
$categoryId = $_POST['category_id'];
$amount = $_POST['amount'];
$date = $_POST['date'];
$description = $_POST['description'];

$receiptImage = '';
if (isset($_FILES['receipt_image'])) {
    $targetDir = "/home/u831477405/domains/moneta.icu/public_html/api/profile-photos/";
    $imageName = time() . '_' . basename($_FILES['receipt_image']['name']);
    $targetFile = $targetDir . $imageName;

    // Ensure the target directory exists and has the right permissions
    if (!is_dir($targetDir)) {
        mkdir($targetDir, 0755, true);
    }

    if (move_uploaded_file($_FILES['receipt_image']['tmp_name'], $targetFile)) {
        $receiptImage = $imageName;
    }
}

$stmt = $mysqli->prepare("INSERT INTO Expenses (user_id, category_id, amount, date, description, receipt_image) VALUES (?, ?, ?, ?, ?, ?)");
$stmt->bind_param("iissss", $userId, $categoryId, $amount, $date, $description, $receiptImage);

if ($stmt->execute()) {
    $response = array('status' => 'success', 'message' => 'Expense logged successfully.');
} else {
    $response = array('status' => 'error', 'message' => 'Failed to log expense.');
}

$stmt->close();
$mysqli->close();

echo json_encode($response);
?>