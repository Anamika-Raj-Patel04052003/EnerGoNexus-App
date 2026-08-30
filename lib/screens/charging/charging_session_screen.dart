import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../widgets/animated_ev_background.dart';

import '../payment/payment_screen.dart';

class ChargingSessionScreen extends StatefulWidget {
  final String stationName;
  final String stationLocation;
  final String chargingType;
  final String price;
  final int selectedPort;
  final DateTime bookingDate;
  final TimeOfDay bookingTime;

  const ChargingSessionScreen({
    super.key,
    required this.stationName,
    required this.stationLocation,
    required this.chargingType,
    required this.price,
    required this.selectedPort,
    required this.bookingDate,
    required this.bookingTime,
  });

  @override
  State<ChargingSessionScreen> createState() =>
      _ChargingSessionScreenState();
}

class _ChargingSessionScreenState
    extends State<ChargingSessionScreen> {
  Timer? timer;

  int chargingSeconds = 0;

  double chargePercentage = 62;

  double energyDelivered = 8.24;

  double power = 22;

  double estimatedCost = 98.88;

  bool charging = true;

  bool completed = false;

  @override
  void initState() {
    super.initState();

    startChargingTimer();
  }

  void startChargingTimer() {
    timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (!mounted || !charging) return;

        setState(() {
          chargingSeconds++;

          if (chargePercentage < 100) {
            chargePercentage += 0.08;
          }

          if (energyDelivered < 12.45) {
            energyDelivered += 0.015;
          }

          if (estimatedCost < 149.40) {
            estimatedCost += 0.20;
          }

          if (chargePercentage >= 100) {
            completeCharging();
          }
        });
      },
    );
  }

  void completeCharging() {
    if (completed) return;

    completed = true;
    charging = false;

    timer?.cancel();

    setState(() {});
  }

  void stopCharging() {
    if (!charging) return;

    timer?.cancel();

    setState(() {
      charging = false;
      completed = true;
    });
  }

  String formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    final h = hours.toString().padLeft(2, '0');
    final m = minutes.toString().padLeft(2, '0');
    final s = secs.toString().padLeft(2, '0');

    return "$h:$m:$s";
  }

  double get finalAmount {
    return double.parse(
      estimatedCost.toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      body: AnimatedEVBackground(
        child: SafeArea(
          child: Column(
            children: [
              // =================================================
              // HEADER
              // =================================================

              Padding(
                padding: const EdgeInsets.fromLTRB(
                  15,
                  12,
                  20,
                  10,
                ),

                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(width: 5),

                    const Expanded(
                      child: Text(
                        "Charging Session",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors
                            .primaryGreen
                            .withOpacity(.12),
                        borderRadius:
                            BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.bolt,
                            color:
                                AppColors.primaryGreen,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "Port ${widget.selectedPort}",
                            style: const TextStyle(
                              color:
                                  AppColors.primaryGreen,
                              fontSize: 11,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.fromLTRB(
                    20,
                    5,
                    20,
                    25,
                  ),

                  child: Column(
                    children: [
                      // =================================================
                      // SESSION IDENTIFIER
                      // =================================================

                      Container(
                        width: double.infinity,
                        padding:
                            const EdgeInsets.all(16),

                        decoration:
                            BoxDecoration(
                          color: AppColors.card,
                          borderRadius:
                              BorderRadius.circular(
                            20,
                          ),
                        ),

                        child: Row(
                          children: [
                            Container(
                              height: 42,
                              width: 42,

                              decoration:
                                  BoxDecoration(
                                color: AppColors
                                    .primaryGreen
                                    .withOpacity(
                                        .14),
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  13,
                                ),
                              ),

                              child: const Icon(
                                Icons
                                    .electric_bolt,
                                color: AppColors
                                    .primaryGreen,
                              ),
                            ),

                            const SizedBox(
                              width: 12,
                            ),

                            const Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [
                                  Text(
                                    "Charging Session",
                                    style:
                                        TextStyle(
                                      color: Colors
                                          .white54,
                                      fontSize: 11,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 4,
                                  ),
                                  Text(
                                    "Session Active",
                                    style:
                                        TextStyle(
                                      color: Colors
                                          .white,
                                      fontSize: 15,
                                      fontWeight:
                                          FontWeight
                                              .bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Container(
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                horizontal: 9,
                                vertical: 6,
                              ),
                              decoration:
                                  BoxDecoration(
                                color: charging
                                    ? Colors.green
                                        .withOpacity(
                                            .14)
                                    : AppColors
                                        .primaryGreen
                                        .withOpacity(
                                            .14),
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  15,
                                ),
                              ),
                              child: Text(
                                charging
                                    ? "CHARGING"
                                    : "COMPLETED",
                                style: TextStyle(
                                  color: charging
                                      ? Colors.green
                                      : AppColors
                                          .primaryGreen,
                                  fontSize: 10,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 25),

                      // =================================================
                      // CHARGING PROGRESS
                      // =================================================

                      Container(
                        width: double.infinity,
                        padding:
                            const EdgeInsets.fromLTRB(
                          20,
                          25,
                          20,
                          25,
                        ),

                        decoration:
                            BoxDecoration(
                          color: AppColors.card,
                          borderRadius:
                              BorderRadius.circular(
                            28,
                          ),
                          border: Border.all(
                            color: AppColors
                                .primaryGreen
                                .withOpacity(.20),
                          ),
                        ),

                        child: Column(
                          children: [
                            SizedBox(
                              height: 220,
                              width: 220,

                              child:
                                  Stack(
                                alignment:
                                    Alignment.center,
                                children: [
                                  SizedBox(
                                    height: 205,
                                    width: 205,
                                    child:
                                        CircularProgressIndicator(
                                      value:
                                          chargePercentage /
                                              100,

                                      strokeWidth:
                                          12,

                                      backgroundColor:
                                          Colors
                                              .white10,

                                      valueColor:
                                          const AlwaysStoppedAnimation<
                                              Color>(
                                        AppColors
                                            .primaryGreen,
                                      ),
                                    ),
                                  ),

                                  Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment
                                            .center,
                                    children: [
                                      Text(
                                        "${chargePercentage.toStringAsFixed(0)}%",
                                        style:
                                            const TextStyle(
                                          color: Colors
                                              .white,
                                          fontSize: 44,
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                        ),
                                      ),

                                      const SizedBox(
                                        height: 5,
                                      ),

                                      Text(
                                        charging
                                            ? "Charging..."
                                            : "Charging Complete",
                                        style:
                                            const TextStyle(
                                          color: Colors
                                              .white54,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 22),

                            Text(
                              widget.stationName,
                              textAlign:
                                  TextAlign.center,
                              style:
                                  const TextStyle(
                                color:
                                    Colors.white,
                                fontSize: 18,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 7),

                            Text(
                              widget.stationLocation,
                              textAlign:
                                  TextAlign.center,
                              style:
                                  const TextStyle(
                                color:
                                    Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // =================================================
                      // LIVE CHARGING DETAILS
                      // =================================================

                      Row(
                        children: [
                          Expanded(
                            child: metricCard(
                              title:
                                  "Energy Delivered",
                              value:
                                  "${energyDelivered.toStringAsFixed(2)} kWh",
                              icon:
                                  Icons.battery_charging_full,
                            ),
                          ),

                          const SizedBox(
                            width: 12,
                          ),

                          Expanded(
                            child: metricCard(
                              title:
                                  "Charging Time",
                              value:
                                  formatDuration(
                                chargingSeconds,
                              ),
                              icon:
                                  Icons.timer_outlined,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: metricCard(
                              title: "Power",
                              value:
                                  "${power.toStringAsFixed(0)} kW",
                              icon:
                                  Icons.speed,
                            ),
                          ),

                          const SizedBox(
                            width: 12,
                          ),

                          Expanded(
                            child: metricCard(
                              title: "Est. Cost",
                              value:
                                  "₹${estimatedCost.toStringAsFixed(2)}",
                              icon:
                                  Icons.currency_rupee,
                              highlight: true,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 22),

                      // =================================================
                      // STATION DETAILS
                      // =================================================

                      Container(
                        width: double.infinity,
                        padding:
                            const EdgeInsets.all(18),

                        decoration:
                            BoxDecoration(
                          color: AppColors.card,
                          borderRadius:
                              BorderRadius.circular(
                            22,
                          ),
                        ),

                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            const Text(
                              "Session Details",
                              style:
                                  TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            ),

                            const SizedBox(
                              height: 15,
                            ),

                            detailRow(
                              "Charging Type",
                              widget.chargingType,
                            ),

                            detailRow(
                              "Charging Port",
                              "Port ${widget.selectedPort}",
                            ),

                            detailRow(
                              "Unit Price",
                              widget.price,
                            ),

                            detailRow(
                              "Booking Date",
                              "${widget.bookingDate.day.toString().padLeft(2, '0')}/"
                              "${widget.bookingDate.month.toString().padLeft(2, '0')}/"
                              "${widget.bookingDate.year}",
                            ),

                            detailRow(
                              "Booking Time",
                              widget.bookingTime
                                  .format(
                                context,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // =================================================
                      // SAFETY / INFO
                      // =================================================

                      Container(
                        width: double.infinity,
                        padding:
                            const EdgeInsets.all(15),

                        decoration:
                            BoxDecoration(
                          color: AppColors
                              .darkGreen
                              .withOpacity(.28),

                          borderRadius:
                              BorderRadius.circular(
                            18,
                          ),

                          border: Border.all(
                            color: AppColors
                                .primaryGreen
                                .withOpacity(.14),
                          ),
                        ),

                        child: Row(
                          children: [
                            Container(
                              height: 40,
                              width: 40,

                              decoration:
                                  BoxDecoration(
                                color: AppColors
                                    .primaryGreen
                                    .withOpacity(
                                        .10),
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  12,
                                ),
                              ),

                              child: const Icon(
                                Icons.lightbulb_outline,
                                color: AppColors
                                    .primaryGreen,
                                size: 21,
                              ),
                            ),

                            const SizedBox(
                              width: 12,
                            ),

                            const Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [
                                  Text(
                                    "Charging Tip",
                                    style:
                                        TextStyle(
                                      color: Colors
                                          .white,
                                      fontSize: 12,
                                      fontWeight:
                                          FontWeight
                                              .bold,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 4,
                                  ),
                                  Text(
                                    "Keep the vehicle connected until charging is complete.",
                                    style:
                                        TextStyle(
                                      color: Colors
                                          .white54,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 25),

                      // =================================================
                      // ACTION BUTTON
                      // =================================================

                      if (charging)
                        SizedBox(
                          width: double.infinity,
                          height: 55,

                          child:
                              OutlinedButton(
                            onPressed:
                                stopCharging,

                            style:
                                OutlinedButton
                                    .styleFrom(
                              foregroundColor:
                                  Colors.redAccent,

                              side:
                                  const BorderSide(
                                color:
                                    Colors.redAccent,
                              ),

                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                  20,
                                ),
                              ),
                            ),

                            child: const Text(
                              "STOP CHARGING",
                              style:
                                  TextStyle(
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ),
                        )
                      else
                        SizedBox(
                          width: double.infinity,
                          height: 55,

                          child:
                              ElevatedButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      PaymentScreen(
                                    rideId:
                                        "charging-${widget.selectedPort}",

                                    amount:
                                        finalAmount,
                                  ),
                                ),
                              );
                            },

                            style:
                                ElevatedButton
                                    .styleFrom(
                              backgroundColor:
                                  AppColors
                                      .primaryGreen,

                              foregroundColor:
                                  Colors.black,

                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                  20,
                                ),
                              ),
                            ),

                            child: const Text(
                              "PROCEED TO PAYMENT",
                              style:
                                  TextStyle(
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================
  // METRIC CARD
  // ===========================================================

  Widget metricCard({
    required String title,
    required String value,
    required IconData icon,
    bool highlight = false,
  }) {
    return Container(
      padding:
          const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: AppColors.card,

        borderRadius:
            BorderRadius.circular(20),

        border: Border.all(
          color: highlight
              ? AppColors.primaryGreen
                  .withOpacity(.25)
              : Colors.white10,
        ),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Icon(
            icon,
            color:
                AppColors.primaryGreen,
            size: 22,
          ),

          const SizedBox(height: 12),

          Text(
            title,
            style:
                const TextStyle(
              color: Colors.white54,
              fontSize: 11,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            value,
            style:
                TextStyle(
              color: highlight
                  ? AppColors.primaryGreen
                  : Colors.white,
              fontSize: 17,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================
  // DETAIL ROW
  // ===========================================================

  Widget detailRow(
    String title,
    String value,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 12),

      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style:
                  const TextStyle(
                color: Colors.white54,
                fontSize: 12,
              ),
            ),
          ),

          Expanded(
            child: Text(
              value,
              textAlign:
                  TextAlign.right,
              maxLines: 1,
              overflow:
                  TextOverflow.ellipsis,
              style:
                  const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}