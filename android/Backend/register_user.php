<?php
include "koneksi.php"; // koneksi ke database

$response = array();

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $username = $_POST['username'];
    $email    = $_POST['email'];
    $password = $_POST['password'];

    // Cek username/email sudah ada atau belum
    $check = mysqli_query($conn, "SELECT * FROM users WHERE username='$username' OR email='$email'");
    if (mysqli_num_rows($check) > 0) {
        $response['status'] = false;
        $response['message'] = "Username atau Email sudah digunakan!";
    } else {
        // Hash password
        $passwordHash = password_hash($password, PASSWORD_BCRYPT);

        $insert = mysqli_query($conn, "INSERT INTO users (username,email,password) VALUES('$username','$email','$passwordHash')");
        if ($insert) {
            $response['status'] = true;
            $response['message'] = "Registrasi berhasil!";
        } else {
            $response['status'] = false;
            $response['message'] = "Registrasi gagal!";
        }
    }
} else {
    $response['status'] = false;
    $response['message'] = "Invalid request!";
}

echo json_encode($response);
?>
