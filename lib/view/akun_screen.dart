import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'edit_profil_screen.dart';
import 'ganti_password_screen.dart';
import 'loginscreen.dart';

class AkunScreen extends StatefulWidget {
  const AkunScreen({super.key});

  @override
  State<AkunScreen> createState() => _AkunScreenState();
}

class _AkunScreenState extends State<AkunScreen> {
  String nama = '';
  String email = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      nama = prefs.getString('nama') ?? '';
      email = prefs.getString('email') ?? '';
    });
  }

  void _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Hapus semua data user

    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Akun Saya'),
        backgroundColor: const Color(0xFF00AFC9),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Avatar dan Nama
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.teal.shade300,
              child: const Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text(nama, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(email, style: const TextStyle(fontSize: 14, color: Colors.black54)),
            const SizedBox(height: 30),

            // Ubah Profil
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.teal),
              title: const Text('Ubah Profil'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pushNamed(context, '/ubah-profil');
              },
            ),

            // Ganti Password
            ListTile(
              leading: const Icon(Icons.lock, color: Colors.orange),
              title: const Text('Ganti Password'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pushNamed(context, '/ganti-password');
              },
            ),

            // Logout
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("Konfirmasi"),
                    content: const Text("Yakin ingin logout?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Batal"),
                      ),
                      TextButton(
                        onPressed: () => _logout(context),
                        child: const Text("Logout", style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
