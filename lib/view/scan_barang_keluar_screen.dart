import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'form_barang_keluar_screen.dart';

class ScanBarangKeluarScreen extends StatefulWidget {
  const ScanBarangKeluarScreen({super.key});

  @override
  State<ScanBarangKeluarScreen> createState() => _ScanBarangKeluarScreenState();
}

class _ScanBarangKeluarScreenState extends State<ScanBarangKeluarScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool isNavigating = false;

  @override
  void reassemble() {
    super.reassemble();
    controller?.pauseCamera();
    controller?.resumeCamera();
  }

  void _onQRViewCreated(QRViewController ctrl) {
    controller = ctrl;

    ctrl.scannedDataStream.listen((scanData) async {
      if (isNavigating) return;

      final rawData = scanData.code ?? '';
      final parts = rawData.split('||');
      final serialNumber = parts.isNotEmpty ? parts[0].trim() : '';

      if (serialNumber.isNotEmpty) {
        isNavigating = true;
        await controller?.pauseCamera();

        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FormBarangKeluarScreen(
              serialNumber: serialNumber,
            ),
          ),
        );

        await controller?.resumeCamera();
        isNavigating = false;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("QR tidak valid")),
        );
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan Barang Keluar")),
      body: QRView(
        key: qrKey,
        onQRViewCreated: _onQRViewCreated,
        overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: MediaQuery.of(context).size.width * 0.8,
        ),
      ),
    );
  }
}
