<?php
header('Content-Type: application/json');
include 'koneksi.php';

if (!isset($_POST['id'])) {
    echo json_encode(["status" => "error", "message" => "ID barang tidak ditemukan"]);
    exit;
}

$id = $_POST['id'];

// Hapus barang berdasarkan ID
$query = "DELETE FROM barang WHERE id = '$id'";

if (mysqli_query($koneksi, $query)) {
    echo json_encode(["status" => "success", "message" => "Barang berhasil dihapus"]);
} else {
    echo json_encode(["status" => "error", "message" => "Gagal menghapus barang: " . mysqli_error($koneksi)]);
}
?>
