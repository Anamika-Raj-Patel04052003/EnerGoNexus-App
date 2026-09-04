import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

import '../../services/energo_unified_service.dart';
import '../../services/razorpay_service.dart';

class ChargingBookingScreen extends StatefulWidget {
  final Map<String, dynamic>? station;
  const ChargingBookingScreen({super.key, this.station});

  @override
  State<ChargingBookingScreen> createState() => _ChargingBookingScreenState();
}

class _ChargingBookingScreenState extends State<ChargingBookingScreen> {
  final List<String> _vehicles = [
    "Tata Nexon EV (40 kWh)",
    "MG ZS EV (50 kWh)",
    "Mahindra XUV400 (39 kWh)",
    "Tata Tiago EV (24 kWh)",
    "Ather 450X (3.7 kWh)",
    "Ola S1 Pro (4 kWh)",
  ];

  late Map<String, dynamic> _currentStation;
  late Map<String, dynamic> _selectedPort;
  String _selectedVehicle = "Tata Nexon EV (40 kWh)";
  double _chargePercentage = 60.0;
  String _paymentMethod = "razorpay";

  // ACTIVE CHARGING SESSION
  bool _isSessionActive = false;
  String? _activePortId;
  int _remainingSeconds = 0;
  Timer? _sessionTimer;

  @override
  void initState() {
    super.initState();
    final service = EnergoUnifiedService();
    _currentStation = service.stations[0];
    _pickDefaultPort();
  }

  void _pickDefaultPort() {
    final List ports = _currentStation['ports'] as List;
    Map<String, dynamic> candidate = ports[0] as Map<String, dynamic>;
    for (final p in ports) {
      final map = p as Map<String, dynamic>;
      if (map['isOccupied'] == false) {
        candidate = map;
        break;
      }
    }
    _selectedPort = candidate;
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    super.dispose();
  }

  // SCIENTIFIC ENERGY & CHARGING TIME FORMULA
  double get _batteryCapacityKwh {
    if (_selectedVehicle.contains("50 kWh")) return 50.0;
    if (_selectedVehicle.contains("39 kWh")) return 39.4;
    if (_selectedVehicle.contains("24 kWh")) return 24.0;
    if (_selectedVehicle.contains("3.7 kWh")) return 3.7;
    if (_selectedVehicle.contains("4 kWh")) return 4.0;
    return 40.5; // Nexon EV Max default
  }

  double get _estimatedKwh => (_chargePercentage / 100) * _batteryCapacityKwh;
  double get _tariffRate => ((_currentStation['rate'] as num?)?.toDouble()) ?? 18.50;
  double get _baseCost => _estimatedKwh * _tariffRate;
  double get _gstAmount => _baseCost * 0.18;
  double get _totalPayable => _baseCost + _gstAmount;

  // AUTO-CALCULATED DURATION IN MINUTES (kWh / kW * 60)
  int get _calculatedDurationMinutes {
    final int portKw = (_selectedPort['kw'] as int?) ?? 120;
    final double hoursNeeded = _estimatedKwh / portKw;
    final int mins = (hoursNeeded * 60).ceil();
    return mins < 5 ? 5 : mins; // Minimum 5 mins
  }

  void _switchStation(Map<String, dynamic> stn) {
    setState(() {
      _currentStation = stn;
      _pickDefaultPort();
    });
  }

  void _bookChargingSlot() async {
    if (_selectedPort['isOccupied'] == true && _selectedPort['id'] != _activePortId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Port is Occupied. Please tap a GREEN Free Port."), backgroundColor: Colors.redAccent),
      );
      return;
    }

    if (_paymentMethod == 'razorpay') {
      final res = await RazorpayPaymentService.openCheckout(
        context: context,
        amount: _totalPayable,
        purpose: "EV Charge: ${_currentStation['name']} - ${_selectedPort['id']}",
      );
      if (res != null && res['status'] == 'SUCCESS') {
        _startChargingSession(res['payment_id'] ?? "pay_rzp_${Random().nextInt(89999) + 10000}");
      }
    } else {
      EnergoUnifiedService().payWithWallet(_totalPayable, "EV Fast Charge (${_selectedPort['id']})");
      _startChargingSession("pay_wallet_${Random().nextInt(89999) + 10000}");
    }
  }

  void _startChargingSession(String txnId) {
    final duration = _calculatedDurationMinutes;

    // LOCK IN CENTRAL UNIFIED SERVICE
    EnergoUnifiedService().bookAmenity(
      stationId: _currentStation['id'] as String,
      category: 'ports',
      itemId: _selectedPort['id'] as String,
      durationMinutes: duration,
      bookedBy: 'Anamika C. (${_selectedVehicle.split(" ").first})',
    );

    setState(() {
      _selectedPort['isOccupied'] = true;
      _isSessionActive = true;
      _activePortId = _selectedPort['id'];
      _remainingSeconds = duration * 60;
    });

    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        _endChargingSession();
      }
    });

    final invId = "GST-EV-${Random().nextInt(89999) + 10000}";

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF131D31),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Color(0xFF00E676), width: 1.5)),
        title: const Row(
          children: [
            Icon(Icons.bolt, color: Color(0xFF00E676), size: 28),
            SizedBox(width: 8),
            Text("Fast Charging Active!", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Tax Slip: $invId • Txn: $txnId", style: const TextStyle(color: Colors.white54, fontSize: 10.5)),
            const Divider(color: Colors.white12, height: 16),
            Text("Station: ${_currentStation['name']}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
            Text("Port: ${_selectedPort['id']} (${_selectedPort['power']})", style: const TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.bold, fontSize: 12.5)),
            const SizedBox(height: 4),
            Text("Target Energy: ${_estimatedKwh.toStringAsFixed(1)} kWh (~${_chargePercentage.toInt()}%)", style: const TextStyle(color: Color(0xFF00F0FF), fontSize: 12, fontWeight: FontWeight.bold)),
            Text("⏱️ Auto Calculated Session: $duration Mins", style: const TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text("Total Paid: ₹ ${_totalPayable.toStringAsFixed(2)} (GST 18% Incl.)", style: const TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00E676), foregroundColor: Colors.black),
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Plug-In & Monitor", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _endChargingSession() {
    _sessionTimer?.cancel();
    setState(() {
      _isSessionActive = false;
      _selectedPort['isOccupied'] = false;
      _activePortId = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("🟢 Charging Session Completed! Port is now Released & FREE."), backgroundColor: Color(0xFF00E676)),
    );
  }

  String _formatTimer(int totalSecs) {
    final mins = (totalSecs ~/ 60).toString().padLeft(2, '0');
    final secs = (totalSecs % 60).toString().padLeft(2, '0');
    return "$mins:$secs";
  }

  @override
  Widget build(BuildContext context) {
    final service = EnergoUnifiedService();

    return AnimatedBuilder(
      animation: service,
      builder: (context, child) {
        final stationsList = service.stations;
        final ports = _currentStation['ports'] as List;

        return Scaffold(
          backgroundColor: const Color(0xFF080E1A),
          appBar: AppBar(
            backgroundColor: const Color(0xFF10192B),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text("Smart AI Fast DC EV Charging", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ACTIVE LIVE COUNTDOWN BANNER
                  if (_isSessionActive) ...[
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0x2600E676),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF00E676), width: 1.5),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(color: Color(0xFF00E676), shape: BoxShape.circle),
                            child: const Icon(Icons.bolt, color: Colors.black, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("⚡ Fast Dispensing: $_activePortId (🔴 IN-USE)", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                                Text("Time Remaining: ${_formatTimer(_remainingSeconds)}", style: const TextStyle(color: Color(0xFF00E676), fontSize: 14, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: _endChargingSession,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(8)),
                              child: const Text("Release", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // 1. NEARBY SUPERHUBS
                  const Text("1. Select EV SuperHub", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5)),
                  const SizedBox(height: 8),

                  SizedBox(
                    height: 86,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: stationsList.length,
                      itemBuilder: (context, i) {
                        final stn = stationsList[i];
                        final isSel = _currentStation['id'] == stn['id'];

                        return GestureDetector(
                          onTap: () => _switchStation(stn),
                          child: Container(
                            width: 220,
                            margin: const EdgeInsets.only(right: 10),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isSel ? const Color(0x3300E676) : const Color(0xFF131D31),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: isSel ? const Color(0xFF00E676) : Colors.white12, width: isSel ? 1.5 : 1),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(stn['name'], maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: isSel ? const Color(0xFF00E676) : Colors.white, fontWeight: FontWeight.bold, fontSize: 12.5)),
                                const SizedBox(height: 2),
                                Text(stn['area'], style: const TextStyle(color: Colors.white54, fontSize: 9.5)),
                                const SizedBox(height: 4),
                                Text("₹${stn['rate']}/kWh • Fast DC Active", style: const TextStyle(color: Color(0xFF00F0FF), fontSize: 11, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 2. PORTS IN CURRENT STATION
                  Text("2. Select Port in ${_currentStation['name']}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5)),
                  const SizedBox(height: 8),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ports.map((item) {
                      final p = item as Map<String, dynamic>;
                      final isOcc = p['isOccupied'] as bool;
                      final isSel = _selectedPort['id'] == p['id'];

                      return GestureDetector(
                        onTap: () {
                          if (isOcc && p['id'] != _activePortId) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("${p['id']} is Occupied (In-Use)"), backgroundColor: Colors.redAccent),
                            );
                          } else {
                            setState(() => _selectedPort = p);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isOcc
                                ? const Color(0x26FF5252)
                                : isSel
                                    ? const Color(0x3300E676)
                                    : const Color(0xFF131D31),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isOcc ? Colors.redAccent : isSel ? const Color(0xFF00E676) : Colors.white12,
                              width: isSel ? 1.8 : 1.0,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.bolt, color: isOcc ? Colors.redAccent : const Color(0xFF00E676), size: 16),
                              const SizedBox(width: 6),
                              Text("${p['id']} (${p['power']})", style: TextStyle(color: isOcc ? Colors.redAccent : Colors.white, fontWeight: FontWeight.bold, fontSize: 11.5)),
                              const SizedBox(width: 6),
                              Text(isOcc ? "🔴" : "🟢", style: const TextStyle(fontSize: 10)),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // 3. EV VEHICLE
                  const Text("3. Select EV Vehicle", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5)),
                  const SizedBox(height: 6),

                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _vehicles.map((v) {
                      final isSel = _selectedVehicle == v;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedVehicle = v),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSel ? const Color(0xFF00E676) : const Color(0xFF131D31),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: isSel ? const Color(0xFF00E676) : Colors.white12),
                          ),
                          child: Text(
                            v,
                            style: TextStyle(color: isSel ? Colors.black : Colors.white70, fontSize: 11, fontWeight: isSel ? FontWeight.bold : FontWeight.normal),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // 4. ENERGY TARGET SLIDER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("4. Energy Target Target (kWh / %)", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5)),
                      Text("${_estimatedKwh.toStringAsFixed(1)} kWh (~${_chargePercentage.toInt()}%)", style: const TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                  Slider(
                    value: _chargePercentage,
                    min: 20,
                    max: 100,
                    divisions: 8,
                    activeColor: const Color(0xFF00E676),
                    inactiveColor: Colors.white12,
                    onChanged: (v) => setState(() => _chargePercentage = v),
                  ),
                  const SizedBox(height: 6),

                  // 5. AUTO-CALCULATED DURATION BANNER (AI SMART CALCULATION)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0x2600F0FF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF00F0FF)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.timer, color: Color(0xFF00F0FF), size: 20),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Auto-Calculated Fast Charge Time:", style: TextStyle(color: Colors.white70, fontSize: 11)),
                                Text("Based on ${_selectedPort['power']} Output", style: const TextStyle(color: Colors.white38, fontSize: 9.5)),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: const Color(0xFF00F0FF), borderRadius: BorderRadius.circular(8)),
                          child: Text("⏱️ $_calculatedDurationMinutes Mins", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 6. PAYMENT METHOD
                  const Text("5. Payment Gateway", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      {'id': 'razorpay', 'name': 'Razorpay UPI/Card', 'color': const Color(0xFF528FF0)},
                      {'id': 'wallet', 'name': 'Wallet (5% Back)', 'color': const Color(0xFF00E676)},
                      {'id': 'cash', 'name': 'Cash on Spot', 'color': Colors.amber},
                    ].map((m) {
                      final isSel = _paymentMethod == (m['id'] as String);
                      final col = m['color'] as Color;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _paymentMethod = m['id'] as String),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: isSel ? col.withOpacity(0.2) : const Color(0xFF131D31),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: isSel ? col : Colors.white12),
                            ),
                            child: Center(
                              child: Text(
                                (m['name'] as String).split(" ").first,
                                style: TextStyle(color: isSel ? col : Colors.white70, fontSize: 11, fontWeight: isSel ? FontWeight.bold : FontWeight.normal),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 22),

                  // 7. FIXED BOTTOM ACTION BAR
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF131D31),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF00E676), width: 1.2),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Total (${_selectedPort['id']} • $_calculatedDurationMinutes Mins)", style: const TextStyle(color: Colors.white54, fontSize: 10.5)),
                            Text("₹ ${_totalPayable.toStringAsFixed(2)}", style: const TextStyle(color: Color(0xFF00E676), fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        GestureDetector(
                          onTap: _bookChargingSlot,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00E676),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.bolt, color: Colors.black, size: 18),
                                const SizedBox(width: 4),
                                Text(_isSessionActive ? "Extend Slot" : "Pay & Plug-In", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13)),
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
      },
    );
  }
}