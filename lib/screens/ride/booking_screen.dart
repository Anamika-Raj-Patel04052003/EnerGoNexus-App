import 'package:flutter/material.dart';

import 'ride_confirmation_screen.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _pickupCtrl = TextEditingController(text: "Zone 1, MP Nagar, Bhopal");
  final _dropCtrl = TextEditingController(text: "Raja Bhoj Airport, VIP Road");

  String _selectedCategory = "EV_BIKE";
  String _selectedParcelWeight = "0 - 2 kg";

  final Map<String, double> _parcelWeightRates = {
    '0 - 2 kg': 50.0,
    '2 - 5 kg': 100.0,
    '5 - 15 kg': 200.0,
    '15 - 30 kg': 350.0,
  };

  final List<Map<String, dynamic>> _rideCategories = [
    {
      'id': 'EV_BIKE',
      'title': 'EV Rapid Bike (Ather / Ola)',
      'subtitle': 'Fastest solo city ride • Zero traffic delay',
      'baseFare': 120.0,
      'icon': Icons.two_wheeler,
      'color': Color(0xFF00E676),
    },
    {
      'id': 'EV_AUTO',
      'title': 'EV Smart Auto (Mahindra Treo)',
      'subtitle': 'Pocket-friendly 3-seater electric commute',
      'baseFare': 190.0,
      'icon': Icons.electric_rickshaw,
      'color': Color(0xFFFFB703),
    },
    {
      'id': 'EV_PINK',
      'title': 'EV Pink Cab (Ladies Safe Fleet)',
      'subtitle': 'Verified lady captain • High security guard',
      'baseFare': 380.0,
      'icon': Icons.shield_outlined,
      'color': Color(0xFFFF69B4),
    },
    {
      'id': 'EV_CAB',
      'title': 'EV Comfort Cab (Tata Nexon EV)',
      'subtitle': 'AC 4-seater silent zero-emission ride',
      'baseFare': 420.0,
      'icon': Icons.directions_car,
      'color': Color(0xFF00F0FF),
    },
    {
      'id': 'EV_PREMIUM',
      'title': 'EV Premium VIP (MG / Ioniq 5)',
      'subtitle': 'Executive luxury business fleet',
      'baseFare': 650.0,
      'icon': Icons.star,
      'color': Color(0xFFA855F7),
    },
    {
      'id': 'EV_CARGO',
      'title': 'EV Parcel Logistics (Cargo Freighter)',
      'subtitle': 'Distance + Weight dynamic courier delivery',
      'baseFare': 150.0,
      'icon': Icons.inventory_2,
      'color': Color(0xFFFF6D00),
    },
  ];

  @override
  void dispose() {
    _pickupCtrl.dispose();
    _dropCtrl.dispose();
    super.dispose();
  }

  double get _currentFare {
    final cat = _rideCategories.firstWhere((c) => c['id'] == _selectedCategory);
    double fare = cat['baseFare'] as double;
    if (_selectedCategory == 'EV_CARGO') {
      fare += (_parcelWeightRates[_selectedParcelWeight] ?? 50.0);
    }
    return fare;
  }

  void _confirmAndFindDriver() {
    final pickup = _pickupCtrl.text.trim();
    final drop = _dropCtrl.text.trim();

    if (pickup.isEmpty || drop.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter Pickup and Dropoff locations"), backgroundColor: Colors.amber),
      );
      return;
    }

    final cat = _rideCategories.firstWhere((c) => c['id'] == _selectedCategory);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RideConfirmationScreen(
          rideDetails: {
            'pickup': pickup,
            'dropoff': drop,
            'category': cat['title'],
            'fare': _currentFare,
            'parcel_weight': _selectedCategory == 'EV_CARGO' ? _selectedParcelWeight : null,
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080E1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF10192B),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Book EV Ride / Parcel", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 1. PICKUP & DROP LANDMARKS
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF131D31),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF00E676).withOpacity(0.35)),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _pickupCtrl,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.my_location, color: Color(0xFF00E676), size: 18),
                      labelText: "Pickup Landmark",
                      labelStyle: TextStyle(color: Colors.white54, fontSize: 12),
                      border: InputBorder.none,
                    ),
                  ),
                  const Divider(color: Colors.white12, height: 10),
                  TextField(
                    controller: _dropCtrl,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.location_on, color: Color(0xFF00F0FF), size: 18),
                      labelText: "Destination Dropoff",
                      labelStyle: TextStyle(color: Colors.white54, fontSize: 12),
                      border: InputBorder.none,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // 2. FLEET CATEGORY LIST
            const Text("Select EV Fleet Category", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 10),

            ..._rideCategories.map((cat) {
              final isSel = _selectedCategory == cat['id'];
              final color = cat['color'] as Color;

              return GestureDetector(
                onTap: () => setState(() => _selectedCategory = cat['id'] as String),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSel ? color.withOpacity(0.14) : const Color(0xFF131D31),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: isSel ? color : Colors.white12, width: isSel ? 1.6 : 1),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: color.withOpacity(0.18), shape: BoxShape.circle),
                        child: Icon(cat['icon'] as IconData, color: color, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(cat['title'] as String, style: TextStyle(color: isSel ? color : Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                            const SizedBox(height: 2),
                            Text(cat['subtitle'] as String, style: const TextStyle(color: Colors.white54, fontSize: 10)),
                          ],
                        ),
                      ),
                      Text(
                        cat['id'] == 'EV_CARGO' ? "From ₹${(cat['baseFare'] as num).toInt()}" : "₹ ${(cat['baseFare'] as num).toInt()}",
                        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ],
                  ),
                ),
              );
            }),

            // 3. PARCEL WEIGHT SELECTOR (ONLY SHOWN IF CARGO IS SELECTED)
            if (_selectedCategory == 'EV_CARGO') ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF131D31),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFF6D00).withOpacity(0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.scale, color: Color(0xFFFF6D00), size: 18),
                        SizedBox(width: 8),
                        Text("Select Parcel Package Weight", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: _parcelWeightRates.keys.map((w) {
                        final isW = _selectedParcelWeight == w;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedParcelWeight = w),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: isW ? const Color(0xFFFF6D00) : const Color(0xFF080E1A),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                children: [
                                  Text(w, style: TextStyle(color: isW ? Colors.black : Colors.white, fontWeight: FontWeight.bold, fontSize: 10.5)),
                                  Text("+₹${_parcelWeightRates[w]!.toInt()}", style: TextStyle(color: isW ? Colors.black87 : Colors.white54, fontSize: 9)),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),

            // 4. CONFIRM BUTTON
            GestureDetector(
              onTap: _confirmAndFindDriver,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF00E676),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.radar, color: Colors.black, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      "Confirm & Find Nearest Driver (₹ ${_currentFare.toInt()})",
                      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13.5),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text("🔒 Pay easily via Razorpay, Wallet or Cash after trip ends.", style: TextStyle(color: Colors.white38, fontSize: 10.5)),
            ),
          ],
        ),
      ),
    );
  }
}