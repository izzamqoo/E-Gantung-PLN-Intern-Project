<?php
header('Content-Type: application/json');
include 'koneksi.php';

// Ambil data dari request
$id_user = $_POST['id_user'] ?? '';
$password_lama = $_POST['password_lama'] ?? '';
$password_baru = $_POST['password_baru'] ?? '';

// Validasi input
if (!$id_user || !$password_lama || !$password_baru) {
    echo json_encode(['status' => 'error', 'message' => 'Semua field wajib diisi']);
    exit;
}

// Ambil data user berdasarkan ID
$query = mysqli_query($koneksi, "SELECT * FROM users WHERE id = '$id_user'");
if (mysqli_num_rows($query) === 0) {
    echo json_encode(['status' => 'error', 'message' => 'Pengguna tidak ditemukan']);
    exit;
}

$data = mysqli_fetch_assoc($query);

// Cek password lama (plaintext - jika sudah pakai hash, gunakan password_verify)
if ($data['password'] !== $password_lama) {
    echo json_encode(['status' => 'error', 'message' => 'Password lama salah']);
    exit;
}

// Update password
$update = mysqli_query($koneksi, "UPDATE users SET password = '$password_baru' WHERE id = '$id_user'");
if ($update) {
    echo json_encode(['status' => 'success', 'message' => 'Password berhasil diperbarui']);
} else {
    echo json_encode(['status' => 'error', 'message' => 'Gagal mengubah password']);
}
?>
