<?php

$type = $_GET['type'] ?? '';
$id   = $_GET['id'] ?? '';

echo "Profile Type: " . htmlspecialchars($type) . "<br>";
echo "User ID: " . htmlspecialchars($id);