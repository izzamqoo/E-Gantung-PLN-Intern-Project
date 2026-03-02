<?php
$host = "localhost";
$user = "root";
$pass = "";
$db   = "egantung"; // pastikan ini nama database kamu sekarang

$koneksi = mysqli_connect($host, $user, $pass, $db);

if (!$koneksi) {
    die("Koneksi gagal: " . mysqli_connect_error());
}
?>
