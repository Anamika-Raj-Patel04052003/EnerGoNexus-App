import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/energo_unified_service.dart';
import 'driver_active_ride_screen.dart';

class DriverDashboardScreen extends StatefulWidget {
  const DriverDashboardScreen({super.key});

  @override
  State<DriverDashboardScreen> createState() => _DriverDashboardScreenState();
}

class _DriverDashboardScreenState extends State<DriverDashboardScreen> with SingleTickerProviderStateMixin {
  bool _isOnline = true;
  bool _hasIncomingRequest = true;
  int _requestCountdown = 15;
  Timer? _requestTimer;
  Timer? _radarPulseTimer;
  double _radarRadius = 0.4;

  // ⚡ EV TELEMETRY DATA
  final double _batterySoc = 84.0; // 84%
  final int _rangeKm = 265; // 265 km remaining
  final double _batteryHealth = 98.5; // 98.5% SOH
  final double _efficiencyKwh = 13.8; // 13.8 kWh/100km
  final int _tirePsi = 33; // 33 PSI All OK

  @override
  void initState() {
    super.initState();
    _startCountdownTimer();
    _radarPulseTimer = Timer.periodic(const Duration(milliseconds: 800), (timer) {
      if (!mounted) return;
      setState(() {
        _radarRadius = _radarRadius == 0.4 ? 1.0 : 0.4;
      });
    });
  }

  void _startCountdownTimer() {
    _requestCountdown = 15;
    _requestTimer?.cancel();
    _requestTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_requestCountdown > 1) {
        setState(() => _requestCountdown--);
      } else {
        timer.cancel();
        setState(() => _hasIncomingRequest = false);
      }
    });
  }

  @override
  void dispose() {
    _requestTimer?.cancel();
    _radarPulseTimer?.cancel();
    super.dispose();
  }

  void _acceptRide() {
    _requestTimer?.cancel();
    setState(() => _hasIncomingRequest = false);

    final service = EnergoUnifiedService();
    service.updateRideStage(ActiveRideStage.driverAssigned);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (ctx) => const DriverActiveRideScreen()),
    );
  }

  void _rejectRide() {
    _requestTimer?.cancel();
    setState(() => _hasIncomingRequest = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Ride declined. Searching next nearby passenger..."), backgroundColor: Colors.white24),
    );
  }

  void _showFacilityBookingDialog(String title, String subtitle, IconData icon, Color color) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF161F30),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: color.withOpacity(0.5))),
        title: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 10),
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
              child: const Row(
                children: [
                  Icon(Icons.location_on, color: Color(0xFF00E5FF), size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text("Nearest Hub: EnerGo Central SuperHub (1.4 km)", style: TextStyle(color: Colors.white, fontSize: 11.5)),
                  )
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel", style: TextStyle(color: Colors.white54))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.black),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("✅ $title Pass Issued! Barrier/Port Access unlocked."), backgroundColor: color),
              );
            },
            child: const Text("Confirm 1-Tap Pass", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
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
                      backgroundColor: const Color(0xFF00E5FF).withOpacity(0.2),
                      child: const Icon(Icons.person, color: Color(0xFF00E5FF), size: 22),
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
                      isBrokerDriver ? "🏢 ${service.brokerCompanyName} • Fleet EV" : "🚕 Solo Independent • DL 01 EV 4891",
                      style: const TextStyle(color: Colors.white54, fontSize: 10.5),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              // ONLINE / OFFLINE TOGGLE
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
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. 🌟 LIVE RADAR & GOOGLE MAPS HOTSPOT VISUALIZER
                _buildLiveGpsRadarCard(),
                const SizedBox(height: 16),

                // 2. ⚡ EV TELEMETRY COCKPIT (BATTERY / RANGE / HEALTH)
                _buildEvTelemetryCard(),
                const SizedBox(height: 16),

                // 3. 🔔 INCOMING RIDE REQUEST RADAR (IF ACTIVE)
                if (_hasIncomingRequest && _isOnline) ...[
                  _buildIncomingRideRequestCard(service),
                  const SizedBox(height: 16),
                ],

                // 4. 🏢 4 SUPERHUB AMENITIES QUICK ACCESS
                _buildSuperHubFacilitiesGrid(),
                const SizedBox(height: 16),

                // 5. 💰 EARNINGS & SHIFT SUMMARY
                _buildEarningsShiftSummary(service, isBrokerDriver),
              ],
            ),
          ),
        );
      },
    );
  }

  // 1. LIVE GPS RADAR
  Widget _buildLiveGpsRadarCard() {
    return Container(
      height: 160,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF161F30),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.3)),
        image: const DecorationImage(
          image: NetworkImage("https://maps.googleapis.com/maps/api/staticmap?center=28.6139,77.2090&zoom=14&size=600x200&maptype=roadmap&style=element:geometry%7Ccolor:0x212121&style=element:labels.text.stroke%7Ccolor:0x212121&style=element:labels.text.fill%7Ccolor:0x757575&key=AIzaSyDp3mkbKShGs1ZHGrQ8By3sDquvoTaymzs"),
          fit: BoxFit.cover,
          opacity: 0.35,
        ),
      ),
      child: Stack(
        children: [
          // RADAR ANIMATION AT CENTER
          Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 800),
              width: 80 * _radarRadius,
              height: 80 * _radarRadius,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF00E5FF).withOpacity(0.15),
                border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.5), width: 1.5),
              ),
            ),
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: Color(0xFF00E5FF), shape: BoxShape.circle),
              child: const Icon(Icons.navigation, color: Colors.black, size: 18),
            ),
          ),
          // TOP STATUS PILL
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.7), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white24)),
              child: const Row(
                children: [
                  Icon(Icons.radar, color: Color(0xFF00E5FF), size: 14),
                  SizedBox(width: 6),
                  Text("High Passenger Demand Area • Connaught Place", style: TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          // BOTTOM SPEED / GPS
          Positioned(
            bottom: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: const Color(0xFF111827), borderRadius: BorderRadius.circular(8)),
              child: const Text("GPS: 28.6139° N, 77.2090° E • 0 km/h", style: TextStyle(color: Color(0xFF38BDF8), fontSize: 9.5, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

  // 2. EV TELEMETRY CARD
  Widget _buildEvTelemetryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161F30),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.bolt, color: Color(0xFF10B981), size: 20),
                  SizedBox(width: 6),
                  Text("EV Smart Telemetry & Range", style: TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.bold)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                child: const Text("BATTERY HEALTHY", style: TextStyle(color: Color(0xFF10B981), fontSize: 9.5, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // SOC BAR & RANGE
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("${_batterySoc.toInt()}%", style: const TextStyle(color: Color(0xFF10B981), fontSize: 26, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              const Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Text("SoC Charge", style: TextStyle(color: Colors.white54, fontSize: 11)),
              ),
              const Spacer(),
              Text("$_rangeKm km", style: const TextStyle(color: Color(0xFF00E5FF), fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(width: 6),
              const Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Text("Est. Range", style: TextStyle(color: Colors.white54, fontSize: 11)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: _batterySoc / 100,
              minHeight: 8,
              backgroundColor: Colors.white10,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
            ),
          ),
          const SizedBox(height: 12),
          // 3 SUB-STATS
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTelemetryMini("Battery Health", "${_batteryHealth}% SOH", Icons.favorite, Colors.redAccent),
              _buildTelemetryMini("Efficiency", "$_efficiencyKwh kWh/100k", Icons.energy_savings_leaf, Colors.green),
              _buildTelemetryMini("Tire Pressure", "$_tirePsi PSI (All 4)", Icons.tire_repair, Colors.amber),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildTelemetryMini(String label, String value, IconData icon, Color col) {
    return Row(
      children: [
        Icon(icon, color: col, size: 14),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(color: Colors.white38, fontSize: 9)),
          ],
        )
      ],
    );
  }

  // 3. 🔔 15-SECOND INCOMING RIDE REQUEST
  Widget _buildIncomingRideRequestCard(EnergoUnifiedService service) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF00E5FF), width: 1.5),
        boxShadow: [
          BoxShadow(color: const Color(0xFF00E5FF).withOpacity(0.2), blurRadius: 20, spreadRadius: 2),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER WITH COUNTDOWN
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
              Text("₹${service.rideFare}", style: const TextStyle(color: Color(0xFF10B981), fontSize: 22, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _requestCountdown / 15.0,
              minHeight: 4,
              backgroundColor: Colors.white10,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00E5FF)),
            ),
          ),
          const SizedBox(height: 12),
          // PASSENGER INFO
          Row(
            children: [
              const CircleAvatar(
                radius: 16,
                backgroundColor: Color(0xFF0284C7),
                child: Icon(Icons.person, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Anamika Choudhary", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                  Text("Rating: 4.9 ★ • Premium EV Rider", style: TextStyle(color: Colors.white54, fontSize: 10.5)),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
                child: const Text("Distance: 4.2 km", style: TextStyle(color: Colors.white70, fontSize: 10.5, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // LOCATIONS
          Row(
            children: [
              const Icon(Icons.my_location, color: Color(0xFF10B981), size: 15),
              const SizedBox(width: 8),
              Expanded(child: Text(service.pickupLocation, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 12))),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.redAccent, size: 15),
              const SizedBox(width: 8),
              Expanded(child: Text(service.dropLocation, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 12))),
            ],
          ),
          const SizedBox(height: 16),
          // ACTION BUTTONS
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white60,
                    side: const BorderSide(color: Colors.white24),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: _rejectRide,
                  child: const Text("Decline"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: _acceptRide,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, size: 16),
                      SizedBox(width: 6),
                      Text("ACCEPT RIDE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  // 4. SUPERHUB FACILITIES
  Widget _buildSuperHubFacilitiesGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("SuperHub Amenities (1-Tap Driver Access)", style: TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Row(
          children: [
            _buildFacilityItem("Fast DC Port", "CCS2 180kW Express", Icons.bolt, const Color(0xFF00E5FF), () {
              _showFacilityBookingDialog("Fast DC Charger Reserve", "Slot reserved at Port DC-02 with auto-smart queuing.", Icons.bolt, const Color(0xFF00E5FF));
            }),
            const SizedBox(width: 10),
            _buildFacilityItem("Parking Bay", "IoT Ultrasonic Bay", Icons.local_parking, const Color(0xFF10B981), () {
              _showFacilityBookingDialog("IoT Parking Bay Pass", "Bay A2 barrier will auto-lower upon vehicle plate detection.", Icons.local_parking, const Color(0xFF10B981));
            }),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _buildFacilityItem("Snooze Pod", "Power Nap Pod #03", Icons.bed, const Color(0xFFEC4899), () {
              _showFacilityBookingDialog("Snooze Pod Reservation", "30-min AC power nap pod unlocked with sanitized bedding.", Icons.bed, const Color(0xFFEC4899));
            }),
            const SizedBox(width: 10),
            _buildFacilityItem("5G Lounge", "Free WiFi & Cafe", Icons.coffee, const Color(0xFFFFD54F), () {
              _showFacilityBookingDialog("5G Driver Lounge Pass", "Free high-speed WiFi access & subsidized EV driver meal coupon.", Icons.coffee, const Color(0xFFFFD54F));
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildFacilityItem(String title, String sub, IconData icon, Color col, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF161F30),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: col.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: col.withOpacity(0.15), shape: BoxShape.circle),
                child: Icon(icon, color: col, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11.5)),
                    Text(sub, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white54, fontSize: 9)),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // 5. EARNINGS & SHIFT SUMMARY
  Widget _buildEarningsShiftSummary(EnergoUnifiedService service, bool isBrokerDriver) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF161F30), borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.white10)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(isBrokerDriver ? "Shift Wage Accrued" : "Today's Net Solo Wallet", style: const TextStyle(color: Colors.white54, fontSize: 11)),
                  const SizedBox(height: 4),
                  Text(
                    isBrokerDriver ? "₹${service.brokerDriverAccruedSalary.toStringAsFixed(2)}" : "₹${service.soloDriverWallet.toStringAsFixed(2)}",
                    style: const TextStyle(color: Color(0xFFFFD54F), fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0284C7), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                icon: const Icon(Icons.account_balance_wallet, size: 14),
                label: Text(isBrokerDriver ? "Salary Ledger" : "Instant Payout", style: const TextStyle(fontSize: 11)),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isBrokerDriver ? "🏢 Salary auto-credited by ${service.brokerCompanyName} every 1st & 15th." : "✅ Razorpay Instant Transfer initiated to your linked Bank A/c."),
                      backgroundColor: const Color(0xFF0284C7),
                    ),
                  );
                },
              ),
            ],
          ),
          const Divider(color: Colors.white10, height: 20),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _ShiftStat(title: "Trips Completed", value: "8"),
              _ShiftStat(title: "Online Hours", value: "5.4 hrs"),
              _ShiftStat(title: "Acceptance Rate", value: "96%"),
            ],
          ),
        ],
      ),
    );
  }
}

class _ShiftStat extends StatelessWidget {
  final String title;
  final String value;
  const _ShiftStat({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 2),
        Text(title, style: const TextStyle(color: Colors.white38, fontSize: 10)),
      ],
    );
  }
}