<?php
include 'koneksi.php';

$id = $_POST['id_user'];
$nama = $_POST['nama'];
$email = $_POST['email'];

$query = "UPDATE users SET username='$nama', email='$email' WHERE id='$id'";

if (mysqli_query($koneksi, $query)) {
    echo json_encode(["status" => "success", "message" => "Profil berhasil diupdate"]);
} else {
    echo json_encode(["status" => "error", "message" => "Gagal update profil"]);
}
?>
