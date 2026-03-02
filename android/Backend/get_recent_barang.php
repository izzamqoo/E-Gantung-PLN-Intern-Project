<?php
header('Content-Type: application/json');
include 'koneksi.php';

$query = "SELECT * FROM barang ORDER BY waktu_masuk DESC LIMIT 10";
$result = mysqli_query($koneksi, $query);

$data = [];
while ($row = mysqli_fetch_assoc($result)) {
    $data[] = $row;
}

echo json_encode([
    "status" => "success",
    "data" => $data
]);
?>
