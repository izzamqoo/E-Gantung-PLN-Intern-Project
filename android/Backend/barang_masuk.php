<?php
header('Content-Type: application/json');
include 'koneksi.php';

// Validasi field kosong
$fields = ['serial_number', 'nama_barang', 'jumlah', 'satuan', 'rak', 'peti', 'catatan'];
foreach ($fields as $field) {
    if (!isset($_POST[$field]) || trim($_POST[$field]) === '') {
        echo json_encode(["status" => "error", "message" => "Field '$field' kosong"]);
        exit;
    }
}

// Ambil data dari POST
$serial  = $_POST['serial_number'];
$nama    = $_POST['nama_barang'];
$jumlah  = $_POST['jumlah'];
$satuan  = $_POST['satuan'];
$rak     = $_POST['rak'];
$peti    = $_POST['peti'];
$catatan = $_POST['catatan'];

// Cek apakah serial_number sudah ada
$cek = mysqli_query($koneksi, "SELECT * FROM barang WHERE serial_number = '$serial'");
if (mysqli_num_rows($cek) > 0) {
    echo json_encode([
        'status' => 'error',
        'message' => 'Serial number sudah terdaftar sebelumnya.'
    ]);
    exit;
}

// Insert ke tabel barang
$query = "INSERT INTO barang (serial_number, nama_barang, jumlah, satuan, rak, peti, catatan, status, waktu_masuk)
          VALUES ('$serial', '$nama', '$jumlah', '$satuan', '$rak', '$peti', '$catatan', 1, NOW())";

// Log debug jika diperlukan
file_put_contents('log.txt', date('Y-m-d H:i:s') . " | SQL: $query\n", FILE_APPEND);

if (mysqli_query($koneksi, $query)) {
    // Insert ke tabel riwayat
    $insertRiwayat = "INSERT INTO riwayat (serial_number, nama_barang, jumlah, jenis, waktu)
                      VALUES ('$serial', '$nama', $jumlah, 'masuk', NOW())";
    mysqli_query($koneksi, $insertRiwayat);

    // === Buat QR Code ===
    require 'phpqrcode/qrlib.php';

    $qrFolder = 'qr_images';
    $qrFileName = $serial . '.png';
    $qrFilePath = __DIR__ . "/$qrFolder/$qrFileName";

    // Cek & buat folder jika belum ada
    if (!file_exists(__DIR__ . "/$qrFolder")) {
        mkdir(__DIR__ . "/$qrFolder", 0777, true);
    }

    // Generate QR code file
    QRcode::png($serial . "||" . $nama, $qrFilePath); // Format QR = serial||nama_barang

    // URL untuk Flutter
    $qrUrl = "http://192.168.100.120/egantung/$qrFolder/$qrFileName";

    echo json_encode([
        "status" => "success",
        "message" => "Barang berhasil ditambahkan dan QR code dibuat",
        "qr_url" => $qrUrl
    ]);
} else {
    echo json_encode([
        "status" => "error",
        "message" => mysqli_error($koneksi)
    ]);
}
?>
