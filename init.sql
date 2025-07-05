# init.sql
CREATE TABLE IF NOT EXISTS students (
    id INT(6) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    age INT(3) NOT NULL,
    department VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO students (name, age, department) VALUES 
('John Doe', 20, 'Computer Science'),
('Jane Smith', 22, 'Engineering'),
('Mike Johnson', 21, 'Business');