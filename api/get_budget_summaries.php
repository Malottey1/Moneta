<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);

include 'db_config.php';

// Get the user_id from the query parameters
$user_id = $_GET['user_id'] ?? null;

// Check if user_id is provided
if (!$user_id) {
    http_response_code(400);
    echo json_encode(['error' => 'user_id parameter is required']);
    exit();
}

// Prepare the SQL query
$query = "SELECT b.category_id, c.category_name, b.amount AS budget, COALESCE(SUM(e.amount), 0) as spent
          FROM Budgets b
          LEFT JOIN Expenses e ON b.category_id = e.category_id AND b.user_id = e.user_id
          JOIN Categories c ON b.category_id = c.category_id
          WHERE b.user_id = ?
          GROUP BY b.category_id, c.category_name, b.amount
          LIMIT 4";

// Log the query for debugging
error_log("Executing query: $query");

// Prepare and execute the SQL statement
if ($stmt = $mysqli->prepare($query)) {
    error_log("Statement prepared successfully");
    $stmt->bind_param('i', $user_id);
    $stmt->execute();
    $result = $stmt->get_result();

    // Check if the result is valid
    if ($result) {
        error_log("Query executed successfully, number of rows: " . $result->num_rows);

        // Fetch the results into an array
        $budgets = array();
        while ($row = $result->fetch_assoc()) {
            error_log("Fetched row: " . json_encode($row));
            $budgets[] = $row;
        }

        // Check if there are any results
        if (empty($budgets)) {
            error_log("No budget summaries found for user_id: $user_id");
            echo json_encode(array('error' => 'No budget summaries found.'));
        } else {
            // Return the results as JSON
            echo json_encode($budgets);
        }
    } else {
        error_log("Query execution failed: " . $stmt->error);
        echo json_encode(array('error' => $stmt->error));
    }

    // Close the statement
    $stmt->close();
} else {
    // Log and return the SQL error if the statement preparation fails
    error_log("Statement preparation failed: " . $mysqli->error);
    echo json_encode(array('error' => $mysqli->error));
}

// Close the database connection
$mysqli->close();
?>