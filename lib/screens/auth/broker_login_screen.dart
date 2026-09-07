import 'package:flutter/material.dart';
import 'broker_register_screen.dart';
import '../broker/broker_dashboard_screen.dart';

class BrokerLoginScreen extends StatefulWidget {
  const BrokerLoginScreen({super.key});

  @override
  State<BrokerLoginScreen> createState() => _BrokerLoginScreenState();
}

class _BrokerLoginScreenState extends State<BrokerLoginScreen> {
  final _emailController = TextEditingController(text: "greenfleet.bhopal@energo.in");
  final _passwordController = TextEditingController(text: "123456");
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080E1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("FLEET BROKER PORTAL", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF332005).withOpacity(0.4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFFB703).withOpacity(0.4)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.business_center, color: Color(0xFFFFB703), size: 30),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Fleet Broker Command HQ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                        Text("Manage multi-EV fleet, track central vault & pay driver salaries.", style: TextStyle(color: Colors.white70, fontSize: 11.5)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            const Text("Broker Credentials", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            TextField(
              controller: _emailController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Broker Code / Corporate Email",
                labelStyle: const TextStyle(color: Colors.white60),
                prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFFFFB703)),
                filled: true,
                fillColor: const Color(0xFF161F30),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Password",
                labelStyle: const TextStyle(color: Colors.white60),
                prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFFFFB703)),
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.white54),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
                filled: true,
                fillColor: const Color(0xFF161F30),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFB703),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const BrokerDashboardScreen()));
                },
                child: const Text("Login to Fleet Dashboard", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            ),
            const SizedBox(height: 24),

            Center(
              child: TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BrokerRegisterScreen())),
                child: const Text("New EV Fleet Owner? Register as Broker (Earn 100% Direct Fares)", style: TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}