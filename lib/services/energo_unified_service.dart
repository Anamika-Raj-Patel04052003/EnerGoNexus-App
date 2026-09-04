import 'dart:async';
import 'package:flutter/material.dart';

enum ActiveRideStage {
  headingToPickup, // Driver is coming
  driverArrived,   // Driver is at pickup
  inTransit,       // PIN verified, ride started
  reachedDestination, // Ride ended, waiting payment
  completed,       // Paid and settled
}

class EnergoUnifiedService extends ChangeNotifier {
  static final EnergoUnifiedService _instance = EnergoUnifiedService._internal();
  factory EnergoUnifiedService() => _instance;

  EnergoUnifiedService._internal() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      _checkAndAutoReleaseExpiredSlots();
    });
  }

  Future<void> init() async {}

  // LIVE SHARED RIDE SESSION
  ActiveRideStage currentRideStage = ActiveRideStage.headingToPickup;
  final String ridePin = "7842";
  final double currentRideFare = 120.0;
  final String passengerName = "Anamika Choudhary";
  final String driverName = "Suresh Verma";
  final String vehicleName = "Tata Nexon EV Max";
  final String vehiclePlate = "MP 04 EV 8891";
  final String pickupLocation = "Zone 1, MP Nagar";
  final String dropLocation = "Raja Bhoj Airport, VIP Road";

  void updateRideStage(ActiveRideStage newStage) {
    currentRideStage = newStage;
    notifyListeners();
  }

  double _walletBalance = 1450.0;
  double get walletBalance => _walletBalance;

  final List<Map<String, dynamic>> _transactions = [
    {'id': 'TXN-9842', 'title': 'EV Ride to Airport', 'amount': 120.0, 'type': 'DEBIT', 'time': 'Today, 03:10 PM'},
    {'id': 'TXN-9841', 'title': '5% Auto-Cashback Reward', 'amount': 6.0, 'type': 'CREDIT', 'time': 'Today, 03:11 PM'},
    {'id': 'TXN-9830', 'title': 'Razorpay Instant Top-Up', 'amount': 500.0, 'type': 'CREDIT', 'time': 'Today, 11:20 AM'},
  ];
  List<Map<String, dynamic>> get transactions => List.unmodifiable(_transactions);

  // 4 STATIONS REAL-TIME DATABASE
  final List<Map<String, dynamic>> stations = [
    {
      'id': 'STN-01',
      'name': 'EnerGo Central SuperHub',
      'area': 'MP Nagar Zone 1 • 1.2 km away',
      'rate': 18.50,
      'ports': [
        {'id': 'Port 1', 'power': '120kW Fast DC', 'kw': 120, 'isOccupied': true, 'bookedBy': 'Suresh Verma (MP 04 EV 8891)', 'bookedUntil': DateTime.now().add(const Duration(minutes: 12))},
        {'id': 'Port 2', 'power': '120kW Fast DC', 'kw': 120, 'isOccupied': false, 'bookedBy': '', 'bookedUntil': null},
        {'id': 'Port 3', 'power': '60kW Rapid DC', 'kw': 60, 'isOccupied': true, 'bookedBy': 'Rajesh Patel (MP 04 ZS 2210)', 'bookedUntil': DateTime.now().add(const Duration(minutes: 18))},
        {'id': 'Port 4', 'power': '60kW Rapid DC', 'kw': 60, 'isOccupied': false, 'bookedBy': '', 'bookedUntil': null},
        {'id': 'Port 5', 'power': '22kW AC Standard', 'kw': 22, 'isOccupied': false, 'bookedBy': '', 'bookedUntil': null},
        {'id': 'Port 6', 'power': '15kW DC Solo', 'kw': 15, 'isOccupied': false, 'bookedBy': '', 'bookedUntil': null},
      ],
      'parking': [
        {'id': 'Bay P-01', 'name': 'Fast DC Bay', 'isOccupied': true, 'plate': 'MP 04 EV 8891', 'bookedUntil': DateTime.now().add(const Duration(minutes: 45))},
        {'id': 'Bay P-02', 'name': 'Fast DC Bay', 'isOccupied': false, 'plate': '', 'bookedUntil': null},
      ],
      'beds': [
        {'id': 'Pod A1', 'name': 'Luxury AC Snooze', 'rate': 80.0, 'isOccupied': true, 'occupant': 'Captain Suresh', 'bookedUntil': DateTime.now().add(const Duration(minutes: 45))},
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
                hasChanged = true;
              }
            }
          }
        }
      }
    }
    if (hasChanged) notifyListeners();
  }

  void payWithWallet(double amount, String purpose) {
    _walletBalance -= amount;
    _transactions.insert(0, {
      'id': 'TXN-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
      'title': purpose,
      'amount': amount,
      'type': 'DEBIT',
      'time': 'Just Now',
    });
    final cashback = amount * 0.05;
    _walletBalance += cashback;
    _transactions.insert(0, {
      'id': 'CB-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
      'title': '5% Auto-Cashback Reward',
      'amount': cashback,
      'type': 'CREDIT',
      'time': 'Just Now',
    });
    notifyListeners();
  }

  void topUpWallet(double amount, String purpose) {
    _walletBalance += amount;
    _transactions.insert(0, {
      'id': 'TOPUP-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
      'title': purpose,
      'amount': amount,
      'type': 'CREDIT',
      'time': 'Just Now',
    });
    notifyListeners();
  }
}

typedef EnerGoUnifiedService = EnergoUnifiedService;