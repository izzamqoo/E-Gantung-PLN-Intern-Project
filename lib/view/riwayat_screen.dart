import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RiwayatScreen extends StatefulWidget {
  const RiwayatScreen({super.key});

  @override
  State<RiwayatScreen> createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends State<RiwayatScreen> {
  List<dynamic> riwayatList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRiwayat();
  }

  Future<void> fetchRiwayat() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(Uri.parse("https://plngresik.net/egantung/get_riwayat.php"));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            riwayatList = data['data'];
            isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal ambil riwayat: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Riwayat Barang")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : riwayatList.isEmpty
              ? const Center(child: Text("Belum ada riwayat"))
              : ListView.builder(
                  itemCount: riwayatList.length,
                  itemBuilder: (context, index) {
                    final item = riwayatList[index];
                    final jenis = item['jenis'];
                    final iconColor = jenis == 'masuk' ? Colors.green : Colors.red;
                    final iconData = jenis == 'masuk' ? Icons.arrow_downward : Icons.arrow_upward;

                    return ListTile(
                      leading: Icon(iconData, color: iconColor),
                      title: Text(item['nama_barang']),
                      subtitle: Text("Kode Barang: ${item['serial_number']}\nJumlah: ${item['jumlah']}"),
                      trailing: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(jenis[0].toUpperCase() + jenis.substring(1), style: TextStyle(color: iconColor)),
                          const SizedBox(height: 4),
                          Text(item['waktu'] ?? "-"),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}

// fungsi ekstensi agar 'masuk' jadi 'Masuk'
extension StringCasingExtension on String {
  String capitalize() => "${this[0].toUpperCase()}${substring(1)}";
}
