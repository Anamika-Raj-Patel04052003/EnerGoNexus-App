import 'package:flutter/material.dart';

class DriverDocumentsScreen extends StatelessWidget {
  const DriverDocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> docs = [
      {
        'title': 'Commercial EV Driving License (DL)',
        'sub': 'DL-MP04-2018-009481 • Valid till 2032',
        'auth': 'RTO Bhopal, Madhya Pradesh',
        'status': 'VERIFIED 🟢',
        'icon': Icons.badge,
      },
      {
        'title': 'Aadhaar Government Identity Proof',
        'sub': 'UIDAI: **** **** 7842 (Biometric Linked)',
        'auth': 'Unique Identification Authority of India',
        'status': 'VERIFIED 🟢',
        'icon': Icons.fingerprint,
      },
      {
        'title': 'Vehicle Registration Certificate (RC)',
        'sub': 'MP 04 EV 8891 (Tata Nexon EV Max)',
        'auth': 'Transport Dept MP • Commercial EV Permit',
        'status': 'VERIFIED 🟢',
        'icon': Icons.description,
      },
      {
        'title': 'Commercial EV Insurance Policy',
        'sub': 'Digit Zero-Dep EV Comprehensive • Exp: Nov 2027',
        'auth': 'Go Digit General Insurance Ltd',
        'status': 'ACTIVE 🟢',
        'icon': Icons.health_and_safety,
      },
      {
        'title': 'Police Verification Clearance',
        'sub': 'Ref: POL-BPL-88921 • Zero Criminal Record',
        'auth': 'Bhopal Police Commissionerate',
        'status': 'CLEARED 🟢',
        'icon': Icons.security,
      },
      {
        'title': 'EV Fast Charger & Fitness Certificate',
        'sub': 'ARAI Certified CCS-2 50kW Compatible',
        'auth': 'Automotive Research Association of India',
        'status': 'PASSED 🟢',
        'icon': Icons.bolt,
      },
    ];

    void showDocDetails(Map<String, dynamic> doc) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF131D31),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: const BorderSide(color: Color(0xFF00E676), width: 1.5)),
          title: Row(
            children: [
              Icon(doc['icon'] as IconData, color: const Color(0xFF00E676)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(doc['title'] as String, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(doc['sub'] as String, style: const TextStyle(color: Color(0xFF00F0FF), fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text("Issuing Authority: ${doc['auth']}", style: const TextStyle(color: Colors.white70, fontSize: 11)),
              const Divider(color: Colors.white12, height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Verification Status:", style: TextStyle(color: Colors.white54, fontSize: 11)),
                  Text(doc['status'] as String, style: const TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.bold, fontSize: 11)),
                ],
              ),
              const SizedBox(height: 4),
              const Text("Synced with EnerGo Sub-Admin Fleet Governance Desk.", style: TextStyle(color: Colors.white38, fontSize: 9.5)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Close", style: TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF080E1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF10192B),
        elevation: 0,
        title: const Text("Driver KYC & Compliance Dossier", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 1. SUB-ADMIN VERIFIED BADGE
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0x2600E676),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF00E676), width: 1.2),
              ),
              child: const Row(
                children: [
                  Icon(Icons.verified, color: Color(0xFF00E676), size: 28),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("KYC Dossier: 100% Verified & Active", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                        Text("Approved by EnerGo Sub-Admin • Ref: KYC-MP04-9921", style: TextStyle(color: Colors.white70, fontSize: 10.5)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            const Text("Verified Legal Documents (Tap to View)", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 10),

            ...docs.map((d) => GestureDetector(
              onTap: () => showDocDetails(d),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF131D31),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(color: Color(0x2600E676), shape: BoxShape.circle),
                      child: Icon(d['icon'] as IconData, color: const Color(0xFF00E676), size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(d['title'] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12.5)),
                          const SizedBox(height: 2),
                          Text(d['sub'] as String, style: const TextStyle(color: Colors.white54, fontSize: 10)),
                        ],
                      ),
                    ),
                    Text(d['status'] as String, style: const TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.bold, fontSize: 10)),
                  ],
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}