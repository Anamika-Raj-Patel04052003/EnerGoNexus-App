import 'package:flutter/material.dart';

class ManageAdminsScreen extends StatefulWidget {
  const ManageAdminsScreen({super.key});

  @override
  State<ManageAdminsScreen> createState() => _ManageAdminsScreenState();
}

class _ManageAdminsScreenState extends State<ManageAdminsScreen> {
  final List<Map<String, dynamic>> _staffList = [
    {
      'id': 'ADM-101',
      'name': 'Manoj Tiwari',
      'email': 'manoj.mpnagar@energo.com',
      'station': 'EnerGo Central SuperHub (MP Nagar)',
      'phone': '+91 98260 88210',
      'status': 'ACTIVE 🟢',
    },
    {
      'id': 'ADM-102',
      'name': 'Priyanka Sen',
      'email': 'priyanka.isbt@energo.com',
      'station': 'Bhopal Express Hub (ISBT)',
      'phone': '+91 98260 77410',
      'status': 'ACTIVE 🟢',
    },
    {
      'id': 'ADM-103',
      'name': 'Rajeev Verma',
      'email': 'rajeev.airport@energo.com',
      'station': 'Airport Rapid Solar Hub (VIP Road)',
      'phone': '+91 98260 99310',
      'status': 'ACTIVE 🟢',
    },
  ];

  void _addNewStaffModal() {
    final nameCtrl = TextEditingController();
    final stationCtrl = TextEditingController(text: "Arera Green Hub");
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF131D31),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.person_add, color: Color(0xFFA855F7)),
            SizedBox(width: 8),
            Text("Assign New Sub-Admin", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, style: const TextStyle(color: Colors.white, fontSize: 12), decoration: const InputDecoration(labelText: "Staff Full Name", labelStyle: TextStyle(color: Colors.white54))),
            TextField(controller: stationCtrl, style: const TextStyle(color: Colors.white, fontSize: 12), decoration: const InputDecoration(labelText: "Assigned SuperHub", labelStyle: TextStyle(color: Colors.white54))),
            TextField(controller: emailCtrl, style: const TextStyle(color: Colors.white, fontSize: 12), decoration: const InputDecoration(labelText: "Official Email", labelStyle: TextStyle(color: Colors.white54))),
            TextField(controller: phoneCtrl, style: const TextStyle(color: Colors.white, fontSize: 12), decoration: const InputDecoration(labelText: "Mobile Number", labelStyle: TextStyle(color: Colors.white54))),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel", style: TextStyle(color: Colors.white54))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFA855F7), foregroundColor: Colors.white),
            onPressed: () {
              if (nameCtrl.text.isNotEmpty) {
                setState(() {
                  _staffList.add({
                    'id': 'ADM-${_staffList.length + 101}',
                    'name': nameCtrl.text.trim(),
                    'email': emailCtrl.text.trim(),
                    'station': stationCtrl.text.trim(),
                    'phone': phoneCtrl.text.trim(),
                    'status': 'ACTIVE 🟢',
                  });
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("✅ Sub-Admin Assigned to SuperHub!"), backgroundColor: Color(0xFF00E676)),
                );
              }
            },
            child: const Text("Save Staff"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080E1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF10192B),
        elevation: 0,
        title: const Text("SuperHub Sub-Admin Staff Directory", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFA855F7),
        foregroundColor: Colors.white,
        onPressed: _addNewStaffModal,
        icon: const Icon(Icons.add),
        label: const Text("Assign Sub-Admin", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ..._staffList.map((s) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF131D31),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 20,
                    backgroundColor: Color(0x33A855F7),
                    child: Icon(Icons.admin_panel_settings, color: Color(0xFFA855F7), size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(s['name'] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5)),
                            Text(s['status'] as String, style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Text("🏢 ${s['station']}", style: const TextStyle(color: Color(0xFF00F0FF), fontSize: 11)),
                        Text("📧 ${s['email']} • 📱 ${s['phone']}", style: const TextStyle(color: Colors.white54, fontSize: 10)),
                      ],
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}