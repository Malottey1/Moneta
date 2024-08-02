<?php
header('Content-Type: application/json');

// Enable error reporting for debugging
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

// Include the database connection file
include 'db_config.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Check if all necessary data is provided
    if (!isset($_POST['first_name'], $_POST['last_name'], $_POST['email'], $_POST['password'], $_POST['gender'], $_POST['date_of_birth'])) {
        echo json_encode(["status" => "error", "message" => "Missing required fields"]);
        exit();
    }

    // Extract data from the POST request
    $first_name = $_POST['first_name'];
    $last_name = $_POST['last_name'];
    $email = $_POST['email'];
    $password = password_hash($_POST['password'], PASSWORD_BCRYPT);
    $gender = $_POST['gender'];
    $date_of_birth = $_POST['date_of_birth'];

    // Handle the profile picture upload
    $profile_picture = '';
    if (isset($_FILES['profile_picture']) && $_FILES['profile_picture']['error'] === UPLOAD_ERR_OK) {
        $target_dir = "/home/u831477405/domains/moneta.icu/public_html/api/profile-photos/";
        $profile_picture = time() . '_' . basename($_FILES["profile_picture"]["name"]);
        $target_file = $target_dir . $profile_picture;

        // Ensure the target directory exists and has the right permissions
        if (!is_dir($target_dir)) {
            mkdir($target_dir, 0755, true);
        }

        if (!move_uploaded_file($_FILES["profile_picture"]["tmp_name"], $target_file)) {
            echo json_encode(["status" => "error", "message" => "Failed to upload profile picture"]);
            exit();
        }
    }

    // Insert the user data into the database
    $stmt = $mysqli->prepare("INSERT INTO Users (first_name, last_name, email, password, gender, date_of_birth, profile_picture) VALUES (?, ?, ?, ?, ?, ?, ?)");
    $stmt->bind_param("sssssss", $first_name, $last_name, $email, $password, $gender, $date_of_birth, $profile_picture);

    if ($stmt->execute()) {
        echo json_encode(["status" => "success", "message" => "User registered successfully"]);
    } else {
        echo json_encode(["status" => "error", "message" => "Failed to register user"]);
    }

    $stmt->close();
    $mysqli->close();
} else {
    echo json_encode(["status" => "error", "message" => "Invalid request method"]);
}
?>