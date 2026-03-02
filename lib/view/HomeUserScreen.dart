import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeUserScreen extends StatefulWidget {
  const HomeUserScreen({super.key});

  @override
  State<HomeUserScreen> createState() => _HomeUserScreenState();
}

class _HomeUserScreenState extends State<HomeUserScreen> {
  List barang = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBarang();
  }

  Future<void> fetchBarang() async {
    try {
      final response = await http.get(
        Uri.parse("https://plngresik.net/egantung/get_barang.php"),
      );
      if (response.statusCode == 200) {
        setState(() {
          barang = json.decode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Stok Barang"),
        backgroundColor: Colors.blue,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : barang.isEmpty
              ? const Center(child: Text("Tidak ada data barang"))
              : ListView.builder(
                  itemCount: barang.length,
                  itemBuilder: (context, index) {
                    final item = barang[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      child: ListTile(
                        leading: const Icon(Icons.inventory),
                        title: Text(item['nama_barang']),
                        subtitle: Text(
                            "Serial: ${item['serial_number']}\nJumlah: ${item['jumlah']} ${item['satuan']}"),
                        trailing: Text("Rak: ${item['rak']} - Peti: ${item['peti']}"),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text(item['nama_barang']),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Serial: ${item['serial_number']}"),
                                    Text("Jumlah: ${item['jumlah']} ${item['satuan']}"),
                                    Text("Rak: ${item['rak']}"),
                                    Text("Peti: ${item['peti']}"),
                                    Text("Catatan: ${item['catatan']}"),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text("Tutup"),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
