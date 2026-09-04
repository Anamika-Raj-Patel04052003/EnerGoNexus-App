import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../config/api_config.dart';
import 'supreme_admin_login_screen.dart';

class SupremeAdminRegisterScreen extends StatefulWidget {
  const SupremeAdminRegisterScreen({super.key});

  @override
  State<SupremeAdminRegisterScreen> createState() => _SupremeAdminRegisterScreenState();
}

class _SupremeAdminRegisterScreenState extends State<SupremeAdminRegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _isLoading = false;
  bool _obscure = true;

  static const Color bgPrimary = Color(0xFF0F172A);
  static const Color bgCard = Color(0xFF1E293B);
  static const Color bgCardHover = Color(0xFF334155);
  static const Color accentGreen = Color(0xFF00D290);
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);

    Future<void> _registerSupremeAdmin() async {
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
          'full_name': name, // ✅ Added
          'name': name,
          'email': email,
          'phone': phone,
          'phone_number': phone,
          'mobile_number': phone,
          'password': password,
          'password_confirmation': password,
          'role': 'super_admin',
        }),
      );

      print("Backend Status: ${res.statusCode}");
      print("Backend Response: ${res.body}");

      final data = jsonDecode(res.body);

      if (res.statusCode == 200 || res.statusCode == 201) {
        if (!mounted) return;
        _showToast("Supreme Admin Registered Successfully!", accentGreen);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SupremeAdminLoginScreen()),
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
                    color: accentGreen.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: accentGreen, width: 2),
                  ),
                  child: const Icon(LucideIcons.crown, color: accentGreen, size: 40),
                ),
                const SizedBox(height: 14),
                const Text(
                  "Supreme Admin Onboarding",
                  style: TextStyle(color: textPrimary, fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Register Master Account for EnerGoNexus",
                  style: TextStyle(color: textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: bgCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: accentGreen.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    children: [
                      _buildField(_nameCtrl, "Full Name", LucideIcons.user),
                      const SizedBox(height: 14),
                      _buildField(_emailCtrl, "Supreme Master Email", LucideIcons.mail),
                      const SizedBox(height: 14),
                      _buildField(_phoneCtrl, "Phone Number", LucideIcons.phone),
                      const SizedBox(height: 14),
                      _buildField(_passCtrl, "Security Password", LucideIcons.lock, isPassword: true),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentGreen,
                      foregroundColor: bgPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _isLoading ? null : _registerSupremeAdmin,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: bgPrimary)
                        : const Text("Register Supreme Admin", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ),
                const SizedBox(height: 14),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const SupremeAdminLoginScreen()),
                    );
                  },
                  child: const Text("Already registered? Login here", style: TextStyle(color: accentGreen)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String hint, IconData icon, {bool isPassword = false}) {
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