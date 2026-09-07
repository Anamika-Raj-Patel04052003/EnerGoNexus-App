import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/energo_unified_service.dart';

class DriverMainNavigation extends StatefulWidget {
  const DriverMainNavigation({super.key});

  @override
  State<DriverMainNavigation> createState() => _DriverMainNavigationState();
}

class _DriverMainNavigationState extends State<DriverMainNavigation> {
  int _currentTabIndex = 0;
  bool _isOnline = true;

  // 🔔 INCOMING RIDE REQUEST STATE (OLA / UBER STYLE)
  bool _hasIncomingRequest = true;
  int _requestCountdown = 15;
  Timer? _countdownTimer;
  Timer? _speedSimTimer;

  // IN-TRANSIT TELEMETRY
  int _currentSpeed = 0;
  int _etaMinutes = 12;
  double _tripProgress = 0.0;
  final _pinController = TextEditingController();

  // ⚡ EV TELEMETRY
  final double _batterySoc = 84.0;
  final int _rangeKm = 265;
  final double _batteryHealth = 98.5;
  final int _tirePsi = 33;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _requestCountdown = 15;
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_requestCountdown > 1) {
        setState(() => _requestCountdown--);
      } else {
        t.cancel();
        setState(() => _hasIncomingRequest = false);
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _speedSimTimer?.cancel();
    _pinController.dispose();
    super.dispose();
  }

  // 1. ACCEPT RIDE ACTION
  void _acceptIncomingRide() {
    _countdownTimer?.cancel();
    setState(() => _hasIncomingRequest = false);

    final service = EnergoUnifiedService();
    service.updateRideStage(ActiveRideStage.driverAssigned);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("🟢 Ride Accepted! Driving to Passenger Pickup."),
        backgroundColor: Color(0xFF10B981),
      ),
    );
  }

  void _declineRide() {
    _countdownTimer?.cancel();
    setState(() => _hasIncomingRequest = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Ride declined. Searching next nearby rider..."), backgroundColor: Colors.white24),
    );
  }

  // 2. VERIFY PIN & START IN-TRANSIT
  void _verifyPinAndStartTrip(EnergoUnifiedService service) {
    if (_pinController.text == service.ridePin) {
      service.updateRideStage(ActiveRideStage.inTransit);
      _startSpeedSimulation();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("🟢 Passenger PIN Verified! Trip in Progress."), backgroundColor: Color(0xFF10B981)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Invalid PIN! Ask passenger for 4-digit PIN (e.g. ${service.ridePin})"), backgroundColor: Colors.redAccent),
      );
    }
  }

  void _startSpeedSimulation() {
    _speedSimTimer?.cancel();
    _speedSimTimer = Timer.periodic(const Duration(seconds: 2), (t) {
      if (!mounted) return;
      setState(() {
        _currentSpeed = 36 + (DateTime.now().second % 18);
        if (_tripProgress < 0.9) {
          _tripProgress += 0.1;
          if (_etaMinutes > 2) _etaMinutes--;
        }
      });
    });
  }

  // 3. COMPLETE RIDE & ROUTE FARE
  void _completeAndSettleRide(EnergoUnifiedService service, bool isBrokerDriver) {
    _speedSimTimer?.cancel();
    _currentSpeed = 0;
    service.completeRideAndRouteFare();
    service.updateRideStage(ActiveRideStage.searching);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isBrokerDriver ? "✅ ₹${service.rideFare} credited to Broker Vault! Shift wage logged." : "✅ ₹${(service.rideFare * 0.9).toStringAsFixed(0)} Net added to Solo Wallet!"),
        backgroundColor: const Color(0xFF10B981),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final service = EnergoUnifiedService();

    return ListenableBuilder(
      listenable: service,
      builder: (context, _) {
        final isBrokerDriver = service.currentDriverType == DriverType.brokerFleetDriver;

        return Scaffold(
          backgroundColor: const Color(0xFF0A0E17),
          appBar: AppBar(
            backgroundColor: const Color(0xFF111827),
            elevation: 0,
            title: Row(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: isBrokerDriver ? const Color(0xFF10B981).withOpacity(0.2) : const Color(0xFF00E5FF).withOpacity(0.2),
                      child: Icon(Icons.person, color: isBrokerDriver ? const Color(0xFF10B981) : const Color(0xFF00E5FF), size: 22),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: _isOnline ? const Color(0xFF10B981) : Colors.redAccent,
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF111827), width: 2),
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(service.driverName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(width: 6),
                        const Icon(Icons.verified, color: Color(0xFF10B981), size: 14),
                      ],
                    ),
                    Text(
                      isBrokerDriver ? "🏢 ${service.brokerCompanyName} • Fleet EV" : "🚕 Solo Independent • ${service.vehiclePlate}",
                      style: const TextStyle(color: Colors.white54, fontSize: 10.5),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 12, top: 10, bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: _isOnline ? const Color(0xFF10B981).withOpacity(0.15) : Colors.white10,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _isOnline ? const Color(0xFF10B981) : Colors.white24),
                ),
                child: Row(
                  children: [
                    Text(_isOnline ? "DUTY ON" : "OFFLINE", style: TextStyle(color: _isOnline ? const Color(0xFF10B981) : Colors.white60, fontSize: 10.5, fontWeight: FontWeight.bold)),
                    Switch(
                      value: _isOnline,
                      activeColor: const Color(0xFF10B981),
                      activeTrackColor: const Color(0xFF10B981).withOpacity(0.3),
                      inactiveThumbColor: Colors.white54,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      onChanged: (val) => setState(() => _isOnline = val),
                    ),
                  ],
                ),
              )
            ],
          ),
          body: IndexedStack(
            index: _currentTabIndex,
            children: [
              _buildDutyCockpitTab(service, isBrokerDriver),
              _buildEvTelemetryAndHubPassTab(),
              _buildEarningsTab(service, isBrokerDriver),
              _buildTripsHistoryTab(service),
              _buildProfileKycTab(service, isBrokerDriver),
            ],
          ),
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              color: Color(0xFF111827),
              border: Border(top: BorderSide(color: Colors.white12)),
            ),
            child: BottomNavigationBar(
              currentIndex: _currentTabIndex,
              onTap: (idx) => setState(() => _currentTabIndex = idx),
              backgroundColor: const Color(0xFF111827),
              type: BottomNavigationBarType.fixed,
              selectedItemColor: const Color(0xFF00E5FF),
              unselectedItemColor: Colors.white54,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10.5),
              unselectedLabelStyle: const TextStyle(fontSize: 10),
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.navigation), label: "Cockpit"),
                BottomNavigationBarItem(icon: Icon(Icons.bolt), label: "EV & Hubs"),
                BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_outlined), label: "Earnings"),
                BottomNavigationBarItem(icon: Icon(Icons.history), label: "Trips"),
                BottomNavigationBarItem(icon: Icon(Icons.verified_user_outlined), label: "KYC"),
              ],
            ),
          ),
        );
      },
    );
  }

  // TAB 1: DUTY COCKPIT
  Widget _buildDutyCockpitTab(EnergoUnifiedService service, bool isBrokerDriver) {
    final stage = service.rideStage;

    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            color: Color(0xFF161F30),
            image: DecorationImage(
              image: NetworkImage("https://maps.googleapis.com/maps/api/staticmap?center=28.6139,77.2090&zoom=14&size=600x600&maptype=roadmap&style=element:geometry%7Ccolor:0x212121&style=element:labels.text.stroke%7Ccolor:0x212121&style=element:labels.text.fill%7Ccolor:0x757575&key=AIzaSyDp3mkbKShGs1ZHGrQ8By3sDquvoTaymzs"),
              fit: BoxFit.cover,
              opacity: 0.65,
            ),
          ),
        ),
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(color: const Color(0xFF0F172A).withOpacity(0.9), borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white12)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.local_fire_department, color: Colors.amber, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      stage == ActiveRideStage.inTransit ? "$_currentSpeed km/h • ETA: $_etaMinutes mins" : "High Demand Area (+₹45 Surge)",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ],
                ),
                Text("$_rangeKm km EV Range", style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_hasIncomingRequest && _isOnline && (stage == ActiveRideStage.searching)) ...[
                _buildIncomingRequestCard(service),
              ],
              if (stage == ActiveRideStage.driverAssigned || stage == ActiveRideStage.headingToPickup || stage == ActiveRideStage.driverArrived) ...[
                _buildPinVerificationCard(service),
              ],
              if (stage == ActiveRideStage.inTransit) ...[
                _buildInTransitHudCard(service),
              ],
              if (stage == ActiveRideStage.reachedDestination || stage == ActiveRideStage.completed) ...[
                _buildPaymentSettlementCard(service, isBrokerDriver),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIncomingRequestCard(EnergoUnifiedService service) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF00E5FF), width: 1.5),
        boxShadow: [
          BoxShadow(color: const Color(0xFF00E5FF).withOpacity(0.25), blurRadius: 24, spreadRadius: 4),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFF00E5FF).withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                child: Row(
                  children: [
                    const Icon(Icons.flash_on, color: Color(0xFF00E5FF), size: 14),
                    const SizedBox(width: 4),
                    Text("NEW RIDE REQUEST (${_requestCountdown}s)", style: const TextStyle(color: Color(0xFF00E5FF), fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Text("₹${service.rideFare}", style: const TextStyle(color: Color(0xFF10B981), fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: _requestCountdown / 15.0,
            minHeight: 4,
            backgroundColor: Colors.white10,
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00E5FF)),
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              CircleAvatar(radius: 16, backgroundColor: Color(0xFF0284C7), child: Icon(Icons.person, color: Colors.white, size: 18)),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Anamika Choudhary", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                  Text("Rating: 4.9 ★ • Distance: 4.2 km", style: TextStyle(color: Colors.white54, fontSize: 10.5)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(children: [const Icon(Icons.my_location, color: Color(0xFF10B981), size: 14), const SizedBox(width: 8), Expanded(child: Text(service.pickupLocation, maxLines: 1, style: const TextStyle(color: Colors.white, fontSize: 11.5)))]),
          const SizedBox(height: 4),
          Row(children: [const Icon(Icons.location_on, color: Colors.redAccent, size: 14), const SizedBox(width: 8), Expanded(child: Text(service.dropLocation, maxLines: 1, style: const TextStyle(color: Colors.white, fontSize: 11.5)))]),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.white60, side: const BorderSide(color: Colors.white24), padding: const EdgeInsets.symmetric(vertical: 12)),
                  onPressed: _declineRide,
                  child: const Text("Decline"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  onPressed: _acceptIncomingRide,
                  child: const Text("ACCEPT RIDE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPinVerificationCard(EnergoUnifiedService service) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: const Color(0xFF111827), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF00E5FF))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Enter 4-Digit Passenger PIN to Start Trip:", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          TextField(
            controller: _pinController,
            keyboardType: TextInputType.number,
            maxLength: 4,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF00E5FF), fontSize: 24, letterSpacing: 8, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              hintText: "ENTER PIN",
              hintStyle: const TextStyle(color: Colors.white24, fontSize: 14, letterSpacing: 1),
              filled: true,
              fillColor: const Color(0xFF161F30),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white),
              onPressed: () => _verifyPinAndStartTrip(service),
              child: const Text("Verify PIN & Start Trip", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInTransitHudCard(EnergoUnifiedService service) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: const Color(0xFF111827), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF10B981))),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.navigation, color: Color(0xFF10B981), size: 28),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Turn Right in 200m", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                      Text("Outer Ring Road • Destination: ${service.dropLocation}", style: const TextStyle(color: Colors.white54, fontSize: 10.5)),
                    ],
                  ),
                ],
              ),
              Text("$_currentSpeed km/h", style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
              onPressed: () => service.updateRideStage(ActiveRideStage.reachedDestination),
              child: const Text("End Trip at Destination", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSettlementCard(EnergoUnifiedService service, bool isBrokerDriver) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: const Color(0xFF111827), borderRadius: BorderRadius.circular(20), border: Border.all(color: isBrokerDriver ? const Color(0xFF00E5FF) : const Color(0xFF10B981))),
      child: Column(
        children: [
          if (isBrokerDriver) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
              child: const Text("⚠️ STRICTLY NO CASH • BROKER FLEET POLICY", style: TextStyle(color: Colors.redAccent, fontSize: 10.5, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
            const Icon(Icons.qr_code_2, size: 100, color: Colors.white),
            Text("Broker Corporate QR: ${service.brokerCorporateUpi}", style: const TextStyle(color: Color(0xFF00E5FF), fontWeight: FontWeight.bold, fontSize: 12)),
            const SizedBox(height: 4),
            const Text("100% Fare settles to Broker Vault. Driver earns shift wage.", style: TextStyle(color: Colors.white54, fontSize: 10)),
          ] else ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
              child: const Text("🟢 CASH OR PERSONAL UPI ACCEPTED", style: TextStyle(color: Color(0xFF10B981), fontSize: 10.5, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
            const Icon(Icons.qr_code, size: 100, color: Colors.white),
            Text("Solo UPI: ${service.soloPersonalUpi}", style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 12)),
          ],
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white),
              onPressed: () => _completeAndSettleRide(service, isBrokerDriver),
              child: const Text("Confirm Payment & Close Trip", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }

  // TAB 2: EV TELEMETRY & 4 SUPERHUB PASSES
  Widget _buildEvTelemetryAndHubPassTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFF161F30), borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.white10)),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("${_batterySoc.toInt()}% SoC", style: const TextStyle(color: Color(0xFF10B981), fontSize: 28, fontWeight: FontWeight.bold)),
                    Text("$_rangeKm km Range", style: const TextStyle(color: Color(0xFF00E5FF), fontSize: 24, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(value: _batterySoc / 100, minHeight: 8, backgroundColor: Colors.white10, valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981))),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Health: $_batteryHealth% SOH", style: const TextStyle(color: Colors.white70, fontSize: 11)),
                    Text("Tires: $_tirePsi PSI (All 4 OK)", style: const TextStyle(color: Colors.white70, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text("SuperHub Amenities (1-Tap Driver Access)", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildHubPassItem("Fast DC Port Reservation", "CCS2 180kW Express Port at Central SuperHub", Icons.bolt, const Color(0xFF00E5FF)),
          _buildHubPassItem("IoT Parking Bay Express Pass", "Ultrasonic Barrier Auto-Lowering on Plate Detect", Icons.local_parking, const Color(0xFF10B981)),
          _buildHubPassItem("Snooze Pod Rest Booking", "30-min Sanitized AC Power Nap Pod", Icons.bed, const Color(0xFFEC4899)),
          _buildHubPassItem("5G Lounge & Meal Pass", "Free High-Speed WiFi & Subsidized Driver Meal", Icons.coffee, const Color(0xFFFFD54F)),
        ],
      ),
    );
  }

  Widget _buildHubPassItem(String title, String sub, IconData icon, Color col) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFF161F30), borderRadius: BorderRadius.circular(14), border: Border.all(color: col.withOpacity(0.3))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: col.withOpacity(0.15), shape: BoxShape.circle), child: Icon(icon, color: col, size: 20)),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12.5)),
                  Text(sub, style: const TextStyle(color: Colors.white54, fontSize: 10)),
                ],
              ),
            ],
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: col, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4)),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("✅ $title Unlocked at Nearest Hub!"), backgroundColor: col));
            },
            child: const Text("1-Tap Pass", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10.5)),
          ),
        ],
      ),
    );
  }

  // TAB 3: EARNINGS
  Widget _buildEarningsTab(EnergoUnifiedService service, bool isBrokerDriver) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: const Color(0xFF161F30), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white10)),
            child: Column(
              children: [
                Text(isBrokerDriver ? "Shift Wage Accrued" : "Today's Solo Wallet", style: const TextStyle(color: Colors.white54, fontSize: 12)),
                const SizedBox(height: 6),
                Text(
                  isBrokerDriver ? "₹${service.brokerDriverAccruedSalary.toStringAsFixed(2)}" : "₹${service.soloDriverWallet.toStringAsFixed(2)}",
                  style: const TextStyle(color: Color(0xFFFFD54F), fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0284C7), foregroundColor: Colors.white),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(isBrokerDriver ? "🏢 Salary auto-credited on 1st & 15th." : "✅ Razorpay Instant Transfer initiated!"), backgroundColor: const Color(0xFF0284C7)),
                    );
                  },
                  child: Text(isBrokerDriver ? "View Salary Ledger" : "Instant Bank Payout"),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatMini(title: "Completed Trips", val: "8"),
              _StatMini(title: "Online Hours", val: "5.4 hrs"),
              _StatMini(title: "Acceptance Rate", val: "96%"),
            ],
          ),
        ],
      ),
    );
  }

  // TAB 4: TRIPS HISTORY
  Widget _buildTripsHistoryTab(EnergoUnifiedService service) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildHistoryItem("TRIP-9842", "Anamika Choudhary (4.9★)", "₹480.00", "Saket -> Central SuperHub"),
        _buildHistoryItem("TRIP-9841", "Rohit Verma (4.8★)", "₹320.00", "Cyber Hub -> TechPark MegaHub"),
        _buildHistoryItem("TRIP-9840", "Kavita Rao (5.0★)", "₹290.00", "Connaught Place -> Airport T3"),
      ],
    );
  }

  Widget _buildHistoryItem(String id, String rider, String fare, String route) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFF161F30), borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(id, style: const TextStyle(color: Color(0xFF00E5FF), fontWeight: FontWeight.bold, fontSize: 12)),
              Text(fare, style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 15)),
            ],
          ),
          const SizedBox(height: 6),
          Text(rider, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
          Text(route, style: const TextStyle(color: Colors.white54, fontSize: 11)),
        ],
      ),
    );
  }

  // TAB 5: KYC & PROFILE
  Widget _buildProfileKycTab(EnergoUnifiedService service, bool isBrokerDriver) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: const Color(0xFF00E5FF).withOpacity(0.2),
            child: const Icon(Icons.person, color: Color(0xFF00E5FF), size: 40),
          ),
          const SizedBox(height: 10),
          Text(service.driverName, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          Text(isBrokerDriver ? "🏢 ${service.brokerCompanyName}" : "🚕 Independent Solo Driver", style: const TextStyle(color: Colors.white54, fontSize: 12)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.15), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFF10B981))),
            child: const Row(
              children: [
                Icon(Icons.verified, color: Color(0xFF10B981), size: 24),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("KYC VERIFIED & APPROVED ✅", style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 13)),
                    Text("Commercial DL, RC & Police Clearance Verified", style: TextStyle(color: Colors.white70, fontSize: 10.5)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatMini extends StatelessWidget {
  final String title;
  final String val;

  const _StatMini({required this.title, required this.val});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFF161F30), borderRadius: BorderRadius.circular(14)),
      child: Column(
        children: [
          Text(val, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 2),
          Text(title, style: const TextStyle(color: Colors.white38, fontSize: 10)),
        ],
      ),
    );
  }
}