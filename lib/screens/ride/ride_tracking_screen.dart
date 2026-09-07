import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../services/energo_unified_service.dart';
import 'in_app_chat_dialog.dart';
import 'ride_completed_screen.dart';

class RideTrackingScreen extends StatefulWidget {
  final Map<String, dynamic>? tripData;
  final Map<String, dynamic>? rideDetails;

  const RideTrackingScreen({
    super.key,
    this.tripData,
    this.rideDetails,
  });

  @override
  State<RideTrackingScreen> createState() => _RideTrackingScreenState();
}

class _RideTrackingScreenState extends State<RideTrackingScreen> {
  Timer? _progressTimer;
  double _tripProgress = 0.35; // 35% in transit
  int _etaMinutes = 8;
  int _speedKmh = 38;

  @override
  void initState() {
    super.initState();
    _startTripSimulation();
  }

  void _startTripSimulation() {
    _progressTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted) return;
      setState(() {
        if (_tripProgress < 0.95) {
          _tripProgress += 0.08;
          if (_etaMinutes > 1) _etaMinutes--;
          _speedKmh = 35 + (DateTime.now().second % 15);
        } else {
          _tripProgress = 1.0;
          _etaMinutes = 0;
          _speedKmh = 0;
          timer.cancel();
          final service = EnergoUnifiedService();
          service.updateRideStage(ActiveRideStage.reachedDestination);
        }
      });
    });
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    super.dispose();
  }

  // 💳 OPEN 3D GOLD COIN RAZORPAY CHECKOUT
  Future<void> _handleRazorpayPayment(EnergoUnifiedService service) async {
    final result = await RazorpayPaymentService.openCheckout(
      context: context,
      amount: service.rideFare,
      purpose: "EnerGo Nexus EV Ride - ${service.currentRideId}",
      customerName: "Anamika Choudhary",
      customerEmail: "anamikaintern0304@gmail.com",
      customerPhone: "+91 98765 43210",
    );

    if (result != null && result['status'] == 'SUCCESS') {
      service.updateRideStage(ActiveRideStage.completed);
      service.completeRideAndRouteFare();

      if (!mounted) return;
         Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (ctx) => RideCompletedScreen(
            fare: service.rideFare,
            pickup: service.pickupLocation,
            destination: service.dropLocation,
          ),
        ),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Payment was cancelled or failed."), backgroundColor: Colors.redAccent),
      );
    }
  }

  void _openChatDialog(EnergoUnifiedService service) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => InAppChatDialog(
        driverName: service.driverName,
        vehiclePlate: service.vehiclePlate,
      ),
    );
  }

  void _callDriver(String phone) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("📞 Calling Driver at $phone..."), backgroundColor: const Color(0xFF10B981)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final service = EnergoUnifiedService();

    return ListenableBuilder(
      listenable: service,
      builder: (context, _) {
        final isReached = service.rideStage == ActiveRideStage.reachedDestination || service.rideStage == ActiveRideStage.completed;

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
                const Row(
                  children: [
                    Icon(Icons.navigation, color: Color(0xFF00E5FF), size: 16),
                    SizedBox(width: 6),
                    Text("Live EV Ride Tracking", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                  ],
                ),
                Text("Ride ID: ${service.currentRideId} • Active GPS", style: const TextStyle(color: Colors.white54, fontSize: 10.5)),
              ],
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 12, top: 10, bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF10B981)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.speed, color: Color(0xFF10B981), size: 13),
                    const SizedBox(width: 4),
                    Text("$_speedKmh km/h", style: const TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
              )
            ],
          ),
          body: Column(
            children: [
              // 1. 🗺️ LIVE GOOGLE MAPS GPS VIEWPORT
              Expanded(
                flex: 5,
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Color(0xFF161F30),
                        image: DecorationImage(
                          image: NetworkImage("https://maps.googleapis.com/maps/api/staticmap?center=28.6139,77.2090&zoom=14&size=600x400&maptype=roadmap&style=element:geometry%7Ccolor:0x212121&style=element:labels.text.stroke%7Ccolor:0x212121&style=element:labels.text.fill%7Ccolor:0x757575&key=AIzaSyDp3mkbKShGs1ZHGrQ8By3sDquvoTaymzs"),
                          fit: BoxFit.cover,
                          opacity: 0.75,
                        ),
                      ),
                    ),
                    // MOVING EV CAR PIN
                    Positioned(
                      top: 120 + (_tripProgress * 60),
                      left: 100 + (_tripProgress * 140),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: Colors.black.withOpacity(0.85), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFF00E5FF))),
                            child: Text("${service.driverName} • $_speedKmh km/h", style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(color: Color(0xFF00E5FF), shape: BoxShape.circle),
                            child: const Icon(Icons.electric_car, color: Colors.black, size: 20),
                          ),
                        ],
                      ),
                    ),
                    // ETA FLOATING BADGE
                    Positioned(
                      top: 16,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(color: const Color(0xFF0F172A).withOpacity(0.9), borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white12)),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time_filled, color: Color(0xFF00E5FF), size: 16),
                            const SizedBox(width: 6),
                            Text(
                              isReached ? "Reached Destination" : "Arriving in $_etaMinutes mins",
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 2. 🚖 DRIVER DETAILS & LIVE ACTIONS
              Container(
                padding: const EdgeInsets.all(18),
                decoration: const BoxDecoration(
                  color: Color(0xFF111827),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(color: Colors.black54, blurRadius: 20, spreadRadius: 4),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // DRIVER HERO
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: const Color(0xFF0284C7).withOpacity(0.2),
                          child: const Icon(Icons.person, color: Color(0xFF00E5FF), size: 28),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(service.driverName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                                  const SizedBox(width: 6),
                                  const Icon(Icons.star, color: Colors.amber, size: 14),
                                  const Text(" 4.9", style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12)),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text("${service.vehiclePlate} • Tata Nexon EV Max", style: const TextStyle(color: Colors.white70, fontSize: 11.5)),
                            ],
                          ),
                        ),
                        // CALL BUTTON
                        IconButton(
                          style: IconButton.styleFrom(backgroundColor: const Color(0xFF10B981).withOpacity(0.15)),
                          icon: const Icon(Icons.call, color: Color(0xFF10B981), size: 20),
                          onPressed: () => _callDriver("+91 98765 43210"),
                        ),
                        const SizedBox(width: 8),
                        // CHAT BUTTON
                        IconButton(
                          style: IconButton.styleFrom(backgroundColor: const Color(0xFF00E5FF).withOpacity(0.15)),
                          icon: const Icon(Icons.chat_bubble_outline, color: Color(0xFF00E5FF), size: 20),
                          onPressed: () => _openChatDialog(service),
                        ),
                      ],
                    ),
                    const Divider(color: Colors.white10, height: 24),

                    // OTP / PIN ROW
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(color: const Color(0xFF161F30), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.3))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.lock_clock, color: Color(0xFF00E5FF), size: 16),
                              SizedBox(width: 8),
                              Text("Start Trip Ride PIN:", style: TextStyle(color: Colors.white70, fontSize: 12)),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(color: const Color(0xFF00E5FF).withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                            child: Text(service.ridePin, style: const TextStyle(color: Color(0xFF00E5FF), letterSpacing: 3, fontWeight: FontWeight.bold, fontSize: 15)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // ROUTE DETAILS
                    Row(
                      children: [
                        const Icon(Icons.my_location, color: Color(0xFF10B981), size: 14),
                        const SizedBox(width: 8),
                        Expanded(child: Text(service.pickupLocation, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 12))),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.redAccent, size: 14),
                        const SizedBox(width: 8),
                        Expanded(child: Text(service.dropLocation, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 12))),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 💳 PAYMENT / COMPLETE BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0284C7),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => _handleRazorpayPayment(service),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.bolt, color: Colors.amber, size: 18),
                            const SizedBox(width: 8),
                            Text("Pay ₹${service.rideFare} via Razorpay (5% Cashback)", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                          ],
                        ),
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
}

// =========================================================================
// 🌟 INTEGRATED RAZORPAY PAYMENT SERVICE WITH 3D ROTATING COIN & NPCI PIN
// =========================================================================
class RazorpayPaymentService {
  static const String razorpayKeyId = "rzp_test_TXyMPmbx2lodQp";

  static Future<Map<String, dynamic>?> openCheckout({
    required BuildContext context,
    required double amount,
    required String purpose,
    String customerName = "Anamika Choudhary",
    String customerEmail = "anamikaintern0304@gmail.com",
    String customerPhone = "+91 98765 43210",
  }) async {
    return showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _DynamicRazorpayCheckoutSuite(
        amount: amount,
        purpose: purpose,
        customerName: customerName,
        customerEmail: customerEmail,
        customerPhone: customerPhone,
        keyId: razorpayKeyId,
      ),
    );
  }
}

class _DynamicRazorpayCheckoutSuite extends StatefulWidget {
  final double amount;
  final String purpose;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final String keyId;

  const _DynamicRazorpayCheckoutSuite({
    required this.amount,
    required this.purpose,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.keyId,
  });

  @override
  State<_DynamicRazorpayCheckoutSuite> createState() => _DynamicRazorpayCheckoutSuiteState();
}

class _DynamicRazorpayCheckoutSuiteState extends State<_DynamicRazorpayCheckoutSuite> with SingleTickerProviderStateMixin {
  String _activeTab = "upi";

  final List<Map<String, dynamic>> _dynamicLinkedBanks = [
    {'bank': 'HDFC Bank', 'accountNo': '•••• 4891', 'holder': 'Anamika Choudhary', 'vpa': 'anamika@okhdfcbank', 'pinLength': 6, 'logo': '🏦'},
    {'bank': 'State Bank of India (SBI)', 'accountNo': '•••• 1122', 'holder': 'Anamika Choudhary', 'vpa': 'anamika@oksbi', 'pinLength': 6, 'logo': '🏛️'},
    {'bank': 'ICICI Bank', 'accountNo': '•••• 3344', 'holder': 'Anamika Choudhary', 'vpa': 'anamika@icici', 'pinLength': 4, 'logo': '🏢'},
  ];

  int _selectedBankIndex = 0;
  late AnimationController _coinAnimCtrl;
  bool _isProcessingWithCoin = false;
  String _processingMethodName = "";

  final _cardNoCtrl = TextEditingController(text: "4111 1111 1111 1111");
  final _expiryCtrl = TextEditingController(text: "12/28");
  final _cvvCtrl = TextEditingController(text: "123");

  @override
  void initState() {
    super.initState();
    _coinAnimCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat();
  }

  @override
  void dispose() {
    _coinAnimCtrl.dispose();
    _cardNoCtrl.dispose();
    _expiryCtrl.dispose();
    _cvvCtrl.dispose();
    super.dispose();
  }

  void _openNpciPinKeypad(Map<String, dynamic> bank) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (pinCtx) => _NpciDynamicPinModal(
        amount: widget.amount,
        bank: bank,
        onPinSuccess: (pin) {
          Navigator.pop(pinCtx);
          _startCoinAnimation("UPI (${bank['bank']})");
        },
      ),
    );
  }

  void _startCoinAnimation(String method) {
    setState(() {
      _isProcessingWithCoin = true;
      _processingMethodName = method;
    });

    Timer(const Duration(milliseconds: 2400), () {
      if (!mounted) return;
      final generatedPayId = "pay_TXy_${Random().nextInt(899999) + 100000}";
      Navigator.pop(context, {
        'status': 'SUCCESS',
        'payment_id': generatedPayId,
        'order_id': "order_${Random().nextInt(899999) + 100000}",
        'method': method,
        'amount': widget.amount,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        width: 460,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
                decoration: const BoxDecoration(color: Color(0xFF0C2340)),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(color: const Color(0xFF0284C7), borderRadius: BorderRadius.circular(8)),
                              child: const Icon(Icons.bolt, color: Colors.white, size: 20),
                            ),
                            const SizedBox(width: 10),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("EnerGo Nexus EV Ltd.", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                                Text("Razorpay Trusted Gateway", style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10)),
                              ],
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                          onPressed: () => Navigator.pop(context, {'status': 'CANCELLED'}),
                        ),
                      ],
                    ),
                    const Divider(color: Colors.white12, height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(widget.purpose, style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 11)),
                        Text("₹ ${widget.amount.toStringAsFixed(2)}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                      ],
                    ),
                  ],
                ),
              ),

              if (_isProcessingWithCoin) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                  child: Column(
                    children: [
                      AnimatedBuilder(
                        animation: _coinAnimCtrl,
                        builder: (context, child) {
                          final double angle = _coinAnimCtrl.value * 2 * pi;
                          return Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()..setEntry(3, 2, 0.002)..rotateY(angle),
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const RadialGradient(colors: [Color(0xFFFFDF00), Color(0xFFD4AF37), Color(0xFF996515)]),
                                border: Border.all(color: const Color(0xFFFFF8DC), width: 3),
                              ),
                              child: const Center(
                                child: Text("₹", style: TextStyle(color: Color(0xFF4A3B00), fontSize: 42, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      Text("Processing Payment via $_processingMethodName...", style: const TextStyle(color: Color(0xFF0C2340), fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                ),
              ] else ...[
                Container(
                  color: const Color(0xFFF8FAFC),
                  child: Row(
                    children: [
                      _buildTab("upi", Icons.account_balance_wallet, "UPI"),
                      _buildTab("cards", Icons.credit_card, "Cards"),
                      _buildTab("qr", Icons.qr_code_2, "QR"),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: _activeTab == "upi"
                      ? _buildUpiSection()
                      : (_activeTab == "cards" ? _buildCardSection() : _buildQrSection()),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab(String id, IconData icon, String label) {
    final isSel = _activeTab == id;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeTab = id),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSel ? Colors.white : const Color(0xFFF1F5F9),
            border: Border(bottom: BorderSide(color: isSel ? const Color(0xFF0C2340) : Colors.transparent, width: 2.5)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isSel ? const Color(0xFF0C2340) : const Color(0xFF64748B), size: 15),
              const SizedBox(width: 5),
              Text(label, style: TextStyle(color: isSel ? const Color(0xFF0C2340) : const Color(0xFF64748B), fontWeight: isSel ? FontWeight.bold : FontWeight.normal, fontSize: 11.5)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpiSection() {
    return Column(
      children: [
        ..._dynamicLinkedBanks.asMap().entries.map((entry) {
          final idx = entry.key;
          final acc = entry.value;
          final isSel = _selectedBankIndex == idx;

          return GestureDetector(
            onTap: () => setState(() => _selectedBankIndex = idx),
            child: Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSel ? const Color(0xFFEFF6FF) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: isSel ? const Color(0xFF0284C7) : const Color(0xFFE2E8F0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(acc['logo'] as String, style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 10),
                      Text("${acc['bank']} ${acc['accountNo']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                  Icon(isSel ? Icons.radio_button_checked : Icons.radio_button_off, color: isSel ? const Color(0xFF0284C7) : Colors.black26, size: 18),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 44,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0C2340), foregroundColor: Colors.white),
            onPressed: () => _openNpciPinKeypad(_dynamicLinkedBanks[_selectedBankIndex]),
            child: Text("Pay ₹ ${widget.amount.toStringAsFixed(2)} via ${_dynamicLinkedBanks[_selectedBankIndex]['bank']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ),
      ],
    );
  }

  Widget _buildCardSection() {
    return Column(
      children: [
        TextField(controller: _cardNoCtrl, decoration: const InputDecoration(labelText: "Card Number", filled: true, fillColor: Color(0xFFF8FAFC))),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: TextField(controller: _expiryCtrl, decoration: const InputDecoration(labelText: "MM/YY", filled: true, fillColor: Color(0xFFF8FAFC)))),
            const SizedBox(width: 8),
            Expanded(child: TextField(controller: _cvvCtrl, obscureText: true, maxLength: 3, decoration: const InputDecoration(labelText: "CVV", counterText: "", filled: true, fillColor: Color(0xFFF8FAFC)))),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 44,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0C2340), foregroundColor: Colors.white),
            onPressed: () => _startCoinAnimation("Card"),
            child: Text("Pay ₹ ${widget.amount.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildQrSection() {
    return Column(
      children: [
        Image.network('https://api.qrserver.com/v1/create-qr-code/?size=120x120&data=upi://pay?pa=energo@hdfcbank&am=${widget.amount}', width: 110, height: 110),
        const SizedBox(height: 10),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF16A34A), foregroundColor: Colors.white),
          onPressed: () => _startCoinAnimation("UPI QR"),
          child: const Text("Simulate QR Scanned & Paid"),
        ),
      ],
    );
  }
}

class _NpciDynamicPinModal extends StatefulWidget {
  final double amount;
  final Map<String, dynamic> bank;
  final ValueChanged<String> onPinSuccess;

  const _NpciDynamicPinModal({required this.amount, required this.bank, required this.onPinSuccess});

  @override
  State<_NpciDynamicPinModal> createState() => _NpciDynamicPinModalState();
}

class _NpciDynamicPinModalState extends State<_NpciDynamicPinModal> {
  String _pin = "";
  int get _requiredPinLength => (widget.bank['pinLength'] as int?) ?? 6;

  void _onKeyPress(String val) {
    if (_pin.length < _requiredPinLength) setState(() => _pin += val);
  }

  void _onBackspace() {
    if (_pin.isNotEmpty) setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  void _onSubmit() {
    if (_pin.length == _requiredPinLength) {
      widget.onPinSuccess(_pin);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Enter $_requiredPinLength-digit UPI PIN"), backgroundColor: Colors.redAccent));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 500,
      decoration: const BoxDecoration(color: Color(0xFF0F172A), borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(color: Color(0xFF1E293B), borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("${widget.bank['bank']} (${widget.bank['accountNo']})", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                const Text("NPCI UPI", style: TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold, fontSize: 11)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_requiredPinLength, (i) {
                final isFilled = i < _pin.length;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isFilled ? const Color(0xFF00E5FF) : Colors.transparent,
                    border: Border.all(color: isFilled ? const Color(0xFF00E5FF) : Colors.white38, width: 2),
                  ),
                );
              }),
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [_key("1"), _key("2"), _key("3")]),
                Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [_key("4"), _key("5"), _key("6")]),
                Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [_key("7"), _key("8"), _key("9")]),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(icon: const Icon(Icons.backspace, color: Colors.white70), onPressed: _onBackspace),
                    _key("0"),
                    IconButton(icon: const Icon(Icons.check_circle, color: Color(0xFF00E5FF), size: 32), onPressed: _onSubmit),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _key(String text) {
    return GestureDetector(
      onTap: () => _onKeyPress(text),
      child: Container(
        width: 70,
        height: 44,
        alignment: Alignment.center,
        child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
      ),
    );
  }
}