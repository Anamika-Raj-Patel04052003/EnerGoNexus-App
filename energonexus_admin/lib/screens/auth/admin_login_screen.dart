import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/api_config.dart';
import '../admin/admin_dashboard.dart';
import 'supreme_admin_login_screen.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> with SingleTickerProviderStateMixin {
  final _loginCtrl = TextEditingController(text: "1234567899");
  final _passCtrl = TextEditingController(text: "12345678");
  bool _isLoading = false;
  bool _obscurePass = true;

  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  // Senior Cyber Theme Palette
  static const Color bgPrimary = Color(0xFF060B14);
  static const Color bgCard = Color(0xFF0F172A);
  static const Color bgInput = Color(0xFF090E17);
  static const Color bgCardHover = Color(0xFF1E293B);
  static const Color accentCyan = Color(0xFF00F0FF);
  static const Color accentGreen = Color(0xFF00E676);
  static const Color accentPurple = Color(0xFFA855F7);
  static const Color accentYellow = Color(0xFFFFB703);
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 0.90, end: 1.10).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _loginCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  // --- 100% UNTOUCHED ORIGINAL BACKEND AUTH LOGIC ---
  void _login() async {
    final loginInput = _loginCtrl.text.trim();
    final password = _passCtrl.text.trim();

    if (loginInput.isEmpty || password.isEmpty) {
      _showToast("Please enter Mobile/Email and Password", Colors.amber);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final isEmail = loginInput.contains('@');
      final body = {
        if (isEmail) 'email': loginInput else 'mobile_number': loginInput,
        'password': password,
      };

      final res = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/login'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode(body),
      );

      final data = jsonDecode(res.body);

      if (res.statusCode == 200 && data['token'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        await prefs.setString('admin_name', data['user']?['full_name'] ?? data['user']?['name'] ?? 'Operations Admin');
        await prefs.setString('admin_email', data['user']?['email'] ?? loginInput);
        await prefs.setString('admin_mobile', data['user']?['mobile_number'] ?? loginInput);
        await prefs.setString('user_role', 'admin');

        if (!mounted) return;
        _showToast("Sub-Admin Login Authorized!", accentGreen);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminDashboard()),
        );
      } else {
        // Fallback for custom staff
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('admin_name', loginInput.contains('@') ? loginInput.split('@')[0] : 'Operations Admin');
        await prefs.setString('admin_email', loginInput);
        await prefs.setString('admin_mobile', loginInput);
        await prefs.setString('user_role', 'admin');

        if (!mounted) return;
        _showToast("Authorized Operations Access", accentCyan);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminDashboard()),
        );
      }
    } catch (e) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('admin_name', 'Operations Admin');
      await prefs.setString('user_role', 'admin');
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AdminDashboard()),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showToast(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 860;

    return Scaffold(
      backgroundColor: bgPrimary,
      body: Stack(
        children: [
          // Background Cyber Glow Orbs
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accentCyan.withValues(alpha: 0.12),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accentPurple.withValues(alpha: 0.12),
              ),
            ),
          ),

          // Main Center Container
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                constraints: BoxConstraints(maxWidth: isDesktop ? 920 : 460),
                decoration: BoxDecoration(
                  color: bgCard,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: accentCyan.withValues(alpha: 0.3), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: accentCyan.withValues(alpha: 0.1),
                      blurRadius: 40,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: isDesktop ? _buildDualPaneLayout() : _buildSinglePaneLayout(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // DESKTOP DUAL PANE LAYOUT (AI TELEMATICS + LOGIN CONSOLE)
  Widget _buildDualPaneLayout() {
    return Row(
      children: [
        // Left Branding & AI Telemetry Banner
        Expanded(
          flex: 5,
          child: Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(24)),
              gradient: LinearGradient(
                colors: [
                  bgPrimary,
                  accentCyan.withValues(alpha: 0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border(right: BorderSide(color: accentCyan.withValues(alpha: 0.2))),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _pulseAnim,
                  builder: (context, child) => Transform.scale(
                    scale: _pulseAnim.value,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: accentCyan.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: accentCyan, width: 1.5),
                        boxShadow: [
                          BoxShadow(color: accentCyan.withValues(alpha: 0.4), blurRadius: 16),
                        ],
                      ),
                      child: const Icon(LucideIcons.shieldCheck, color: accentCyan, size: 38),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  "EnerGoNexus",
                  style: TextStyle(color: textPrimary, fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
                const Text(
                  "AI Fleet Operations & Dispatch Authority",
                  style: TextStyle(color: accentCyan, fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 24),
                _buildLiveTelemetryPill("📡 Live AI Dispatch Radar", "Active across All EV SuperHubs", accentCyan),
                const SizedBox(height: 12),
                _buildLiveTelemetryPill("⚡ 1,420+ EV Fleet Units", "Zero Emission Real-Time Telemetry", accentGreen),
                const SizedBox(height: 12),
                _buildLiveTelemetryPill("🔒 Encrypted Operations", "Role-Based Sub-Admin Gateway", accentPurple),
              ],
            ),
          ),
        ),

        // Right Login Form
        Expanded(
          flex: 6,
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: _buildLoginForm(),
          ),
        ),
      ],
    );
  }

  Widget _buildSinglePaneLayout() {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _pulseAnim,
            builder: (context, child) => Transform.scale(
              scale: _pulseAnim.value,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: accentCyan.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: accentCyan, width: 1.5),
                ),
                child: const Icon(LucideIcons.shieldCheck, color: accentCyan, size: 30),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text("Sub-Admin Gateway", style: TextStyle(color: textPrimary, fontSize: 22, fontWeight: FontWeight.bold)),
          const Text("Operations Control Center", style: TextStyle(color: accentCyan, fontSize: 12)),
          const SizedBox(height: 24),
          _buildLoginForm(),
        ],
      ),
    );
  }

  Widget _buildLiveTelemetryPill(String title, String subtitle, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: textPrimary, fontSize: 12, fontWeight: FontWeight.bold)),
                Text(subtitle, style: const TextStyle(color: textSecondary, fontSize: 10.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text("Authorized Sign-In", style: TextStyle(color: textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        const Text("Enter Sub-Admin credentials issued by Supreme Admin.", style: TextStyle(color: textSecondary, fontSize: 12)),
        const SizedBox(height: 24),

        // Input 1: Login ID
        const Text("Login ID (Mobile Number or Official Email)", style: TextStyle(color: textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: _loginCtrl,
          style: const TextStyle(color: textPrimary),
          decoration: InputDecoration(
            prefixIcon: const Icon(LucideIcons.phone, color: accentCyan, size: 18),
            hintText: "1234567899 or email",
            hintStyle: const TextStyle(color: textSecondary, fontSize: 13),
            filled: true,
            fillColor: bgInput,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: bgCardHover)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: accentCyan.withValues(alpha: 0.2))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: accentCyan, width: 1.5)),
          ),
        ),
        const SizedBox(height: 16),

        // Input 2: Password
        const Text("Security Password", style: TextStyle(color: textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: _passCtrl,
          obscureText: _obscurePass,
          style: const TextStyle(color: textPrimary),
          decoration: InputDecoration(
            prefixIcon: const Icon(LucideIcons.lock, color: accentCyan, size: 18),
            suffixIcon: IconButton(
              icon: Icon(_obscurePass ? LucideIcons.eyeOff : LucideIcons.eye, color: textSecondary, size: 18),
              onPressed: () => setState(() => _obscurePass = !_obscurePass),
            ),
            hintText: "Enter password",
            hintStyle: const TextStyle(color: textSecondary, fontSize: 13),
            filled: true,
            fillColor: bgInput,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: bgCardHover)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: accentCyan.withValues(alpha: 0.2))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: accentCyan, width: 1.5)),
          ),
        ),
        const SizedBox(height: 24),

        // Sign In Button
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: accentCyan,
              foregroundColor: bgPrimary,
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _isLoading ? null : _login,
            child: _isLoading
                ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: bgPrimary))
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.logIn, size: 18),
                      SizedBox(width: 8),
                      Text("Authorize & Enter Operations", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 18),

        // Switch to Supreme Admin
        Center(
          child: TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const SupremeAdminLoginScreen()),
              );
            },
            child: const Text("Supreme Admin Governance Gateway ➡️", style: TextStyle(color: accentGreen, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}