<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

// Enable error reporting for debugging
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

// Include the database connection file
include 'db_config.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Check if a file was uploaded
    if (isset($_FILES['profile_picture']) && $_FILES['profile_picture']['error'] === UPLOAD_ERR_OK) {
        $target_dir = "/home/u831477405/domains/moneta.icu/public_html/api/profile-photos/";
        $profile_picture = time() . '_' . basename($_FILES["profile_picture"]["name"]);
        $target_file = $target_dir . $profile_picture;

        // Ensure the target directory exists and has the right permissions
        if (!is_dir($target_dir)) {
            mkdir($target_dir, 0755, true);
        }

        // Move the uploaded file to the target directory
        if (move_uploaded_file($_FILES["profile_picture"]["tmp_name"], $target_file)) {
            // Return the URL of the uploaded file
            $url = 'https://moneta.icu/api/profile-photos/' . $profile_picture;
            echo json_encode(["status" => "success", "url" => $url]);
        } else {
            echo json_encode(["status" => "error", "message" => "Failed to upload profile picture"]);
        }
    } else {
        echo json_encode(["status" => "error", "message" => "No file uploaded or upload error"]);
    }
} else {
    echo json_encode(["status" => "error", "message" => "Invalid request method"]);
}
?>
