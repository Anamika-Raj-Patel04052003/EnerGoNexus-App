import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/constants/app_colors.dart';
import '../../widgets/animated_ev_background.dart';

class ActiveRideScreen extends StatefulWidget {
  final Map<String, dynamic> rideData;

  const ActiveRideScreen({
    super.key,
    required this.rideData,
  });

  @override
  State<ActiveRideScreen> createState() =>
      _ActiveRideScreenState();
}

class _ActiveRideScreenState
    extends State<ActiveRideScreen> {

  bool rideCancelled = false;

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

  String get pickup {
    return _getString(
      [
        "pickup_location",
        "pickup",
        "pickupLocation",
      ],
      "Current Location",
    );
  }

  String get destination {
    return _getString(
      [
        "destination",
        "destination_location",
        "destinationLocation",
      ],
      "Destination",
    );
  }

  String get vehicleType {
    return _getString(
      [
        "vehicle_type",
        "vehicleType",
        "vehicle",
      ],
      "Mini EV",
    );
  }

  String get fare {
    final value = _getValue(
      [
        "estimated_fare",
        "estimatedFare",
        "fare",
      ],
    );

    if (value == null) {
      return "₹0";
    }

    if (value is num) {
      return "₹${value.toStringAsFixed(0)}";
    }

    return "₹$value";
  }

  String get distance {
    final value = _getValue(
      [
        "distance_km",
        "distance",
        "distanceKm",
      ],
    );

    if (value == null) {
      return "5.0 km";
    }

    if (value is num) {
      return "${value.toStringAsFixed(1)} km";
    }

    return "$value km";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedEVBackground(
        child: SafeArea(
          child: Column(
            children: [

              // ==========================================================
              // HEADER
              // ==========================================================

              Padding(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  12,
                  20,
                  8,
                ),

                child: Row(
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
                      "Active Ride",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const Spacer(),

                    Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),

                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen
                            .withOpacity(0.12),

                        borderRadius:
                            BorderRadius.circular(12),

                        border: Border.all(
                          color: AppColors.primaryGreen
                              .withOpacity(0.25),
                        ),
                      ),

                      child: const Row(
                        children: [

                          Icon(
                            Icons.circle,
                            color:
                                AppColors.primaryGreen,
                            size: 7,
                          ),

                          SizedBox(width: 6),

                          Text(
                            "LIVE",
                            style: TextStyle(
                              color:
                                  AppColors.primaryGreen,
                              fontSize: 10,
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

              // ==========================================================
              // CONTENT
              // ==========================================================

              Expanded(
                child: SingleChildScrollView(
                  physics:
                      const BouncingScrollPhysics(),

                  padding:
                      const EdgeInsets.fromLTRB(
                    20,
                    10,
                    20,
                    20,
                  ),

                  child: Column(
                    children: [

                      // ====================================================
                      // MAP PLACEHOLDER
                      // ====================================================

                      mapPlaceholder(),

                      const SizedBox(height: 18),

                      // ====================================================
                      // ETA CARD
                      // ====================================================

                      etaCard(),

                      const SizedBox(height: 18),

                      // ====================================================
                      // DRIVER CARD
                      // ====================================================

                      driverCard(),

                      const SizedBox(height: 18),

                      // ====================================================
                      // ROUTE CARD
                      // ====================================================

                      routeCard(),

                      const SizedBox(height: 18),

                      // ====================================================
                      // FARE CARD
                      // ====================================================

                      fareCard(),

                      const SizedBox(height: 18),

                      // ====================================================
                      // SAFETY CARD
                      // ====================================================

                      safetyCard(),

                      const SizedBox(height: 20),

                      // ====================================================
                      // CANCEL
                      // ====================================================

                      SizedBox(
                        width: double.infinity,
                        height: 52,

                        child: OutlinedButton(
                          onPressed:
                              showCancelDialog,

                          style: OutlinedButton
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
                                18,
                              ),
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

  // ================================================================
  // MAP PLACEHOLDER
  // ================================================================

  Widget mapPlaceholder() {
    return Container(
      height: 220,
      width: double.infinity,

      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(26),

        color: const Color(0xFF101916),

        border: Border.all(
          color: AppColors.primaryGreen
              .withOpacity(0.18),
        ),

        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withOpacity(0.20),

            blurRadius: 20,

            offset:
                const Offset(0, 8),
          ),
        ],
      ),

      child: Stack(
        children: [

          // ==========================================================
          // FAKE MAP GRID
          // ==========================================================

          Positioned.fill(
            child: CustomPaint(
              painter: _MapPatternPainter(),
            ),
          ),

          // ==========================================================
          // ROUTE LINE
          // ==========================================================

          Positioned.fill(
            child: CustomPaint(
              painter: _RoutePainter(),
            ),
          ),

          // ==========================================================
          // PICKUP
          // ==========================================================

          const Positioned(
            left: 48,
            bottom: 48,

            child: _MapMarker(
              icon: LucideIcons.navigation,
              label: "Pickup",
            ),
          ),

          // ==========================================================
          // DRIVER
          // ==========================================================

          const Positioned(
            left: 145,
            top: 78,

            child: _MapMarker(
              icon: LucideIcons.car,
              label: "Driver",
              filled: true,
            ),
          ),

          // ==========================================================
          // DESTINATION
          // ==========================================================

          const Positioned(
            right: 38,
            top: 40,

            child: _MapMarker(
              icon: LucideIcons.mapPin,
              label: "Destination",
            ),
          ),

          // ==========================================================
          // MAP LABEL
          // ==========================================================

          Positioned(
            left: 16,
            top: 15,

            child: Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 7,
              ),

              decoration: BoxDecoration(
                color: Colors.black
                    .withOpacity(0.45),

                borderRadius:
                    BorderRadius.circular(10),
              ),

              child: const Text(
                "Live trip preview",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),
            ),
          ),

          // ==========================================================
          // GOOGLE MAPS LATER
          // ==========================================================

          const Positioned(
            right: 15,
            bottom: 12,

            child: Text(
              "MAP",
              style: TextStyle(
                color: Colors.white24,
                fontSize: 9,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // ETA CARD
  // ================================================================

  Widget etaCard() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: AppColors.card,

        borderRadius:
            BorderRadius.circular(22),

        border: Border.all(
          color: AppColors.primaryGreen
              .withOpacity(0.18),
        ),
      ),

      child: Row(
        children: [

          Container(
            height: 50,
            width: 50,

            decoration: BoxDecoration(
              color: AppColors.primaryGreen
                  .withOpacity(0.10),

              borderRadius:
                  BorderRadius.circular(15),
            ),

            child: const Icon(
              LucideIcons.clock3,
              color:
                  AppColors.primaryGreen,
              size: 24,
            ),
          ),

          const SizedBox(width: 13),

          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                Text(
                  "Driver arriving in",
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 11,
                  ),
                ),

                SizedBox(height: 3),

                Text(
                  "4 minutes",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 7,
            ),

            decoration: BoxDecoration(
              color: AppColors.primaryGreen
                  .withOpacity(0.10),

              borderRadius:
                  BorderRadius.circular(10),
            ),

            child: const Text(
              "ON THE WAY",
              style: TextStyle(
                color:
                    AppColors.primaryGreen,
                fontSize: 9,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // DRIVER CARD
  // ================================================================

  Widget driverCard() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(19),

      decoration: BoxDecoration(
        color: AppColors.card,

        borderRadius:
            BorderRadius.circular(24),

        border: Border.all(
          color: AppColors.primaryGreen
              .withOpacity(0.22),
        ),
      ),

      child: Column(
        children: [

          Row(
            children: [

              // DRIVER AVATAR
              Container(
                height: 62,
                width: 62,

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
                  size: 30,
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
                        fontSize: 17,
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
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),

                        SizedBox(width: 7),

                        Text(
                          "1,240 rides",
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

              // CALL BUTTON
              _roundActionButton(
                icon:
                    LucideIcons.phone,
                onTap: () {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Calling driver will be connected later.",
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(width: 8),

              // MESSAGE BUTTON
              _roundActionButton(
                icon:
                    LucideIcons.messageCircle,
                onTap: () {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Driver chat will be connected later.",
                      ),
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 17),

          Container(
            padding:
                const EdgeInsets.all(13),

            decoration: BoxDecoration(
              color: Colors.black
                  .withOpacity(0.15),

              borderRadius:
                  BorderRadius.circular(15),
            ),

            child: Row(
              children: [

                const Icon(
                  LucideIcons.carFront,
                  color:
                      AppColors.primaryGreen,
                  size: 22,
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [

                      Text(
                        vehicleType,
                        style:
                            const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 3),

                      const Text(
                        "Electric Vehicle",
                        style: TextStyle(
                          color:
                              Colors.white54,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),

                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen
                        .withOpacity(0.10),

                    borderRadius:
                        BorderRadius.circular(8),
                  ),

                  child: const Text(
                    "EV • 2847",
                    style: TextStyle(
                      color:
                          AppColors.primaryGreen,
                      fontSize: 10,
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

  // ================================================================
  // ROUTE CARD
  // ================================================================

  Widget routeCard() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(19),

      decoration: BoxDecoration(
        color: AppColors.card,

        borderRadius:
            BorderRadius.circular(23),

        border: Border.all(
          color: AppColors.primaryGreen
              .withOpacity(0.16),
        ),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          const Text(
            "Your Route",

            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(height: 18),

          routePoint(
            icon:
                LucideIcons.navigation,
            title:
                "Pickup",
            value:
                pickup,
            isFirst:
                true,
          ),

          routeConnector(),

          routePoint(
            icon:
                LucideIcons.mapPin,
            title:
                "Destination",
            value:
                destination,
            isFirst:
                false,
          ),
        ],
      ),
    );
  }

  Widget routePoint({
    required IconData icon,
    required String title,
    required String value,
    required bool isFirst,
  }) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [

        Container(
          height: 38,
          width: 38,

          decoration: BoxDecoration(
            shape: BoxShape.circle,

            color: AppColors.primaryGreen
                .withOpacity(0.10),

            border: Border.all(
              color: AppColors.primaryGreen
                  .withOpacity(0.20),
            ),
          ),

          child: Icon(
            icon,
            color:
                AppColors.primaryGreen,
            size: 18,
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
                style:
                    const TextStyle(
                  color: Colors.white54,
                  fontSize: 10,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                value,
                maxLines: 2,
                overflow:
                    TextOverflow.ellipsis,

                style:
                    const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget routeConnector() {
    return Padding(
      padding:
          const EdgeInsets.only(
        left: 18,
        top: 3,
        bottom: 3,
      ),

      child: Container(
        height: 22,
        width: 2,

        color: AppColors.primaryGreen
            .withOpacity(0.25),
      ),
    );
  }

  // ================================================================
  // FARE CARD
  // ================================================================

  Widget fareCard() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(19),

      decoration: BoxDecoration(
        color: AppColors.darkGreen
            .withOpacity(0.32),

        borderRadius:
            BorderRadius.circular(22),

        border: Border.all(
          color: AppColors.primaryGreen
              .withOpacity(0.15),
        ),
      ),

      child: Row(
        children: [

          Container(
            height: 45,
            width: 45,

            decoration: BoxDecoration(
              color: AppColors.primaryGreen
                  .withOpacity(0.10),

              borderRadius:
                  BorderRadius.circular(14),
            ),

            child: const Icon(
              LucideIcons.wallet,
              color:
                  AppColors.primaryGreen,
              size: 21,
            ),
          ),

          const SizedBox(width: 12),

          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                Text(
                  "Estimated Fare",
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 11,
                  ),
                ),

                SizedBox(height: 3),

                Text(
                  "Final fare may vary",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),

          Text(
            fare,
            style: const TextStyle(
              color:
                  AppColors.primaryGreen,
              fontSize: 22,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // SAFETY
  // ================================================================

  Widget safetyCard() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: AppColors.card,

        borderRadius:
            BorderRadius.circular(19),

        border: Border.all(
          color: AppColors.primaryGreen
              .withOpacity(0.12),
        ),
      ),

      child: Row(
        children: [

          Container(
            height: 42,
            width: 42,

            decoration: BoxDecoration(
              color: AppColors.primaryGreen
                  .withOpacity(0.10),

              borderRadius:
                  BorderRadius.circular(12),
            ),

            child: const Icon(
              LucideIcons.shieldCheck,
              color:
                  AppColors.primaryGreen,
              size: 21,
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

          const Icon(
            LucideIcons.chevronRight,
            color: Colors.white38,
            size: 19,
          ),
        ],
      ),
    );
  }

  // ================================================================
  // ROUND ACTION BUTTON
  // ================================================================

  Widget _roundActionButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,

      borderRadius:
          BorderRadius.circular(14),

      child: Container(
        height: 42,
        width: 42,

        decoration: BoxDecoration(
          color: AppColors.primaryGreen
              .withOpacity(0.10),

          borderRadius:
              BorderRadius.circular(14),

          border: Border.all(
            color: AppColors.primaryGreen
                .withOpacity(0.15),
          ),
        ),

        child: Icon(
          icon,
          color:
              AppColors.primaryGreen,
          size: 18,
        ),
      ),
    );
  }

  // ================================================================
  // CANCEL DIALOG
  // ================================================================

  void showCancelDialog() {
    showDialog(
      context: context,

      builder: (dialogContext) {
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
            "Are you sure you want to cancel your active ride?",

            style: TextStyle(
              color: Colors.white70,
              height: 1.4,
            ),
          ),

          actions: [

            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );
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
                Navigator.pop(
                  dialogContext,
                );

                setState(() {
                  rideCancelled = true;
                });

                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(
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
                      Navigator.pop(
                        context,
                      );
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
}

// ============================================================================
// MAP MARKER
// ============================================================================

class _MapMarker extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool filled;

  const _MapMarker({
    required this.icon,
    required this.label,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        Container(
          height: 35,
          width: 35,

          decoration: BoxDecoration(
            color: filled
                ? AppColors.primaryGreen
                : const Color(0xFF18231F),

            shape: BoxShape.circle,

            border: Border.all(
              color:
                  AppColors.primaryGreen,
              width: 1.5,
            ),

            boxShadow: [
              BoxShadow(
                color: AppColors.primaryGreen
                    .withOpacity(0.25),
                blurRadius: 12,
              ),
            ],
          ),

          child: Icon(
            icon,
            color: filled
                ? Colors.black
                : AppColors.primaryGreen,
            size: 17,
          ),
        ),

        const SizedBox(height: 4),

        Container(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 6,
            vertical: 3,
          ),

          decoration: BoxDecoration(
            color: Colors.black
                .withOpacity(0.50),

            borderRadius:
                BorderRadius.circular(6),
          ),

          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 8,
              fontWeight:
                  FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// MAP PATTERN
// ============================================================================

class _MapPatternPainter extends CustomPainter {
  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final paint = Paint()
      ..color = const Color(0xFF26332F)
          .withOpacity(0.35)
      ..strokeWidth = 1;

    // Horizontal roads
    for (double y = 20; y < size.height; y += 38) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y + 15),
        paint,
      );
    }

    // Vertical roads
    for (double x = 20; x < size.width; x += 55) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + 20, size.height),
        paint,
      );
    }

    final greenPaint = Paint()
      ..color = AppColors.primaryGreen
          .withOpacity(0.08)
      ..strokeWidth = 3;

    canvas.drawLine(
      Offset(size.width * 0.08, size.height * 0.72),
      Offset(size.width * 0.50, size.height * 0.32),
      greenPaint,
    );

    canvas.drawLine(
      Offset(size.width * 0.50, size.height * 0.32),
      Offset(size.width * 0.88, size.height * 0.18),
      greenPaint,
    );
  }

  @override
  bool shouldRepaint(
    covariant _MapPatternPainter oldDelegate,
  ) {
    return false;
  }
}

// ============================================================================
// ROUTE PAINTER
// ============================================================================

class _RoutePainter extends CustomPainter {
  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final path = Path();

    path.moveTo(
      size.width * 0.17,
      size.height * 0.72,
    );

    path.cubicTo(
      size.width * 0.30,
      size.height * 0.66,
      size.width * 0.34,
      size.height * 0.30,
      size.width * 0.50,
      size.height * 0.38,
    );

    path.cubicTo(
      size.width * 0.63,
      size.height * 0.45,
      size.width * 0.72,
      size.height * 0.20,
      size.width * 0.83,
      size.height * 0.18,
    );

    final paint = Paint()
      ..color = AppColors.primaryGreen
          .withOpacity(0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(
      path,
      paint,
    );

    final dotPaint = Paint()
      ..color = AppColors.primaryGreen;

    canvas.drawCircle(
      Offset(
        size.width * 0.17,
        size.height * 0.72,
      ),
      4,
      dotPaint,
    );

    canvas.drawCircle(
      Offset(
        size.width * 0.83,
        size.height * 0.18,
      ),
      4,
      dotPaint,
    );
  }

  @override
  bool shouldRepaint(
    covariant _RoutePainter oldDelegate,
  ) {
    return false;
  }
}