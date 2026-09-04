import 'package:flutter/material.dart';

import '../driver/driver_main_navigation.dart';

class DriverLoginScreen extends StatefulWidget {
  const DriverLoginScreen({super.key});

  @override
  State<DriverLoginScreen> createState() => _DriverLoginScreenState();
}

class _DriverLoginScreenState extends State<DriverLoginScreen> {
  final _mobileCtrl = TextEditingController(text: "9876543210");
  final _pinCtrl = TextEditingController(text: "7842");

  @override
  void dispose() {
    _mobileCtrl.dispose();
    _pinCtrl.dispose();
    super.dispose();
  }

  void _loginAsDriver() {
    // DIRECT PUSH TO DRIVER MAIN NAVIGATION (CAPTAIN COCKPIT)
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const DriverMainNavigation()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080E1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF10192B),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pushReplacementNamed(context, '/role-selection'),
        ),
        title: const Text("EV Captain (Driver) Login", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF131D31),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF00F0FF), width: 2),
                  ),
                  child: const Icon(Icons.local_taxi, color: Color(0xFF00F0FF), size: 44),
                ),
              ),
              const SizedBox(height: 14),
              const Center(
                child: Text("Welcome Back, Captain!", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              const Center(
                child: Text("Sign in to your on-duty EV cockpit", style: TextStyle(color: Colors.white54, fontSize: 12)),
              ),
              const SizedBox(height: 28),

              // MOBILE NUMBER
              const Text("Registered Mobile Number", style: TextStyle(color: Colors.white70, fontSize: 12.5, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              TextField(
                controller: _mobileCtrl,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.phone, color: Color(0xFF00F0FF), size: 18),
                  filled: true,
                  fillColor: const Color(0xFF131D31),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),

              // PIN / PASSWORD
              const Text("Captain 4-Digit Security PIN", style: TextStyle(color: Colors.white70, fontSize: 12.5, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              TextField(
                controller: _pinCtrl,
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 4,
                style: const TextStyle(color: Colors.white, fontSize: 18, letterSpacing: 6),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock, color: Color(0xFF00F0FF), size: 18),
                  counterText: "",
                  filled: true,
                  fillColor: const Color(0xFF131D31),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 22),

              // SIGN IN BUTTON
              GestureDetector(
                onTap: _loginAsDriver,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00F0FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text("Sign In to Duty Cockpit", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // QUICK 1-TAP DEMO LOGIN BUTTON
              GestureDetector(
                onTap: _loginAsDriver,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0x2600E676),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF00E676)),
                  ),
                  child: const Center(
                    child: Text("🚀 1-Tap Login: Suresh Verma (Tata Nexon EV)", style: TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.bold, fontSize: 12.5)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}