<?php
header('Content-Type: application/json');
include 'koneksi.php';

if (isset($_GET['rak'])) {
    $rak = $_GET['rak'];

    $query = "SELECT * FROM barang WHERE rak = '$rak' ORDER BY waktu_masuk DESC";
    $result = mysqli_query($koneksi, $query);

    $data = [];
    while ($row = mysqli_fetch_assoc($result)) {
        $data[] = $row;
    }

    echo json_encode([
        "status" => "success",
        "data" => $data
    ]);
} else {
    echo json_encode([
        "status" => "error",
        "message" => "Parameter rak tidak ditemukan"
    ]);
}
?>
