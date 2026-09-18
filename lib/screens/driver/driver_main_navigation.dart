import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/energo_unified_service.dart';
import '../ride/ride_completed_screen.dart';

enum ActiveRideStage {
  idle,
  searching,
  driverAssigned,
  headingToPickup,
  driverArrived,
  inTransit,
  reachedDestination,
  completed,
}

class DriverMainNavigation extends StatefulWidget {
  const DriverMainNavigation({super.key});

  @override
  State<DriverMainNavigation> createState() => _DriverMainNavigationState();
}

class _DriverMainNavigationState extends State<DriverMainNavigation> {
  final EnergoUnifiedService _service = EnergoUnifiedService();
  int _currentTab = 0;
  bool _isOnline = true;
  Timer? _countdownTimer;
  int _requestCountdown = 15;

  // 🚗 Active Ride Simulation & Lifecycle State
  ActiveRideStage _activeRideStage = ActiveRideStage.idle;
  bool _hasIncomingRide = false;
  double _activeRideFare = 480.0;
  String _activeRidePickup = "Terminal 3, VIP Gate 4";
  String _activeRideDestination = "SuperHub Alpha, Aerocity";
  String _passengerName = "Anamika Choudhary";
  String _brokerCompany = "BluSmart Fleet Mobility Ltd.";

  // Solo Driver UPI & QR Manager State
  String _soloUpiId = "rahul.sharma@okaxis";
  String _soloQrLink = "upi://pay?pa=rahul.sharma@okaxis&pn=Rahul%20Sharma&cu=INR";

  // Shift Checklist State (For Broker Fleet Driver)
  bool _inspectionPassed = false;
  double _startOdo = 42150.0;
  final _odoCtrl = TextEditingController(text: "42150");

  @override
  void initState() {
    super.initState();
    _service.addListener(_onServiceUpdate);
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _service.removeListener(_onServiceUpdate);
    _odoCtrl.dispose();
    super.dispose();
  }

  void _onServiceUpdate() {
    if (mounted) setState(() {});
  }

  bool get _isSolo {
    try {
      return _service.currentDriverType == DriverType.soloDriver;
    } catch (_) {
      return true;
    }
  }

  String get _driverName {
    try {
      return _service.driverName.isNotEmpty ? _service.driverName : "Rahul Sharma";
    } catch (_) {
      return "Rahul Sharma";
    }
  }

  String get _vehiclePlate {
    try {
      return _service.vehiclePlate.isNotEmpty ? _service.vehiclePlate : "DL 01 EV 4891";
    } catch (_) {
      return "DL 01 EV 4891";
    }
  }

  void _startRequestCountdown() {
    _requestCountdown = 15;
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_requestCountdown > 1) {
        setState(() => _requestCountdown--);
      } else {
        timer.cancel();
        _rejectIncomingRide();
      }
    });
  }

  void _triggerSimulatedRideRequest() {
    setState(() {
      _hasIncomingRide = true;
      _activeRideStage = ActiveRideStage.searching;
    });
    _startRequestCountdown();
  }

  void _acceptIncomingRide() {
    _countdownTimer?.cancel();
    setState(() {
      _hasIncomingRide = false;
      _activeRideStage = ActiveRideStage.headingToPickup;
    });
  }

  void _rejectIncomingRide() {
    _countdownTimer?.cancel();
    setState(() {
      _hasIncomingRide = false;
      _activeRideStage = ActiveRideStage.idle;
    });
  }

  void _driverArrivedAtPickup() {
    setState(() {
      _activeRideStage = ActiveRideStage.driverArrived;
    });
  }

  void _verifyOtpAndStartTrip(String pin) {
    setState(() {
      _activeRideStage = ActiveRideStage.inTransit;
    });
  }

  void _reachDestination() {
    setState(() {
      _activeRideStage = ActiveRideStage.reachedDestination;
    });
  }

  void _finishRideAndPay() {
    setState(() {
      _activeRideStage = ActiveRideStage.completed;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D131F),
      body: SafeArea(
        child: IndexedStack(
          index: _currentTab,
          children: [
            _buildCockpitHUD(),
            _buildEVTelemetryAndHubsTab(),
            _buildEarningsAndPayoutsTab(),
            _buildTripsAndInspectionTab(),
            _buildProfileAndVaultTab(),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF131B2E),
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.08))),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentTab,
          onTap: (idx) => setState(() => _currentTab = idx),
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: _isSolo ? const Color(0xFF00E5FF) : const Color(0xFF00E676),
          unselectedItemColor: Colors.white54,
          selectedFontSize: 11,
          unselectedFontSize: 10,
          items: [
            const BottomNavigationBarItem(icon: Icon(Icons.navigation_rounded), label: "Cockpit HUD"),
            const BottomNavigationBarItem(icon: Icon(Icons.electric_bolt_rounded), label: "EV & Hubs"),
            BottomNavigationBarItem(
              icon: Icon(_isSolo ? Icons.account_balance_wallet_rounded : Icons.payments_rounded),
              label: _isSolo ? "Payouts" : "Shift Wages",
            ),
            BottomNavigationBarItem(
              icon: Icon(_isSolo ? Icons.history_rounded : Icons.checklist_rounded),
              label: _isSolo ? "Trips" : "Duty Log",
            ),
            const BottomNavigationBarItem(icon: Icon(Icons.shield_rounded), label: "Vault & KYC"),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // TAB 1: COCKPIT / RADAR / RIDE LIFECYCLE
  // ==========================================
  Widget _buildCockpitHUD() {
    return Stack(
      children: [
        // 1. Simulated Live Vector Map & Heatmap
        Container(
          width: double.infinity,
          height: double.infinity,
          color: const Color(0xFF0A0E17),
          child: CustomPaint(
            painter: _RadarMapPainter(),
          ),
        ),

        // 2. Top Driver Header & Online/Offline Switch
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: Column(
            children: [
              _buildTopIdentityCard(),
              const SizedBox(height: 10),
              _buildSurgeRadarBanner(),
            ],
          ),
        ),

        // 3. SOS & Quick Support Floating Buttons
        Positioned(
          top: 170,
          right: 16,
          child: Column(
            children: [
              _buildFloatingTool(
                icon: Icons.sos_rounded,
                color: Colors.redAccent,
                label: "SOS",
                onTap: _showSOSDialog,
              ),
              const SizedBox(height: 10),
              _buildFloatingTool(
                icon: Icons.headset_mic_rounded,
                color: const Color(0xFF00E5FF),
                label: _isSolo ? "RSA Help" : "Fleet Mgr",
                onTap: _showSupportDialog,
              ),
            ],
          ),
        ),

        // 4. Bottom Dynamic Interactive Panels
        Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: _buildBottomInteractivePanel(),
        ),
      ],
    );
  }

  Widget _buildTopIdentityCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF131B2E).withOpacity(0.95),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _isSolo ? const Color(0xFF00E5FF).withOpacity(0.3) : const Color(0xFF00E676).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: _isSolo ? const Color(0xFF00E5FF).withOpacity(0.2) : const Color(0xFF00E676).withOpacity(0.2),
            child: Icon(
              _isSolo ? Icons.person_rounded : Icons.business_center_rounded,
              color: _isSolo ? const Color(0xFF00E5FF) : const Color(0xFF00E676),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        _driverName,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _isSolo ? Colors.cyan.withOpacity(0.2) : Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _isSolo ? "SOLO EV" : "FLEET DRIVER",
                        style: TextStyle(
                          color: _isSolo ? const Color(0xFF00E5FF) : const Color(0xFF00E676),
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  _vehiclePlate,
                  style: const TextStyle(color: Colors.white60, fontSize: 11),
                ),
              ],
            ),
          ),
          Switch(
            value: _isOnline,
            activeColor: _isSolo ? const Color(0xFF00E5FF) : const Color(0xFF00E676),
            onChanged: (val) {
              setState(() => _isOnline = val);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_isOnline ? "🟢 You are ONLINE for ride requests" : "🔴 You are OFFLINE"),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSurgeRadarBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withOpacity(0.3)),
      ),
      child: const Row(
        children: [
          Icon(Icons.local_fire_department_rounded, color: Colors.amber, size: 18),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              "High Surge Zone: Aerocity & Cyber Hub (+₹65 to +₹120 surge bonus)",
              style: TextStyle(color: Colors.amber, fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingTool({required IconData icon, required Color color, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF131B2E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.5)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 6)],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomInteractivePanel() {
    // Stage 1: Incoming 15s Ride Request
    if (_hasIncomingRide && _activeRideStage == ActiveRideStage.searching) {
      return _buildIncomingRideCard();
    }

    // Stage 2: Heading to Pickup
    if (_activeRideStage == ActiveRideStage.driverAssigned || _activeRideStage == ActiveRideStage.headingToPickup) {
      return _buildHeadingToPickupCard();
    }

    // Stage 3: Arrived -> PIN Verification
    if (_activeRideStage == ActiveRideStage.driverArrived) {
      return _buildArrivedAndOTPVerificationCard();
    }

    // Stage 4: In Transit Speedometer HUD
    if (_activeRideStage == ActiveRideStage.inTransit) {
      return _buildInTransitHUDCard();
    }

    // Stage 5: Settlement
    if (_activeRideStage == ActiveRideStage.reachedDestination) {
      return _buildFareSettlementCard();
    }

    // Default Idle State
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF131B2E),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.radar_rounded, color: Colors.greenAccent, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Searching for Passenger Requests...", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                Text(
                  _isSolo ? "Solo Driver Mode • 100% Cash/UPI Control" : "Broker Fleet Mode • Automated Corporate Ledger",
                  style: const TextStyle(color: Colors.white60, fontSize: 11),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E293B),
              foregroundColor: const Color(0xFF00E5FF),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            onPressed: _triggerSimulatedRideRequest,
            child: const Text("Simulate", style: TextStyle(fontSize: 11)),
          ),
        ],
      ),
    );
  }

  // --- RIDE STAGE 1: 15s INCOMING RIDE REQUEST POPUP ---
  Widget _buildIncomingRideCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF131B2E),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF00E5FF), width: 2),
        boxShadow: [
          BoxShadow(color: const Color(0xFF00E5FF).withOpacity(0.2), blurRadius: 20, spreadRadius: 2),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.timer_rounded, color: Colors.redAccent, size: 16),
                    const SizedBox(width: 6),
                    Text("Expires in ${_requestCountdown}s", style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
              ),
              Text(
                "₹${_activeRideFare.toStringAsFixed(0)}",
                style: const TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.bold, fontSize: 22),
              ),
            ],
          ),
          const Divider(color: Colors.white10, height: 20),
          Row(
            children: [
              const Icon(Icons.my_location_rounded, color: Colors.greenAccent, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _activeRidePickup,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on_rounded, color: Colors.redAccent, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _activeRideDestination,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white60,
                    side: const BorderSide(color: Colors.white24),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _rejectIncomingRide,
                  child: const Text("Decline"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00E676),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _acceptIncomingRide,
                  child: const Text("ACCEPT RIDE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- RIDE STAGE 2: HEADING TO PICKUP ---
  Widget _buildHeadingToPickupCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF131B2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.cyan.withOpacity(0.4)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: Color(0xFF00E5FF),
                radius: 18,
                child: Icon(Icons.person, color: Colors.black),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Passenger: $_passengerName", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    const Text("Pickup: Terminal 3 VIP Gate", style: TextStyle(color: Colors.white60, fontSize: 11)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.call, color: Colors.greenAccent),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00E5FF),
              foregroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 48),
            ),
            onPressed: _driverArrivedAtPickup,
            child: const Text("I HAVE ARRIVED AT PICKUP", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // --- RIDE STAGE 3: OTP / PIN VERIFICATION ---
  Widget _buildArrivedAndOTPVerificationCard() {
    final pinCtrl = TextEditingController(text: "7842");
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF131B2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amberAccent.withOpacity(0.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Row(
            children: [
              Icon(Icons.pin_rounded, color: Colors.amberAccent),
              SizedBox(width: 10),
              Text("Enter 4-Digit Passenger Start PIN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: pinCtrl,
            keyboardType: TextInputType.number,
            maxLength: 4,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.amberAccent, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 10),
            decoration: InputDecoration(
              counterText: "",
              filled: true,
              fillColor: const Color(0xFF0D131F),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amberAccent,
              foregroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 48),
            ),
            onPressed: () {
              if (pinCtrl.text.trim() == "7842" || pinCtrl.text.isNotEmpty) {
                _verifyOtpAndStartTrip(pinCtrl.text.trim());
              }
            },
            child: const Text("VERIFY PIN & START TRIP", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // --- RIDE STAGE 4: IN TRANSIT SPEEDOMETER HUD ---
  Widget _buildInTransitHUDCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF131B2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.greenAccent.withOpacity(0.4)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("IN TRANSIT TO DESTINATION", style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 11)),
                  Text("SuperHub Hub-Alpha Dropoff", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.cyanAccent.withOpacity(0.3)),
                ),
                child: const Text("54 km/h", style: TextStyle(color: Color(0xFF00E5FF), fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
            ),
            onPressed: _reachDestination,
            child: const Text("COMPLETE TRIP / REACH DESTINATION", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // --- RIDE STAGE 5: SETTLEMENT & QR DISPATCH ---
  Widget _buildFareSettlementCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF131B2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _isSolo ? const Color(0xFF00E5FF) : const Color(0xFF00E676)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_isSolo ? "Collect Solo Driver Fare" : "Broker Vault Settlement", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              Text("₹${_activeRideFare.toStringAsFixed(0)}", style: const TextStyle(color: Color(0xFF00E676), fontSize: 22, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _isSolo ? Colors.cyan.withOpacity(0.1) : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _isSolo ? Colors.cyan : Colors.redAccent),
            ),
            child: Row(
              children: [
                Icon(_isSolo ? Icons.qr_code_2_rounded : Icons.money_off_rounded, color: _isSolo ? Colors.cyanAccent : Colors.redAccent),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _isSolo
                        ? "Personal UPI: $_soloUpiId (or Accept Direct Cash)"
                        : "STRICTLY NO CASH: 100% fare auto-routed to $_brokerCompany Corporate Vault.",
                    style: TextStyle(color: _isSolo ? Colors.cyanAccent : Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00E676),
              foregroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 48),
            ),
            onPressed: () {
              _finishRideAndPay();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (ctx) => RideCompletedScreen(
                    fare: _activeRideFare,
                    pickup: _activeRidePickup,
                    drop: _activeRideDestination,
                    driverName: _driverName,
                    vehicleNumber: _vehiclePlate,
                  ),
                ),
              );
            },
            child: const Text("CONFIRM PAYMENT RECEIVED & CLOSE", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 2: EV TELEMETRY & 4 SUPERHUB PASSES
  // ==========================================
  Widget _buildEVTelemetryAndHubsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("⚡ Tesla-Grade EV Battery & Health Telemetry", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildEVGaugeOverview(),
          const SizedBox(height: 20),
          const Text("📍 4 SuperHub 1-Tap Driver Amenities Passes", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildHubPassCard(
            title: "180kW DC Fast Charging Reserve",
            subtitle: "CCS2 Gun #3 reserved at SuperHub Delta",
            icon: Icons.electric_car_rounded,
            color: const Color(0xFF00E5FF),
            badge: "FREE DRIVER PASS",
          ),
          const SizedBox(height: 10),
          _buildHubPassCard(
            title: "IoT Parking Barrier 1-Tap Raise",
            subtitle: "Bay #B4 Ultrasonic Auto-Pass",
            icon: Icons.local_parking_rounded,
            color: const Color(0xFF00E676),
            badge: "AUTHORIZED",
          ),
          const SizedBox(height: 10),
          _buildHubPassCard(
            title: "Driver Snooze Pod & Rest Cabin",
            subtitle: "Pod #8 Available (20 min power nap)",
            icon: Icons.bed_rounded,
            color: Colors.purpleAccent,
            badge: "RESERVE NOW",
          ),
          const SizedBox(height: 10),
          _buildHubPassCard(
            title: "5G Lounge & Beverage Coupon",
            subtitle: "Complimentary Hot Tea / Coffee + EV WiFi",
            icon: Icons.coffee_rounded,
            color: Colors.amberAccent,
            badge: "CLAIM 100% OFF",
          ),
        ],
      ),
    );
  }

  Widget _buildEVGaugeOverview() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF131B2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildGaugeStat("84%", "State of Charge", Colors.greenAccent, Icons.battery_charging_full_rounded),
              _buildGaugeStat("265 km", "Range Remaining", const Color(0xFF00E5FF), Icons.speed_rounded),
              _buildGaugeStat("98.5%", "Battery SOH", Colors.amberAccent, Icons.health_and_safety_rounded),
            ],
          ),
          const Divider(color: Colors.white10, height: 24),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text("FL Tyre: 33 PSI", style: TextStyle(color: Colors.white70, fontSize: 11)),
              Text("FR Tyre: 33 PSI", style: TextStyle(color: Colors.white70, fontSize: 11)),
              Text("RL Tyre: 34 PSI", style: TextStyle(color: Colors.white70, fontSize: 11)),
              Text("RR Tyre: 34 PSI", style: TextStyle(color: Colors.white70, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGaugeStat(String value, String label, Color color, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: color, size: 26),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 10)),
      ],
    );
  }

  Widget _buildHubPassCard({required String title, required String subtitle, required IconData icon, required Color color, required String badge}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF131B2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                Text(subtitle, style: const TextStyle(color: Colors.white60, fontSize: 11)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
            child: Text(badge, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 3: EARNINGS & RAZORPAY / SHIFT WAGES
  // ==========================================
  Widget _buildEarningsAndPayoutsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _isSolo ? "💰 Solo Driver Earnings & Instant Bank Payout" : "🏢 Shift Wage & Corporate Ledger",
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _isSolo
                    ? [const Color(0xFF00838F), const Color(0xFF004D40)]
                    : [const Color(0xFF1B5E20), const Color(0xFF0D5302)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_isSolo ? "TODAY'S NET EARNINGS" : "TODAY'S SHIFT WAGE (GUARANTEED)", style: const TextStyle(color: Colors.white70, fontSize: 11)),
                const SizedBox(height: 6),
                Text(
                  _isSolo ? "₹2,840.00" : "₹850.00 + ₹245 (Per-Ride Incentive)",
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_isSolo ? "Completed Trips: 8" : "Shift: 08:00 AM - 04:00 PM", style: const TextStyle(color: Colors.white70, fontSize: 11)),
                    Text(_isSolo ? "Platform Fee (10%): -₹284" : "Fleet: $_brokerCompany", style: const TextStyle(color: Colors.white70, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (_isSolo) ...[
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00E5FF),
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 50),
              ),
              icon: const Icon(Icons.bolt_rounded),
              label: const Text("1-TAP INSTANT RAZORPAY PAYOUT (₹2,556)", style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("✅ Instant Payout of ₹2,556 processed via Razorpay to HDFC A/c ****4891"),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.lock_rounded, color: Colors.greenAccent),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Corporate Vault Sync Active: Shift earnings auto-transferred by Fleet Broker at 06:00 PM daily.",
                      style: TextStyle(color: Colors.greenAccent, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ==========================================
  // TAB 4: TRIPS & DUTY INSPECTION CHECKLIST
  // ==========================================
  Widget _buildTripsAndInspectionTab() {
    if (!_isSolo) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("📋 Pre-Shift 360° Vehicle Damage & Odo Inspection", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFF131B2E), borderRadius: BorderRadius.circular(18)),
              child: Column(
                children: [
                  TextField(
                    controller: _odoCtrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: "Starting Odometer Reading (KM)",
                      labelStyle: TextStyle(color: Colors.white60),
                      prefixIcon: Icon(Icons.speed_rounded, color: Color(0xFF00E676)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  CheckboxListTile(
                    title: const Text("Front & Rear Bumper Free of Dents", style: TextStyle(color: Colors.white, fontSize: 12)),
                    value: _inspectionPassed,
                    activeColor: const Color(0xFF00E676),
                    onChanged: (v) => setState(() => _inspectionPassed = v ?? false),
                  ),
                  CheckboxListTile(
                    title: const Text("Tyres Pressure & Spare Wheel Checked (33 PSI)", style: TextStyle(color: Colors.white, fontSize: 12)),
                    value: _inspectionPassed,
                    activeColor: const Color(0xFF00E676),
                    onChanged: (v) => setState(() => _inspectionPassed = v ?? false),
                  ),
                  CheckboxListTile(
                    title: const Text("AC Cooling & Sanitized Seat Covers", style: TextStyle(color: Colors.white, fontSize: 12)),
                    value: _inspectionPassed,
                    activeColor: const Color(0xFF00E676),
                    onChanged: (v) => setState(() => _inspectionPassed = v ?? false),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00E676),
                      foregroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 46),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("✅ Pre-Duty Vehicle Inspection Saved & Synced to Fleet ERP"), backgroundColor: Colors.green),
                      );
                    },
                    child: const Text("SUBMIT PRE-DUTY REPORT", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text("📜 Recent Trip Ledger", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _buildTripTile("SuperHub Alpha ➔ Aerocity T3", "₹420", "Completed • Paid via Personal UPI", Colors.greenAccent),
        _buildTripTile("Cyber City ➔ Sector 29 Hub", "₹310", "Completed • Paid in Cash", Colors.amberAccent),
        _buildTripTile("Dwarka Expressway ➔ IGI Terminal 1", "₹580", "Completed • Razorpay Online", Colors.cyanAccent),
      ],
    );
  }

  Widget _buildTripTile(String route, String fare, String status, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFF131B2E), borderRadius: BorderRadius.circular(14)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(route, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                Text(status, style: TextStyle(color: color, fontSize: 11)),
              ],
            ),
          ),
          Text(fare, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 5: VAULT, UPI MANAGER & KYC
  // ==========================================
  Widget _buildProfileAndVaultTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("🛡️ Driver Vault, UPI & Document Center", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          // Solo Driver Personal UPI & QR Manager
          if (_isSolo) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF131B2E),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Personal UPI & QR Code Settings", style: TextStyle(color: Color(0xFF00E5FF), fontWeight: FontWeight.bold)),
                      Icon(Icons.qr_code_2_rounded, color: Color(0xFF00E5FF)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text("Current Settlement UPI ID: $_soloUpiId", style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E293B),
                      foregroundColor: const Color(0xFF00E5FF),
                    ),
                    onPressed: _showEditSoloUpiDialog,
                    child: const Text("Edit UPI ID / Upload QR Code"),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],

          _buildDocItem("Commercial Driving License", "DL-04201994812", "VERIFIED", Colors.greenAccent),
          _buildDocItem("EV RC Smart Card", _vehiclePlate, "VERIFIED", Colors.greenAccent),
          _buildDocItem("Commercial EV Insurance Policy", "Bajaj Allianz EV-4891", "VALID TILL 2027", Colors.cyanAccent),
          _buildDocItem("Police Background Verification", "Delhi Police Verified", "VERIFIED", Colors.greenAccent),
        ],
      ),
    );
  }

  Widget _buildDocItem(String title, String num, String status, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFF131B2E), borderRadius: BorderRadius.circular(14)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              Text(num, style: const TextStyle(color: Colors.white60, fontSize: 11)),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
            child: Text(status, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showEditSoloUpiDialog() {
    final ctrl = TextEditingController(text: _soloUpiId);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF131B2E),
        title: const Text("Edit Personal UPI ID", style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: ctrl,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(labelText: "Enter UPI ID (e.g. name@okhdfcbank)", labelStyle: TextStyle(color: Colors.white60)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00E5FF), foregroundColor: Colors.black),
            onPressed: () {
              setState(() => _soloUpiId = ctrl.text.trim());
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("✅ Personal UPI ID updated successfully!"), backgroundColor: Colors.green));
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _showSOSDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1F1212),
        title: const Row(children: [Icon(Icons.warning_amber_rounded, color: Colors.redAccent), SizedBox(width: 8), Text("EMERGENCY SOS", style: TextStyle(color: Colors.redAccent))]),
        content: const Text("Instant Police dispatch & EnerGo Nexus Highway EV Assistance will be notified with your live GPS location.", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white), onPressed: () => Navigator.pop(ctx), child: const Text("CALL 112 & RSA")),
        ],
      ),
    );
  }

  void _showSupportDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF131B2E),
        title: Text(_isSolo ? "Roadside EV Assistance" : "Fleet Control Room Hotline", style: const TextStyle(color: Colors.white)),
        content: Text(_isSolo ? "Call 24x7 EnerGo EV Highway Assistance: 1800-419-EV-HELP" : "Direct line to $_brokerCompany Dispatcher: +91 98110 00192", style: const TextStyle(color: Colors.white70)),
        actions: [
          ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00E5FF), foregroundColor: Colors.black), onPressed: () => Navigator.pop(ctx), child: const Text("Call Now")),
        ],
      ),
    );
  }
}

// Custom Radar Painter for Live Map Grid
class _RadarMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1A263F)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Grid lines
    for (double i = 0; i < size.width; i += 40) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double j = 0; j < size.height; j += 40) {
      canvas.drawLine(Offset(0, j), Offset(size.width, j), paint);
    }

    // Hotspot surge circle
    final surgePaint = Paint()
      ..color = Colors.amber.withOpacity(0.12)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width * 0.65, size.height * 0.35), 80, surgePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}