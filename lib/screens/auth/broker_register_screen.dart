import 'package:flutter/material.dart';
import '../broker/broker_dashboard_screen.dart';

class BrokerRegisterScreen extends StatefulWidget {
  const BrokerRegisterScreen({super.key});

  @override
  State<BrokerRegisterScreen> createState() => _BrokerRegisterScreenState();
}

class _BrokerRegisterScreenState extends State<BrokerRegisterScreen> {
  final _companyController = TextEditingController();
  final _ownerController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _upiController = TextEditingController();
  final _fleetSizeController = TextEditingController(text: "5");

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
        title: const Text("FLEET BROKER ONBOARDING", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SECURITY DEPOSIT BADGE
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF00E676).withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF00E676).withOpacity(0.5)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.verified_user, color: Color(0xFF00E676), size: 28),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("₹25,000 Refundable Security Deposit", style: TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.bold, fontSize: 13.5)),
                        Text("KYC verified by Supreme Admin. Enables 100% Direct Ride Vault routing.", style: TextStyle(color: Colors.white70, fontSize: 11)),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text("Company & Owner Details", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 14),

            _buildField(_companyController, "Fleet Company Name (e.g. Green Bhopal EV)", Icons.business),
            const SizedBox(height: 12),
            _buildField(_ownerController, "Owner / Managing Director Name", Icons.person),
            const SizedBox(height: 12),
            _buildField(_phoneController, "Official Phone Number", Icons.phone),
            const SizedBox(height: 12),
            _buildField(_emailController, "Official Email Address", Icons.email),
            const SizedBox(height: 12),
            _buildField(_upiController, "Corporate Bank UPI ID (e.g. greenfleet@icici)", Icons.account_balance_wallet),
            const SizedBox(height: 12),
            _buildField(_fleetSizeController, "Initial Fleet EV Count (Cars)", Icons.directions_car),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00E676),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("✅ Registration Submitted! KYC Approved by Supreme Admin."), backgroundColor: Color(0xFF00E676)),
                  );
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const BrokerDashboardScreen()));
                },
                child: const Text("Pay Deposit & Submit for Verification", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String label, IconData icon) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white60, fontSize: 13),
        prefixIcon: Icon(icon, color: const Color(0xFF00E676), size: 20),
        filled: true,
        fillColor: const Color(0xFF161F30),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }
}