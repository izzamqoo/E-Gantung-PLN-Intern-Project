import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FormInputScreen extends StatefulWidget {
  final String qrData;

  const FormInputScreen({super.key, required this.qrData});

  @override
  State<FormInputScreen> createState() => _FormInputScreenState();
}

class _FormInputScreenState extends State<FormInputScreen> {
  final _namaController = TextEditingController();
  final _jumlahController = TextEditingController();
  final _satuanController = TextEditingController();
  final _catatanController = TextEditingController();
  String? selectedRak;
  String? selectedPeti;

  late String serialNumber;

  final Map<String, String> rakMap = {
    'Rak A': '1', 'Rak B': '2', 'Rak C': '3', 'Rak D': '4', 'Rak E': '5',
    'Rak F': '6', 'Rak G': '7', 'Rak H': '8', 'Rak I': '9', 'Rak J': '10',
    'Rak K': '11', 'Rak L': '12', 'Rak M': '13', 'Rak N': '14', 'Rak O': '15',
  };

  final Map<String, String> petiMap = {
    'A11': '1', 'A21': '2', 'A31': '3', 'A41': '4', 'A12': '5', 'A22': '6', 'A32': '7', 'A42': '8',
    'B11': '9', 'B21': '10', 'B31': '11', 'B41': '12', 'B12': '13', 'B22': '14', 'B32': '15', 'B42': '16',
    'C11': '17', 'C21': '18', 'C31': '19', 'C41': '20', 'C12': '21', 'C22': '22', 'C32': '23', 'C42': '24',
    'D11': '25', 'D21': '26', 'D31': '27', 'D41': '28', 'D12': '29', 'D22': '30', 'D32': '31', 'D42': '32',
    'E11': '33', 'E21': '34', 'E31': '35', 'E41': '36', 'E12': '37', 'E22': '38', 'E32': '39', 'E42': '40',
    'F11': '41', 'F21': '42', 'F31': '43', 'F41': '44', 'F12': '45', 'F22': '46', 'F32': '47', 'F42': '48',
    'G11': '49', 'G21': '50', 'G31': '51', 'G41': '52', 'G12': '53', 'G22': '54', 'G32': '55', 'G42': '56',
    'H11': '57', 'H21': '58', 'H31': '59', 'H41': '60', 'H12': '61', 'H22': '62', 'H32': '63', 'H42': '64',
    'I11': '65', 'I21': '66', 'I31': '67', 'I41': '68', 'I12': '69', 'I22': '70', 'I32': '71', 'I42': '72',
    'J11': '73', 'J21': '74', 'J31': '75', 'J41': '76', 'J12': '77', 'J22': '78', 'J32': '79', 'J42': '80',
    'K11': '81', 'K21': '82', 'K31': '83', 'K41': '84', 'K12': '85', 'K22': '86', 'K32': '87', 'K42': '88',
    'L11': '89', 'L21': '90', 'L31': '91', 'L41': '92', 'L12': '93', 'L22': '94', 'L32': '95', 'L42': '96',
    'M11': '97', 'M21': '98', 'M31': '99', 'M41': '100', 'M12': '101', 'M22': '102', 'M32': '103', 'M42': '104',
    'N11': '105', 'N21': '106', 'N31': '107', 'N41': '108', 'N12': '109', 'N22': '110', 'N32': '111', 'N42': '112',
    'O11': '113', 'O21': '114', 'O31': '115', 'O41': '116', 'O12': '117', 'O22': '118', 'O32': '119', 'O42': '120',
  };

  @override
  void initState() {
    super.initState();
    final parts = widget.qrData.split("||");
    serialNumber = parts[0];
    if (parts.length > 1) {
      _namaController.text = parts[1];
    }
  }

  Future<void> submitData() async {
    FocusScope.of(context).unfocus();

    if (_namaController.text.isEmpty ||
        _jumlahController.text.isEmpty ||
        _satuanController.text.isEmpty ||
        selectedRak == null ||
        selectedPeti == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Harap lengkapi semua data")),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse("https://plngresik.net/egantung/barang_masuk.php"),
        body: {
          "serial_number": serialNumber,
          "nama_barang": _namaController.text,
          "jumlah": _jumlahController.text,
          "satuan": _satuanController.text,
          "rak": rakMap[selectedRak]!,
          "peti": petiMap[selectedPeti]!,
          "catatan": _catatanController.text,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'success') {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text("Berhasil"),
              content: const Text("Barang berhasil disimpan ke stok."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  child: const Text("Tutup"),
                )
              ],
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'])),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Server error: ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal membaca response: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Input Barang Masuk")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text("Kode Barang: $serialNumber"),
            TextField(
              controller: _namaController,
              decoration: const InputDecoration(labelText: "Nama Barang"),
            ),
            TextField(
              controller: _jumlahController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Jumlah"),
            ),
            TextField(
              controller: _satuanController,
              decoration: const InputDecoration(labelText: "Satuan"),
            ),
            DropdownButtonFormField<String>(
              value: selectedRak,
              decoration: const InputDecoration(labelText: "Rak"),
              items: rakMap.keys
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) => setState(() => selectedRak = val),
            ),
            DropdownButtonFormField<String>(
              value: selectedPeti,
              decoration: const InputDecoration(labelText: "Peti"),
              items: petiMap.keys
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) => setState(() => selectedPeti = val),
            ),
            TextField(
              controller: _catatanController,
              decoration: const InputDecoration(labelText: "Catatan"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: submitData,
              child: const Text("Simpan"),
            )
          ],
        ),
      ),
    );
  }
}
