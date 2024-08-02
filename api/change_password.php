<?php
include 'db_config.php';

$user_id = $_POST['user_id'];
$old_password = $_POST['old_password'];
$new_password = $_POST['new_password'];

// Fetch the old password from the database
$query = "SELECT password FROM Users WHERE user_id = ?";
$stmt = $mysqli->prepare($query);
$stmt->bind_param('i', $user_id);
$stmt->execute();
$result = $stmt->get_result();
$user = $result->fetch_assoc();

if (password_verify($old_password, $user['password'])) {
    // Old password is correct, proceed to change the password
    $new_password_hashed = password_hash($new_password, PASSWORD_BCRYPT);
    $update_query = "UPDATE Users SET password = ? WHERE user_id = ?";
    $update_stmt = $mysqli->prepare($update_query);
    $update_stmt->bind_param('si', $new_password_hashed, $user_id);

    if ($update_stmt->execute()) {
        echo json_encode(['status' => 'success']);
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Failed to update password']);
    }
} else {
    echo json_encode(['status' => 'error', 'message' => 'Old password is incorrect']);
}

$stmt->close();
$mysqli->close();
?>