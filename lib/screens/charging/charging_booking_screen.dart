import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../widgets/animated_ev_background.dart';

import 'charging_session_screen.dart';

class ChargingBookingScreen extends StatefulWidget {
  final String stationName;
  final String stationLocation;
  final String chargingType;
  final String price;

  const ChargingBookingScreen({
    super.key,
    required this.stationName,
    required this.stationLocation,
    required this.chargingType,
    required this.price,
  });

  @override
  State<ChargingBookingScreen> createState() =>
      _ChargingBookingScreenState();
}

class _ChargingBookingScreenState
    extends State<ChargingBookingScreen> {
  int selectedPort = 1;

  DateTime? selectedDate;

  TimeOfDay? selectedTime;

  bool bookingLoading = false;

  // ==========================================================
  // DATE PICKER
  // ==========================================================

  Future<void> selectDate() async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(
        const Duration(days: 30),
      ),
      initialDate: selectedDate ?? now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primaryGreen,
              surface: AppColors.card,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  // ==========================================================
  // TIME PICKER
  // ==========================================================

  Future<void> selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime:
          selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primaryGreen,
              surface: AppColors.card,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  // ==========================================================
  // BOOK SLOT
  // ==========================================================

  Future<void> bookChargingSlot() async {
    if (selectedDate == null) {
      showMessage(
        "Please select a charging date",
      );
      return;
    }

    if (selectedTime == null) {
      showMessage(
        "Please select a charging time",
      );
      return;
    }

    try {
      setState(() {
        bookingLoading = true;
      });

      // ------------------------------------------------------
      // Backend booking API later connect karenge.
      // Abhi navigation structure prepare kar rahe hain.
      // ------------------------------------------------------

      await Future.delayed(
        const Duration(milliseconds: 700),
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ChargingSessionScreen(
            stationName:
                widget.stationName,

            stationLocation:
                widget.stationLocation,

            chargingType:
                widget.chargingType,

            price:
                widget.price,

            selectedPort:
                selectedPort,

            bookingDate:
                selectedDate!,

            bookingTime:
                selectedTime!,
          ),
        ),
      );
    } catch (e) {
      debugPrint(
        "CHARGING BOOKING ERROR: $e",
      );

      showMessage(
        "Unable to book charging slot",
      );
    } finally {
      if (mounted) {
        setState(() {
          bookingLoading = false;
        });
      }
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  // ==========================================================
  // FORMAT DATE
  // ==========================================================

  String get formattedDate {
    if (selectedDate == null) {
      return "Select Date";
    }

    final day =
        selectedDate!.day.toString().padLeft(2, '0');

    final month =
        selectedDate!.month.toString().padLeft(2, '0');

    final year =
        selectedDate!.year.toString();

    return "$day/$month/$year";
  }

  // ==========================================================
  // FORMAT TIME
  // ==========================================================

  String get formattedTime {
    if (selectedTime == null) {
      return "Select Time";
    }

    return selectedTime!.format(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          AppColors.background,

      body: AnimatedEVBackground(
        child: SafeArea(
          child: Column(
            children: [
              // =================================================
              // HEADER
              // =================================================

              Padding(
                padding:
                    const EdgeInsets.fromLTRB(
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

                    const Text(
                      "Book Charging",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // =================================================
              // CONTENT
              // =================================================

              Expanded(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.fromLTRB(
                    20,
                    5,
                    20,
                    30,
                  ),

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      // =================================================
                      // STATION HERO CARD
                      // =================================================

                      Container(
                        width: double.infinity,
                        padding:
                            const EdgeInsets.all(20),

                        decoration:
                            BoxDecoration(
                          color: AppColors.card,
                          borderRadius:
                              BorderRadius.circular(
                            25,
                          ),
                          border: Border.all(
                            color: AppColors
                                .primaryGreen
                                .withOpacity(.20),
                          ),
                        ),

                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,

                          children: [
                            Row(
                              children: [
                                Container(
                                  height: 65,
                                  width: 65,

                                  decoration:
                                      BoxDecoration(
                                    color: AppColors
                                        .primaryGreen
                                        .withOpacity(
                                            .14),
                                    borderRadius:
                                        BorderRadius
                                            .circular(
                                      18,
                                    ),
                                  ),

                                  child:
                                      const Icon(
                                    Icons.ev_station,
                                    color: AppColors
                                        .primaryGreen,
                                    size: 34,
                                  ),
                                ),

                                const SizedBox(
                                  width: 15,
                                ),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,
                                    children: [
                                      Text(
                                        widget.stationName,
                                        style:
                                            const TextStyle(
                                          color: Colors
                                              .white,
                                          fontSize: 19,
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                        ),
                                      ),

                                      const SizedBox(
                                        height: 6,
                                      ),

                                      Text(
                                        widget.stationLocation,
                                        style:
                                            const TextStyle(
                                          color: Colors
                                              .white54,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(
                              height: 20,
                            ),

                            Row(
                              children: [
                                infoChip(
                                  Icons.bolt,
                                  widget.chargingType,
                                ),

                                const SizedBox(
                                  width: 10,
                                ),

                                infoChip(
                                  Icons.currency_rupee,
                                  widget.price,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // =================================================
                      // PORT SELECTION
                      // =================================================

                      const Text(
                        "Select Charging Port",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 15),

                      GridView.builder(
                        shrinkWrap: true,
                        physics:
                            const NeverScrollableScrollPhysics(),

                        itemCount: 4,

                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 2.3,
                        ),

                        itemBuilder:
                            (context, index) {
                          final port =
                              index + 1;

                          final selected =
                              selectedPort ==
                                  port;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedPort =
                                    port;
                              });
                            },

                            child: Container(
                              decoration:
                                  BoxDecoration(
                                color: selected
                                    ? AppColors
                                        .primaryGreen
                                        .withOpacity(
                                            .16)
                                    : AppColors.card,

                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  18,
                                ),

                                border:
                                    Border.all(
                                  color: selected
                                      ? AppColors
                                          .primaryGreen
                                      : Colors
                                          .transparent,
                                ),
                              ),

                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment
                                        .center,

                                children: [
                                  Icon(
                                    Icons
                                        .power,
                                    color: AppColors
                                        .primaryGreen,
                                    size: 20,
                                  ),

                                  const SizedBox(
                                    width: 8,
                                  ),

                                  Text(
                                    "Port $port",
                                    style:
                                        const TextStyle(
                                      color: Colors
                                          .white,
                                      fontWeight:
                                          FontWeight
                                              .bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 28),

                      // =================================================
                      // DATE & TIME
                      // =================================================

                      const Text(
                        "Select Date & Time",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 15),

                      Row(
                        children: [
                          Expanded(
                            child: selectionCard(
                              icon:
                                  Icons.calendar_month,
                              title:
                                  "Date",
                              value:
                                  formattedDate,
                              onTap:
                                  selectDate,
                            ),
                          ),

                          const SizedBox(
                            width: 12,
                          ),

                          Expanded(
                            child: selectionCard(
                              icon:
                                  Icons.access_time,
                              title:
                                  "Time",
                              value:
                                  formattedTime,
                              onTap:
                                  selectTime,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      // =================================================
                      // BOOKING SUMMARY
                      // =================================================

                      Container(
                        width: double.infinity,

                        padding:
                            const EdgeInsets.all(
                          20,
                        ),

                        decoration:
                            BoxDecoration(
                          color:
                              AppColors.darkGreen
                                  .withOpacity(
                                      .28),

                          borderRadius:
                              BorderRadius.circular(
                            22,
                          ),

                          border: Border.all(
                            color: AppColors
                                .primaryGreen
                                .withOpacity(.18),
                          ),
                        ),

                        child: Column(
                          children: [
                            summaryRow(
                              "Station",
                              widget.stationName,
                            ),

                            summaryRow(
                              "Charging Type",
                              widget.chargingType,
                            ),

                            summaryRow(
                              "Selected Port",
                              "Port $selectedPort",
                            ),

                            summaryRow(
                              "Price",
                              widget.price,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      // =================================================
                      // BOOK BUTTON
                      // =================================================

                      SizedBox(
                        width: double.infinity,
                        height: 56,

                        child: ElevatedButton(
                          onPressed:
                              bookingLoading
                                  ? null
                                  : bookChargingSlot,

                          style:
                              ElevatedButton.styleFrom(
                            backgroundColor:
                                AppColors
                                    .primaryGreen,

                            foregroundColor:
                                Colors.black,

                            disabledBackgroundColor:
                                Colors.white10,

                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                20,
                              ),
                            ),
                          ),

                          child: bookingLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child:
                                      CircularProgressIndicator(
                                    color: Colors
                                        .black,
                                  ),
                                )
                              : const Text(
                                  "BOOK CHARGING SLOT",
                                  style:
                                      TextStyle(
                                    fontSize: 15,
                                    fontWeight:
                                        FontWeight
                                            .bold,
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
  // INFO CHIP
  // ===========================================================

  Widget infoChip(
    IconData icon,
    String text,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),

      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius:
            BorderRadius.circular(15),
      ),

      child: Row(
        children: [
          Icon(
            icon,
            color:
                AppColors.primaryGreen,
            size: 17,
          ),

          const SizedBox(width: 6),

          Text(
            text,
            style:
                const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight:
                  FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================
  // DATE/TIME CARD
  // ===========================================================

  Widget selectionCard({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,

      child: Container(
        padding:
            const EdgeInsets.all(16),

        decoration: BoxDecoration(
          color: AppColors.card,

          borderRadius:
              BorderRadius.circular(20),

          border: Border.all(
            color: Colors.white10,
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

            const SizedBox(height: 10),

            Text(
              title,

              style:
                  const TextStyle(
                color: Colors.white54,
                fontSize: 12,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              value,

              maxLines: 1,

              overflow:
                  TextOverflow.ellipsis,

              style:
                  const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================
  // SUMMARY ROW
  // ===========================================================

  Widget summaryRow(
    String title,
    String value,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 13),

      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style:
                  const TextStyle(
                color: Colors.white54,
                fontSize: 13,
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
                fontSize: 13,
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