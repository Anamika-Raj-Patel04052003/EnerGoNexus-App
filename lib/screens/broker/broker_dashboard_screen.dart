import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/energo_unified_service.dart';

class BrokerDashboardScreen extends StatefulWidget {
  final String brokerName;
  final String companyName;

  const BrokerDashboardScreen({
    super.key,
    this.brokerName = "Vikramaditya Singhania",
    this.companyName = "BluSmart Fleet Mobility Ltd.",
  });

  @override
  State<BrokerDashboardScreen> createState() => _BrokerDashboardScreenState();
}

class _BrokerDashboardScreenState extends State<BrokerDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Timer? _telemetryTimer;

  // 💰 BROKER CENTRAL VAULT STATS
  double _centralVaultBalance = 148520.00;
  double _todayGrossRevenue = 18450.00;
  double _accruedDriverWages = 6200.00;
  int _activeCarsOnline = 18;
  int _totalFleetCars = 24;

  // 🚗 LIVE FLEET EV TELEMETRY ROSTER
  final List<Map<String, dynamic>> _fleetVehicles = [
    {
      'plate': 'DL 01 EV 4891',
      'model': 'Tata Nexon EV Max',
      'driver': 'Rahul Sharma',
      'status': 'IN_TRANSIT',
      'soc': 82,
      'range': 265,
      'speed': '38 km/h',
      'trip': 'Airport Drop • ₹480',
      'health': '99% SOH',
    },
    {
      'plate': 'DL 04 EF 1122',
      'model': 'MG ZS EV Long Range',
      'driver': 'Sunil Verma',
      'status': 'CHARGING',
      'soc': 45,
      'range': 180,
      'speed': '0 km/h',
      'trip': 'Central SuperHub (Port DC-02)',
      'health': '98% SOH',
    },
    {
      'plate': 'HR 26 EV 8899',
      'model': 'Mahindra XUV400 EL',
      'driver': 'Amit Kumar',
      'status': 'IN_TRANSIT',
      'soc': 64,
      'range': 210,
      'speed': '44 km/h',
      'trip': 'TechPark Shuttle • ₹320',
      'health': '97% SOH',
    },
    {
      'plate': 'UP 16 EV 3344',
      'model': 'Hyundai Kona EV',
      'driver': 'Vikram Singh',
      'status': 'STANDBY',
      'soc': 94,
      'range': 310,
      'speed': '0 km/h',
      'trip': 'Idle at Connaught Place Hotspot',
      'health': '100% SOH',
    },
    {
      'plate': 'DL 08 BK 7741',
      'model': 'Tata Tiago EV',
      'driver': 'Rajesh Patel',
      'status': 'IN_TRANSIT',
      'soc': 52,
      'range': 140,
      'speed': '28 km/h',
      'trip': 'Express Delivery • ₹210',
      'health': '96% SOH',
    },
  ];

  // 👥 FLEET DRIVERS & WAGE LEDGER
  final List<Map<String, dynamic>> _fleetDrivers = [
    {'name': 'Rahul Sharma', 'phone': '+91 98112 44331', 'pin': '7842', 'trips': 7, 'wage': 1450.0, 'status': 'PAID_TODAY', 'rating': 4.9},
    {'name': 'Sunil Verma', 'phone': '+91 98223 55442', 'pin': '1122', 'trips': 9, 'wage': 1850.0, 'status': 'PENDING_PAYOUT', 'rating': 4.8},
    {'name': 'Amit Kumar', 'phone': '+91 98334 66553', 'pin': '3344', 'trips': 6, 'wage': 1200.0, 'status': 'PENDING_PAYOUT', 'rating': 4.9},
    {'name': 'Vikram Singh', 'phone': '+91 98445 77664', 'pin': '5566', 'trips': 5, 'wage': 1050.0, 'status': 'PENDING_PAYOUT', 'rating': 4.7},
    {'name': 'Rajesh Patel', 'phone': '+91 98556 88775', 'pin': '9900', 'trips': 4, 'wage': 850.0, 'status': 'PAID_TODAY', 'rating': 4.8},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _telemetryTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) return;
      setState(() {
        _centralVaultBalance += (DateTime.now().second % 3 == 0) ? 12.50 : 0.0;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _telemetryTimer?.cancel();
    super.dispose();
  }

  // 1-TAP DISBURSE ALL SALARIES VIA NPCI/RAZORPAY
  void _disburseAllWages() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF161F30),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: const BorderSide(color: Color(0xFF00E5FF))),
        title: const Row(
          children: [
            Icon(Icons.payments, color: Color(0xFF10B981), size: 24),
            SizedBox(width: 10),
            Text("1-Tap Driver Payroll", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Disburse all accrued daily wages to active fleet drivers via Razorpay / NPCI UPI Auto-Payroll?", style: TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(10)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Total Payout Amount:", style: TextStyle(color: Colors.white54, fontSize: 12)),
                  Text("₹${_accruedDriverWages.toStringAsFixed(2)}", style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel", style: TextStyle(color: Colors.white54))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.black),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _centralVaultBalance -= _accruedDriverWages;
                _accruedDriverWages = 0.0;
                for (var d in _fleetDrivers) {
                  d['status'] = 'PAID_TODAY';
                }
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("✅ ₹6,200 Disbursed to all 5 Fleet Drivers successfully!"), backgroundColor: Color(0xFF10B981)),
              );
            },
            child: const Text("Confirm & Transfer", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _paySingleDriver(int index) {
    setState(() {
      _fleetDrivers[index]['status'] = 'PAID_TODAY';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("✅ ₹${_fleetDrivers[index]['wage']} paid to ${_fleetDrivers[index]['name']}!"),
        backgroundColor: const Color(0xFF10B981),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E17),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111827),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(color: Color(0xFF00E5FF), shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Text(widget.companyName, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
              ],
            ),
            Text("Broker: ${widget.brokerName} • Enterprise ERP", style: const TextStyle(color: Colors.white54, fontSize: 11)),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12, top: 10, bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF10B981)),
            ),
            child: const Row(
              children: [
                Icon(Icons.shield_outlined, color: Color(0xFF10B981), size: 14),
                SizedBox(width: 4),
                Text("KYC APPROVED", style: TextStyle(color: Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
          )
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF00E5FF),
          indicatorWeight: 3,
          labelColor: const Color(0xFF00E5FF),
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
          tabs: const [
            Tab(icon: Icon(Icons.speed, size: 17), text: "Fleet Telemetry"),
            Tab(icon: Icon(Icons.people_alt_outlined, size: 17), text: "Driver Roster"),
            Tab(icon: Icon(Icons.alt_route, size: 17), text: "Live Trips"),
            Tab(icon: Icon(Icons.build_circle_outlined, size: 17), text: "EV Health"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFleetTelemetryTab(),
          _buildDriverRosterTab(),
          _buildLiveTripsTab(),
          _buildEvHealthTab(),
        ],
      ),
    );
  }

  // TAB 1: FLEET TELEMETRY & VAULT HERO
  Widget _buildFleetTelemetryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 💰 CENTRAL VAULT HERO CARD
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF162544), Color(0xFF0F172A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.4)),
              boxShadow: [
                BoxShadow(color: const Color(0xFF00E5FF).withOpacity(0.1), blurRadius: 20, spreadRadius: 2),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.account_balance, color: Color(0xFF00E5FF), size: 18),
                        SizedBox(width: 8),
                        Text("Broker Corporate Vault (100% Fare Inflow)", style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
                      child: const Text("NO CASH ALLOWED", style: TextStyle(color: Colors.redAccent, fontSize: 9.5, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("₹${_centralVaultBalance.toStringAsFixed(2)}", style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      icon: const Icon(Icons.flash_on, size: 16),
                      label: const Text("1-Tap Wage Payout", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      onPressed: _disburseAllWages,
                    ),
                  ],
                ),
                const Divider(color: Colors.white12, height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildVaultMini("Today's Gross", "₹${_todayGrossRevenue.toStringAsFixed(0)}", const Color(0xFF10B981)),
                    _buildVaultMini("Pending Wages", "₹${_accruedDriverWages.toStringAsFixed(0)}", const Color(0xFFFFD54F)),
                    _buildVaultMini("Active Online", "$_activeCarsOnline / $_totalFleetCars EVs", const Color(0xFF00E5FF)),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 🗺️ LIVE FLEET GPS SATELLITE RADAR
          Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF161F30),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white10),
              image: const DecorationImage(
                image: NetworkImage("https://maps.googleapis.com/maps/api/staticmap?center=28.6139,77.2090&zoom=13&size=600x200&maptype=roadmap&style=element:geometry%7Ccolor:0x212121&style=element:labels.text.stroke%7Ccolor:0x212121&style=element:labels.text.fill%7Ccolor:0x757575&key=AIzaSyDp3mkbKShGs1ZHGrQ8By3sDquvoTaymzs"),
                fit: BoxFit.cover,
                opacity: 0.4,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Colors.black.withOpacity(0.7), borderRadius: BorderRadius.circular(20)),
                    child: const Row(
                      children: [
                        Icon(Icons.radar, color: Color(0xFF00E5FF), size: 14),
                        SizedBox(width: 6),
                        Text("Live 24 Fleet EV Radar • National Capital Region", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (i) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(color: Color(0xFF00E5FF), shape: BoxShape.circle),
                      child: const Icon(Icons.electric_car, color: Colors.black, size: 16),
                    )),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 🚗 FLEET CARS ROSTER
          const Text("Assigned Fleet Electric Vehicles", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ..._fleetVehicles.map((car) => _buildVehicleItem(car)),
        ],
      ),
    );
  }

  Widget _buildVaultMini(String label, String val, Color col) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(val, style: TextStyle(color: col, fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10)),
      ],
    );
  }

  Widget _buildVehicleItem(Map<String, dynamic> car) {
    final status = car['status'] as String;
    final isTransit = status == 'IN_TRANSIT';
    final isCharging = status == 'CHARGING';
    final col = isTransit ? const Color(0xFF10B981) : (isCharging ? const Color(0xFF00E5FF) : Colors.amber);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF161F30),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: col.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: col.withOpacity(0.15), shape: BoxShape.circle),
                    child: Icon(Icons.electric_car, color: col, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${car['plate']} • ${car['model']}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12.5)),
                      Text("Driver: ${car['driver']} | ${car['speed']}", style: const TextStyle(color: Colors.white54, fontSize: 10.5)),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: col.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                child: Text(status.replaceAll('_', ' '), style: TextStyle(color: col, fontWeight: FontWeight.bold, fontSize: 9.5)),
              ),
            ],
          ),
          const Divider(color: Colors.white10, height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(car['trip'], style: const TextStyle(color: Colors.white70, fontSize: 11)),
              Row(
                children: [
                  Text("SoC: ${car['soc']}%", style: TextStyle(color: col, fontWeight: FontWeight.bold, fontSize: 11)),
                  const SizedBox(width: 8),
                  Text("(${car['range']} km)", style: const TextStyle(color: Colors.white38, fontSize: 10)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // TAB 2: DRIVER ROSTER & WAGES
  Widget _buildDriverRosterTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _fleetDrivers.length,
      itemBuilder: (ctx, i) {
        final d = _fleetDrivers[i];
        final isPaid = d['status'] == 'PAID_TODAY';

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF161F30),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color(0xFF0284C7).withOpacity(0.2),
                    child: const Icon(Icons.person, color: Color(0xFF00E5FF), size: 22),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${d['name']} (${d['rating']}★)", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 2),
                      Text("PIN: ${d['pin']} • ${d['phone']}", style: const TextStyle(color: Colors.white54, fontSize: 10.5)),
                      Text("Today: ${d['trips']} Trips | Wage: ₹${d['wage']}", style: const TextStyle(color: Color(0xFFFFD54F), fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isPaid ? Colors.white10 : const Color(0xFF10B981),
                  foregroundColor: isPaid ? Colors.white54 : Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: isPaid ? null : () => _paySingleDriver(i),
                child: Text(isPaid ? "PAID" : "Pay ₹${d['wage'].toInt()}", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    );
  }

  // TAB 3: LIVE TRIPS
  Widget _buildLiveTripsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildTripCard("TRIP-9842", "Rahul Sharma", "Anamika Choudhary (4.9★)", "DL 01 EV 4891", "₹480.00", "Corporate QR #TXy-881", "IN PROGRESS"),
        _buildTripCard("TRIP-9841", "Amit Kumar", "Rohit Verma (4.8★)", "HR 26 EV 8899", "₹320.00", "Corporate QR #TXy-880", "IN PROGRESS"),
        _buildTripCard("TRIP-9840", "Sunil Verma", "Kavita Rao (5.0★)", "DL 04 EF 1122", "₹290.00", "Corporate QR #TXy-879", "COMPLETED"),
      ],
    );
  }

  Widget _buildTripCard(String id, String driver, String rider, String car, String fare, String qrId, String status) {
    final isProg = status == "IN PROGRESS";
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF161F30),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isProg ? const Color(0xFF10B981).withOpacity(0.4) : Colors.white10),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(id, style: const TextStyle(color: Color(0xFF00E5FF), fontWeight: FontWeight.bold, fontSize: 12)),
              Text(fare, style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 15)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Driver: $driver ($car)", style: const TextStyle(color: Colors.white, fontSize: 11)),
              Text("Rider: $rider", style: const TextStyle(color: Colors.white70, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(qrId, style: const TextStyle(color: Colors.white38, fontSize: 10)),
              Text(status, style: TextStyle(color: isProg ? const Color(0xFF10B981) : Colors.white54, fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  // TAB 4: EV HEALTH
  Widget _buildEvHealthTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _fleetVehicles.length,
      itemBuilder: (ctx, i) {
        final car = _fleetVehicles[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: const Color(0xFF161F30), borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white10)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.health_and_safety, color: Color(0xFF10B981), size: 24),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${car['plate']} • ${car['model']}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12.5)),
                      Text("State of Health: ${car['health']} | Tire: 33 PSI OK", style: const TextStyle(color: Colors.white54, fontSize: 10.5)),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                child: const Text("SERVICE OK", style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 9.5)),
              )
            ],
          ),
        );
      },
    );
  }
}