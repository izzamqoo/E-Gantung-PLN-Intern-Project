import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart' as mlkit;
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'FormInputScreen.dart';

class ScanQRScreen extends StatefulWidget {
  const ScanQRScreen({super.key});

  @override
  State<ScanQRScreen> createState() => _ScanQRScreenState();
}

class _ScanQRScreenState extends State<ScanQRScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  final ImagePicker picker = ImagePicker();
  bool flashOn = false;

  @override
  void reassemble() {
    super.reassemble();
    controller?.pauseCamera();
    controller?.resumeCamera();
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      controller.pauseCamera();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => FormInputScreen(qrData: scanData.code!),
        ),
      );
    });
  }

  Future<void> _pickImageFromGallery() async {
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      final inputImage = InputImage.fromFilePath(pickedImage.path);
      final barcodeScanner = mlkit.BarcodeScanner();
      final List<mlkit.Barcode> barcodes = await barcodeScanner.processImage(inputImage);

      if (barcodes.isNotEmpty) {
        final code = barcodes.first.rawValue;
        if (code != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => FormInputScreen(qrData: code),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("QR tidak terbaca")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("QR tidak ditemukan")),
        );
      }
    }
  }

  void _toggleFlash() async {
    if (controller != null) {
      flashOn = !flashOn;
      await controller!.toggleFlash();
      setState(() {});
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
            overlay: QrScannerOverlayShape(
              borderColor: Colors.white,
              borderRadius: 16,
              borderLength: 32,
              borderWidth: 6,
              cutOutSize: MediaQuery.of(context).size.width * 0.7,
            ),
          ),
          Positioned(
            top: 30,
            left: 20,
            child: IconButton(
              onPressed: _toggleFlash,
              icon: Icon(
                flashOn ? Icons.flash_on : Icons.flash_off,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
          Positioned(
            bottom: 180,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Letakkan kode dalam bingkai',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
          Positioned(
            bottom: 60,
            left: MediaQuery.of(context).size.width / 2 - 35,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.qr_code_scanner, color: Colors.white38, size: 40),
            ),
          ),
          Positioned(
            bottom: 65,
            right: 30,
            child: IconButton(
              onPressed: _pickImageFromGallery,
              icon: const Icon(Icons.image, color: Colors.white, size: 32),
            ),
          ),
        ],
      ),
    );
  }
}
