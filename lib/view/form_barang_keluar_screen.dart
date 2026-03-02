import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FormBarangKeluarScreen extends StatefulWidget {
  final String serialNumber;
  final String? namaBarangFromQR;

  const FormBarangKeluarScreen({
    super.key,
    required this.serialNumber,
    this.namaBarangFromQR,
  });

  @override
  State<FormBarangKeluarScreen> createState() => _FormBarangKeluarScreenState();
}

class _FormBarangKeluarScreenState extends State<FormBarangKeluarScreen> {
  Map<String, dynamic>? barang;
  bool isLoading = true;
  final TextEditingController jumlahController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchBarangDetail();
  }

  Future<void> fetchBarangDetail() async {
    try {
      final response = await http.post(
        Uri.parse("https://plngresik.net/egantung/get_barang_by_serial.php"),
        body: {"serial_number": widget.serialNumber},
      );

      final jsonData = json.decode(response.body);

      if (jsonData['status'] == 'success') {
        setState(() {
          barang = jsonData['data'];
          jumlahController.text = "1";
          isLoading = false;
        });
      } else {
        // Kalau tidak ditemukan di database, tetap tampilkan dari QR
        setState(() {
          barang = {
            "serial_number": widget.serialNumber,
            "nama_barang": widget.namaBarangFromQR ?? "Tidak diketahui",
            "jumlah": 0
          };
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal ambil data: $e")),
      );
    }
  }

  Future<void> konfirmasiKeluar() async {
    final jumlahKeluar = int.tryParse(jumlahController.text) ?? 0;
    final stokTersedia = int.tryParse(barang?['jumlah'].toString() ?? '0') ?? 0;

    if (jumlahKeluar <= 0) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Peringatan'),
          content: const Text("Jumlah harus lebih dari 0"),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text("OK"))
          ],
        ),
      );
      return;
    }

    if (jumlahKeluar > stokTersedia) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Peringatan'),
          content: Text("Jumlah melebihi stok ($stokTersedia)"),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text("OK"))
          ],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Konfirmasi"),
        content: Text("Apakah Anda yakin ingin mengeluarkan $jumlahKeluar barang ini?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              submitBarangKeluar(jumlahKeluar);
            },
            child: const Text("Ya"),
          ),
        ],
      ),
    );
  }

  Future<void> submitBarangKeluar(int jumlahKeluar) async {
    final response = await http.post(
      Uri.parse("https://plngresik.net/egantung/barang_keluar.php"),
      body: {
        "serial_number": widget.serialNumber,
        "jumlah_keluar": jumlahKeluar.toString(),
      },
    );

    final res = json.decode(response.body);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(res['status'] == 'success' ? 'Berhasil' : 'Gagal'),
        content: Text(res['message']),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              if (res['status'] == 'success') {
                Navigator.pop(context, true);
              }
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Form Barang Keluar")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : barang == null
              ? const Center(child: Text("Barang tidak ditemukan"))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Nama Barang: ${barang!['nama_barang']}", style: const TextStyle(fontSize: 18)),
                      const SizedBox(height: 8),
                      Text("Kode Barang: ${barang!['serial_number']}"),
                      const SizedBox(height: 8),
                      Text("Stok Tersedia: ${barang!['jumlah']}"),
                      const SizedBox(height: 16),
                      TextField(
                        controller: jumlahController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Jumlah Keluar",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: konfirmasiKeluar,
                        icon: const Icon(Icons.send),
                        label: const Text("Keluarkan Barang"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
