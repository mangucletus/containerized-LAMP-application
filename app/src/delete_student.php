<!-- app/src/delete_student.php -->


<?php
require_once 'config.php';

if (isset($_GET['id']) && is_numeric($_GET['id'])) {
    $id = (int)$_GET['id'];
    
    try {
        $stmt = $pdo->prepare("DELETE FROM students WHERE id = ?");
        $stmt->execute([$id]);
        
        if ($stmt->rowCount() > 0) {
            header("Location: index.php?success=Student deleted successfully");
        } else {
            header("Location: index.php?error=Student not found");
        }
        exit();
    } catch(PDOException $e) {
        header("Location: index.php?error=Error deleting student: " . urlencode($e->getMessage()));
        exit();
    }
} else {
    header("Location: index.php?error=Invalid student ID");
    exit();
}
?>