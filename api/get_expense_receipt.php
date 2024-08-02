<?php
include 'db_config.php';

$expenseId = $_GET['expense_id'];
$userId = $_GET['user_id'];

$stmt = $mysqli->prepare("SELECT receipt_image FROM Expenses WHERE id = ? AND user_id = ?");
$stmt->bind_param("ii", $expenseId, $userId);
$stmt->execute();
$stmt->bind_result($receiptImage);
$stmt->fetch();
$stmt->close();

$receiptImageUrl = $receiptImage ? 'https://moneta.icu/api/receipts/' . $receiptImage : '';

$response = array('status' => 'success', 'receipt_image_url' => $receiptImageUrl);
echo json_encode($response);

$mysqli->close();
?>