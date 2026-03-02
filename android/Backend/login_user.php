<?php
include "koneksi.php";

$response = array();

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $username = $_POST['username'];
    $password = $_POST['password'];

    $result = mysqli_query($conn, "SELECT * FROM users WHERE username='$username' LIMIT 1");
    if (mysqli_num_rows($result) > 0) {
        $row = mysqli_fetch_assoc($result);

        if (password_verify($password, $row['password'])) {
            $response['status'] = true;
            $response['message'] = "Login berhasil!";
            $response['data'] = array(
                "id" => $row['id'],
                "username" => $row['username'],
                "email" => $row['email'],
                "role" => $row['role']
            );
        } else {
            $response['status'] = false;
            $response['message'] = "Password salah!";
        }
    } else {
        $response['status'] = false;
        $response['message'] = "User tidak ditemukan!";
    }
} else {
    $response['status'] = false;
    $response['message'] = "Invalid request!";
}

echo json_encode($response);
?>
