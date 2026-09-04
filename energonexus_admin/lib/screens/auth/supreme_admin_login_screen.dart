import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/api_config.dart';
import '../super_admin/super_admin_dashboard.dart';
import 'supreme_admin_register_screen.dart';

class SupremeAdminLoginScreen extends StatefulWidget {
  const SupremeAdminLoginScreen({super.key});

  @override
  State<SupremeAdminLoginScreen> createState() => _SupremeAdminLoginScreenState();
}

class _SupremeAdminLoginScreenState extends State<SupremeAdminLoginScreen> {
  final _inputCtrl = TextEditingController(); // Mobile Number or Email
  final _passCtrl = TextEditingController();
  bool _isLoading = false;
  bool _obscure = true;

  static const Color bgPrimary = Color(0xFF0F172A);
  static const Color bgCard = Color(0xFF1E293B);
  static const Color bgCardHover = Color(0xFF334155);
  static const Color accentGreen = Color(0xFF00D290);
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);

  Future<void> _submitSupremeLogin() async {
    final input = _inputCtrl.text.trim();
    final password = _passCtrl.text.trim();

    if (input.isEmpty || password.isEmpty) {
      _showToast("Enter your mobile number/email & password.", Colors.amber);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final res = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/login'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({
          'mobile_number': input, // ✅ Backend mobile_number mang raha hai
          'phone': input,
          'phone_number': input,
          'email': input,
          'password': password,
        }),
      );

      print("Login Status: ${res.statusCode}");
      print("Login Response: ${res.body}");

      final data = jsonDecode(res.body);

      if (res.statusCode == 200 && (data['token'] != null || data['access_token'] != null)) {
        final token = data['token'] ?? data['access_token'];
        final user = data['user'] ?? {};
        final role = user['role'] ?? 'super_admin';
        final name = user['full_name'] ?? user['name'] ?? 'Supreme Admin';

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('role', role);
        await prefs.setString('super_admin_name', name);

        if (!mounted) return;
        _showToast("Welcome, Supreme Admin $name!", accentGreen);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SuperAdminDashboard()),
        );
      } else {
        _showToast(data['message'] ?? data['error'] ?? "Authentication failed.", Colors.redAccent);
      }
    } catch (e) {
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
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: accentGreen.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: accentGreen, width: 2),
                    boxShadow: [
                      BoxShadow(color: accentGreen.withValues(alpha: 0.2), blurRadius: 20, spreadRadius: 2),
                    ],
                  ),
                  child: const Icon(LucideIcons.crown, color: accentGreen, size: 44),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Supreme Admin Access",
                  style: TextStyle(color: textPrimary, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Full Ecosystem Governance & Platform Control",
                  style: TextStyle(color: textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 28),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: bgCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: accentGreen.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: _inputCtrl,
                        style: const TextStyle(color: textPrimary),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(LucideIcons.user, color: textSecondary, size: 18),
                          hintText: "Mobile Number or Email",
                          hintStyle: const TextStyle(color: textSecondary),
                          filled: true,
                          fillColor: bgPrimary,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: bgCardHover),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passCtrl,
                        obscureText: _obscure,
                        style: const TextStyle(color: textPrimary),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(LucideIcons.lock, color: textSecondary, size: 18),
                          suffixIcon: IconButton(
                            icon: Icon(_obscure ? LucideIcons.eyeOff : LucideIcons.eye, color: textSecondary, size: 18),
                            onPressed: () => setState(() => _obscure = !_obscure),
                          ),
                          hintText: "Password",
                          hintStyle: const TextStyle(color: textSecondary),
                          filled: true,
                          fillColor: bgPrimary,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: bgCardHover),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentGreen,
                      foregroundColor: bgPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 4,
                    ),
                    onPressed: _isLoading ? null : _submitSupremeLogin,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: bgPrimary)
                        : const Text("Authorize Supreme Access", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 14),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SupremeAdminRegisterScreen()),
                    );
                  },
                  child: const Text("New Supreme Admin? Register here", style: TextStyle(color: accentGreen)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}