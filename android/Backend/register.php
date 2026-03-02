<?php
header('Content-Type: application/json');
include 'koneksi.php';

$username = $_POST['username'] ?? '';
$email = $_POST['email'] ?? '';
$password = $_POST['password'] ?? '';

// Validasi input kosong
if (!$username || !$email || !$password) {
    echo json_encode(['status' => 'error', 'message' => 'Semua field wajib diisi']);
    exit;
}

// Cek email sudah terdaftar atau belum
$cek = mysqli_query($koneksi, "SELECT * FROM users WHERE email = '$email'");
if (mysqli_num_rows($cek) > 0) {
    echo json_encode(['status' => 'error', 'message' => 'Email sudah terdaftar']);
    exit;
}

// Simpan user dengan role default 'user'
$query = "INSERT INTO users (username, email, password, role) VALUES ('$username', '$email', '$password', 'user')";
$insert = mysqli_query($koneksi, $query);

if ($insert) {
    echo json_encode(['status' => 'success', 'message' => 'Registrasi berhasil']);
} else {
    echo json_encode(['status' => 'error', 'message' => 'Gagal registrasi']);
}
?>
