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
  int _selectedHours = 1;
  TimeOfDay _startTime = TimeOfDay.now();
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

  // PRICING CALCULATION (Tariff per hour based on Port kW)
  double get _baseStationFee => 20.0;
  double get _hourlyRate {
    final int portKw = (_selectedPort['kw'] as int?) ?? 120;
    if (portKw >= 120) return 180.0; // Fast DC
    if (portKw >= 60) return 120.0;  // Rapid DC
    return 60.0; // AC Standard
  }
  double get _durationCost => _selectedHours * _hourlyRate;
  double get _totalPayable => _baseStationFee + _durationCost;

  // CALCULATE END TIME
  TimeOfDay get _endTime {
    final int totalMinutes = _startTime.hour * 60 + _startTime.minute + (_selectedHours * 60);
    final int endHour = (totalMinutes ~/ 60) % 24;
    final int endMin = totalMinutes % 60;
    return TimeOfDay(hour: endHour, minute: endMin);
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final int hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final String period = time.period == DayPeriod.am ? 'AM' : 'PM';
    final String min = time.minute.toString().padLeft(2, '0');
    return "$hour:$min $period";
  }

  Future<void> _pickStartTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF00E676),
              onPrimary: Colors.black,
              surface: Color(0xFF131D31),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _startTime = picked);
    }
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
        const SnackBar(content: Text("This Port is currently BOOKED (🔴). Please select a GREEN (🟢) Free Port."), backgroundColor: Colors.redAccent),
      );
      return;
    }

    final service = EnergoUnifiedService();

    if (_paymentMethod == 'wallet') {
      if (!service.canPayWithWallet(_totalPayable)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Insufficient Cashback (₹${service.walletBalance.toStringAsFixed(2)}). Pay via Razorpay to earn 5% Cashback!"),
            backgroundColor: Colors.amber,
          ),
        );
        return;
      }
      service.payWithWallet(_totalPayable, "EV Charging (${_selectedPort['id']})");
      _startChargingSession("pay_wallet_${Random().nextInt(89999) + 10000}", earnedCashback: 0.0);
    } else {
      // RAZORPAY PAYMENT (5% CASHBACK)
      final res = await RazorpayPaymentService.openCheckout(
        context: context,
        amount: _totalPayable,
        purpose: "EV Charge: ${_currentStation['name']} - ${_selectedPort['id']} [${_formatTimeOfDay(_startTime)} - ${_formatTimeOfDay(_endTime)}]",
      );

      if (res != null && res['status'] == 'SUCCESS') {
        final payId = res['payment_id'] ?? "pay_rzp_${Random().nextInt(89999) + 10000}";

        // 🌟 5% CASHBACK AUTO-CREDIT
        service.recordRazorpayPaymentAndCreditCashback(
          amountPaid: _totalPayable,
          purpose: "EV Charging (${_selectedPort['id']})",
          paymentId: payId,
        );

        _startChargingSession(payId, earnedCashback: _totalPayable * 0.05);
      }
    }
  }

  void _startChargingSession(String txnId, {required double earnedCashback}) {
    final durationMins = _selectedHours * 60;

    // LOCK PORT TO 🔴 RED FOR EXACT TIME DURATION
    EnergoUnifiedService().bookAmenity(
      stationId: _currentStation['id'] as String,
      category: 'ports',
      itemId: _selectedPort['id'] as String,
      durationMinutes: durationMins,
      bookedBy: 'Anamika C. (${_selectedVehicle.split(" ").first})',
    );

    setState(() {
      _selectedPort['isOccupied'] = true;
      _isSessionActive = true;
      _activePortId = _selectedPort['id'];
      _remainingSeconds = durationMins * 60;
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

    final invId = "GST-CHG-${Random().nextInt(89999) + 10000}";
    final timeSlotText = "${_formatTimeOfDay(_startTime)} - ${_formatTimeOfDay(_endTime)}";

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
            Text("Charging Port Locked & Reserved!", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Tax Slip: $invId • Txn: $txnId", style: const TextStyle(color: Colors.white54, fontSize: 10.5)),
            const Divider(color: Colors.white12, height: 16),
            Text("Station: ${_currentStation['name']}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
            Text("Port: ${_selectedPort['id']} (${_selectedPort['power']}) 🔴 LOCKED", style: const TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.bold, fontSize: 12.5)),
            const SizedBox(height: 4),
            Text("⏰ Reserved Slot: $timeSlotText ($_selectedHours Hours)", style: const TextStyle(color: Color(0xFF00F0FF), fontSize: 12, fontWeight: FontWeight.bold)),
            Text("Total Paid: ₹ ${_totalPayable.toStringAsFixed(2)}", style: const TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.bold, fontSize: 14)),
            if (earnedCashback > 0) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: const Color(0x2600E676), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFF00E676))),
                child: Row(
                  children: [
                    const Icon(Icons.stars, color: Color(0xFF00E676), size: 16),
                    const SizedBox(width: 6),
                    Text("+₹${earnedCashback.toStringAsFixed(2)} (5% Cashback) Credited!", style: const TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.bold, fontSize: 11)),
                  ],
                ),
              ),
            ],
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
      const SnackBar(content: Text("🟢 Time Slot Completed! Port is now Released & FREE (Green)."), backgroundColor: Color(0xFF00E676)),
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
        final bool canPayWithWallet = service.canPayWithWallet(_totalPayable);

        return Scaffold(
          backgroundColor: const Color(0xFF080E1A),
          appBar: AppBar(
            backgroundColor: const Color(0xFF10192B),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text("EV Charging Port Time-Slot Booking", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ACTIVE COUNTDOWN BANNER
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
                                Text("⚡ Charging Active: $_activePortId (🔴 LOCKED)", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
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

                  // 1. SELECT HUB
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

                  // 2. LIVE PORTS GRID (🟢 GREEN FREE / 🔴 RED BOOKED)
                  Text("2. Select Port in ${_currentStation['name']}", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5)),
                  const SizedBox(height: 8),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ports.map((item) {
                      final p = item as Map<String, dynamic>;
                      final isOcc = p['isOccupied'] as bool;
                      final isSel = _selectedPort['id'] == p['id'];
                      final col = isOcc ? Colors.redAccent : const Color(0xFF00E676);

                      return GestureDetector(
                        onTap: () {
                          if (isOcc && p['id'] != _activePortId) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("${p['id']} is currently Booked (🔴). Choose a Free Port (🟢)."), backgroundColor: Colors.redAccent),
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
                              color: col,
                              width: isSel ? 1.8 : 1.0,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.bolt, color: col, size: 16),
                              const SizedBox(width: 6),
                              Text("${p['id']} (${p['power']})", style: TextStyle(color: isOcc ? Colors.redAccent : Colors.white, fontWeight: FontWeight.bold, fontSize: 11.5)),
                              const SizedBox(width: 6),
                              Text(isOcc ? "🔴 BOOKED" : "🟢 FREE", style: TextStyle(color: col, fontSize: 9.5, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // 3. VEHICLE SELECTION
                  const Text("3. Select Your Vehicle", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5)),
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

                  // 4. ADVANCE TIME-SLOT DURATION & CLOCK PICKER
                  const Text("4. Select Charging Time Slot", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5)),
                  const SizedBox(height: 8),

                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF131D31),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () => _pickStartTime(context),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF080E1A),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: const Color(0xFF00E676)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("From (Start Time)", style: TextStyle(color: Colors.white54, fontSize: 10)),
                                    Row(
                                      children: [
                                        const Icon(Icons.access_time, color: Color(0xFF00E676), size: 15),
                                        const SizedBox(width: 4),
                                        Text(_formatTimeOfDay(_startTime), style: const TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.bold, fontSize: 12.5)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const Icon(Icons.arrow_forward, color: Colors.white38, size: 18),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF080E1A),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFF00F0FF)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Until (End Time)", style: TextStyle(color: Colors.white54, fontSize: 10)),
                                  Row(
                                    children: [
                                      const Icon(Icons.timer_off, color: Color(0xFF00F0FF), size: 15),
                                      const SizedBox(width: 4),
                                      Text(_formatTimeOfDay(_endTime), style: const TextStyle(color: Color(0xFF00F0FF), fontWeight: FontWeight.bold, fontSize: 12.5)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // QUICK DURATION BUTTONS
                        Row(
                          children: [1, 2, 3, 4].map((h) {
                            final isSel = _selectedHours == h;
                            return Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _selectedHours = h),
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 3),
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isSel ? const Color(0xFF00E676) : const Color(0xFF080E1A),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: isSel ? const Color(0xFF00E676) : Colors.white12),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "$h hr${h > 1 ? 's' : ''}",
                                      style: TextStyle(
                                        color: isSel ? Colors.black : Colors.white70,
                                        fontSize: 11.5,
                                        fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 5. PAYMENT METHOD
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("5. Payment Method", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: const Color(0x2600E676), borderRadius: BorderRadius.circular(6)),
                        child: const Text("🎁 +5% Cashback on Razorpay", style: TextStyle(color: Color(0xFF00E676), fontSize: 10.5, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _paymentMethod = 'razorpay'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: _paymentMethod == 'razorpay' ? const Color(0x33528FF0) : const Color(0xFF131D31),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: _paymentMethod == 'razorpay' ? const Color(0xFF528FF0) : Colors.white12, width: 1.5),
                            ),
                            child: const Column(
                              children: [
                                Text("Razorpay UPI/Card", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                                SizedBox(height: 2),
                                Text("Earn 5% Cashback", style: TextStyle(color: Color(0xFF00E676), fontSize: 9.5, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            if (!canPayWithWallet) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Insufficient Wallet Cashback (₹${service.walletBalance.toStringAsFixed(2)}). Pay via Razorpay to earn 5% Cashback!"),
                                  backgroundColor: Colors.amber,
                                ),
                              );
                            } else {
                              setState(() => _paymentMethod = 'wallet');
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: canPayWithWallet
                                  ? (_paymentMethod == 'wallet' ? const Color(0x3300E676) : const Color(0xFF131D31))
                                  : const Color(0xFF080E1A),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: canPayWithWallet
                                    ? (_paymentMethod == 'wallet' ? const Color(0xFF00E676) : Colors.white12)
                                    : Colors.white10,
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  "Wallet Balance",
                                  style: TextStyle(color: canPayWithWallet ? Colors.white : Colors.white38, fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  canPayWithWallet ? "₹${service.walletBalance.toStringAsFixed(2)} Available" : "Low Bal (₹${service.walletBalance.toInt()})",
                                  style: TextStyle(color: canPayWithWallet ? const Color(0xFF00E676) : Colors.redAccent, fontSize: 9.5),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),

                  // 6. BOTTOM ACTION BAR
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
                            Text("Total ($_selectedHours hr • ${_selectedPort['id']})", style: const TextStyle(color: Colors.white54, fontSize: 10.5)),
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
                                Text(_isSessionActive ? "Extend Slot" : "Reserve & Pay", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13)),
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