import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../widgets/animated_ev_background.dart';

import 'charging_booking_screen.dart';

class ChargingStationScreen extends StatefulWidget {
  const ChargingStationScreen({
    super.key,
  });

  @override
  State<ChargingStationScreen> createState() =>
      _ChargingStationScreenState();
}

class _ChargingStationScreenState
    extends State<ChargingStationScreen> {
  final List<Map<String, dynamic>> stations = [
    {
      "name": "EnerGo Fast Charging Hub",
      "location": "HSR Layout, Bengaluru",
      "distance": "2.5 km",
      "ports": "4 Ports Available",
      "type": "DC Fast Charging",
      "price": "₹12 / unit",
      "open": true,
    },
    {
      "name": "EnerGo EV Point",
      "location": "BTM Layout, Bengaluru",
      "distance": "4.1 km",
      "ports": "6 Ports Available",
      "type": "Fast Charging",
      "price": "₹11 / unit",
      "open": true,
    },
    {
      "name": "GreenCharge Station",
      "location": "Koramangala, Bengaluru",
      "distance": "5.8 km",
      "ports": "2 Ports Available",
      "type": "AC Charging",
      "price": "₹9 / unit",
      "open": false,
    },
  ];

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
                  20,
                  15,
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
                        "Charging Stations",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.my_location,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ],
                ),
              ),

              // =================================================
              // SEARCH BAR
              // =================================================

              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20),

                child: Container(
                  height: 52,

                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(.35),
                    borderRadius:
                        BorderRadius.circular(18),

                    border: Border.all(
                      color: AppColors.primaryGreen
                          .withOpacity(.15),
                    ),
                  ),

                  child: const TextField(
                    style: TextStyle(
                      color: Colors.white,
                    ),

                    decoration: InputDecoration(
                      border: InputBorder.none,

                      prefixIcon: Icon(
                        Icons.search,
                        color:
                            AppColors.primaryGreen,
                      ),

                      hintText:
                          "Search charging station",

                      hintStyle: TextStyle(
                        color: Colors.white54,
                      ),

                      contentPadding:
                          EdgeInsets.symmetric(
                        vertical: 15,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // =================================================
              // FILTERS
              // =================================================

              SizedBox(
                height: 42,

                child: ListView(
                  scrollDirection:
                      Axis.horizontal,

                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),

                  children: [
                    filterChip(
                      "All",
                      true,
                    ),

                    filterChip(
                      "Fast Charging",
                      false,
                    ),

                    filterChip(
                      "AC",
                      false,
                    ),

                    filterChip(
                      "Available",
                      false,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              // =================================================
              // STATION LIST
              // =================================================

              Expanded(
                child: ListView.builder(
                  padding:
                      const EdgeInsets.fromLTRB(
                    20,
                    5,
                    20,
                    25,
                  ),

                  itemCount:
                      stations.length,

                  itemBuilder:
                      (context, index) {
                    final station =
                        stations[index];

                    return stationCard(
                      station,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================
  // FILTER CHIP
  // ===========================================================

  Widget filterChip(
    String title,
    bool selected,
  ) {
    return Container(
      margin:
          const EdgeInsets.only(right: 10),

      padding:
          const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 10,
      ),

      decoration: BoxDecoration(
        color: selected
            ? AppColors.primaryGreen
                .withOpacity(.18)
            : AppColors.card,

        borderRadius:
            BorderRadius.circular(20),

        border: Border.all(
          color: selected
              ? AppColors.primaryGreen
              : Colors.transparent,
        ),
      ),

      child: Text(
        title,

        style: TextStyle(
          color: selected
              ? AppColors.primaryGreen
              : Colors.white70,

          fontSize: 13,

          fontWeight:
              selected
                  ? FontWeight.bold
                  : FontWeight.normal,
        ),
      ),
    );
  }

  // ===========================================================
  // STATION CARD
  // ===========================================================

  Widget stationCard(
    Map<String, dynamic> station,
  ) {
    final bool isOpen =
        station["open"] == true;

    return Container(
      margin:
          const EdgeInsets.only(bottom: 18),

      padding:
          const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: AppColors.card,

        borderRadius:
            BorderRadius.circular(24),

        border: Border.all(
          color: AppColors.primaryGreen
              .withOpacity(.18),
        ),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          // =================================================
          // TOP ROW
          // =================================================

          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              Container(
                height: 58,
                width: 58,

                decoration: BoxDecoration(
                  color:
                      AppColors.primaryGreen
                          .withOpacity(.14),

                  borderRadius:
                      BorderRadius.circular(17),
                ),

                child: const Icon(
                  Icons.ev_station,
                  color:
                      AppColors.primaryGreen,
                  size: 30,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    Text(
                      station["name"] ??
                          "Charging Station",

                      style:
                          const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      station["location"] ??
                          "",

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

              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 6,
                ),

                decoration: BoxDecoration(
                  color: isOpen
                      ? Colors.green
                          .withOpacity(.15)
                      : Colors.red
                          .withOpacity(.12),

                  borderRadius:
                      BorderRadius.circular(20),
                ),

                child: Text(
                  isOpen
                      ? "OPEN"
                      : "CLOSED",

                  style: TextStyle(
                    color: isOpen
                        ? Colors.green
                        : Colors.redAccent,

                    fontSize: 11,

                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // =================================================
          // DETAILS
          // =================================================

          Row(
            children: [
              Expanded(
                child: detailItem(
                  Icons.near_me,
                  station["distance"] ??
                      "--",
                ),
              ),

              Expanded(
                child: detailItem(
                  Icons.power,
                  station["ports"] ??
                      "--",
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: detailItem(
                  Icons.bolt,
                  station["type"] ??
                      "--",
                ),
              ),

              Expanded(
                child: detailItem(
                  Icons.currency_rupee,
                  station["price"] ??
                      "--",
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // =================================================
          // BUTTON
          // =================================================

          SizedBox(
            width: double.infinity,
            height: 48,

            child: ElevatedButton(
              onPressed: isOpen
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ChargingBookingScreen(
                            stationName:
                                station["name"]
                                    .toString(),

                            stationLocation:
                                station["location"]
                                    .toString(),

                            chargingType:
                                station["type"]
                                    .toString(),

                            price:
                                station["price"]
                                    .toString(),
                          ),
                        ),
                      );
                    }
                  : null,

              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    AppColors.primaryGreen,

                foregroundColor:
                    Colors.black,

                disabledBackgroundColor:
                    Colors.white10,

                disabledForegroundColor:
                    Colors.white30,

                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(18),
                ),
              ),

              child: Text(
                isOpen
                    ? "VIEW & BOOK"
                    : "STATION CLOSED",

                style:
                    const TextStyle(
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================
  // DETAIL ITEM
  // ===========================================================

  Widget detailItem(
    IconData icon,
    String text,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          color:
              AppColors.primaryGreen,
          size: 17,
        ),

        const SizedBox(width: 7),

        Expanded(
          child: Text(
            text,

            maxLines: 1,

            overflow:
                TextOverflow.ellipsis,

            style:
                const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}