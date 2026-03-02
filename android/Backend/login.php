<?php
header('Content-Type: application/json');
include 'koneksi.php';

$email = $_POST['email'] ?? '';
$password = $_POST['password'] ?? '';

// Validasi input kosong
if (!$email || !$password) {
    echo json_encode(['status' => 'error', 'message' => 'Email dan password wajib diisi']);
    exit;
}

// Cari user berdasarkan email
$query = mysqli_query($koneksi, "SELECT * FROM users WHERE email = '$email'");

if (mysqli_num_rows($query) > 0) {
    $data = mysqli_fetch_assoc($query);

    // Cek password (plaintext — sebaiknya nanti diganti hash)
    if ($data['password'] === $password) {
        echo json_encode([
            'status' => 'success',
            'message' => 'Login berhasil',
            'id' => $data['id'],
            'nama' => $data['username'], // <= ini yang dibutuhkan Flutter
            'email' => $data['email'],
            'role' => $data['role']
        ]);
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Password salah']);
    }
} else {
    echo json_encode(['status' => 'error', 'message' => 'Email tidak ditemukan']);
}
?>
