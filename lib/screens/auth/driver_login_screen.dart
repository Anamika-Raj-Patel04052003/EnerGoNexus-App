import 'package:flutter/material.dart';
import '../driver/driver_main_navigation.dart';

class DriverLoginScreen extends StatefulWidget {
  const DriverLoginScreen({super.key});

  @override
  State<DriverLoginScreen> createState() => _DriverLoginScreenState();
}

class _DriverLoginScreenState extends State<DriverLoginScreen> {
  int _selectedMode = 0; // 0: Solo Driver, 1: Broker Fleet Driver

  final _phoneCtrl = TextEditingController(text: "+91 98112 44331");
  final _pinCtrl = TextEditingController(text: "7842");

  void _loginDriver() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (ctx) => const DriverMainNavigation()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E17),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111827),
        title: const Text("Driver Cockpit Login", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.15), shape: BoxShape.circle),
                child: const Icon(Icons.local_taxi, color: Color(0xFF10B981), size: 48),
              ),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text("Welcome to EnerGo Driver Cockpit", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const Center(
              child: Text("Select your driver affiliation to continue", style: TextStyle(color: Colors.white54, fontSize: 12)),
            ),
            const SizedBox(height: 24),

            // TOGGLE: SOLO vs BROKER DRIVER
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: const Color(0xFF161F30), borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedMode = 0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _selectedMode == 0 ? const Color(0xFF00E5FF) : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            "🚕 Solo Driver",
                            style: TextStyle(color: _selectedMode == 0 ? Colors.black : Colors.white70, fontWeight: FontWeight.bold, fontSize: 12.5),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedMode = 1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _selectedMode == 1 ? const Color(0xFF10B981) : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            "🏢 Fleet Broker Driver",
                            style: TextStyle(color: _selectedMode == 1 ? Colors.black : Colors.white70, fontWeight: FontWeight.bold, fontSize: 12.5),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // FORM FIELDS
            TextField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                labelText: "Registered Mobile Number",
                labelStyle: const TextStyle(color: Colors.white60, fontSize: 12),
                prefixIcon: const Icon(Icons.phone, color: Color(0xFF00E5FF), size: 18),
                filled: true,
                fillColor: const Color(0xFF161F30),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white24)),
              ),
            ),
            const SizedBox(height: 14),

            TextField(
              controller: _pinCtrl,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              style: const TextStyle(color: Colors.white, fontSize: 18, letterSpacing: 4),
              decoration: InputDecoration(
                labelText: _selectedMode == 0 ? "4-Digit Solo PIN / OTP" : "4-Digit Broker Fleet PIN",
                labelStyle: const TextStyle(color: Colors.white60, fontSize: 12),
                prefixIcon: const Icon(Icons.lock, color: Color(0xFF10B981), size: 18),
                filled: true,
                fillColor: const Color(0xFF161F30),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white24)),
              ),
            ),
            const SizedBox(height: 20),

            // LOGIN BUTTON
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedMode == 0 ? const Color(0xFF00E5FF) : const Color(0xFF10B981),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _loginDriver,
                child: Text(
                  _selectedMode == 0 ? "LOGIN AS SOLO EV DRIVER" : "LOGIN AS BROKER FLEET DRIVER",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}