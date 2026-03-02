<?php
header('Content-Type: application/json');
include 'koneksi.php';

$query = "SELECT * FROM riwayat ORDER BY waktu DESC";

$result = mysqli_query($koneksi, $query);

if (!$result) {
    echo json_encode([
        'status' => 'error',
        'message' => 'Query gagal: ' . mysqli_error($koneksi)
    ]);
    exit;
}

$data = [];

while ($row = mysqli_fetch_assoc($result)) {
    $data[] = $row;
}

echo json_encode([
    'status' => 'success',
    'data' => $data
]);
?>
