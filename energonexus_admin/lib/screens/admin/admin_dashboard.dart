import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/api_config.dart';
import '../auth/admin_login_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> with TickerProviderStateMixin {
  late TabController _tabCtrl;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;
  late AnimationController _radarCtrl;
  late AnimationController _flowCtrl;

  String _adminName = "Operations Admin";
  String _adminEmail = "admin@energonexus.com";
  String _searchQuery = "";
  String _dispatchFilter = "all";
  String _currentTime = "";
  Timer? _clockTimer;

  // Cyber MNC Palette
  static const Color bgPrimary = Color(0xFF060B14);
  static const Color bgCard = Color(0xFF0F172A);
  static const Color bgCardHover = Color(0xFF1E293B);
  static const Color accentCyan = Color(0xFF00F0FF);
  static const Color accentGreen = Color(0xFF00E676);
  static const Color accentPurple = Color(0xFFA855F7);
  static const Color accentYellow = Color(0xFFFFB703);
  static const Color accentOrange = Color(0xFFFF6D00);
  static const Color accentRed = Color(0xFFFF3366);
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);

  // 1. LIVE DISPATCH DATA
  final List<Map<String, dynamic>> _liveDispatches = [
    {
      'id': 'RD-9021',
      'type': 'ride',
      'passenger_name': 'Rohan Sharma',
      'passenger_phone': '+91 98234 11209',
      'pickup': 'Zone 1, MP Nagar, Bhopal',
      'dropoff': 'Raja Bhoj Airport, Bhopal',
      'fare': 420,
      'status': 'IN_TRANSIT',
      'driver_name': 'Suresh Verma',
      'driver_phone': '+91 98765 43210',
      'vehicle_model': 'Tata Nexon EV Max',
      'plate_number': 'MP 04 EV 8891',
      'driver_rating': 4.9,
      'eta': '8 mins',
      'payment_mode': 'UPI Online (Prepaid)',
      'progress': 0.68,
    },
    {
      'id': 'RD-9022',
      'type': 'ride',
      'passenger_name': 'Pooja Verma',
      'passenger_phone': '+91 98112 33445',
      'pickup': 'New Market, TT Nagar, Bhopal',
      'dropoff': 'Bhopal Junction Railway Station',
      'fare': 190,
      'status': 'MATCHING_DRIVER',
      'driver_name': 'Scanning Nearest EV Fleet...',
      'driver_phone': 'N/A',
      'vehicle_model': 'EV Sedan Category',
      'plate_number': 'Pending Match',
      'driver_rating': 0.0,
      'eta': 'Auto-Dispatching',
      'payment_mode': 'Cash on Trip End',
      'progress': 0.15,
    },
    {
      'id': 'PR-4011',
      'type': 'parcel',
      'sender_name': 'Nexus Electronics Ltd',
      'sender_phone': '+91 98990 01122',
      'pickup': 'Govindpura Industrial Area',
      'dropoff': 'Arera Colony E-7, Bhopal',
      'parcel_type': 'EV Battery Spare Part (4.2 kg)',
      'fare': 260,
      'status': 'DISPATCHED',
      'driver_name': 'Aakash Courier Partner',
      'driver_phone': '+91 98123 99887',
      'vehicle_model': 'Ather 450X EV Cargo',
      'plate_number': 'MP 04 EV 1024',
      'driver_rating': 4.8,
      'otp': '7842',
      'payment_mode': 'Prepaid Corporate Account',
      'progress': 0.45,
    },
  ];

  // 2. DRIVER KYC PIPELINE
  final List<Map<String, dynamic>> _pendingDrivers = [
    {
      'id': 'DRV-101',
      'driver_name': 'Vikramaditya Singh',
      'mobile': '9823456789',
      'email': 'vikram.ev@gmail.com',
      'aadhaar_no': '4512 8890 2234',
      'license_no': 'DL-MP-2024-99882',
      'license_expiry': '2032-11-15',
      'vehicle_model': 'Tata Tigor EV FastCharge',
      'plate_number': 'MP 04 EV 7741',
      'battery_kwh': '26.0 kWh',
      'insurance_valid_upto': '2027-08-30',
      'experience': '4 Years Commercial EV',
    },
    {
      'id': 'DRV-102',
      'driver_name': 'Mohammad Imran',
      'mobile': '9812345670',
      'email': 'imran.cabs@gmail.com',
      'aadhaar_no': '8892 1102 9945',
      'license_no': 'DL-MP-2023-44102',
      'license_expiry': '2030-05-10',
      'vehicle_model': 'Mahindra XUV400 EV',
      'plate_number': 'MP 04 EV 3320',
      'battery_kwh': '39.4 kWh',
      'insurance_valid_upto': '2026-12-31',
      'experience': '2 Years Fleet Delivery',
    },
  ];

  final List<Map<String, dynamic>> _verifiedDrivers = [
    {'name': 'Suresh Verma', 'phone': '+91 98765 43210', 'vehicle': 'Tata Nexon EV Max (MP 04 EV 8891)', 'status': 'ON_TRIP', 'rating': 4.9, 'rides': 342, 'wallet': '₹ 4,820'},
    {'name': 'Aakash Partner', 'phone': '+91 98123 99887', 'vehicle': 'Ather 450X Cargo (MP 04 EV 1024)', 'status': 'DISPATCHING', 'rating': 4.8, 'rides': 512, 'wallet': '₹ 6,190'},
    {'name': 'Deepak Rajput', 'phone': '+91 98450 11223', 'vehicle': 'MG ZS EV Exclusive (MP 04 EV 5501)', 'status': 'CHARGING_AT_HUB', 'rating': 5.0, 'rides': 189, 'wallet': '₹ 3,400'},
  ];

  // 3. MULTI-CITY SUPERHUBS
  final List<Map<String, dynamic>> _superHubs = [
    {
      'name': 'EnerGo Bhopal Central SuperHub',
      'city': 'Bhopal, Madhya Pradesh',
      'address': 'Plot 14, Hoshangabad Road, MP Nagar',
      'ports_total': 8,
      'ports_active': 5,
      'beds_total': 6,
      'beds_occupied': 4,
      'laundry_units': 3,
      'parking_slots': 15,
      'parking_occupied': 9,
      'wash_bays': 2,
      'energy_kwh': '250 kWh (94% BESS Reserve)',
      'price_per_kwh': 18.50,
      'grid_load': 0.78,
    },
    {
      'name': 'EnerGo Indore VijayNagar FastHub',
      'city': 'Indore, Madhya Pradesh',
      'address': 'AB Road, Near C21 Mall, Vijay Nagar',
      'ports_total': 6,
      'ports_active': 4,
      'beds_total': 4,
      'beds_occupied': 2,
      'laundry_units': 2,
      'parking_slots': 12,
      'parking_occupied': 7,
      'wash_bays': 2,
      'energy_kwh': '200 kWh (88% BESS Reserve)',
      'price_per_kwh': 18.00,
      'grid_load': 0.65,
    },
    {
      'name': 'EnerGo Delhi Airport MegaHub',
      'city': 'New Delhi, NCR',
      'address': 'Terminal 3 EV Zone, IGI Airport',
      'ports_total': 12,
      'ports_active': 9,
      'beds_total': 8,
      'beds_occupied': 5,
      'laundry_units': 4,
      'parking_slots': 25,
      'parking_occupied': 19,
      'wash_bays': 4,
      'energy_kwh': '500 kWh (98% Multi-Grid Reserve)',
      'price_per_kwh': 19.50,
      'grid_load': 0.89,
    },
  ];

  // 4. LOUNGE BEDS & AMENITIES
  final List<Map<String, dynamic>> _bedBookings = [
    {'pod': 'Rest Pod #A1 (AC Luxury)', 'driver': 'Rajesh Driver', 'vehicle': 'Tata Nexon EV (MP 04 EV 1120)', 'checkin': '14:30', 'duration': '2 Hours', 'rate': '₹80/hr', 'status': 'OCCUPIED'},
    {'pod': 'Rest Pod #A2 (AC Luxury)', 'driver': 'Sanjay Verma', 'vehicle': 'MG ZS EV (DL 01 EV 4410)', 'checkin': '15:10', 'duration': '1 Hour', 'rate': '₹80/hr', 'status': 'OCCUPIED'},
    {'pod': 'Rest Pod #B1 (Snooze Cabin)', 'driver': 'Vacant / Sanitized', 'vehicle': 'Ready for tired EV driver', 'checkin': '--', 'duration': '--', 'rate': '₹75/hr', 'status': 'AVAILABLE'},
    {'pod': 'Rest Pod #B2 (Snooze Cabin)', 'driver': 'Vacant / Sanitized', 'vehicle': 'Ready for tired EV driver', 'checkin': '--', 'duration': '--', 'rate': '₹75/hr', 'status': 'AVAILABLE'},
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 5, vsync: this);

    // 1. Pulse Controller
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 0.88, end: 1.12).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    // 2. Radar 360 Sweep Controller
    _radarCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();

    // 3. Electrical Energy Flow Controller
    _flowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();

    _updateLiveTime();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (timer) => _updateLiveTime());
    _loadProfile();
  }

  void _updateLiveTime() {
    final now = DateTime.now();
    final h = now.hour.toString().padLeft(2, '0');
    final m = now.minute.toString().padLeft(2, '0');
    final s = now.second.toString().padLeft(2, '0');
    if (mounted) setState(() => _currentTime = "$h:$m:$s IST");
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _pulseCtrl.dispose();
    _radarCtrl.dispose();
    _flowCtrl.dispose();
    _clockTimer?.cancel();
    super.dispose();
  }

  void _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _adminName = prefs.getString('admin_name') ?? 'Operations Admin';
      _adminEmail = prefs.getString('admin_email') ?? 'admin@energonexus.com';
    });
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AdminLoginScreen()),
    );
  }

  void _showToast(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgPrimary,
      appBar: _buildAnimatedAppBar(),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _buildLiveDispatchTab(),
          _buildDriverKYCTab(),
          _buildSuperHubsTab(),
          _buildAmenityLedgerTab(),
          _buildMasterDirectoryTab(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: bgCard,
          border: Border(top: BorderSide(color: accentCyan.withValues(alpha: 0.25), width: 1.5)),
          boxShadow: [
            BoxShadow(color: accentCyan.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, -3)),
          ],
        ),
        child: TabBar(
          controller: _tabCtrl,
          indicatorColor: accentCyan,
          indicatorWeight: 3.5,
          labelColor: accentCyan,
          unselectedLabelColor: textSecondary,
          labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          tabs: const [
            Tab(icon: Icon(LucideIcons.radio, size: 19), text: "Radar Dispatch"),
            Tab(icon: Icon(LucideIcons.shieldCheck, size: 19), text: "Driver KYC"),
            Tab(icon: Icon(LucideIcons.zap, size: 19), text: "EV SuperHubs"),
            Tab(icon: Icon(LucideIcons.bedDouble, size: 19), text: "Lounge & Beds"),
            Tab(icon: Icon(LucideIcons.users, size: 19), text: "Master CRM"),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAnimatedAppBar() {
    return AppBar(
      backgroundColor: bgCard,
      elevation: 0,
      title: Row(
        children: [
          AnimatedBuilder(
            animation: _pulseAnim,
            builder: (context, child) => Transform.scale(
              scale: _pulseAnim.value,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentCyan.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: accentCyan, width: 1.5),
                  boxShadow: [
                    BoxShadow(color: accentCyan.withValues(alpha: 0.4), blurRadius: 12, spreadRadius: 1),
                  ],
                ),
                child: const Icon(LucideIcons.shieldCheck, color: accentCyan, size: 20),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text("Sub-Admin: $_adminName", style: const TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: accentGreen.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4), border: Border.all(color: accentGreen, width: 0.8)),
                    child: const Text("OPS MASTER", style: TextStyle(color: accentGreen, fontSize: 9, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              Text("$_adminEmail • Telemetry Active: $_currentTime", style: const TextStyle(color: accentCyan, fontSize: 11)),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(icon: const Icon(LucideIcons.refreshCw, color: textSecondary), onPressed: () => _showToast("Fleet telematics synced live!", accentCyan)),
        IconButton(icon: const Icon(LucideIcons.logOut, color: accentRed), onPressed: _logout),
        const SizedBox(width: 8),
      ],
    );
  }

  // =========================================================================
  // TAB 1: RADAR DISPATCH WITH 360° ROTATING SWEEP & PROGRESS BARS
  // =========================================================================
  Widget _buildLiveDispatchTab() {
    final filtered = _liveDispatches.where((d) {
      if (_dispatchFilter == 'rides' && d['type'] != 'ride') return false;
      if (_dispatchFilter == 'parcels' && d['type'] != 'parcel') return false;
      final q = _searchQuery.toLowerCase();
      if (q.isEmpty) return true;
      final pName = (d['passenger_name'] ?? d['sender_name'] ?? '').toString().toLowerCase();
      final dName = (d['driver_name'] ?? '').toString().toLowerCase();
      final id = (d['id'] ?? '').toString().toLowerCase();
      return pName.contains(q) || dName.contains(q) || id.contains(q);
    }).toList();

    return Column(
      children: [
        // Futuristic Radar Visualizer Card
        Container(
          margin: const EdgeInsets.fromLTRB(16, 14, 16, 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bgCard,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: accentCyan.withValues(alpha: 0.35)),
            gradient: LinearGradient(
              colors: [bgCard, accentCyan.withValues(alpha: 0.08)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [
              // 360 Radar Canvas
              SizedBox(
                width: 58,
                height: 58,
                child: AnimatedBuilder(
                  animation: _radarCtrl,
                  builder: (context, child) => CustomPaint(
                    painter: _RadarSweepPainter(progress: _radarCtrl.value),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Automated Fleet Dispatch Radar Active", style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 15)),
                    SizedBox(height: 3),
                    Text("Live 360° Telemetry • Matching nearest EV drivers & couriers.", style: TextStyle(color: textSecondary, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Live Search Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: TextField(
            style: const TextStyle(color: textPrimary),
            onChanged: (v) => setState(() => _searchQuery = v),
            decoration: InputDecoration(
              prefixIcon: const Icon(LucideIcons.search, color: textSecondary, size: 18),
              hintText: "Search by Passenger, Driver or Booking ID...",
              hintStyle: const TextStyle(color: textSecondary, fontSize: 13),
              filled: true,
              fillColor: bgCard,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: bgCardHover)),
            ),
          ),
        ),

        // Filter Chips
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            children: [
              _buildFilterChip("All Trips (${_liveDispatches.length})", 'all', accentCyan),
              const SizedBox(width: 8),
              _buildFilterChip("Passenger Rides", 'rides', accentGreen),
              const SizedBox(width: 8),
              _buildFilterChip("EV Parcel Cargo", 'parcels', accentPurple),
            ],
          ),
        ),

        // Trips List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filtered.length,
            itemBuilder: (context, i) {
              final item = filtered[i];
              final isRide = item['type'] == 'ride';
              final isMatching = item['status'] == 'MATCHING_DRIVER';
              final progress = (item['progress'] as double?) ?? 0.5;

              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: bgCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isMatching ? accentYellow.withValues(alpha: 0.5) : accentCyan.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: (isRide ? accentGreen : accentPurple).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                              child: Icon(isRide ? LucideIcons.car : LucideIcons.package, color: isRide ? accentGreen : accentPurple, size: 18),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("${item['id']} • ${isRide ? 'EV Passenger Ride' : 'EV Parcel Courier'}", style: const TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
                                Text(item['payment_mode'] ?? 'Online Paid', style: const TextStyle(color: textSecondary, fontSize: 11)),
                              ],
                            ),
                          ],
                        ),
                        Text("₹ ${item['fare']}", style: const TextStyle(color: accentGreen, fontWeight: FontWeight.bold, fontSize: 18)),
                      ],
                    ),
                    const Divider(color: bgCardHover, height: 20),

                    // Passenger Info
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: bgPrimary, borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("👤 Passenger: ${item['passenger_name'] ?? item['sender_name']}", style: const TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
                              Text("📱 ${item['passenger_phone'] ?? item['sender_phone']}", style: const TextStyle(color: accentCyan, fontSize: 12, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text("🔵 Pickup: ${item['pickup']}", style: const TextStyle(color: textSecondary, fontSize: 12)),
                          const SizedBox(height: 4),
                          Text("🏁 Destination: ${item['dropoff']}", style: const TextStyle(color: textSecondary, fontSize: 12)),
                          const SizedBox(height: 10),

                          // Animated Route Progress Bar
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(isMatching ? "Status: Scanning Fleet" : "Live Route Telemetry: ${(progress * 100).toInt()}%", style: const TextStyle(color: textSecondary, fontSize: 10)),
                                  Text("ETA: ${item['eta']}", style: const TextStyle(color: accentCyan, fontSize: 10, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: LinearProgressIndicator(
                                  value: progress,
                                  minHeight: 6,
                                  backgroundColor: bgCardHover,
                                  valueColor: AlwaysStoppedAnimation<Color>(isMatching ? accentYellow : accentGreen),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Driver Match Card
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isMatching ? accentYellow.withValues(alpha: 0.08) : accentCyan.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isMatching ? accentYellow.withValues(alpha: 0.4) : accentCyan.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(isMatching ? LucideIcons.loader : LucideIcons.userCheck, color: isMatching ? accentYellow : accentCyan, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("🚖 Assigned Partner: ${item['driver_name']}", style: const TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 12)),
                                Text("🚗 ${item['vehicle_model']} • Plate: ${item['plate_number']}", style: const TextStyle(color: textSecondary, fontSize: 11)),
                              ],
                            ),
                          ),
                          if (!isMatching)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(color: accentGreen.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(6)),
                              child: Text("⭐ ${item['driver_rating']}", style: const TextStyle(color: accentGreen, fontWeight: FontWeight.bold, fontSize: 11)),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Actions
                    Row(
                      children: [
                        if (isMatching)
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(backgroundColor: accentCyan, foregroundColor: bgPrimary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                              onPressed: () {
                                setState(() {
                                  item['status'] = 'IN_TRANSIT';
                                  item['driver_name'] = 'Ramesh Kumar (Auto-Matched)';
                                  item['driver_phone'] = '+91 98765 00112';
                                  item['plate_number'] = 'MP 04 EV 9901';
                                  item['driver_rating'] = 4.9;
                                  item['progress'] = 0.50;
                                });
                                _showToast("Ride #${item['id']} Dispatched to Ramesh Kumar!", accentGreen);
                              },
                              icon: const Icon(LucideIcons.send, size: 16),
                              label: const Text("Auto-Dispatch to Nearest Driver", style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          )
                        else
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accentGreen.withValues(alpha: 0.2),
                                foregroundColor: accentGreen,
                                side: const BorderSide(color: accentGreen),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: () => _showTripTelemetryDialog(context, item),
                              icon: const Icon(LucideIcons.eye, size: 16),
                              label: const Text("View Full Telemetry & Logs"),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, String value, Color color) {
    final isSelected = _dispatchFilter == value;
    return GestureDetector(
      onTap: () => setState(() => _dispatchFilter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.2) : bgCard,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? color : bgCardHover),
        ),
        child: Text(label, style: TextStyle(color: isSelected ? color : textSecondary, fontSize: 11, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      ),
    );
  }

  void _showTripTelemetryDialog(BuildContext context, Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: bgCard,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Trip Telemetry: ${item['id']}", style: const TextStyle(color: textPrimary, fontSize: 17, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(LucideIcons.x, color: textSecondary), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const SizedBox(height: 12),
            _buildDetailRow("Passenger / Sender", "${item['passenger_name'] ?? item['sender_name']} (${item['passenger_phone'] ?? item['sender_phone']})"),
            _buildDetailRow("EV Driver Partner", "${item['driver_name']} (${item['driver_phone']})"),
            _buildDetailRow("EV Model & Plate", "${item['vehicle_model']} • ${item['plate_number']}"),
            _buildDetailRow("Trip Route", "From: ${item['pickup']} ➡️ To: ${item['dropoff']}"),
            _buildDetailRow("Fare & Payment", "₹ ${item['fare']} (${item['payment_mode']})"),
            if (item['otp'] != null) _buildDetailRow("Delivery Security OTP", "${item['otp']}"),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: accentRed, foregroundColor: textPrimary),
                onPressed: () {
                  Navigator.pop(ctx);
                  setState(() => _liveDispatches.remove(item));
                  _showToast("Trip ${item['id']} Cancelled by Sub-Admin Override.", Colors.amber);
                },
                icon: const Icon(LucideIcons.alertTriangle, size: 16),
                label: const Text("Emergency Incident Override / Cancel Trip"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: textSecondary, fontSize: 11)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(color: textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // =========================================================================
  // TAB 2: DRIVER & FLEET KYC COMPLIANCE ENGINE (SUB-ADMIN APPROVAL MANDATORY)
  // =========================================================================
  Widget _buildDriverKYCTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: bgCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: accentYellow.withValues(alpha: 0.3))),
          child: const Row(
            children: [
              Icon(LucideIcons.fileCheck2, color: accentYellow, size: 32),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Driver KYC Compliance Authority", style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 15)),
                    SizedBox(height: 2),
                    Text("New EV drivers cannot register directly. Sub-Admin must thoroughly verify License, RC & Insurance.", style: TextStyle(color: textSecondary, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Pending Driver Verifications (${_pendingDrivers.length})", style: const TextStyle(color: textPrimary, fontSize: 15, fontWeight: FontWeight.bold)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: accentYellow.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
              child: const Text("Action Required", style: TextStyle(color: accentYellow, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (_pendingDrivers.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: bgCard, borderRadius: BorderRadius.circular(14)),
            child: const Center(child: Text("All driver KYC documents verified! No pending backlog.", style: TextStyle(color: accentGreen))),
          )
        else
          ..._pendingDrivers.map((d) => Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: bgCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: bgCardHover)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(d['driver_name'], style: const TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: accentYellow.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                          child: const Text("PENDING KYC", style: TextStyle(color: accentYellow, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text("📱 Mobile: ${d['mobile']} • 📧 ${d['email']}", style: const TextStyle(color: textSecondary, fontSize: 12)),
                    Text("🚗 Vehicle: ${d['vehicle_model']} (${d['plate_number']})", style: const TextStyle(color: accentCyan, fontSize: 12, fontWeight: FontWeight.w600)),
                    const Divider(color: bgCardHover, height: 22),

                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        _buildKycBadge("DL: ${d['license_no']}", accentCyan),
                        _buildKycBadge("Aadhaar: ${d['aadhaar_no']}", accentPurple),
                        _buildKycBadge("Battery: ${d['battery_kwh']}", accentGreen),
                      ],
                    ),
                    const SizedBox(height: 14),

                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: accentGreen, foregroundColor: bgPrimary),
                            onPressed: () => _approveDriverKYC(d),
                            icon: const Icon(LucideIcons.checkCheck, size: 16),
                            label: const Text("Approve & Activate Driver", style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(LucideIcons.eye, color: accentCyan),
                          tooltip: "Inspect All Documents",
                          onPressed: () => _showDriverInspectionModal(context, d),
                        ),
                        IconButton(
                          icon: const Icon(LucideIcons.xCircle, color: accentRed),
                          tooltip: "Reject Driver",
                          onPressed: () => _rejectDriverKYC(d),
                        ),
                      ],
                    ),
                  ],
                ),
              )),

        const SizedBox(height: 24),

        const Text("Verified Active Drivers Fleet", style: TextStyle(color: textPrimary, fontSize: 15, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ..._verifiedDrivers.map((vd) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: bgCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: bgCardHover)),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: accentGreen.withValues(alpha: 0.2),
                    child: Text(vd['name'][0], style: const TextStyle(color: accentGreen, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(vd['name'], style: const TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
                        Text(vd['vehicle'], style: const TextStyle(color: textSecondary, fontSize: 11)),
                        Text("⭐ ${vd['rating']} • Total Trips: ${vd['rides']} • Wallet: ${vd['wallet']}", style: const TextStyle(color: accentCyan, fontSize: 10.5)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: accentGreen.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                    child: Text(vd['status'], style: const TextStyle(color: accentGreen, fontSize: 9.5, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildKycBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: TextStyle(color: color, fontSize: 10.5, fontWeight: FontWeight.w600)),
    );
  }

  void _approveDriverKYC(Map<String, dynamic> d) {
    setState(() {
      _pendingDrivers.remove(d);
      _verifiedDrivers.insert(0, {
        'name': d['driver_name'],
        'phone': d['mobile'],
        'vehicle': "${d['vehicle_model']} (${d['plate_number']})",
        'status': 'ONLINE_AVAILABLE',
        'rating': 5.0,
        'rides': 0,
        'wallet': '₹ 500 (Welcome Bonus)',
      });
    });
    _showToast("Driver ${d['driver_name']} Verified & Authorized for Rides!", accentGreen);
  }

  void _rejectDriverKYC(Map<String, dynamic> d) {
    setState(() => _pendingDrivers.remove(d));
    _showToast("Driver ${d['driver_name']} Application Rejected.", accentRed);
  }

  void _showDriverInspectionModal(BuildContext context, Map<String, dynamic> d) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: bgCard,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("KYC Dossier: ${d['driver_name']}", style: const TextStyle(color: textPrimary, fontSize: 17, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(LucideIcons.x, color: textSecondary), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const SizedBox(height: 12),
            _buildDetailRow("Driving License Number", "${d['license_no']} (Valid upto: ${d['license_expiry']})"),
            _buildDetailRow("Aadhaar Identity Number", "${d['aadhaar_no']}"),
            _buildDetailRow("Vehicle Registration & Model", "${d['vehicle_model']} • Plate: ${d['plate_number']}"),
            _buildDetailRow("EV Battery Capacity", "${d['battery_kwh']} Lithium-Ion Pack"),
            _buildDetailRow("Commercial Insurance", "Active (Valid upto: ${d['insurance_valid_upto']})"),
            _buildDetailRow("Driving Experience", "${d['experience']}"),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: accentGreen, foregroundColor: bgPrimary),
                onPressed: () {
                  Navigator.pop(ctx);
                  _approveDriverKYC(d);
                },
                icon: const Icon(LucideIcons.checkCheck, size: 16),
                label: const Text("Approve & Onboard Partner", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // TAB 3: EV SUPERHUBS & INFRASTRUCTURE MONITOR
  // =========================================================================
  Widget _buildSuperHubsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _superHubs.length,
      itemBuilder: (context, i) {
        final hub = _superHubs[i];
        final gridLoad = (hub['grid_load'] as double?) ?? 0.75;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: bgCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: bgCardHover)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(hub['name'], style: const TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                        Text("📍 ${hub['city']} • ${hub['address']}", style: const TextStyle(color: textSecondary, fontSize: 12)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: accentGreen.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                    child: Text("₹ ${hub['price_per_kwh']} / kWh", style: const TextStyle(color: accentGreen, fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildAmenityBadge("⚡ Ports: ${hub['ports_active']} / ${hub['ports_total']} In-Use", accentCyan),
                  _buildAmenityBadge("🛏️ Beds: ${hub['beds_occupied']} / ${hub['beds_total']} Occupied", accentPurple),
                  _buildAmenityBadge("🅿️ Parking: ${hub['parking_occupied']} / ${hub['parking_slots']} Parked", accentOrange),
                  _buildAmenityBadge("🧺 Laundry: ${hub['laundry_units']} Units Active", accentYellow),
                  _buildAmenityBadge("🚿 Car Wash: ${hub['wash_bays']} Bays Ready", accentGreen),
                ],
              ),
              const SizedBox(height: 14),

              // Animated Grid Load Telemetry
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: bgPrimary, borderRadius: BorderRadius.circular(10)),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(LucideIcons.batteryCharging, color: accentGreen, size: 18),
                            const SizedBox(width: 8),
                            Text("BESS Grid Storage: ${hub['energy_kwh']}", style: const TextStyle(color: textPrimary, fontSize: 11.5, fontWeight: FontWeight.w600)),
                          ],
                        ),
                        Text("${(gridLoad * 100).toInt()}% Load", style: const TextStyle(color: accentCyan, fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: gridLoad,
                        minHeight: 5,
                        backgroundColor: bgCardHover,
                        valueColor: const AlwaysStoppedAnimation<Color>(accentGreen),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAmenityBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8), border: Border.all(color: color.withValues(alpha: 0.3))),
      child: Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }

  // =========================================================================
  // TAB 4: LOUNGE BEDS & AMENITY BOOKING LEDGER
  // =========================================================================
  Widget _buildAmenityLedgerTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: bgCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: accentPurple.withValues(alpha: 0.3))),
          child: const Row(
            children: [
              Icon(LucideIcons.bedDouble, color: accentPurple, size: 30),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Driver Rest Lounge & Sleep Pod Ledger", style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 15)),
                    SizedBox(height: 2),
                    Text("Live record of who booked which bed, vehicle plate, duration & hourly tariff.", style: TextStyle(color: textSecondary, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        ..._bedBookings.map((b) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: bgCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: bgCardHover)),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: accentPurple.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(LucideIcons.bed, color: accentPurple, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(b['pod'], style: const TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
                        Text("👤 ${b['driver']} • 🚗 ${b['vehicle']}", style: const TextStyle(color: textSecondary, fontSize: 11)),
                        Text("Rate: ${b['rate']} • In: ${b['checkin']} (${b['duration']})", style: const TextStyle(color: accentCyan, fontSize: 11)),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: b['status'] == 'OCCUPIED' ? accentRed : accentGreen,
                      foregroundColor: textPrimary,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    ),
                    onPressed: () {
                      setState(() {
                        if (b['status'] == 'OCCUPIED') {
                          b['status'] = 'AVAILABLE';
                          b['driver'] = 'Vacant / Cleaned';
                          b['vehicle'] = 'Ready for EV driver';
                          b['checkin'] = '--';
                          b['duration'] = '--';
                        } else {
                          b['status'] = 'OCCUPIED';
                          b['driver'] = 'Driver Check-in (Now)';
                          b['vehicle'] = 'Assigned EV';
                          b['checkin'] = 'Live';
                          b['duration'] = '1 Hour';
                        }
                      });
                      _showToast("Updated ${b['pod']} Status", accentCyan);
                    },
                    child: Text(b['status'] == 'OCCUPIED' ? "Check-Out" : "Check-In", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  // =========================================================================
  // TAB 5: MASTER PASSENGER & DRIVER CRM DIRECTORY
  // =========================================================================
  Widget _buildMasterDirectoryTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: bgCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: accentCyan.withValues(alpha: 0.3))),
          child: const Row(
            children: [
              Icon(LucideIcons.users, color: accentCyan, size: 30),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Master Platform Directory (CRM)", style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 15)),
                    SizedBox(height: 2),
                    Text("Complete database access of Passengers, EV Fleet Drivers, and Logistics Shippers.", style: TextStyle(color: textSecondary, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const Text("Registered Passengers (Live)", style: TextStyle(color: textPrimary, fontSize: 15, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        _buildCrmCard("Rohan Sharma", "+91 98234 11209", "rohan.sharma@gmail.com", "42 Rides Taken • Active Rider", accentCyan),
        _buildCrmCard("Pooja Verma", "+91 98112 33445", "pooja.v@outlook.com", "18 Rides Taken • Frequent Traveler", accentGreen),
        _buildCrmCard("Ananya Roy", "+91 98990 44551", "ananya.roy@yahoo.com", "29 Rides Taken • Airport Commuter", accentPurple),
        const SizedBox(height: 20),
        const Text("Verified EV Drivers (Fleet)", style: TextStyle(color: textPrimary, fontSize: 15, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        _buildCrmCard("Suresh Verma", "+91 98765 43210", "suresh.nexon@gmail.com", "Tata Nexon EV (MP 04 EV 8891) • ⭐ 4.9", accentGreen),
        _buildCrmCard("Aakash Partner", "+91 98123 99887", "aakash.cargo@gmail.com", "Ather 450X Cargo (MP 04 EV 1024) • ⭐ 4.8", accentCyan),
      ],
    );
  }

  Widget _buildCrmCard(String name, String phone, String email, String subtitle, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: bgCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: bgCardHover)),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: color.withValues(alpha: 0.2), child: Text(name[0], style: TextStyle(color: color, fontWeight: FontWeight.bold))),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
                Text("📱 $phone • 📧 $email", style: const TextStyle(color: textSecondary, fontSize: 11)),
                Text(subtitle, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =========================================================================
// CUSTOM ANIMATED RADAR SWEEP PAINTER (360° ROTATING SWEEP BEAM)
// =========================================================================
class _RadarSweepPainter extends CustomPainter {
  final double progress;
  _RadarSweepPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Outer radar circles
    final circlePaint = Paint()
      ..color = const Color(0xFF00F0FF).withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawCircle(center, radius, circlePaint);
    canvas.drawCircle(center, radius * 0.65, circlePaint);
    canvas.drawCircle(center, radius * 0.35, circlePaint);

    // Crosshairs
    canvas.drawLine(Offset(0, center.dy), Offset(size.width, center.dy), circlePaint);
    canvas.drawLine(Offset(center.dx, 0), Offset(center.dx, size.height), circlePaint);

    // Rotating sweep gradient beam
    final sweepAngle = progress * 2 * math.pi;
    final sweepPaint = Paint()
      ..shader = SweepGradient(
        center: Alignment.center,
        startAngle: 0.0,
        endAngle: math.pi / 2,
        colors: [
          const Color(0xFF00F0FF).withValues(alpha: 0.0),
          const Color(0xFF00F0FF).withValues(alpha: 0.45),
        ],
        transform: GradientRotation(sweepAngle),
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, sweepPaint);

    // Blip dots (EV vehicles on radar)
    final blipPaint = Paint()..color = const Color(0xFF00E676);
    canvas.drawCircle(Offset(center.dx + radius * 0.4, center.dy - radius * 0.3), 3.0, blipPaint);
    canvas.drawCircle(Offset(center.dx - radius * 0.5, center.dy + radius * 0.2), 2.5, blipPaint);
  }

  @override
  bool shouldRepaint(covariant _RadarSweepPainter oldDelegate) => oldDelegate.progress != progress;
}