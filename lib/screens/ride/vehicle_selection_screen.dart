import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/constants/app_colors.dart';
import '../../widgets/animated_ev_background.dart';

class VehicleSelectionScreen extends StatefulWidget {
  final String selected;
  final double distance;

  const VehicleSelectionScreen({
    super.key,
    required this.selected,
    required this.distance,
  });

  @override
  State<VehicleSelectionScreen> createState() =>
      _VehicleSelectionScreenState();
}

class _VehicleSelectionScreenState
    extends State<VehicleSelectionScreen> {
  late String selectedVehicle;

  final List<Map<String, dynamic>> vehicles = [
    {
      "name": "Bike",
      "subtitle": "Quick Ride",
      "icon": LucideIcons.bike,
      "rate": 8.0,
      "accent": "speed",
    },
    {
      "name": "Auto",
      "subtitle": "Affordable Ride",
      "icon": LucideIcons.carTaxiFront,
      "rate": 12.0,
      "accent": "eco",
    },
    {
      "name": "Mini EV",
      "subtitle": "Eco Friendly Ride",
      "icon": LucideIcons.car,
      "rate": 10.0,
      "accent": "ev",
    },
    {
      "name": "Sedan EV",
      "subtitle": "Comfort Ride",
      "icon": LucideIcons.carFront,
      "rate": 15.0,
      "accent": "comfort",
    },
    {
      "name": "Premium EV",
      "subtitle": "Luxury Ride",
      "icon": LucideIcons.car,
      "rate": 25.0,
      "accent": "premium",
      "best": true,
    },
  ];

  @override
  void initState() {
    super.initState();
    selectedVehicle = widget.selected;
  }

  double calculateFare(double rate) {
    return widget.distance * rate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedEVBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ==========================================================
                // HEADER
                // ==========================================================

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
                      "Choose Vehicle",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // ==========================================================
                // DISTANCE
                // ==========================================================

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: AppColors.primaryGreen
                          .withOpacity(0.20),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        LucideIcons.route,
                        color: AppColors.primaryGreen,
                        size: 21,
                      ),

                      const SizedBox(width: 10),

                      Text(
                        "Distance: "
                        "${widget.distance.toStringAsFixed(1)} km",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ==========================================================
                // VEHICLE LIST
                // ==========================================================

                Expanded(
                  child: ListView.builder(
                    physics:
                        const BouncingScrollPhysics(),

                    itemCount: vehicles.length,

                    itemBuilder: (context, index) {
                      final vehicle = vehicles[index];

                      final String name =
                          vehicle["name"] as String;

                      final bool isSelected =
                          selectedVehicle == name;

                      final double fare =
                          calculateFare(
                        (vehicle["rate"] as num)
                            .toDouble(),
                      );

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedVehicle = name;
                          });
                        },

                        child: AnimatedContainer(
                          duration:
                              const Duration(
                            milliseconds: 220,
                          ),

                          curve: Curves.easeOut,

                          margin:
                              const EdgeInsets.only(
                            bottom: 15,
                          ),

                          padding:
                              const EdgeInsets.all(16),

                          decoration: BoxDecoration(
                            color: AppColors.card,

                            borderRadius:
                                BorderRadius.circular(25),

                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primaryGreen
                                  : Colors.transparent,

                              width: 2,
                            ),

                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: AppColors
                                          .primaryGreen
                                          .withOpacity(
                                        0.18,
                                      ),
                                      blurRadius: 22,
                                      spreadRadius: 1,
                                    ),
                                  ]
                                : [],
                          ),

                          child: Row(
                            children: [

                              // =================================================
                              // PREMIUM VEHICLE ICON
                              // =================================================

                              VehicleIconCard(
                                icon:
                                    vehicle["icon"]
                                        as IconData,

                                accent:
                                    vehicle["accent"]
                                        as String,

                                selected:
                                    isSelected,

                                isPremium:
                                    vehicle["best"] ==
                                        true,
                              ),

                              const SizedBox(width: 16),

                              // =================================================
                              // DETAILS
                              // =================================================

                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                  children: [

                                    Row(
                                      children: [

                                        Flexible(
                                          child: Text(
                                            name,
                                            overflow:
                                                TextOverflow
                                                    .ellipsis,
                                            style:
                                                const TextStyle(
                                              color:
                                                  Colors.white,
                                              fontSize: 18,
                                              fontWeight:
                                                  FontWeight
                                                      .bold,
                                            ),
                                          ),
                                        ),

                                        if (vehicle["best"] ==
                                            true)
                                          Container(
                                            margin:
                                                const EdgeInsets
                                                    .only(
                                              left: 8,
                                            ),
                                            padding:
                                                const EdgeInsets
                                                    .symmetric(
                                              horizontal: 8,
                                              vertical: 3,
                                            ),
                                            decoration:
                                                BoxDecoration(
                                              color: AppColors
                                                  .primaryGreen,
                                              borderRadius:
                                                  BorderRadius
                                                      .circular(
                                                10,
                                              ),
                                            ),
                                            child:
                                                const Row(
                                              mainAxisSize:
                                                  MainAxisSize
                                                      .min,
                                              children: [

                                                Icon(
                                                  Icons
                                                      .star_rounded,
                                                  color:
                                                      Colors.black,
                                                  size: 10,
                                                ),

                                                SizedBox(
                                                  width: 3,
                                                ),

                                                Text(
                                                  "BEST",
                                                  style:
                                                      TextStyle(
                                                    color:
                                                        Colors.black,
                                                    fontSize: 9,
                                                    fontWeight:
                                                        FontWeight
                                                            .bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),

                                    const SizedBox(height: 7),

                                    Row(
                                      children: [

                                        Icon(
                                          _getFeatureIcon(
                                            vehicle["accent"]
                                                as String,
                                          ),
                                          color: AppColors
                                              .primaryGreen,
                                          size: 15,
                                        ),

                                        const SizedBox(width: 5),

                                        Flexible(
                                          child: Text(
                                            vehicle["subtitle"]
                                                as String,
                                            overflow:
                                                TextOverflow
                                                    .ellipsis,
                                            style:
                                                const TextStyle(
                                              color:
                                                  Colors.white54,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(width: 8),

                              // =================================================
                              // FARE
                              // =================================================

                              Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.end,
                                children: [

                                  Text(
                                    "₹${fare.toStringAsFixed(0)}",
                                    style:
                                        const TextStyle(
                                      color: AppColors
                                          .primaryGreen,
                                      fontSize: 19,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 3),

                                  const Text(
                                    "Estimated",
                                    style: TextStyle(
                                      color:
                                          Colors.white54,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 12),

                // ==========================================================
                // CONFIRM
                // ==========================================================

                SizedBox(
                  width: double.infinity,
                  height: 55,

                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(
                        context,
                        selectedVehicle,
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

                    child: const Text(
                      "CONFIRM VEHICLE",
                      style: TextStyle(
                        fontWeight:
                            FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getFeatureIcon(String accent) {
    switch (accent) {
      case "speed":
        return Icons.bolt_rounded;

      case "eco":
        return Icons.eco_rounded;

      case "ev":
        return Icons.battery_charging_full_rounded;

      case "comfort":
        return Icons.airline_seat_recline_extra_rounded;

      case "premium":
        return Icons.auto_awesome_rounded;

      default:
        return Icons.star_rounded;
    }
  }
}


// ============================================================================
// PREMIUM VEHICLE ICON CARD (v2 - richer glass/glow look)
// ============================================================================

class VehicleIconCard extends StatelessWidget {
  final IconData icon;
  final String accent;
  final bool selected;
  final bool isPremium;

  const VehicleIconCard({
    super.key,
    required this.icon,
    required this.accent,
    required this.selected,
    required this.isPremium,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOut,

      height: 74,
      width: 80,

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),

        // Deeper glass gradient instead of flat fill
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryGreen.withOpacity(
              selected ? 0.30 : 0.14,
            ),
            const Color(0xFF0B1512),
            const Color(0xFF06100D),
          ],
          stops: const [0.0, 0.55, 1.0],
        ),

        border: Border.all(
          color: selected
              ? AppColors.primaryGreen.withOpacity(0.65)
              : AppColors.primaryGreen.withOpacity(0.16),
          width: selected ? 1.4 : 1,
        ),

        boxShadow: [
          // Outer glow
          BoxShadow(
            color: AppColors.primaryGreen.withOpacity(
              selected ? 0.35 : 0.10,
            ),
            blurRadius: selected ? 24 : 12,
            spreadRadius: selected ? 1.5 : 0.5,
          ),
          // Inner depth shadow for glass feel
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),

      child: Stack(
        alignment: Alignment.center,
        children: [

          // ------------------------------------------------------------
          // Top glass highlight sheen
          // ------------------------------------------------------------
          Positioned(
            top: 4,
            left: 8,
            right: 8,
            child: Container(
              height: 18,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.06),
                    Colors.white.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),

          // ------------------------------------------------------------
          // Soft radial glow behind the icon
          // ------------------------------------------------------------
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.primaryGreen.withOpacity(
                    selected ? 0.28 : 0.14,
                  ),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          // ------------------------------------------------------------
          // Main vehicle icon with gradient shading
          // ------------------------------------------------------------
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                AppColors.primaryGreen,
                AppColors.primaryGreen.withOpacity(0.75),
              ],
              stops: const [0.0, 0.55, 1.0],
            ).createShader(bounds),
            blendMode: BlendMode.srcIn,
            child: Icon(
              icon,
              size: isPremium ? 40 : 38,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: AppColors.primaryGreen.withOpacity(0.6),
                  blurRadius: selected ? 16 : 8,
                ),
              ],
            ),
          ),

          // ================================================================
          // PREMIUM CROWN BADGE
          // ================================================================

          if (isPremium)
            Positioned(
              top: 6,
              right: 7,
              child: Container(
                height: 22,
                width: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primaryGreen.withOpacity(0.35),
                      AppColors.primaryGreen.withOpacity(0.12),
                    ],
                  ),
                  border: Border.all(
                    color: AppColors.primaryGreen.withOpacity(0.55),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryGreen.withOpacity(0.35),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.workspace_premium_rounded,
                  color: AppColors.primaryGreen,
                  size: 13,
                ),
              ),
            ),

          // ================================================================
          // EV BADGE
          // ================================================================

          if (accent == "ev" ||
              accent == "comfort" ||
              accent == "premium")
            Positioned(
              bottom: 7,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 5,
                  vertical: 1.5,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryGreen.withOpacity(0.30),
                      AppColors.primaryGreen.withOpacity(0.12),
                    ],
                  ),
                  border: Border.all(
                    color: AppColors.primaryGreen.withOpacity(0.4),
                    width: 0.6,
                  ),
                ),
                child: const Text(
                  "EV",
                  style: TextStyle(
                    color: AppColors.primaryGreen,
                    fontSize: 7,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

          // ================================================================
          // SPEED DETAIL - BIKE
          // ================================================================

          if (accent == "speed")
            Positioned(
              top: 7,
              right: 7,
              child: Icon(
                Icons.bolt_rounded,
                color: AppColors.primaryGreen.withOpacity(0.85),
                size: 14,
                shadows: [
                  Shadow(
                    color: AppColors.primaryGreen.withOpacity(0.5),
                    blurRadius: 6,
                  ),
                ],
              ),
            ),

          // ================================================================
          // ECO DETAIL - AUTO
          // ================================================================

          if (accent == "eco")
            Positioned(
              top: 7,
              right: 7,
              child: Icon(
                Icons.eco_rounded,
                color: AppColors.primaryGreen.withOpacity(0.85),
                size: 14,
                shadows: [
                  Shadow(
                    color: AppColors.primaryGreen.withOpacity(0.5),
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}