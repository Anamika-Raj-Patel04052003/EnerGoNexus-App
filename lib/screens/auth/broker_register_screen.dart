import 'package:flutter/material.dart';
import 'broker_login_screen.dart';

class BrokerRegisterScreen extends StatefulWidget {
  const BrokerRegisterScreen({super.key});

  @override
  State<BrokerRegisterScreen> createState() => _BrokerRegisterScreenState();
}

class _BrokerRegisterScreenState extends State<BrokerRegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _companyCtrl = TextEditingController(text: "BluSmart Fleet Mobility Ltd.");
  final _signatoryCtrl = TextEditingController(text: "Anmol Singh");
  final _emailCtrl = TextEditingController(text: "corporate@blusmart.in");
  final _phoneCtrl = TextEditingController(text: "+91 98110 00192");
  final _gstCtrl = TextEditingController(text: "07AAACB2211D1Z1");
  final _panCtrl = TextEditingController(text: "AAACB2211D");
  final _bankAccCtrl = TextEditingController(text: "50200084920194");
  final _ifscCtrl = TextEditingController(text: "HDFC0000240");
  
  // UPI ID & Scanner / Google Form Link for Settlement
  final _upiCtrl = TextEditingController(text: "blusmart.corp@hdfcbank");
  final _googleFormCtrl = TextEditingController(text: "https://forms.gle/EnerGoFleetSettlementKYC");

  int _fleetSize = 50;
  bool _agreedToTerms = true;

  @override
  void dispose() {
    _companyCtrl.dispose();
    _signatoryCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _gstCtrl.dispose();
    _panCtrl.dispose();
    _bankAccCtrl.dispose();
    _ifscCtrl.dispose();
    _upiCtrl.dispose();
    _googleFormCtrl.dispose();
    super.dispose();
  }

  void _submitBrokerRegistration() {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF131B2E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Color(0xFF00E676)),
              SizedBox(width: 8),
              Text("Application Submitted", style: TextStyle(color: Colors.white, fontSize: 16)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Company: ${_companyCtrl.text.trim()}", style: const TextStyle(color: Colors.white70)),
              Text("Corporate UPI: ${_upiCtrl.text.trim()}", style: const TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.bold)),
              Text("Settlement Form: ${_googleFormCtrl.text.trim()}", style: const TextStyle(color: Colors.white54, fontSize: 11)),
              const SizedBox(height: 10),
              const Text(
                "Status: PENDING_SUPREME_ADMIN_APPROVAL\n\nYour application has been routed to Supreme Admin HQ. You can also update your UPI/Form settings at any time after login.",
                style: TextStyle(color: Colors.white60, fontSize: 12),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00E676),
                foregroundColor: Colors.black,
              ),
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (c) => const BrokerLoginScreen()),
                );
              },
              child: const Text("Go to Broker Login"),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111827),
        title: const Text("Broker Corporate Registration", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.domain_rounded, color: Color(0xFF00E676), size: 28),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Onboard your EV Fleet with EnerGo Nexus. Setup Corporate Vault, Settlement UPI & Driver Payroll.",
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              const Text("1. Corporate Details", style: TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              _buildTextField(_companyCtrl, "Company / Fleet Name", Icons.business_rounded),
              const SizedBox(height: 10),
              _buildTextField(_signatoryCtrl, "Authorized Signatory Name", Icons.person_outline_rounded),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _buildTextField(_emailCtrl, "Corporate Email", Icons.email_outlined)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildTextField(_phoneCtrl, "Official Phone", Icons.phone_outlined)),
                ],
              ),
              const SizedBox(height: 20),

              const Text("2. Tax & Compliance", style: TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _buildTextField(_gstCtrl, "GSTIN Number", Icons.receipt_long_rounded)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildTextField(_panCtrl, "Corporate PAN", Icons.badge_outlined)),
                ],
              ),
              const SizedBox(height: 20),

              const Text("3. Corporate Vault & Settlement UPI / Google Form", style: TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              _buildTextField(_upiCtrl, "Corporate Settlement UPI ID (for 100% Ride Inflow)", Icons.qr_code_2_rounded),
              const SizedBox(height: 10),
              _buildTextField(_googleFormCtrl, "Google Form KYC / Scanner Link", Icons.link_rounded),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _buildTextField(_bankAccCtrl, "Bank Account Number", Icons.account_balance_outlined)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildTextField(_ifscCtrl, "IFSC Code", Icons.code_rounded)),
                ],
              ),
              const SizedBox(height: 20),

              const Text("4. Fleet Capacity", style: TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text("Total Active EV Fleet Size: $_fleetSize EVs", style: const TextStyle(color: Colors.white70, fontSize: 13)),
              Slider(
                value: _fleetSize.toDouble(),
                min: 5,
                max: 500,
                divisions: 99,
                activeColor: const Color(0xFF00E676),
                onChanged: (v) => setState(() => _fleetSize = v.toInt()),
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00E676),
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: _submitBrokerRegistration,
                child: const Text("SUBMIT BROKER APPLICATION", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String label, IconData icon) {
    return TextFormField(
      controller: ctrl,
      style: const TextStyle(color: Colors.white, fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white60, fontSize: 12),
        prefixIcon: Icon(icon, color: const Color(0xFF00E676), size: 20),
        filled: true,
        fillColor: const Color(0xFF131B2E),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
      validator: (v) => (v == null || v.isEmpty) ? "Required" : null,
    );
  }
}
