<?php
header('Content-Type: application/json');
include 'koneksi.php';

// Ambil data dari POST
$serial = isset($_POST['serial_number']) ? mysqli_real_escape_string($koneksi, $_POST['serial_number']) : '';
$jumlahKeluar = isset($_POST['jumlah_keluar']) ? (int)$_POST['jumlah_keluar'] : 0;

// Validasi input
if (empty($serial) || $jumlahKeluar <= 0) {
    echo json_encode([
        "status" => "error",
        "message" => "Data tidak valid: Serial number kosong atau jumlah <= 0"
    ]);
    exit;
}

// Cek apakah barang ada di database
$query = "SELECT * FROM barang WHERE serial_number = '$serial'";
$result = mysqli_query($koneksi, $query);
$barang = mysqli_fetch_assoc($result);

if (!$barang) {
    echo json_encode(["status" => "error", "message" => "Barang tidak ditemukan"]);
    exit;
}

// Hitung stok baru
$jumlahLama = (int)$barang['jumlah'];
$jumlahBaru = $jumlahLama - $jumlahKeluar;

if ($jumlahBaru < 0) {
    echo json_encode(["status" => "error", "message" => "Jumlah keluar melebihi stok ($jumlahLama tersedia)"]);
    exit;
}

// Status: 1 = masih tersedia, 0 = habis
$status = ($jumlahBaru <= 0) ? 0 : 1;

// Update stok dan waktu keluar
$update = "UPDATE barang 
           SET jumlah = $jumlahBaru, 
               status = $status, 
               waktu_keluar = NOW() 
           WHERE serial_number = '$serial'";

if (mysqli_query($koneksi, $update)) {
    // Tambahkan juga ke tabel riwayat
    $namaBarang = mysqli_real_escape_string($koneksi, $barang['nama_barang']);
    $insertRiwayat = "INSERT INTO riwayat (serial_number, nama_barang, jumlah, jenis, waktu)
                      VALUES ('$serial', '$namaBarang', $jumlahKeluar, 'keluar', NOW())";
    mysqli_query($koneksi, $insertRiwayat);

    echo json_encode([
        "status" => "success",
        "message" => "Barang berhasil dikurangi ($jumlahKeluar). Sisa: $jumlahBaru"
    ]);
} else {
    echo json_encode([
        "status" => "error",
        "message" => "Gagal mengupdate: " . mysqli_error($koneksi)
    ]);
}
?>
