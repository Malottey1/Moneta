<?php
include 'db_config.php';

$query = "SELECT category_name FROM Categories";
$result = $mysqli->query($query);

$categories = array();
while ($row = $result->fetch_assoc()) {
    $categories[] = $row['category_name'];
}

$response = array('categories' => $categories);

echo json_encode($response);

$mysqli->close();
?>