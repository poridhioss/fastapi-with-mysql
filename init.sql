-- Assuming the database `fastapi_db` already exists; adjust if needed.
USE fastapi_db;

CREATE TABLE IF NOT EXISTS users (
    id   INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NULL
);
