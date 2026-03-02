import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';

class DetailRakScreen extends StatefulWidget {
  final String rakId;

  const DetailRakScreen({super.key, required this.rakId});

  @override
  State<DetailRakScreen> createState() => _DetailRakScreenState();
}

class _DetailRakScreenState extends State<DetailRakScreen> {
  List<dynamic> barangList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBarangByRak();
  }

  Future<void> fetchBarangByRak() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(
        Uri.parse("https://plngresik.net/egantung/get_barang_by_rak.php?rak=${widget.rakId}"),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['status'] == 'success') {
          setState(() {
            barangList = jsonData['data'];
            isLoading = false;
          });
        } else {
          throw Exception(jsonData['message']);
        }
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil data: $e')),
      );
    }
  }

  void showDetailPopup(Map<String, dynamic> barang) {
    final serial = barang['serial_number'];
    final qrUrl = "https://plngresik.net/egantung/qr_images/$serial.png";

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                alignment: Alignment.topRight,
                children: [
                  Container(
                    height: 150,
                    width: double.infinity,
                    color: Colors.grey[300],
                    child: const Center(child: Text("[Gambar Barang]")),
                  ),
                  IconButton(
                    icon: const Icon(Icons.qr_code, color: Colors.blue),
                    onPressed: () => showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("QR Code Barang"),
                        content: Image.network(qrUrl, height: 150),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Tutup"),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text("Nama       : ${barang['nama_barang']}"),
              Row(
                children: [
                  Expanded(child: Text("Kode Barang    : $serial")),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 18),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: serial));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Kode disalin")),
                      );
                    },
                  ),
                ],
              ),
              Text("Rak        : ${barang['rak']}"),
              Text("Peti       : ${barang['peti']}"),
              Text("Jumlah     : ${barang['jumlah']} ${barang['satuan']}"),
              Text("Catatan    : ${barang['catatan'] ?? '-'}"),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => confirmDelete(barang['id']),
                    child: const Text("Hapus", style: TextStyle(color: Colors.red)),
                  ),
                  TextButton(
                    onPressed: () => showEditDialog(barang),
                    child: const Text("Edit"),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Keluarkan"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showEditDialog(Map<String, dynamic> barang) {
    final TextEditingController namaController = TextEditingController(text: barang['nama_barang']);
    final TextEditingController jumlahController = TextEditingController(text: barang['jumlah']);
    final TextEditingController satuanController = TextEditingController(text: barang['satuan']);
    final TextEditingController catatanController = TextEditingController(text: barang['catatan']);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Barang"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: namaController, decoration: const InputDecoration(labelText: 'Nama Barang')),
            TextField(controller: jumlahController, decoration: const InputDecoration(labelText: 'Jumlah')),
            TextField(controller: satuanController, decoration: const InputDecoration(labelText: 'Satuan')),
            TextField(controller: catatanController, decoration: const InputDecoration(labelText: 'Catatan')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () async {
              await http.post(
                Uri.parse("https://plngresik.net/egantung/update_barang.php"),
                body: {
                  'id': barang['id'],
                  'nama_barang': namaController.text,
                  'jumlah': jumlahController.text,
                  'satuan': satuanController.text,
                  'catatan': catatanController.text,
                },
              );
              Navigator.pop(context);
              fetchBarangByRak();
            },
            child: const Text("Simpan"),
          )
        ],
      ),
    );
  }

  void confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Hapus Barang"),
        content: const Text("Yakin ingin menghapus barang ini?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () async {
              await http.post(
                Uri.parse("https://plngresik.net/egantung/delete_barang.php"),
                body: {'id': id},
              );
              Navigator.pop(context);
              fetchBarangByRak();
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Isi Rak ${widget.rakId}")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: fetchBarangByRak,
              child: barangList.isEmpty
                  ? ListView(
                      children: const [
                        Padding(
                          padding: EdgeInsets.only(top: 100),
                          child: Center(child: Text("Belum ada barang di rak ini")),
                        ),
                      ],
                    )
                  : ListView.builder(
                      itemCount: barangList.length,
                      itemBuilder: (context, index) {
                        final barang = barangList[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: ListTile(
                            title: Text(barang['nama_barang']),
                            subtitle: Text("Jumlah: ${barang['jumlah']} ${barang['satuan']}"),
                            trailing: Text("Peti: ${barang['peti']}"),
                            onTap: () => showDetailPopup(barang),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
