import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/constants/app_colors.dart';
import 'driver_login_screen.dart';

class DriverRegisterScreen extends StatefulWidget {
  const DriverRegisterScreen({super.key});

  @override
  State<DriverRegisterScreen> createState() => _DriverRegisterScreenState();
}

class _DriverRegisterScreenState extends State<DriverRegisterScreen> {
  int _currentStep = 1;

  // Step 1: Personal
  final _nameCtrl = TextEditingController(text: "Vikramaditya Singh");
  final _phoneCtrl = TextEditingController(text: "9823456789");
  final _emailCtrl = TextEditingController(text: "vikram.ev@gmail.com");
  final _passCtrl = TextEditingController(text: "12345678");

  // Step 2: Vehicle
  String _vehicleCategory = "EV Cab (Passenger)";
  final _vehicleModelCtrl = TextEditingController(text: "Tata Nexon EV Max");
  final _plateCtrl = TextEditingController(text: "MP 04 EV 7741");
  final _batteryKwhCtrl = TextEditingController(text: "40.5 kWh");

  // Step 3: KYC
  final _licenseCtrl = TextEditingController(text: "DL-MP-2024-99882");
  final _aadhaarCtrl = TextEditingController(text: "4512 8890 2234");
  bool _isSubmitting = false;

  void _submitRegistration() async {
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 1400));
    setState(() => _isSubmitting = false);

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: AppColors.primaryGreen)),
        title: const Row(
          children: [
            Icon(LucideIcons.badgeCheck, color: AppColors.primaryGreen, size: 28),
            SizedBox(width: 10),
            Text("Application Submitted!"),
          ],
        ),
        content: const Text(
          "Your driver onboarding dossier has been routed to Sub-Admin Operations for KYC approval. You can login with your credentials once activated.",
          style: TextStyle(color: Colors.white70, fontSize: 13),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen, foregroundColor: Colors.black),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const DriverLoginScreen()),
              );
            },
            child: const Text("Go to Driver Login", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(LucideIcons.arrowLeft)),
        title: const Text("EV Driver Onboarding", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Step Progress Bar
            Row(
              children: [
                _buildStepPill(1, "Personal", _currentStep >= 1),
                const SizedBox(width: 6),
                _buildStepPill(2, "EV Vehicle", _currentStep >= 2),
                const SizedBox(width: 6),
                _buildStepPill(3, "KYC Docs", _currentStep >= 3),
              ],
            ),
            const SizedBox(height: 24),

            if (_currentStep == 1) ...[
              const Text("Step 1: Personal Contact Details", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 14),
              _buildInput("Full Legal Name", _nameCtrl, LucideIcons.user),
              _buildInput("Mobile Number", _phoneCtrl, LucideIcons.phone, isNumber: true),
              _buildInput("Email Address", _emailCtrl, LucideIcons.mail),
              _buildInput("Create Password", _passCtrl, LucideIcons.lock, isPass: true),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  onPressed: () => setState(() => _currentStep = 2),
                  child: const Text("Next: Vehicle Details ➡️", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ] else if (_currentStep == 2) ...[
              const Text("Step 2: EV Commercial Vehicle", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 14),
              _buildInput("EV Vehicle Model", _vehicleModelCtrl, LucideIcons.car),
              _buildInput("Number Plate (e.g. MP 04 EV 7741)", _plateCtrl, LucideIcons.hash),
              _buildInput("Battery Capacity (kWh)", _batteryKwhCtrl, LucideIcons.batteryCharging),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.white70, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      onPressed: () => setState(() => _currentStep = 1),
                      child: const Text("Back"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      onPressed: () => setState(() => _currentStep = 3),
                      child: const Text("Next: KYC Documents ➡️", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ] else ...[
              const Text("Step 3: Driver KYC & Compliance", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 14),
              _buildInput("Driving License Number", _licenseCtrl, LucideIcons.idCard),
              _buildInput("Aadhaar Identity Number", _aadhaarCtrl, LucideIcons.shieldCheck, isNumber: true),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12)),
                child: const Row(
                  children: [
                    Icon(LucideIcons.fileCheck2, color: Color(0xFF00F0FF), size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text("All commercial insurance & RC papers will be verified by Sub-Admin.", style: TextStyle(color: Colors.white60, fontSize: 11)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                  onPressed: _isSubmitting ? null : _submitRegistration,
                  icon: const Icon(LucideIcons.checkCheck, size: 18),
                  label: _isSubmitting
                      ? const CircularProgressIndicator(strokeWidth: 2, color: Colors.black)
                      : const Text("Submit Dossier to Sub-Admin", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStepPill(int step, String title, bool active) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.primaryGreen.withValues(alpha: 0.15) : AppColors.card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: active ? AppColors.primaryGreen : Colors.white10),
        ),
        child: Center(
          child: Text(
            "$step. $title",
            style: TextStyle(color: active ? AppColors.primaryGreen : Colors.white38, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController ctrl, IconData icon, {bool isNumber = false, bool isPass = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11.5, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          TextField(
            controller: ctrl,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            obscureText: isPass,
            style: const TextStyle(color: Colors.white, fontSize: 13.5),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: AppColors.primaryGreen, size: 18),
              filled: true,
              fillColor: AppColors.card,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
        ],
      ),
    );
  }
}