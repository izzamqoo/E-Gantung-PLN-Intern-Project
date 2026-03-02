<?php 
header('Content-Type: application/json');
include 'koneksi.php';

// Ambil serial_number dari GET atau POST
$serial = '';
if (isset($_GET['serial_number'])) {
    $serial = mysqli_real_escape_string($koneksi, $_GET['serial_number']);
} elseif (isset($_POST['serial_number'])) {
    $serial = mysqli_real_escape_string($koneksi, $_POST['serial_number']);
}

// Validasi jika serial kosong
if (empty($serial)) {
    echo json_encode([
        "status" => "error",
        "message" => "Serial number tidak dikirim"
    ]);
    exit;
}

// Ambil data barang berdasarkan serial number
$query = "SELECT * FROM barang WHERE serial_number = '$serial'";
$result = mysqli_query($koneksi, $query);

// Cek hasil query
if ($result && mysqli_num_rows($result) > 0) {
    $barang = mysqli_fetch_assoc($result);

    echo json_encode([
        "status" => "success",
        "data" => $barang
    ]);
} else {
    echo json_encode([
        "status" => "error",
        "message" => "Barang tidak ditemukan"
    ]);
}
?>
