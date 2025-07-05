
<!-- app/src/add_student.php -->

<?php
require_once 'config.php';

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $name = trim($_POST['name']);
    $age = (int)$_POST['age'];
    $department = trim($_POST['department']);
    
    // Validate input
    if (empty($name) || empty($department) || $age <= 0) {
        header("Location: index.php?error=Please fill all fields correctly");
        exit();
    }
    
    try {
        $stmt = $pdo->prepare("INSERT INTO students (name, age, department) VALUES (?, ?, ?)");
        $stmt->execute([$name, $age, $department]);
        
        header("Location: index.php?success=Student added successfully");
        exit();
    } catch(PDOException $e) {
        header("Location: index.php?error=Error adding student: " . urlencode($e->getMessage()));
        exit();
    }
} else {
    header("Location: index.php");
    exit();
}
?>