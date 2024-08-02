<?php
$host = 'localhost';
$user = 'u831477405_root';
$password = 'Naakey057@'; // Update with your MySQL password
$database = 'u831477405_moneta';

// Create a new mysqli object with database connection parameters
$mysqli = new mysqli($host, $user, $password, $database);

// Check for a connection error and handle it
if ($mysqli->connect_error) {
    die("Connection failed: " . $mysqli->connect_error);
}
?>