import 'package:flutter/material.dart';

class VehicleApprovalScreen extends StatefulWidget {
  const VehicleApprovalScreen({super.key});

  @override
  State<VehicleApprovalScreen> createState() => _VehicleApprovalScreenState();
}

class _VehicleApprovalScreenState extends State<VehicleApprovalScreen> {
  final List<Map<String, dynamic>> _pendingApprovals = [
    {
      'id': 'APP-9921',
      'driver': 'Vikram Mehta',
      'vehicle': 'Tata Tiago EV (Electric)',
      'plate': 'MP 04 EV 7712',
      'mobile': '+91 98260 11223',
      'docs': ['Commercial DL', 'RC Book', 'Aadhaar Card', 'EV Insurance'],
      'status': 'PENDING',
    },
    {
      'id': 'APP-9924',
      'driver': 'Harish Sharma',
      'vehicle': 'Mahindra XUV400 EV',
      'plate': 'MP 04 EV 3341',
      'mobile': '+91 98260 44556',
      'docs': ['Commercial DL', 'RC Book', 'Police Clearance'],
      'status': 'PENDING',
    },
  ];

  void _approveDriver(int index) {
    setState(() {
      _pendingApprovals[index]['status'] = 'APPROVED';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ Driver KYC & Vehicle RC Approved! Driver can now go ON-DUTY."), backgroundColor: Color(0xFF00E676)),
    );
  }

  void _rejectDriver(int index) {
    setState(() {
      _pendingApprovals.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("❌ Driver application rejected."), backgroundColor: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080E1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF10192B),
        elevation: 0,
        title: const Text("Fleet Vehicle & KYC Approval Queue", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0x2600F0FF), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFF00F0FF))),
              child: const Row(
                children: [
                  Icon(Icons.shield, color: Color(0xFF00F0FF), size: 24),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text("Review and approve EV commercial permits before granting driver on-duty access.", style: TextStyle(color: Colors.white, fontSize: 11.5)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            if (_pendingApprovals.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Text("🎉 All Driver KYC applications have been reviewed!", style: TextStyle(color: Colors.white54, fontSize: 13)),
                ),
              ),

            ..._pendingApprovals.asMap().entries.map((entry) {
              final idx = entry.key;
              final app = entry.value;
              final isApp = app['status'] == 'APPROVED';

              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF131D31),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isApp ? const Color(0xFF00E676) : Colors.white12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Application: ${app['id']}", style: const TextStyle(color: Colors.white54, fontSize: 11)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: (isApp ? const Color(0xFF00E676) : Colors.amber).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isApp ? "APPROVED 🟢" : "PENDING REVIEW 🟡",
                            style: TextStyle(color: isApp ? const Color(0xFF00E676) : Colors.amber, fontSize: 9.5, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(app['driver'] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    Text("🚗 ${app['vehicle']} • Plate: ${app['plate']}", style: const TextStyle(color: Color(0xFF00F0FF), fontSize: 11.5)),
                    Text("📱 Phone: ${app['mobile']}", style: const TextStyle(color: Colors.white70, fontSize: 11)),
                    const Divider(color: Colors.white12, height: 16),
                    const Text("Uploaded Legal Dossier:", style: TextStyle(color: Colors.white54, fontSize: 10.5)),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: (app['docs'] as List<String>).map((d) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: const Color(0xFF080E1A), borderRadius: BorderRadius.circular(6)),
                        child: Text("📄 $d", style: const TextStyle(color: Colors.white70, fontSize: 10)),
                      )).toList(),
                    ),
                    const SizedBox(height: 14),

                    if (!isApp)
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _rejectDriver(idx),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(color: const Color(0xFF080E1A), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.redAccent)),
                                child: const Center(
                                  child: Text("Reject", style: TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 2,
                            child: GestureDetector(
                              onTap: () => _approveDriver(idx),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(color: const Color(0xFF00E676), borderRadius: BorderRadius.circular(8)),
                                child: const Center(
                                  child: Text("Approve & Grant Permit", style: TextStyle(color: Colors.black, fontSize: 12.5, fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}