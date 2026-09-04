import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../config/api_config.dart';
import 'admin_login_screen.dart';

class AdminRegisterScreen extends StatefulWidget {
  const AdminRegisterScreen({super.key});

  @override
  State<AdminRegisterScreen> createState() => _AdminRegisterScreenState();
}

class _AdminRegisterScreenState extends State<AdminRegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _isLoading = false;
  bool _obscure = true;

  static const Color bgPrimary = Color(0xFF0F172A);
  static const Color bgCard = Color(0xFF1E293B);
  static const Color bgCardHover = Color(0xFF334155);
  static const Color accentCyan = Color(0xFF06B6D4);
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);

  Future<void> _registerAdmin() async {
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    final password = _passCtrl.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showToast("Please fill all required fields.", Colors.amber);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final res = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'full_name': name,
          'name': name,
          'email': email,
          'phone': phone,
          'phone_number': phone,
          'mobile_number': phone,
          'password': password,
          'password_confirmation': password,
          'role': 'admin',
        }),
      );

      print("Admin Register Status: ${res.statusCode}");
      print("Admin Register Response: ${res.body}");

      final data = jsonDecode(res.body);

      if (res.statusCode == 200 || res.statusCode == 201) {
        if (!mounted) return;
        _showToast("Admin Registered Successfully! Please Login.", accentCyan);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminLoginScreen()),
        );
      } else {
        String errorMsg = data['message'] ?? "Registration failed";
        if (data['errors'] != null) {
          final errors = data['errors'] as Map<String, dynamic>;
          errorMsg = errors.values.map((e) => e is List ? e.first : e.toString()).join('\n');
        }
        _showToast(errorMsg, Colors.redAccent);
      }
    } catch (e) {
      print("Error: $e");
      _showToast("Connection error: $e", Colors.redAccent);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showToast(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg, style: const TextStyle(fontWeight: FontWeight.bold)), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgPrimary,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: accentCyan.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: accentCyan, width: 2),
                  ),
                  child: const Icon(LucideIcons.userPlus, color: accentCyan, size: 40),
                ),
                const SizedBox(height: 14),
                const Text(
                  "Admin Registration",
                  style: TextStyle(color: textPrimary, fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Register as an Operations & Dispatch Admin",
                  style: TextStyle(color: textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: bgCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: bgCardHover),
                  ),
                  child: Column(
                    children: [
                      _buildTextField(_nameCtrl, "Admin Full Name", LucideIcons.user),
                      const SizedBox(height: 14),
                      _buildTextField(_emailCtrl, "Admin Official Email", LucideIcons.mail),
                      const SizedBox(height: 14),
                      _buildTextField(_phoneCtrl, "Contact Number", LucideIcons.phone),
                      const SizedBox(height: 14),
                      _buildTextField(_passCtrl, "Password", LucideIcons.lock, isPassword: true),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentCyan,
                      foregroundColor: bgPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _isLoading ? null : _registerAdmin,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: bgPrimary)
                        : const Text("Register as Admin", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ),
                const SizedBox(height: 14),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const AdminLoginScreen()),
                    );
                  },
                  child: const Text("Already have an account? Login here", style: TextStyle(color: accentCyan)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String hint, IconData icon, {bool isPassword = false}) {
    return TextField(
      controller: ctrl,
      obscureText: isPassword ? _obscure : false,
      style: const TextStyle(color: textPrimary),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: textSecondary, size: 18),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(_obscure ? LucideIcons.eyeOff : LucideIcons.eye, color: textSecondary, size: 18),
                onPressed: () => setState(() => _obscure = !_obscure),
              )
            : null,
        hintText: hint,
        hintStyle: const TextStyle(color: textSecondary),
        filled: true,
        fillColor: bgPrimary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: bgCardHover),
        ),
      ),
    );
  }
}