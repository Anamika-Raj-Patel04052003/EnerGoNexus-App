import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/constants/app_colors.dart';
import '../../widgets/animated_ev_background.dart';
import 'active_ride_screen.dart';


class RideConfirmationScreen extends StatefulWidget {
  final Map<String, dynamic> rideData;

  const RideConfirmationScreen({
    super.key,
    required this.rideData,
  });

  @override
  State<RideConfirmationScreen> createState() =>
      _RideConfirmationScreenState();
}

class _RideConfirmationScreenState
    extends State<RideConfirmationScreen>
    with SingleTickerProviderStateMixin {
  bool driverFound = false;
  bool rideCancelled = false;

  Timer? driverTimer;

  late AnimationController pulseController;

  @override
  void initState() {
    super.initState();

    pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    // ------------------------------------------------------------
    // TEMPORARY DRIVER SEARCH SIMULATION
    // Google Maps / real driver matching will be connected later.
    // ------------------------------------------------------------

    driverTimer = Timer(
      const Duration(seconds: 3),
      () {
        if (!mounted || rideCancelled) return;

        setState(() {
          driverFound = true;
        });

        pulseController.stop();
      },
    );
  }

  @override
  void dispose() {
    driverTimer?.cancel();
    pulseController.dispose();
    super.dispose();
  }

  // ============================================================
  // SAFE DATA HELPERS
  // ============================================================

  String get pickup {
    return _getString([
      "pickup_location",
      "pickup",
      "pickupLocation",
    ], "Current Location");
  }

  String get destination {
    return _getString([
      "destination",
      "destination_location",
      "destinationLocation",
    ], "Destination");
  }

  String get vehicleType {
    return _getString([
      "vehicle_type",
      "vehicleType",
      "vehicle",
    ], "Mini EV");
  }

  String get fare {
    final value = _getValue([
      "estimated_fare",
      "estimatedFare",
      "fare",
    ]);

    if (value == null) {
      return "₹0";
    }

    if (value is num) {
      return "₹${value.toStringAsFixed(0)}";
    }

    return "₹$value";
  }

  String get distance {
    final value = _getValue([
      "distance_km",
      "distance",
      "distanceKm",
    ]);

    if (value == null) {
      return "5.0 km";
    }

    if (value is num) {
      return "${value.toStringAsFixed(1)} km";
    }

    return "$value km";
  }

  String _getString(
    List<String> keys,
    String fallback,
  ) {
    for (final key in keys) {
      final value = widget.rideData[key];

      if (value != null &&
          value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }

    return fallback;
  }

  dynamic _getValue(List<String> keys) {
    for (final key in keys) {
      final value = widget.rideData[key];

      if (value != null) {
        return value;
      }
    }

    return null;
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedEVBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [

                // ==================================================
                // HEADER
                // ==================================================

                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        LucideIcons.arrowLeft,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(width: 4),

                    const Text(
                      "Ride Status",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ==================================================
                // STATUS SECTION
                // ==================================================

                statusSection(),

                const SizedBox(height: 25),

                // ==================================================
                // RIDE DETAILS
                // ==================================================

                Expanded(
                  child: SingleChildScrollView(
                    physics:
                        const BouncingScrollPhysics(),

                    child: Column(
                      children: [

                        rideInfoCard(),

                        const SizedBox(height: 18),

                        if (driverFound)
                          driverCard(),

                        if (driverFound)
                          const SizedBox(height: 18),

                        safetyCard(),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                // ==================================================
                // BOTTOM ACTION
                // ==================================================

                if (driverFound)
                  trackButton()
                else
                  cancelButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // STATUS SECTION
  // ============================================================

  Widget statusSection() {
    return Column(
      children: [

        Center(
          child: AnimatedBuilder(
            animation: pulseController,

            builder: (context, child) {
              final scale =
                  1.0 +
                  (pulseController.value * 0.08);

              return Transform.scale(
                scale: scale,
                child: child,
              );
            },

            child: Container(
              height: 100,
              width: 100,

              decoration: BoxDecoration(
                shape: BoxShape.circle,

                color: AppColors.primaryGreen
                    .withOpacity(0.10),

                border: Border.all(
                  color: AppColors.primaryGreen
                      .withOpacity(0.25),

                  width: 1.5,
                ),

                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryGreen
                        .withOpacity(0.12),

                    blurRadius: 25,

                    spreadRadius: 3,
                  ),
                ],
              ),

              child: Center(
                child: Container(
                  height: 72,
                  width: 72,

                  decoration: BoxDecoration(
                    shape: BoxShape.circle,

                    color: AppColors.primaryGreen
                        .withOpacity(0.14),
                  ),

                  child: Icon(
                    driverFound
                        ? LucideIcons.car
                        : LucideIcons.search,

                    color:
                        AppColors.primaryGreen,

                    size: 38,
                  ),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),

        Text(
          driverFound
              ? "Driver Found"
              : "Finding Driver...",

          style: const TextStyle(
            color: Colors.white,
            fontSize: 23,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          driverFound
              ? "Your driver is ready to pick you up"
              : "Looking for the best driver near you",

          textAlign: TextAlign.center,

          style: const TextStyle(
            color: Colors.white54,
            fontSize: 13,
          ),
        ),

        const SizedBox(height: 15),

        if (!driverFound)
          searchingIndicator(),
      ],
    );
  }

  // ============================================================
  // SEARCHING INDICATOR
  // ============================================================

  Widget searchingIndicator() {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.center,

      children: [

        Container(
          height: 7,
          width: 7,

          decoration: const BoxDecoration(
            color: AppColors.primaryGreen,
            shape: BoxShape.circle,
          ),
        ),

        const SizedBox(width: 6),

        Container(
          height: 7,
          width: 7,

          decoration: BoxDecoration(
            color: AppColors.primaryGreen
                .withOpacity(0.65),
            shape: BoxShape.circle,
          ),
        ),

        const SizedBox(width: 6),

        Container(
          height: 7,
          width: 7,

          decoration: BoxDecoration(
            color: AppColors.primaryGreen
                .withOpacity(0.35),
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // RIDE INFORMATION CARD
  // ============================================================

  Widget rideInfoCard() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: AppColors.card,

        borderRadius:
            BorderRadius.circular(25),

        border: Border.all(
          color: AppColors.primaryGreen
              .withOpacity(0.20),
        ),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          const Text(
            "Ride Details",

            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          detailRow(
            LucideIcons.navigation,
            "Pickup",
            pickup,
          ),

          const SizedBox(height: 16),

          detailRow(
            LucideIcons.mapPin,
            "Destination",
            destination,
          ),

          const SizedBox(height: 16),

          detailRow(
            LucideIcons.car,
            "Vehicle",
            vehicleType,
          ),

          const SizedBox(height: 16),

          detailRow(
            LucideIcons.route,
            "Distance",
            distance,
          ),

          const SizedBox(height: 16),

          detailRow(
            LucideIcons.wallet,
            "Estimated Fare",
            fare,
            highlight: true,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DETAIL ROW
  // ============================================================

  Widget detailRow(
    IconData icon,
    String title,
    String value, {
    bool highlight = false,
  }) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [

        Container(
          height: 40,
          width: 40,

          decoration: BoxDecoration(
            color: AppColors.primaryGreen
                .withOpacity(0.10),

            borderRadius:
                BorderRadius.circular(12),
          ),

          child: Icon(
            icon,
            color: AppColors.primaryGreen,
            size: 20,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              Text(
                title,

                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                value,

                maxLines: 2,

                overflow:
                    TextOverflow.ellipsis,

                style: TextStyle(
                  color: highlight
                      ? AppColors.primaryGreen
                      : Colors.white,

                  fontSize:
                      highlight ? 18 : 14,

                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // DRIVER CARD
  // ============================================================

  Widget driverCard() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: AppColors.card,

        borderRadius:
            BorderRadius.circular(23),

        border: Border.all(
          color: AppColors.primaryGreen
              .withOpacity(0.30),
        ),
      ),

      child: Column(
        children: [

          Row(
            children: [

              Container(
                height: 58,
                width: 58,

                decoration: BoxDecoration(
                  shape: BoxShape.circle,

                  color: AppColors.primaryGreen
                      .withOpacity(0.12),

                  border: Border.all(
                    color: AppColors.primaryGreen
                        .withOpacity(0.30),
                  ),
                ),

                child: const Icon(
                  LucideIcons.userRound,
                  color:
                      AppColors.primaryGreen,
                  size: 28,
                ),
              ),

              const SizedBox(width: 14),

              const Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    Text(
                      "Rajesh Kumar",

                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 5),

                    Row(
                      children: [

                        Icon(
                          Icons.star_rounded,
                          color:
                              Colors.amber,
                          size: 16,
                        ),

                        SizedBox(width: 4),

                        Text(
                          "4.8",

                          style: TextStyle(
                            color:
                                Colors.white70,
                            fontSize: 12,
                          ),
                        ),

                        SizedBox(width: 8),

                        Text(
                          "•  1,240 rides",

                          style: TextStyle(
                            color:
                                Colors.white54,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 6,
                ),

                decoration: BoxDecoration(
                  color: AppColors.primaryGreen
                      .withOpacity(0.12),

                  borderRadius:
                      BorderRadius.circular(10),
                ),

                child: const Text(
                  "4 min",

                  style: TextStyle(
                    color:
                        AppColors.primaryGreen,
                    fontSize: 12,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Container(
            padding:
                const EdgeInsets.all(13),

            decoration: BoxDecoration(
              color: Colors.black
                  .withOpacity(0.16),

              borderRadius:
                  BorderRadius.circular(15),
            ),

            child: Row(
              children: [

                const Icon(
                  LucideIcons.carFront,
                  color:
                      AppColors.primaryGreen,
                  size: 21,
                ),

                const SizedBox(width: 10),

                const Expanded(
                  child: Text(
                    "Electric Vehicle",

                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ),

                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),

                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(8),

                    color: Colors.white
                        .withOpacity(0.06),
                  ),

                  child: const Text(
                    "EV • 2847",

                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SAFETY CARD
  // ============================================================

  Widget safetyCard() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(15),

      decoration: BoxDecoration(
        color: AppColors.darkGreen
            .withOpacity(0.30),

        borderRadius:
            BorderRadius.circular(18),

        border: Border.all(
          color: AppColors.primaryGreen
              .withOpacity(0.12),
        ),
      ),

      child: Row(
        children: [

          Container(
            height: 38,
            width: 38,

            decoration: BoxDecoration(
              color: AppColors.primaryGreen
                  .withOpacity(0.10),

              borderRadius:
                  BorderRadius.circular(11),
            ),

            child: const Icon(
              LucideIcons.shieldCheck,
              color:
                  AppColors.primaryGreen,
              size: 20,
            ),
          ),

          const SizedBox(width: 11),

          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                Text(
                  "Ride Safety",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                SizedBox(height: 3),

                Text(
                  "Your trip is protected",
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CANCEL BUTTON
  // ============================================================

  Widget cancelButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,

      child: OutlinedButton(
        onPressed: showCancelDialog,

        style:
            OutlinedButton.styleFrom(
          foregroundColor:
              Colors.redAccent,

          side: const BorderSide(
            color: Colors.redAccent,
          ),

          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(20),
          ),
        ),

        child: const Text(
          "CANCEL RIDE",

          style: TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CANCEL DIALOG
  // ============================================================

  void showCancelDialog() {
    showDialog(
      context: context,

      builder: (context) {
        return AlertDialog(
          backgroundColor:
              AppColors.card,

          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(22),
          ),

          title: const Text(
            "Cancel Ride?",
            style: TextStyle(
              color: Colors.white,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          content: const Text(
            "Are you sure you want to cancel this ride?",

            style: TextStyle(
              color: Colors.white70,
            ),
          ),

          actions: [

            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },

              child: const Text(
                "NO",
                style: TextStyle(
                  color:
                      Colors.white70,
                ),
              ),
            ),

            TextButton(
              onPressed: () {
                Navigator.pop(context);

                setState(() {
                  rideCancelled = true;
                });

                driverTimer?.cancel();

                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Ride cancelled",
                    ),
                  ),
                );

                Future.delayed(
                  const Duration(
                    milliseconds: 700,
                  ),
                  () {
                    if (mounted) {
                      Navigator.pop(context);
                    }
                  },
                );
              },

              child: const Text(
                "CANCEL",
                style: TextStyle(
                  color:
                      Colors.redAccent,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // TRACK BUTTON
  // ============================================================

  Widget trackButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,

      child: ElevatedButton(
        // onPressed: () {
        //   // ======================================================
        //   // GOOGLE MAPS TRACKING WILL BE CONNECTED HERE LATER.
        //   // ======================================================

        //   ScaffoldMessenger.of(context)
        //       .showSnackBar(
        //     const SnackBar(
        //       content: Text(
        //         "Live tracking will be available with Google Maps.",
        //       ),
        //     ),
        //   );
        // },

        onPressed: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ActiveRideScreen(
        rideData: widget.rideData,
      ),
    ),
  );
},

        style:
            ElevatedButton.styleFrom(
          backgroundColor:
              AppColors.primaryGreen,

          foregroundColor:
              Colors.black,

          elevation: 0,

          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(20),
          ),
        ),

        child: const Row(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [

            Icon(
              LucideIcons.navigation,
              size: 19,
            ),

            SizedBox(width: 8),

            Text(
              "TRACK RIDE",
              style: TextStyle(
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}