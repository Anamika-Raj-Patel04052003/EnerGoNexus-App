import 'dart:math';
import 'package:flutter/material.dart';

import '../../services/razorpay_service.dart';

class FacilityBookingScreen extends StatefulWidget {
  const FacilityBookingScreen({super.key});

  @override
  State<FacilityBookingScreen> createState() => _FacilityBookingScreenState();
}

class _FacilityBookingScreenState extends State<FacilityBookingScreen> {
  final List<Map<String, dynamic>> _nearbyLoungeHubs = [
    {
      'id': 'LOU-01',
      'name': 'MP Nagar SuperHub Snooze Lounge',
      'area': 'Zone 1 2nd Floor • 1.2 km away',
      'rate': 80.0,
      'freePods': 3,
      'pods': [
        {'id': 'Pod A1', 'name': 'Luxury AC Snooze', 'rate': 80.0, 'isOccupied': false},
        {'id': 'Pod A2', 'name': 'Luxury AC Snooze', 'rate': 80.0, 'isOccupied': true},
        {'id': 'Pod B1', 'name': 'Soundproof Rest', 'rate': 60.0, 'isOccupied': false},
        {'id': 'Pod B2', 'name': 'Soundproof Rest', 'rate': 60.0, 'isOccupied': false},
      ],
    },
    {
      'id': 'LOU-02',
      'name': 'ISBT Executive Driver Cabins',
      'area': 'ISBT Rest Floor • 3.5 km away',
      'rate': 50.0,
      'freePods': 4,
      'pods': [
        {'id': 'Cabin 1', 'name': 'Recliner Bed', 'rate': 50.0, 'isOccupied': false},
        {'id': 'Cabin 2', 'name': 'Recliner Bed', 'rate': 50.0, 'isOccupied': false},
        {'id': 'Cabin 3', 'name': 'AC Power Nap', 'rate': 60.0, 'isOccupied': false},
      ],
    },
  ];

  late Map<String, dynamic> _currentHub;
  late Map<String, dynamic> _selectedPod;
  int _hours = 2;
  String _paymentMethod = "razorpay";

  @override
  void initState() {
    super.initState();
    _currentHub = _nearbyLoungeHubs[0];
    _pickDefaultPod();
  }

  void _pickDefaultPod() {
    final List pods = _currentHub['pods'] as List;
    Map<String, dynamic> candidate = pods[0] as Map<String, dynamic>;
    for (final p in pods) {
      final map = p as Map<String, dynamic>;
      if (map['isOccupied'] == false) {
        candidate = map;
        break;
      }
    }
    _selectedPod = candidate;
  }

  double get _rate => ((_selectedPod['rate'] as num?)?.toDouble()) ?? 80.0;
  double get _totalCost => _rate * _hours;

  void _switchHub(Map<String, dynamic> hub) {
    setState(() {
      _currentHub = hub;
      _pickDefaultPod();
    });
  }

  void _bookPodSlot() async {
    if (_selectedPod['isOccupied'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pod is Occupied. Tap a GREEN Pod."), backgroundColor: Colors.redAccent),
      );
      return;
    }

    if (_paymentMethod == 'razorpay') {
      final res = await RazorpayPaymentService.openCheckout(
        context: context,
        amount: _totalCost,
        purpose: "Lounge: ${_currentHub['name']} - ${_selectedPod['id']}",
      );
      if (res != null && res['status'] == 'SUCCESS') {
        _onSuccess(res['payment_id'] ?? "pay_rzp_${Random().nextInt(89999) + 10000}");
      }
    } else {
      _onSuccess("pay_wallet_${Random().nextInt(89999) + 10000}");
    }
  }

  void _onSuccess(String txnId) {
    setState(() => _selectedPod['isOccupied'] = true);
    final passId = "POD-PASS-${Random().nextInt(8999) + 1000}";

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF131D31),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: const BorderSide(color: Color(0xFFA855F7), width: 1.5)),
        title: const Row(
          children: [
            Icon(Icons.qr_code_2, color: Color(0xFFA855F7), size: 28),
            SizedBox(width: 8),
            Text("Lounge Digital QR Pass", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Pass ID: $passId • Txn: $txnId", style: const TextStyle(color: Colors.white54, fontSize: 10.5)),
            const Divider(color: Colors.white12, height: 16),
            Text("Hub: ${_currentHub['name']}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
            Text("Reserved: ${_selectedPod['id']} (${_selectedPod['name']})", style: const TextStyle(color: Color(0xFFA855F7), fontWeight: FontWeight.bold, fontSize: 12.5)),
            const SizedBox(height: 4),
            Text("Duration: $_hours Hours • Total: ₹ ${_totalCost.toInt()}", style: const TextStyle(color: Color(0xFFA855F7), fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _selectedPod['isOccupied'] = false);
            },
            child: const Text("Release Pod", style: TextStyle(color: Colors.redAccent)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Done", style: TextStyle(color: Color(0xFFA855F7), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pods = _currentHub['pods'] as List;

    return Scaffold(
      backgroundColor: const Color(0xFF080E1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF10192B),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("24x7 Rest Lounges & Pods", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. NEARBY LOUNGE HUBS
              const Text("1. Select Nearby Rest Lounge", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5)),
              const SizedBox(height: 8),

              SizedBox(
                height: 86,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _nearbyLoungeHubs.length,
                  itemBuilder: (context, i) {
                    final hub = _nearbyLoungeHubs[i];
                    final isSel = _currentHub['id'] == hub['id'];

                    return GestureDetector(
                      onTap: () => _switchHub(hub),
                      child: Container(
                        width: 220,
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isSel ? const Color(0x33A855F7) : const Color(0xFF131D31),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: isSel ? const Color(0xFFA855F7) : Colors.white12, width: isSel ? 1.5 : 1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(hub['name'], maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: isSel ? const Color(0xFFA855F7) : Colors.white, fontWeight: FontWeight.bold, fontSize: 12.5)),
                            const SizedBox(height: 2),
                            Text(hub['area'], style: const TextStyle(color: Colors.white54, fontSize: 9.5)),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("₹${hub['rate'].toInt()}/hr", style: const TextStyle(color: Color(0xFFA855F7), fontSize: 11, fontWeight: FontWeight.bold)),
                                Text("🟢 ${hub['freePods']} Free", style: const TextStyle(color: Color(0xFF00E676), fontSize: 10, fontWeight: FontWeight.bold)),
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

              // 2. PODS IN CURRENT HUB
              Text("2. Select Pod in ${_currentHub['name']}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5)),
              const SizedBox(height: 8),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: pods.map((item) {
                  final p = item as Map<String, dynamic>;
                  final isOcc = p['isOccupied'] as bool;
                  final isSel = _selectedPod['id'] == p['id'];

                  return GestureDetector(
                    onTap: () {
                      if (isOcc) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("${p['id']} is Occupied"), backgroundColor: Colors.redAccent),
                        );
                      } else {
                        setState(() => _selectedPod = p);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isOcc
                            ? const Color(0x26FF5252)
                            : isSel
                                ? const Color(0x33A855F7)
                                : const Color(0xFF131D31),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isOcc ? Colors.redAccent : isSel ? const Color(0xFFA855F7) : Colors.white12,
                          width: isSel ? 1.8 : 1.0,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.bed, color: isOcc ? Colors.redAccent : const Color(0xFFA855F7), size: 16),
                          const SizedBox(width: 6),
                          Text("${p['id']} (₹${(p['rate'] as num).toInt()}/h)", style: TextStyle(color: isOcc ? Colors.redAccent : Colors.white, fontWeight: FontWeight.bold, fontSize: 11.5)),
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
                children: [1, 2, 4, 8].map((h) {
                  final isSel = _hours == h;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _hours = h),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isSel ? const Color(0xFFA855F7) : const Color(0xFF131D31),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text("$h Hr${h > 1 ? 's' : ''}", style: TextStyle(color: isSel ? Colors.white : Colors.white70, fontWeight: FontWeight.bold, fontSize: 11)),
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
                  border: Border.all(color: const Color(0xFFA855F7), width: 1.2),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Total (${_selectedPod['id']})", style: const TextStyle(color: Colors.white54, fontSize: 11)),
                        Text("₹ ${_totalCost.toInt()}", style: const TextStyle(color: Color(0xFFA855F7), fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    GestureDetector(
                      onTap: _bookPodSlot,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFA855F7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle, color: Colors.white, size: 18),
                            SizedBox(width: 4),
                            Text("Book Pod Pass", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
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