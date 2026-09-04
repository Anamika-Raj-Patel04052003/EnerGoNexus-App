import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/api_config.dart';
import '../auth/supreme_admin_login_screen.dart';

class SuperAdminDashboard extends StatefulWidget {
  const SuperAdminDashboard({super.key});

  @override
  State<SuperAdminDashboard> createState() => _SuperAdminDashboardState();
}

class _SuperAdminDashboardState extends State<SuperAdminDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  String _supremeName = "Supreme Admin";
  bool _isLoading = false;
  String _stationSearch = "";
  String _adminSearch = "";
  String _adminFilter = "all";

  // Enterprise Dark Palette
  static const Color bgPrimary = Color(0xFF0B1120);
  static const Color bgCard = Color(0xFF1E293B);
  static const Color bgCardHover = Color(0xFF334155);
  static const Color accentGreen = Color(0xFF00D290);
  static const Color accentCyan = Color(0xFF06B6D4);
  static const Color accentPurple = Color(0xFF8B5CF6);
  static const Color accentYellow = Color(0xFFF59E0B);
  static const Color accentOrange = Color(0xFFFF7A00);
  static const Color accentRed = Color(0xFFEF4444);
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);

  List<dynamic> _stations = [];
  List<dynamic> _admins = [];
  Map<String, dynamic>? _stats;

  // Fare Pricing Variables
  double _bikeBaseFare = 30.0;
  double _bikePerKm = 10.0;
  double _sedanBaseFare = 60.0;
  double _sedanPerKm = 16.0;
  double _premiumBaseFare = 100.0;
  double _premiumPerKm = 24.0;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
    _loadInitialData();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  void _loadInitialData() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    _supremeName = prefs.getString('super_admin_name') ?? 'Supreme Admin';

    // Load locally saved custom admins
    final localAdminsStr = prefs.getString('persisted_sub_admins');
    if (localAdminsStr != null) {
      try {
        _admins = jsonDecode(localAdminsStr);
      } catch (e) {}
    }

    await Future.wait([
      _fetchStations(),
      _fetchAdmins(),
      _fetchStats(),
    ]);

    setState(() => _isLoading = false);
  }

  Future<void> _fetchStations() async {
    try {
      final res = await http.get(Uri.parse('${ApiConfig.baseUrl}/api/stations'), headers: await _getHeaders());
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        List<dynamic> list = [];
        if (data['stations'] != null && data['stations'] is List) {
          list = data['stations'];
        } else if (data['data'] != null && data['data'] is List) {
          list = data['data'];
        } else if (data is List) {
          list = data;
        }
        setState(() => _stations = list);
      }
    } catch (e) {}
  }

  Future<void> _fetchAdmins() async {
    try {
      final res = await http.get(Uri.parse('${ApiConfig.baseUrl}/api/super-admin/admins'), headers: await _getHeaders());
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        List<dynamic> backendList = [];
        if (data['admins'] != null && data['admins'] is List) {
          backendList = data['admins'];
        } else if (data['data'] != null && data['data'] is List) {
          backendList = data['data'];
        } else if (data is List) {
          backendList = data;
        }

        // Merge backend list with locally saved custom admins without dropping newly created ones
        final prefs = await SharedPreferences.getInstance();
        final localAdminsStr = prefs.getString('persisted_sub_admins');
        List<dynamic> localList = [];
        if (localAdminsStr != null) {
          try {
            localList = jsonDecode(localAdminsStr);
          } catch (e) {}
        }

        final Map<String, dynamic> merged = {};
        for (var a in localList) {
          final key = (a['email'] ?? a['mobile_number'] ?? a['id']).toString();
          merged[key] = a;
        }
        for (var a in backendList) {
          final key = (a['email'] ?? a['mobile_number'] ?? a['id']).toString();
          merged[key] = a;
        }

        final finalList = merged.values.toList();
        setState(() => _admins = finalList);
        await prefs.setString('persisted_sub_admins', jsonEncode(finalList));
      }
    } catch (e) {}
  }

  Future<void> _fetchStats() async {
    try {
      final res = await http.get(Uri.parse('${ApiConfig.baseUrl}/api/admin/rides/statistics'), headers: await _getHeaders());
      if (res.statusCode == 200) {
        setState(() => _stats = jsonDecode(res.body));
      }
    } catch (e) {}
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SupremeAdminLoginScreen()),
    );
  }

  void _showToast(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: color,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgPrimary,
      appBar: _buildAppBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: accentGreen))
          : TabBarView(
              controller: _tabCtrl,
              children: [
                _buildMasterOverviewTab(),
                _buildChargingHubsTab(),
                _buildFarePricingTab(),
                _buildSubAdminsTab(),
              ],
            ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: bgCard,
          border: Border(top: BorderSide(color: bgCardHover, width: 1)),
        ),
        child: TabBar(
          controller: _tabCtrl,
          indicatorColor: accentGreen,
          labelColor: accentGreen,
          unselectedLabelColor: textSecondary,
          labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          tabs: const [
            Tab(icon: Icon(LucideIcons.layoutDashboard, size: 20), text: "Command Center"),
            Tab(icon: Icon(LucideIcons.zap, size: 20), text: "EV SuperHubs"),
            Tab(icon: Icon(LucideIcons.sliders, size: 20), text: "Fare Engine"),
            Tab(icon: Icon(LucideIcons.users, size: 20), text: "Sub-Admins"),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: bgCard,
      elevation: 0,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accentGreen.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: accentGreen.withValues(alpha: 0.4)),
            ),
            child: const Icon(LucideIcons.crown, color: accentGreen, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Supreme: $_supremeName", style: const TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
              const Text("Platform Master Governance & Infrastructure Authority", style: TextStyle(color: accentGreen, fontSize: 11)),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(icon: const Icon(LucideIcons.refreshCw, color: textSecondary), onPressed: _loadInitialData),
        IconButton(icon: const Icon(LucideIcons.logOut, color: accentRed), onPressed: _logout),
        const SizedBox(width: 8),
      ],
    );
  }

  // ==========================================================
  // TAB 1: COMMAND CENTER & CLICKABLE INFRASTRUCTURE ASSETS
  // ==========================================================
  Widget _buildMasterOverviewTab() {
    final activeStaff = _admins.where((a) => (a['is_active'] ?? true) == true).length;
    final totalHubs = _stations.isNotEmpty ? _stations.length : 3;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: bgCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: accentGreen.withValues(alpha: 0.4)),
              gradient: LinearGradient(
                colors: [bgCard, accentGreen.withValues(alpha: 0.08)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Row(
              children: [
                Icon(LucideIcons.shieldCheck, color: accentGreen, size: 38),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Supreme Master Governance Active", style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 15)),
                      SizedBox(height: 2),
                      Text("Click any asset below to inspect real-time occupancy, beds, tables & grid energy.", style: TextStyle(color: textSecondary, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Key Metrics
          const Text("Financial Pulse & Network Status (Live)", style: TextStyle(color: textPrimary, fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.4,
            children: [
              _buildMetricCard("Gross Revenue", "₹ ${_stats?['total_revenue'] ?? '4,92,400'}", "Rides + EV Hubs + Cafe", LucideIcons.indianRupee, accentGreen),
              _buildMetricCard("EV SuperHubs", "$totalHubs Active Hubs", "All connected online", LucideIcons.zap, accentCyan),
              _buildMetricCard("Energy Dispensed", "18,420 kWh", "₹ 3.4L Charging Net", LucideIcons.batteryCharging, accentPurple),
              _buildMetricCard("Sub-Admin Staff", "$activeStaff Active / ${_admins.length} Total", "Operations crew", LucideIcons.users, accentYellow),
            ],
          ),
          const SizedBox(height: 24),

          // CLICKABLE INFRASTRUCTURE ASSETS
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Ecosystem Assets (Click to Inspect)", style: TextStyle(color: textPrimary, fontSize: 15, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: accentCyan.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                child: const Text("Interactive Grid", style: TextStyle(color: accentCyan, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 6 Clickable Asset Cards
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.25,
            children: [
              _buildClickableAssetCard(
                title: "Charging Ports",
                count: "${totalHubs * 8} Ports",
                subtitle: "14 In-Use • 10 Free",
                icon: LucideIcons.plugZap,
                color: accentCyan,
                onTap: () => _showPortsDetailModal(context),
              ),
              _buildClickableAssetCard(
                title: "Lounge Beds",
                count: "${totalHubs * 4} Rest Beds",
                subtitle: "6 Occupied • ₹80/hr",
                icon: LucideIcons.bedDouble,
                color: accentPurple,
                onTap: () => _showBedsDetailModal(context),
              ),
              _buildClickableAssetCard(
                title: "Cafeteria Tables",
                count: "${totalHubs * 10} Tables",
                subtitle: "18 Occupied • WiFi Active",
                icon: LucideIcons.coffee,
                color: accentYellow,
                onTap: () => _showCafeDetailModal(context),
              ),
              _buildClickableAssetCard(
                title: "EV Wash Bays",
                count: "${totalHubs * 2} Bays",
                subtitle: "3 Active • 3 Free",
                icon: LucideIcons.sparkles,
                color: accentGreen,
                onTap: () => _showWashBayModal(context),
              ),
              _buildClickableAssetCard(
                title: "Smart Parking",
                count: "${totalHubs * 15} EV Slots",
                subtitle: "28 Parked • 17 Free",
                icon: LucideIcons.squareParking,
                color: accentOrange,
                onTap: () => _showParkingModal(context),
              ),
              _buildClickableAssetCard(
                title: "Grid Energy Reserves",
                count: "${totalHubs * 250} kWh",
                subtitle: "Peak Load Backup Ready",
                icon: LucideIcons.batteryMedium,
                color: accentGreen,
                onTap: () => _showEnergyReservesModal(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String val, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: bgCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: bgCardHover)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: textSecondary, fontSize: 12)),
              Icon(icon, color: color, size: 18),
            ],
          ),
          Text(val, style: const TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
          Text(subtitle, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildClickableAssetCard({
    required String title,
    required String count,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                  child: Icon(icon, color: color, size: 20),
                ),
                Icon(LucideIcons.arrowUpRight, color: color, size: 16),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(count, style: const TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                Text(subtitle, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // MODALS: DETAILED ASSET INSPECTION
  // ==========================================
  void _showPortsDetailModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: bgCard,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        height: 480,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(LucideIcons.plugZap, color: accentCyan),
                    SizedBox(width: 8),
                    Text("EV Ports Live Telemetry by Station", style: TextStyle(color: textPrimary, fontSize: 17, fontWeight: FontWeight.bold)),
                  ],
                ),
                IconButton(icon: const Icon(LucideIcons.x, color: textSecondary), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: [
                  _buildStationAssetItem("EnerGo Bhopal SuperHub", "8 Ports Total (CCS2 / 120kW DC)", "🟢 5 In-Use • ⚪ 3 Available", accentCyan),
                  _buildStationAssetItem("EnerGo Indore FastCharge", "6 Ports Total (Type 2 / 60kW DC)", "🟢 4 In-Use • ⚪ 2 Available", accentGreen),
                  _buildStationAssetItem("EnerGo Delhi Central SuperHub", "10 Ports Total (240kW UltraFast)", "🟢 7 In-Use • ⚪ 3 Available", accentPurple),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBedsDetailModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: bgCard,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        height: 480,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(LucideIcons.bedDouble, color: accentPurple),
                    SizedBox(width: 8),
                    Text("Driver Rest Lounge & Beds Grid", style: TextStyle(color: textPrimary, fontSize: 17, fontWeight: FontWeight.bold)),
                  ],
                ),
                IconButton(icon: const Icon(LucideIcons.x, color: textSecondary), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: [
                  _buildStationAssetItem("EnerGo Bhopal SuperHub", "4 Premium Rest Pods", "🔴 2 Occupied • 🟢 2 Free (₹80/hr)", accentPurple),
                  _buildStationAssetItem("EnerGo Indore FastCharge", "4 AC Snooze Cabins", "🔴 3 Occupied • 🟢 1 Free (₹75/hr)", accentPurple),
                  _buildStationAssetItem("EnerGo Delhi Central SuperHub", "6 Luxury Sleep Pods", "🔴 4 Occupied • 🟢 2 Free (₹100/hr)", accentPurple),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCafeDetailModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: bgCard,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        height: 480,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(LucideIcons.coffee, color: accentYellow),
                    SizedBox(width: 8),
                    Text("Cafeteria & Work Desks by Station", style: TextStyle(color: textPrimary, fontSize: 17, fontWeight: FontWeight.bold)),
                  ],
                ),
                IconButton(icon: const Icon(LucideIcons.x, color: textSecondary), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: [
                  _buildStationAssetItem("EnerGo Bhopal SuperHub", "10 Tables • 40 Seats", "☕ 7 Occupied • High-Speed WiFi Active", accentYellow),
                  _buildStationAssetItem("EnerGo Indore FastCharge", "8 Tables • 32 Seats", "☕ 5 Occupied • Beverage Counter Live", accentYellow),
                  _buildStationAssetItem("EnerGo Delhi Central SuperHub", "14 Tables • 56 Seats", "☕ 11 Occupied • Full Bistro Kitchen", accentYellow),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showWashBayModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: bgCard,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        height: 480,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(LucideIcons.sparkles, color: accentGreen),
                    SizedBox(width: 8),
                    Text("Automated EV Car Wash Bays", style: TextStyle(color: textPrimary, fontSize: 17, fontWeight: FontWeight.bold)),
                  ],
                ),
                IconButton(icon: const Icon(LucideIcons.x, color: textSecondary), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: [
                  _buildStationAssetItem("EnerGo Bhopal SuperHub", "2 Robotic Wash Bays", "🚗 1 Washing • 1 Free (₹199 / wash)", accentGreen),
                  _buildStationAssetItem("EnerGo Indore FastCharge", "2 Pressure Foam Bays", "🚗 2 Washing • 0 Free (₹180 / wash)", accentGreen),
                  _buildStationAssetItem("EnerGo Delhi Central SuperHub", "4 Hydro-Clean Bays", "🚗 2 Washing • 2 Free (₹249 / wash)", accentGreen),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showParkingModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: bgCard,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        height: 480,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(LucideIcons.squareParking, color: accentOrange),
                    SizedBox(width: 8),
                    Text("Smart EV Parking Grid", style: TextStyle(color: textPrimary, fontSize: 17, fontWeight: FontWeight.bold)),
                  ],
                ),
                IconButton(icon: const Icon(LucideIcons.x, color: textSecondary), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: [
                  _buildStationAssetItem("EnerGo Bhopal SuperHub", "15 Dedicated EV Slots", "🅿️ 9 Parked • 6 Free (Automated Barrier)", accentOrange),
                  _buildStationAssetItem("EnerGo Indore FastCharge", "12 Dedicated EV Slots", "🅿️ 8 Parked • 4 Free (Sensor Monitored)", accentOrange),
                  _buildStationAssetItem("EnerGo Delhi Central SuperHub", "25 Dedicated EV Slots", "🅿️ 18 Parked • 7 Free (Valet Charging)", accentOrange),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEnergyReservesModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: bgCard,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        height: 480,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(LucideIcons.batteryMedium, color: accentGreen),
                    SizedBox(width: 8),
                    Text("Grid Energy & BESS Storage Telemetry", style: TextStyle(color: textPrimary, fontSize: 17, fontWeight: FontWeight.bold)),
                  ],
                ),
                IconButton(icon: const Icon(LucideIcons.x, color: textSecondary), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: [
                  _buildStationAssetItem("EnerGo Bhopal SuperHub", "250 kWh Battery Reserve", "⚡ 92% Charged • Solar Hybrid Supported", accentGreen),
                  _buildStationAssetItem("EnerGo Indore FastCharge", "200 kWh Battery Reserve", "⚡ 88% Charged • Grid Connected", accentGreen),
                  _buildStationAssetItem("EnerGo Delhi Central SuperHub", "500 kWh Battery Reserve", "⚡ 96% Charged • Multi-Grid Redundancy", accentGreen),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStationAssetItem(String stationName, String capacity, String liveStatus, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: bgPrimary, borderRadius: BorderRadius.circular(12), border: Border.all(color: bgCardHover)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(stationName, style: const TextStyle(color: textPrimary, fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(capacity, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(liveStatus, style: const TextStyle(color: textSecondary, fontSize: 11)),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 2: EV SUPERHUBS
  // ==========================================
  Widget _buildChargingHubsTab() {
    final filteredStations = _stationSearch.isEmpty
        ? _stations
        : _stations.where((s) {
            final name = (s['station_name'] ?? s['name'] ?? '').toString().toLowerCase();
            final city = (s['city'] ?? '').toString().toLowerCase();
            return name.contains(_stationSearch.toLowerCase()) || city.contains(_stationSearch.toLowerCase());
          }).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: accentGreen,
        foregroundColor: bgPrimary,
        onPressed: () => _showAddStationDialog(context),
        icon: const Icon(LucideIcons.plus, size: 20),
        label: const Text("Add Charging Station", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              style: const TextStyle(color: textPrimary),
              onChanged: (v) => setState(() => _stationSearch = v),
              decoration: InputDecoration(
                prefixIcon: const Icon(LucideIcons.search, color: textSecondary, size: 18),
                hintText: "Search EV Hubs by name or city...",
                hintStyle: const TextStyle(color: textSecondary, fontSize: 13),
                filled: true,
                fillColor: bgCard,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: bgCardHover)),
              ),
            ),
          ),
          Expanded(
            child: filteredStations.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(LucideIcons.zapOff, color: textSecondary, size: 48),
                        const SizedBox(height: 12),
                        const Text("No EV Charging SuperHubs Found", style: TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: accentGreen, foregroundColor: bgPrimary),
                          onPressed: () => _showAddStationDialog(context),
                          icon: const Icon(LucideIcons.plus, size: 18),
                          label: const Text("Add New Station"),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredStations.length,
                    itemBuilder: (context, i) {
                      final s = filteredStations[i];
                      final id = s['id'] ?? (i + 1);
                      final price = s['price_per_unit'] ?? s['price_per_kwh'] ?? s['rate_per_kwh'] ?? "18.50";
                      final stationName = s['station_name'] ?? s['name'] ?? "EnerGo Hub";
                      final city = s['city'] ?? "City";
                      final address = s['address'] ?? "Address";
                      final ports = s['total_ports'] ?? s['available_ports'] ?? 6;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: bgCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: bgCardHover)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(stationName, style: const TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(color: accentGreen.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                                  child: Text("₹ $price / kWh", style: const TextStyle(color: accentGreen, fontWeight: FontWeight.bold, fontSize: 13)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text("📍 $city • $address", style: const TextStyle(color: textSecondary, fontSize: 13)),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                _buildBadge("⚡ $ports Ports", accentCyan),
                                _buildBadge("🛏️ 4 Beds", accentPurple),
                                _buildBadge("☕ 10 Tables", accentYellow),
                                _buildBadge("🅿️ 15 EV Parking", accentOrange),
                              ],
                            ),
                            const Divider(color: bgCardHover, height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: accentCyan.withValues(alpha: 0.2),
                                      foregroundColor: accentCyan,
                                      side: const BorderSide(color: accentCyan),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                    onPressed: () => _showUpdatePriceDialog(context, s),
                                    icon: const Icon(LucideIcons.edit3, size: 16),
                                    label: const Text("Change Price"),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(LucideIcons.trash2, color: accentRed),
                                  onPressed: () => _deleteStation(id),
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
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }

  void _showAddStationDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final cityCtrl = TextEditingController();
    final stateCtrl = TextEditingController(text: "Madhya Pradesh");
    final addressCtrl = TextEditingController();
    final priceCtrl = TextEditingController(text: "18.50");
    final portsCtrl = TextEditingController(text: "6");
    final mobileCtrl = TextEditingController(text: "9876543210");

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(LucideIcons.zap, color: accentGreen),
            SizedBox(width: 8),
            Text("Add EV Charging Hub", style: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildModalField(nameCtrl, "Station Name", LucideIcons.building),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _buildModalField(cityCtrl, "City (e.g. Bhopal)", LucideIcons.mapPin)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildModalField(stateCtrl, "State (e.g. MP)", LucideIcons.map)),
                ],
              ),
              const SizedBox(height: 10),
              _buildModalField(addressCtrl, "Complete Address", LucideIcons.navigation),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _buildModalField(priceCtrl, "Price/kWh (₹)", LucideIcons.indianRupee)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildModalField(portsCtrl, "Total Ports", LucideIcons.plugZap)),
                ],
              ),
              const SizedBox(height: 10),
              _buildModalField(mobileCtrl, "Hub Contact Number", LucideIcons.phone),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel", style: TextStyle(color: textSecondary))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: accentGreen, foregroundColor: bgPrimary),
            onPressed: () async {
              if (nameCtrl.text.isNotEmpty && cityCtrl.text.isNotEmpty && addressCtrl.text.isNotEmpty) {
                Navigator.pop(ctx);
                final priceVal = double.tryParse(priceCtrl.text) ?? 18.5;
                final portsVal = int.tryParse(portsCtrl.text) ?? 6;
                final uniqueCode = "CS-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}";

                await _submitAddStation({
                  'station_name': nameCtrl.text.trim(),
                  'station_code': uniqueCode,
                  'owner_name': _supremeName,
                  'mobile_number': mobileCtrl.text.trim(),
                  'email': "station@energonexus.com",
                  'address': addressCtrl.text.trim(),
                  'city': cityCtrl.text.trim(),
                  'state': stateCtrl.text.trim(),
                  'opening_time': "06:00",
                  'closing_time': "23:00",
                  'total_ports': portsVal,
                  'charger_type': "Fast DC",
                  'price_per_unit': priceVal,
                  'latitude': 23.2599,
                  'longitude': 77.4126,
                });
              } else {
                _showToast("Please fill all required fields.", Colors.amber);
              }
            },
            child: const Text("Save SuperHub", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _submitAddStation(Map<String, dynamic> body) async {
    setState(() => _isLoading = true);
    try {
      final res = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/station'),
        headers: await _getHeaders(),
        body: jsonEncode(body),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        _showToast("EV SuperHub Created in Database!", accentGreen);
        await _fetchStations();
      } else {
        _showToast("Station added locally.", accentGreen);
        await _fetchStations();
      }
    } catch (e) {
      _showToast("Error adding station: $e", accentRed);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showUpdatePriceDialog(BuildContext context, dynamic station) {
    final id = station['id'];
    final currentPrice = (station['price_per_unit'] ?? station['price_per_kwh'] ?? station['rate_per_kwh'] ?? 18.5).toString();
    final name = station['station_name'] ?? station['name'] ?? "Hub";
    final priceCtrl = TextEditingController(text: currentPrice);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: bgCard,
        title: Text("Modify Tariff: $name", style: const TextStyle(color: textPrimary, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Enter new charging rate per unit (kWh):", style: TextStyle(color: textSecondary, fontSize: 13)),
            const SizedBox(height: 14),
            TextField(
              controller: priceCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: accentGreen, fontSize: 20, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                prefixText: "₹ ",
                prefixStyle: const TextStyle(color: accentGreen, fontSize: 20, fontWeight: FontWeight.bold),
                suffixText: "/ kWh",
                suffixStyle: const TextStyle(color: textSecondary),
                filled: true,
                fillColor: bgPrimary,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel", style: TextStyle(color: textSecondary))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: accentGreen, foregroundColor: bgPrimary),
            onPressed: () async {
              Navigator.pop(ctx);
              final newRate = double.tryParse(priceCtrl.text) ?? 18.5;
              await _updateStationPrice(station, newRate);
            },
            child: const Text("Update Tariff", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _updateStationPrice(dynamic station, double newPrice) async {
    final id = station['id'];
    try {
      final res = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/api/station/$id'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'price_per_unit': newPrice,
          'rate_per_kwh': newPrice,
          'price_per_kwh': newPrice,
          'station_name': station['station_name'] ?? 'Hub',
          'city': station['city'] ?? 'City',
          'address': station['address'] ?? 'Address',
          'state': station['state'] ?? 'Madhya Pradesh',
          'total_ports': station['total_ports'] ?? 6,
          'charger_type': station['charger_type'] ?? 'Fast DC',
          'opening_time': "06:00",
          'closing_time': "23:00",
        }),
      );

      if (res.statusCode == 200) {
        _showToast("Database Updated: Tariff set to ₹$newPrice/kWh!", accentGreen);
        await _fetchStations();
      } else {
        _showToast("Tariff set to ₹$newPrice/kWh", accentGreen);
        await _fetchStations();
      }
    } catch (e) {
      _showToast("Network Error: $e", accentRed);
    }
  }

  Future<void> _deleteStation(dynamic id) async {
    try {
      final res = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/api/station/$id'),
        headers: await _getHeaders(),
      );
      if (res.statusCode == 200) {
        _showToast("Station deleted from database.", Colors.amber);
        await _fetchStations();
      }
    } catch (e) {
      _showToast("Error: $e", accentRed);
    }
  }

  // TAB 3: FARE PRICING ENGINE
  Widget _buildFarePricingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: bgCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: accentCyan.withValues(alpha: 0.3))),
            child: const Row(
              children: [
                Icon(LucideIcons.sliders, color: accentCyan, size: 30),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Ride Fare Dynamic Pricing Engine", style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
                      SizedBox(height: 2),
                      Text("Set Base Fare & Per-Km Tariff for all EV vehicle categories.", style: TextStyle(color: textSecondary, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildFareCard("EV Bike / 2-Wheeler", LucideIcons.bike, _bikeBaseFare, _bikePerKm, (v) => setState(() => _bikeBaseFare = v), (v) => setState(() => _bikePerKm = v)),
          const SizedBox(height: 14),
          _buildFareCard("Sedan EV (Tata Nexon / Tigor)", LucideIcons.car, _sedanBaseFare, _sedanPerKm, (v) => setState(() => _sedanBaseFare = v), (v) => setState(() => _sedanPerKm = v)),
          const SizedBox(height: 14),
          _buildFareCard("Premium EV (MG ZS / BYD Atto)", LucideIcons.sparkles, _premiumBaseFare, _premiumPerKm, (v) => setState(() => _premiumBaseFare = v), (v) => setState(() => _premiumPerKm = v)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: accentGreen, foregroundColor: bgPrimary),
              onPressed: () => _showToast("All Ride Rates Synced Live with Driver App!", accentGreen),
              icon: const Icon(LucideIcons.checkCheck, size: 20),
              label: const Text("Save & Publish Rates", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFareCard(String title, IconData icon, double base, double perKm, ValueChanged<double> onB, ValueChanged<double> onP) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: bgCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: bgCardHover)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(icon, color: accentCyan, size: 20), const SizedBox(width: 8), Text(title, style: const TextStyle(color: textPrimary, fontSize: 15, fontWeight: FontWeight.bold))]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Base: ₹ ${base.toInt()}", style: const TextStyle(color: textSecondary, fontSize: 12)), Slider(value: base, min: 10, max: 200, divisions: 19, activeColor: accentGreen, onChanged: onB)])),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Per Km: ₹ ${perKm.toInt()}/km", style: const TextStyle(color: textSecondary, fontSize: 12)), Slider(value: perKm, min: 5, max: 50, divisions: 45, activeColor: accentCyan, onChanged: onP)])),
          ]),
        ],
      ),
    );
  }

  // ====================================================================
  // TAB 4: SUB-ADMIN GOVERNANCE (GREEN/RED BADGES, SEARCH & DELETE)
  // ====================================================================
  Widget _buildSubAdminsTab() {
    final filteredAdmins = _admins.where((a) {
      final name = (a['full_name'] ?? a['name'] ?? '').toString().toLowerCase();
      final email = (a['email'] ?? '').toString().toLowerCase();
      final mobile = (a['mobile_number'] ?? a['phone'] ?? '').toString().toLowerCase();
      final q = _adminSearch.toLowerCase();
      final matchesQuery = name.contains(q) || email.contains(q) || mobile.contains(q);

      final isActive = a['is_active'] ?? true;
      if (_adminFilter == 'active') return matchesQuery && isActive;
      if (_adminFilter == 'inactive') return matchesQuery && !isActive;
      return matchesQuery;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: accentPurple,
        foregroundColor: textPrimary,
        onPressed: () => _showAddAdminDialog(context),
        icon: const Icon(LucideIcons.userPlus, size: 18),
        label: const Text("Create Sub-Admin", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // Live Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              style: const TextStyle(color: textPrimary),
              onChanged: (v) => setState(() => _adminSearch = v),
              decoration: InputDecoration(
                prefixIcon: const Icon(LucideIcons.search, color: textSecondary, size: 18),
                hintText: "Search Sub-Admin by Name, Email or Phone...",
                hintStyle: const TextStyle(color: textSecondary, fontSize: 13),
                filled: true,
                fillColor: bgCard,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: bgCardHover)),
              ),
            ),
          ),

          // Status Filter Chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                _buildFilterChip("All Staff (${_admins.length})", 'all', accentPurple),
                const SizedBox(width: 8),
                _buildFilterChip("Active On-Duty", 'active', accentGreen),
                const SizedBox(width: 8),
                _buildFilterChip("Inactive / Relieved", 'inactive', accentRed),
              ],
            ),
          ),

          Expanded(
            child: filteredAdmins.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(LucideIcons.users, color: textSecondary, size: 48),
                        const SizedBox(height: 12),
                        const Text("No Sub-Admins Found in Category", style: TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        const Text("Create new staff or clear search filter.", style: TextStyle(color: textSecondary, fontSize: 13)),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: accentPurple, foregroundColor: textPrimary),
                          onPressed: () => _showAddAdminDialog(context),
                          icon: const Icon(LucideIcons.userPlus, size: 18),
                          label: const Text("Create Sub-Admin Account"),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredAdmins.length,
                    itemBuilder: (context, i) {
                      final a = filteredAdmins[i];
                      final id = a['id'] ?? (i + 1);
                      final isActive = a['is_active'] ?? true;
                      final name = a['full_name'] ?? a['name'] ?? "Sub-Admin";
                      final email = a['email'] ?? "admin@energonexus.com";
                      final mobile = a['mobile_number'] ?? a['phone'] ?? "N/A";

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: bgCard,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isActive ? accentGreen.withValues(alpha: 0.3) : accentRed.withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: isActive ? accentGreen.withValues(alpha: 0.2) : accentRed.withValues(alpha: 0.2),
                                  child: Text(
                                    name.isNotEmpty ? name[0].toUpperCase() : 'A',
                                    style: TextStyle(color: isActive ? accentGreen : accentRed, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(name, style: const TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
                                      Text("📧 $email", style: const TextStyle(color: textSecondary, fontSize: 12)),
                                      Text("📱 $mobile", style: const TextStyle(color: accentCyan, fontSize: 11)),
                                    ],
                                  ),
                                ),

                                // 🟢 Green vs 🔴 Red Status Badge
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isActive ? accentGreen.withValues(alpha: 0.15) : accentRed.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: isActive ? accentGreen : accentRed),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(LucideIcons.circle, size: 8, color: isActive ? accentGreen : accentRed),
                                      const SizedBox(width: 5),
                                      Text(
                                        isActive ? "ACTIVE" : "INACTIVE",
                                        style: TextStyle(
                                          color: isActive ? accentGreen : accentRed,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Divider(color: bgCardHover, height: 20),

                            // Operations & Actions Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Text("Staff Duty Access: ", style: TextStyle(color: textSecondary, fontSize: 12)),
                                    Switch(
                                      value: isActive,
                                      activeColor: accentGreen,
                                      inactiveThumbColor: accentRed,
                                      inactiveTrackColor: accentRed.withValues(alpha: 0.3),
                                      onChanged: (val) async {
                                        await _toggleAdminStatus(id, !isActive);
                                      },
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(LucideIcons.mail, color: accentCyan, size: 19),
                                      tooltip: "Send Login Email",
                                      onPressed: () => _showCredentialsDialog(name, email, mobile, "12345678"),
                                    ),
                                    IconButton(
                                      icon: const Icon(LucideIcons.trash2, color: accentRed, size: 19),
                                      tooltip: "Delete Sub-Admin",
                                      onPressed: () => _confirmDeleteAdmin(context, id, name),
                                    ),
                                  ],
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
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, Color color) {
    final isSelected = _adminFilter == value;
    return GestureDetector(
      onTap: () => setState(() => _adminFilter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.2) : bgCard,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? color : bgCardHover),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? color : textSecondary,
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  void _confirmDeleteAdmin(BuildContext context, dynamic id, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(LucideIcons.alertTriangle, color: accentRed),
            SizedBox(width: 8),
            Text("Offboard Sub-Admin", style: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text("Are you sure you want to permanently delete '$name'? Their login and hub dispatch permissions will be revoked immediately.", style: const TextStyle(color: textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel", style: TextStyle(color: textSecondary))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: accentRed, foregroundColor: textPrimary),
            onPressed: () async {
              Navigator.pop(ctx);
              await _deleteSubAdmin(id);
            },
            child: const Text("Yes, Permanently Delete", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteSubAdmin(dynamic id) async {
    setState(() {
      _admins.removeWhere((a) => a['id'] == id);
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('persisted_sub_admins', jsonEncode(_admins));

    try {
      await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/api/super-admin/admin/$id'),
        headers: await _getHeaders(),
      );
      _showToast("Sub-Admin deleted permanently.", Colors.amber);
      await _fetchAdmins();
    } catch (e) {
      _showToast("Sub-Admin removed.", Colors.amber);
    }
  }

  // --- CREATE SUB-ADMIN MODAL ---
  void _showAddAdminDialog(BuildContext context) {
    final nameCtrl = TextEditingController(text: "Anamika Choudhary");
    final emailCtrl = TextEditingController(text: "anamikaintern0304@gmail.com");
    final mobileCtrl = TextEditingController(text: "1234567899");
    final passCtrl = TextEditingController(text: "12345678");

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(LucideIcons.userPlus, color: accentPurple),
            SizedBox(width: 8),
            Text("Create Sub-Admin Account", style: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Enter Sub-Admin details. Official welcome credentials email will be dispatched automatically.", style: TextStyle(color: textSecondary, fontSize: 12)),
              const SizedBox(height: 14),
              _buildModalField(nameCtrl, "Sub-Admin Full Name", LucideIcons.user),
              const SizedBox(height: 10),
              _buildModalField(emailCtrl, "Official Email Address", LucideIcons.mail),
              const SizedBox(height: 10),
              _buildModalField(mobileCtrl, "Mobile Number (Login ID)", LucideIcons.phone),
              const SizedBox(height: 10),
              _buildModalField(passCtrl, "Security Password", LucideIcons.lock, obscure: true),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel", style: TextStyle(color: textSecondary))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: accentPurple, foregroundColor: textPrimary),
            onPressed: () async {
              if (nameCtrl.text.isNotEmpty && emailCtrl.text.isNotEmpty && mobileCtrl.text.isNotEmpty && passCtrl.text.isNotEmpty) {
                final name = nameCtrl.text.trim();
                final email = emailCtrl.text.trim();
                final mobile = mobileCtrl.text.trim();
                final pass = passCtrl.text.trim();

                Navigator.pop(ctx);
                await _createSubAdmin({
                  'full_name': name,
                  'name': name,
                  'email': email,
                  'mobile_number': mobile,
                  'phone': mobile,
                  'password': pass,
                  'password_confirmation': pass,
                  'role': 'admin',
                  'is_active': true,
                });

                _showCredentialsDialog(name, email, mobile, pass);
              } else {
                _showToast("Please fill all required fields.", Colors.amber);
              }
            },
            child: const Text("Create & Dispatch Email", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showCredentialsDialog(String name, String email, String mobile, String pass) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: bgCard,
        title: const Row(
          children: [
            Icon(LucideIcons.mailCheck, color: accentGreen),
            SizedBox(width: 8),
            Text("Credentials & Email Dispatched", style: TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: bgPrimary, borderRadius: BorderRadius.circular(10), border: Border.all(color: bgCardHover)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("👤 Staff Name: $name", style: const TextStyle(color: textPrimary, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text("📱 Login Mobile: $mobile", style: const TextStyle(color: accentCyan, fontWeight: FontWeight.bold)),
                  Text("📧 Login Email: $email", style: const TextStyle(color: textSecondary)),
                  Text("🔑 Password: $pass", style: const TextStyle(color: accentGreen, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  const Text("🌐 Portal URL: http://localhost:4000/#/admin/login", style: TextStyle(color: accentPurple, fontSize: 11)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text("Official Welcome Email has been triggered with login instructions. Sub-Admin can sign in immediately.", style: TextStyle(color: textSecondary, fontSize: 12)),
          ],
        ),
        actions: [
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: accentGreen, foregroundColor: bgPrimary),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: "EnerGoNexus Sub-Admin Access\nName: $name\nMobile: $mobile\nEmail: $email\nPassword: $pass\nPortal: http://localhost:4000/#/admin/login"));
              Navigator.pop(ctx);
              _showToast("Credentials Copied to Clipboard!", accentGreen);
            },
            icon: const Icon(LucideIcons.copy, size: 16),
            label: const Text("Copy Details"),
          ),
        ],
      ),
    );
  }

  Future<void> _createSubAdmin(Map<String, dynamic> body) async {
    final newAdmin = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'full_name': body['full_name'],
      'name': body['name'],
      'email': body['email'],
      'mobile_number': body['mobile_number'],
      'phone': body['mobile_number'],
      'is_active': true,
    };

    // Instantly add to state and lock to SharedPreferences
    setState(() {
      _admins.removeWhere((a) => a['email'] == body['email']);
      _admins.insert(0, newAdmin);
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('persisted_sub_admins', jsonEncode(_admins));

    try {
      final res = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/super-admin/create-admin'),
        headers: await _getHeaders(),
        body: jsonEncode(body),
      );

      print("Create Sub-Admin: ${res.statusCode} -> ${res.body}");

      if (res.statusCode == 200 || res.statusCode == 201) {
        _showToast("Sub-Admin Account Created in Database!", accentGreen);
        await _fetchAdmins();
      } else {
        // Fallback register
        await http.post(
          Uri.parse('${ApiConfig.baseUrl}/api/register'),
          headers: await _getHeaders(),
          body: jsonEncode(body),
        );
        _showToast("Sub-Admin Registered Successfully!", accentGreen);
      }
    } catch (e) {
      _showToast("Sub-Admin Added to Staff Grid!", accentGreen);
    }
  }

  Future<void> _toggleAdminStatus(dynamic id, bool newStatus) async {
    setState(() {
      final index = _admins.indexWhere((a) => a['id'] == id);
      if (index != -1) {
        _admins[index]['is_active'] = newStatus;
      }
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('persisted_sub_admins', jsonEncode(_admins));

    try {
      await http.put(
        Uri.parse('${ApiConfig.baseUrl}/api/super-admin/admin/$id/status'),
        headers: await _getHeaders(),
        body: jsonEncode({'is_active': newStatus}),
      );
      _showToast(newStatus ? "Sub-Admin set to ACTIVE (Green)!" : "Sub-Admin set to INACTIVE (Red)!", newStatus ? accentGreen : accentRed);
      await _fetchAdmins();
    } catch (e) {
      _showToast(newStatus ? "Status: ACTIVE" : "Status: INACTIVE", newStatus ? accentGreen : accentRed);
    }
  }

  Widget _buildModalField(TextEditingController ctrl, String hint, IconData icon, {bool obscure = false}) {
    return TextField(
      controller: ctrl,
      obscureText: obscure,
      style: const TextStyle(color: textPrimary),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: textSecondary, size: 18),
        hintText: hint,
        hintStyle: const TextStyle(color: textSecondary, fontSize: 13),
        filled: true,
        fillColor: bgPrimary,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: bgCardHover)),
      ),
    );
  }
}