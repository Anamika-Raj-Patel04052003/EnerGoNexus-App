import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

enum ActiveRideStage {
  searching,
  driverAssigned,
  headingToPickup,
  driverArrived,
  inTransit,
  reachedDestination,
  completed,
}

enum DriverType {
  soloDriver,         // 🚕 इंडिपेंडेंट ड्राइवर (अपनी EV, सीधा किराया/कैश)
  brokerFleetDriver,  // 🏢 ब्रोकर फ्लीट ड्राइवर (ब्रोकर EV, 100% वॉल्ट, नो कैश, सैलरी)
}

class EnergoUnifiedService extends ChangeNotifier {
  static final EnergoUnifiedService _instance = EnergoUnifiedService._internal();
  factory EnergoUnifiedService() => _instance;

  EnergoUnifiedService._internal() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      _checkAndAutoReleaseExpiredSlots();
    });
  }

  // LARAVEL UNIFIED BACKEND BASE URL
  static const String baseUrl = "http://127.0.0.1:8000/api";

  Future<void> init() async {
    await fetchBackendStats();
  }

  // ====================================================
  // 1. DUAL DRIVER & BROKER ECOSYSTEM STATE & BACKEND
  // ====================================================
  DriverType currentDriverType = DriverType.brokerFleetDriver;

  // A. SOLO DRIVER DATA (इंडिपेंडेंट ड्राइवर)
  String soloDriverName = "Rajesh Verma (Self-Owned EV)";
  String soloVehicleNumber = "MP 04 EV 9911";
  String soloVehicleModel = "Tata Tiago EV";
  String soloPersonalUpi = "rajesh.driver@paytm";
  double soloDriverWallet = 1850.0;
  double soloCommissionDue = 185.0;

  // B. BROKER FLEET DATA (ब्रोकर फ्लीट ड्राइवर)
  String brokerCompanyName = "Bhopal Green Mobility Fleet Ltd.";
  String brokerCorporateUpi = "greenfleet.corporate@icici";
  String brokerDriverName = "Vikram Sharma (Fleet EV-04)";
  String brokerVehicleNumber = "MP 04 EV 8891";
  String brokerVehicleModel = "Tata Nexon EV Max";
  double brokerVaultBalance = 84950.00;
  double brokerDriverAccruedSalary = 1450.00; // ड्राइवर की सैलरी लेजर
  int brokerDriverCompletedTrips = 11;
  String driverDutyStatus = "ON_DUTY";

  // DYNAMIC GETTERS FOR SCREENS
  String get driverName => currentDriverType == DriverType.soloDriver ? soloDriverName : brokerDriverName;
  String get vehicleName => currentDriverType == DriverType.soloDriver ? soloVehicleModel : brokerVehicleModel;
  String get vehiclePlate => currentDriverType == DriverType.soloDriver ? soloVehicleNumber : brokerVehicleNumber;

  // 1-TAP SALARY PAYOUT METHODS (SOLVES THE COMPILER ERROR)
  void payDriverSalaryWage(double amount) {
    if (brokerVaultBalance >= amount) {
      brokerVaultBalance -= amount;
      brokerDriverAccruedSalary = (brokerDriverAccruedSalary - amount).clamp(0.0, 999999.0);
      notifyListeners();
    }
  }

  void payDriverWage(double amount) => payDriverSalaryWage(amount);

  // C. SUPERHUB FLEET EXPENSE LIST
  List<Map<String, dynamic>> fleetExpenses = [
    {"type": "SuperHub DC Fast Charge (32 kWh)", "hub": "Central SuperHub", "amount": 480.0, "time": "Today, 02:15 PM"},
    {"type": "Smart Reserved EV Parking (2 Hrs)", "hub": "DB Mall SuperHub", "amount": 30.0, "time": "Today, 11:40 AM"},
  ];

  void setDriverType(DriverType type) {
    currentDriverType = type;
    notifyListeners();
  }

  void updateDriverDutyStatus(String status) {
    driverDutyStatus = status;
    notifyListeners();
  }

  // ====================================================
  // 2. DISPATCH & RIDE STATE ENGINE (CONNECTED TO BACKEND)
  // ====================================================
  bool hasIncomingRideRequest = true;
  bool isDriverOnTrip = false;
  ActiveRideStage currentRideStage = ActiveRideStage.headingToPickup;

  // COMPATIBILITY GETTERS
  ActiveRideStage get rideStage => currentRideStage;
  String get currentRideId => "ENR-99824";
  double get rideFare => currentRideFare;
  final double currentRideFare = 120.0;
  final String ridePin = "7842";
  final String passengerName = "Anamika Choudhary";
  final String pickupLocation = "Zone 1, MP Nagar";
  final String dropLocation = "Raja Bhoj Airport, VIP Road";

  double driverTodayEarnings = 2450.0;
  int driverTodayTripsCount = 8;

  final List<Map<String, dynamic>> driverTripsHistory = [
    {
      'id': 'TRP-8812',
      'passenger': 'Rahul Sharma',
      'pickup': 'ISBT Bus Stand',
      'drop': 'MP Nagar Zone 2',
      'fare': 85.0,
      'time': 'Today, 02:15 PM',
      'rating': 5.0,
      'status': 'COMPLETED',
    },
    {
      'id': 'TRP-8809',
      'passenger': 'Priya Sen',
      'pickup': 'Arera Colony E-3',
      'drop': 'DB City Mall',
      'fare': 110.0,
      'time': 'Today, 12:30 PM',
      'rating': 4.9,
      'status': 'COMPLETED',
    },
  ];

  void passengerBookRide() {
    hasIncomingRideRequest = true;
    isDriverOnTrip = false;
    currentRideStage = ActiveRideStage.headingToPickup;
    notifyListeners();
  }

  void driverAcceptRide() {
    hasIncomingRideRequest = false;
    isDriverOnTrip = true;
    currentRideStage = ActiveRideStage.headingToPickup;
    notifyListeners();
  }

  void driverRejectRide() {
    hasIncomingRideRequest = false;
    notifyListeners();
  }

  void updateRideStage(ActiveRideStage newStage) {
    currentRideStage = newStage;
    notifyListeners();
  }

  void completeRideAndRouteFare({int driverStars = 5}) {
    completeRideAndAddToHistory(driverStars: driverStars);
  }

  // RIDE COMPLETION & SYNC WITH LARAVEL BACKEND
  Future<void> completeRideAndAddToHistory({int driverStars = 5}) async {
    hasIncomingRideRequest = false;
    isDriverOnTrip = false;
    currentRideStage = ActiveRideStage.completed;

    if (currentDriverType == DriverType.soloDriver) {
      final commission = currentRideFare * 0.10;
      final netEarning = currentRideFare - commission;
      soloDriverWallet += netEarning;
      soloCommissionDue += commission;
      driverTodayEarnings += netEarning;
    } else {
      brokerVaultBalance += currentRideFare;
      brokerDriverAccruedSalary += 40.0;
      brokerDriverCompletedTrips += 1;
    }

    driverTodayTripsCount += 1;

    driverTripsHistory.insert(0, {
      'id': 'TRP-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
      'passenger': passengerName,
      'pickup': pickupLocation,
      'drop': dropLocation,
      'fare': currentRideFare,
      'time': 'Just Now',
      'rating': driverStars.toDouble(),
      'status': 'COMPLETED',
      'driverType': currentDriverType == DriverType.soloDriver ? 'SOLO_DRIVER' : 'BROKER_FLEET',
    });

    notifyListeners();

    // 📡 SEND TO LARAVEL BACKEND API
    try {
      await http.post(
        Uri.parse("$baseUrl/driver/settle-ride"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "ride_code": currentRideId,
          "driver_type": currentDriverType == DriverType.soloDriver ? "SOLO_DRIVER" : "BROKER_FLEET_DRIVER",
          "fare_amount": currentRideFare,
          "driver_id": 1,
          "fleet_broker_id": 1,
        }),
      );
    } catch (_) {
      // Offline fallback ensures UI never fails
    }
  }

  // ====================================================
  // 3. PASSENGER WALLET & 5% CASHBACK REWARDS
  // ====================================================
  double _walletBalance = 150.0;
  double get walletBalance => _walletBalance;

  final List<Map<String, dynamic>> _transactions = [
    {
      'id': 'CB-9942',
      'title': '5% Cashback on EV Fast Charging',
      'amount': 26.20,
      'type': 'CREDIT',
      'time': 'Today, 03:45 PM',
      'desc': 'Razorpay ₹523.92 Payment',
    },
  ];
  List<Map<String, dynamic>> get transactions => List.unmodifiable(_transactions);

  void recordRazorpayPaymentAndCreditCashback({
    required double amountPaid,
    required String purpose,
    required String paymentId,
  }) {
    final double cashback = amountPaid * 0.05;
    _walletBalance += cashback;

    _transactions.insert(0, {
      'id': 'CB-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
      'title': '5% Auto-Cashback Reward',
      'amount': cashback,
      'type': 'CREDIT',
      'time': 'Just Now',
      'desc': 'Earned on Razorpay ($purpose)',
    });

    notifyListeners();
  }

  bool canPayWithWallet(double amount) => _walletBalance >= amount;

  bool payWithWallet(double amount, String purpose) {
    if (_walletBalance < amount) return false;
    _walletBalance -= amount;
    _transactions.insert(0, {
      'id': 'WLT-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
      'title': 'Redeemed: $purpose',
      'amount': amount,
      'type': 'DEBIT',
      'time': 'Just Now',
      'desc': '100% Wallet Cashback Used',
    });
    notifyListeners();
    return true;
  }

  // ====================================================
  // 4. SUPERHUB STATIONS DATABASE
  // ====================================================
  final List<Map<String, dynamic>> stations = [
    {
      'id': 'STN-01',
      'name': 'EnerGo Central SuperHub',
      'area': 'MP Nagar Zone 1 • 1.2 km away',
      'rate': 18.50,
      'ports': [
        {'id': 'Port 1', 'power': '120kW Fast DC', 'kw': 120, 'isOccupied': true, 'bookedBy': 'Vikram Sharma (MP 04 EV 8891)', 'bookedUntil': DateTime.now().add(const Duration(minutes: 12))},
        {'id': 'Port 2', 'power': '120kW Fast DC', 'kw': 120, 'isOccupied': false, 'bookedBy': '', 'bookedUntil': null},
        {'id': 'Port 3', 'power': '60kW Rapid DC', 'kw': 60, 'isOccupied': true, 'bookedBy': 'Rajesh Patel', 'bookedUntil': DateTime.now().add(const Duration(minutes: 18))},
        {'id': 'Port 4', 'power': '60kW Rapid DC', 'kw': 60, 'isOccupied': false, 'bookedBy': '', 'bookedUntil': null},
      ],
      'parking': [
        {'id': 'Bay P-01', 'name': 'Fast DC Bay', 'isOccupied': true, 'plate': 'MP 04 EV 8891', 'bookedUntil': DateTime.now().add(const Duration(minutes: 45))},
        {'id': 'Bay P-02', 'name': 'Fast DC Bay', 'isOccupied': false, 'plate': '', 'bookedUntil': null},
      ],
      'beds': [
        {'id': 'Pod A1', 'name': 'Luxury AC Snooze', 'rate': 80.0, 'isOccupied': true, 'occupant': 'Captain Vikram', 'bookedUntil': DateTime.now().add(const Duration(minutes: 45))},
        {'id': 'Pod A2', 'name': 'Luxury AC Snooze', 'rate': 80.0, 'isOccupied': false, 'occupant': '', 'bookedUntil': null},
      ],
      'tables': [
        {'id': 'Table 1', 'name': 'Workstation Desk', 'rate': 40.0, 'isOccupied': true, 'guest': 'Anamika C. (5G WiFi)', 'bookedUntil': DateTime.now().add(const Duration(minutes: 35))},
        {'id': 'Table 2', 'name': 'Workstation Desk', 'rate': 40.0, 'isOccupied': false, 'guest': '', 'bookedUntil': null},
      ],
    },
  ];

  void bookAmenity({
    required String stationId,
    required String category,
    required String itemId,
    required int durationMinutes,
    required String bookedBy,
  }) {
    final stn = stations.firstWhere((s) => s['id'] == stationId, orElse: () => stations[0]);
    final List items = stn[category] as List;

    for (var it in items) {
      if (it['id'] == itemId) {
        it['isOccupied'] = true;
        it['bookedBy'] = bookedBy;
        it['occupant'] = bookedBy;
        it['guest'] = bookedBy;
        it['plate'] = bookedBy;
        it['bookedUntil'] = DateTime.now().add(Duration(minutes: durationMinutes));
        break;
      }
    }
    notifyListeners();
  }

  void _checkAndAutoReleaseExpiredSlots() {
    bool hasChanged = false;
    final now = DateTime.now();

    for (var stn in stations) {
      for (var cat in ['ports', 'parking', 'beds', 'tables']) {
        if (stn[cat] != null) {
          final List items = stn[cat] as List;
          for (var it in items) {
            if (it['isOccupied'] == true && it['bookedUntil'] != null) {
              final DateTime until = it['bookedUntil'] as DateTime;
              if (now.isAfter(until)) {
                it['isOccupied'] = false;
                it['bookedUntil'] = null;
                it['bookedBy'] = '';
                hasChanged = true;
              }
            }
          }
        }
      }
    }
    if (hasChanged) notifyListeners();
  }

  Future<void> fetchBackendStats() async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/broker/1/dashboard"));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['data'] != null && data['data']['fleet_summary'] != null) {
          brokerVaultBalance = (data['data']['fleet_summary']['vault_balance'] as num).toDouble();
          notifyListeners();
        }
      }
    } catch (_) {}
  }
}

typedef EnerGoUnifiedService = EnergoUnifiedService;