import 'dart:math';
import 'package:flutter/material.dart';

import '../../services/razorpay_service.dart';

class CafeTableScreen extends StatefulWidget {
  const CafeTableScreen({super.key});

  @override
  State<CafeTableScreen> createState() => _CafeTableScreenState();
}

class _CafeTableScreenState extends State<CafeTableScreen> {
  final List<Map<String, dynamic>> _nearbyCafes = [
    {
      'id': 'CAF-01',
      'name': 'MP Nagar SuperHub Cafe & Work',
      'area': 'Zone 1 Lobby Level • 1.2 km away',
      'rate': 40.0,
      'freeTables': 3,
      'tables': [
        {'id': 'Table 1', 'name': 'Workstation Desk', 'rate': 40.0, 'isOccupied': false},
        {'id': 'Table 2', 'name': 'Workstation Desk', 'rate': 40.0, 'isOccupied': true},
        {'id': 'Table 3', 'name': 'Dining 4-Seater', 'rate': 50.0, 'isOccupied': false},
        {'id': 'Table 4', 'name': 'Dining 4-Seater', 'rate': 50.0, 'isOccupied': false},
      ],
    },
    {
      'id': 'CAF-02',
      'name': 'ISBT 5G Co-Working Pods',
      'area': 'ISBT 1st Floor • 3.5 km away',
      'rate': 35.0,
      'freeTables': 4,
      'tables': [
        {'id': 'Desk 1', 'name': 'Solo WiFi Desk', 'rate': 35.0, 'isOccupied': false},
        {'id': 'Desk 2', 'name': 'Solo WiFi Desk', 'rate': 35.0, 'isOccupied': false},
      ],
    },
  ];

  late Map<String, dynamic> _currentCafe;
  late Map<String, dynamic> _selectedTable;
  int _hours = 1;
  String _paymentMethod = "razorpay";

  @override
  void initState() {
    super.initState();
    _currentCafe = _nearbyCafes[0];
    _pickDefaultTable();
  }

  void _pickDefaultTable() {
    final List tables = _currentCafe['tables'] as List;
    Map<String, dynamic> candidate = tables[0] as Map<String, dynamic>;
    for (final t in tables) {
      final map = t as Map<String, dynamic>;
      if (map['isOccupied'] == false) {
        candidate = map;
        break;
      }
    }
    _selectedTable = candidate;
  }

  double get _rate => ((_selectedTable['rate'] as num?)?.toDouble()) ?? 40.0;
  double get _totalCost => _rate * _hours;

  void _switchCafe(Map<String, dynamic> cafe) {
    setState(() {
      _currentCafe = cafe;
      _pickDefaultTable();
    });
  }

  void _bookTableSlot() async {
    if (_selectedTable['isOccupied'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Table is Occupied. Tap a GREEN Table."), backgroundColor: Colors.redAccent),
      );
      return;
    }

    if (_paymentMethod == 'razorpay') {
      final res = await RazorpayPaymentService.openCheckout(
        context: context,
        amount: _totalCost,
        purpose: "Cafe: ${_currentCafe['name']} - ${_selectedTable['id']}",
      );
      if (res != null && res['status'] == 'SUCCESS') {
        _onSuccess(res['payment_id'] ?? "pay_rzp_${Random().nextInt(89999) + 10000}");
      }
    } else {
      _onSuccess("pay_wallet_${Random().nextInt(89999) + 10000}");
    }
  }

  void _onSuccess(String txnId) {
    setState(() => _selectedTable['isOccupied'] = true);
    final passId = "CAFE-PASS-${Random().nextInt(8999) + 1000}";

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF131D31),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: const BorderSide(color: Color(0xFFFFB703), width: 1.5)),
        title: const Row(
          children: [
            Icon(Icons.local_cafe, color: Color(0xFFFFB703), size: 28),
            SizedBox(width: 8),
            Text("Cafe Digital Pass", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Pass ID: $passId • Txn: $txnId", style: const TextStyle(color: Colors.white54, fontSize: 10.5)),
            const Divider(color: Colors.white12, height: 16),
            Text("Cafe: ${_currentCafe['name']}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
            Text("Reserved: ${_selectedTable['id']} (${_selectedTable['name']})", style: const TextStyle(color: Color(0xFFFFB703), fontWeight: FontWeight.bold, fontSize: 12.5)),
            const SizedBox(height: 4),
            const Text("WiFi: EnerGo_HighSpeed_5G (Pass: evcoffee123)", style: TextStyle(color: Color(0xFF00F0FF), fontSize: 11.5)),
            const SizedBox(height: 4),
            Text("Total Paid: ₹ ${_totalCost.toInt()}", style: const TextStyle(color: Color(0xFFFFB703), fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _selectedTable['isOccupied'] = false);
            },
            child: const Text("Release Table", style: TextStyle(color: Colors.redAccent)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Done", style: TextStyle(color: Color(0xFFFFB703), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tables = _currentCafe['tables'] as List;

    return Scaffold(
      backgroundColor: const Color(0xFF080E1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF10192B),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Cafe & Workstation Tables", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. NEARBY CAFE HUBS
              const Text("1. Select Nearby Cafe & Work Hub", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5)),
              const SizedBox(height: 8),

              SizedBox(
                height: 86,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _nearbyCafes.length,
                  itemBuilder: (context, i) {
                    final cafe = _nearbyCafes[i];
                    final isSel = _currentCafe['id'] == cafe['id'];

                    return GestureDetector(
                      onTap: () => _switchCafe(cafe),
                      child: Container(
                        width: 220,
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isSel ? const Color(0x33FFB703) : const Color(0xFF131D31),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: isSel ? const Color(0xFFFFB703) : Colors.white12, width: isSel ? 1.5 : 1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(cafe['name'], maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: isSel ? const Color(0xFFFFB703) : Colors.white, fontWeight: FontWeight.bold, fontSize: 12.5)),
                            const SizedBox(height: 2),
                            Text(cafe['area'], style: const TextStyle(color: Colors.white54, fontSize: 9.5)),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("₹${cafe['rate'].toInt()}/hr", style: const TextStyle(color: Color(0xFFFFB703), fontSize: 11, fontWeight: FontWeight.bold)),
                                Text("🟢 ${cafe['freeTables']} Free", style: const TextStyle(color: Color(0xFF00E676), fontSize: 10, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // 2. TABLES IN SELECTED CAFE
              Text("2. Select Table in ${_currentCafe['name']}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5)),
              const SizedBox(height: 8),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: tables.map((item) {
                  final t = item as Map<String, dynamic>;
                  final isOcc = t['isOccupied'] as bool;
                  final isSel = _selectedTable['id'] == t['id'];

                  return GestureDetector(
                    onTap: () {
                      if (isOcc) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("${t['id']} is Occupied"), backgroundColor: Colors.redAccent),
                        );
                      } else {
                        setState(() => _selectedTable = t);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isOcc
                            ? const Color(0x26FF5252)
                            : isSel
                                ? const Color(0x33FFB703)
                                : const Color(0xFF131D31),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isOcc ? Colors.redAccent : isSel ? const Color(0xFFFFB703) : Colors.white12,
                          width: isSel ? 1.8 : 1.0,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.local_cafe, color: isOcc ? Colors.redAccent : const Color(0xFFFFB703), size: 16),
                          const SizedBox(width: 6),
                          Text("${t['id']} (₹${(t['rate'] as num).toInt()}/h)", style: TextStyle(color: isOcc ? Colors.redAccent : Colors.white, fontWeight: FontWeight.bold, fontSize: 11.5)),
                          const SizedBox(width: 6),
                          Text(isOcc ? "🔴" : "🟢", style: const TextStyle(fontSize: 10)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // 3. DURATION
              const Text("3. Select Duration", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5)),
              const SizedBox(height: 6),
              Row(
                children: [1, 2, 4].map((h) {
                  final isSel = _hours == h;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _hours = h),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isSel ? const Color(0xFFFFB703) : const Color(0xFF131D31),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text("$h Hr${h > 1 ? 's' : ''}", style: TextStyle(color: isSel ? Colors.black : Colors.white70, fontWeight: FontWeight.bold, fontSize: 11)),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // 4. ACTION BAR
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF131D31),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFFFB703), width: 1.2),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Total (${_selectedTable['id']})", style: const TextStyle(color: Colors.white54, fontSize: 11)),
                        Text("₹ ${_totalCost.toInt()}", style: const TextStyle(color: Color(0xFFFFB703), fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    GestureDetector(
                      onTap: _bookTableSlot,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFB703),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle, color: Colors.black, size: 18),
                            SizedBox(width: 4),
                            Text("Book Table Pass", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}