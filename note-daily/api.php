<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, DELETE");
header("Access-Control-Allow-Headers: Content-Type");

$servername = "localhost";
$username = "root"; // Ganti dengan username MySQL Anda
$password = ""; // Ganti dengan password MySQL Anda
$dbname = "notes_app";

// Membuat koneksi
$conn = new mysqli($servername, $username, $password, $dbname);

// Cek koneksi
if ($conn->connect_error) {
    die("Koneksi Gagal : " . $conn->connect_error);
}

// Mengambil semua catatan
if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    $sql = "SELECT * FROM notes";
    $result = $conn->query($sql);
    $notes = array();
    if ($result->num_rows > 0) {
        while($row = $result->fetch_assoc()) {
            $notes[] = $row;
        }
    }
    echo json_encode($notes);
}

// Menambahkan catatan baru
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $title = $_POST['title'];
    $content = $_POST['content'];
    if (empty($title) || empty($content)) {
        echo json_encode(["message" => "Judul dan Isi tidak boleh kosong."]);
        exit;
    }
    $sql = "INSERT INTO notes (title, content) VALUES ('$title', '$content')";
    if ($conn->query($sql) === TRUE) {
        echo json_encode(["message" => "Catatan Berhasil disimpan."]);
    } else {
        echo json_encode(["message" => "Error: " . $sql . "<br>" . $conn->error]);
    }
}

// Menghapus catatan
if ($_SERVER['REQUEST_METHOD'] === 'DELETE') {
    parse_str(file_get_contents("php://input"), $_DELETE);
    $id = $_DELETE['id'];
    $sql = "DELETE FROM notes WHERE id=$id";
    if ($conn->query($sql) === TRUE) {
        echo json_encode(["message" => "Catatan Berhasil dihapus."]);
    } else {
        echo json_encode(["message" => "Error: " . $sql . "<br>" . $conn->error]);
    }
}

$conn->close();
?>