import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/constants/app_colors.dart';
import '../../services/api_service.dart';
import 'charging_payment_screen.dart';

class ChargingSessionScreen extends StatefulWidget {
  final Map<String, dynamic> booking;

  const ChargingSessionScreen({
    super.key,
    required this.booking,
  });

  @override
  State<ChargingSessionScreen> createState() =>
      _ChargingSessionScreenState();
}

class _ChargingSessionScreenState
    extends State<ChargingSessionScreen> {
  bool loading = false;
  bool completed = false;

  Map<String, dynamic>? session;

  Timer? timer;

  DateTime? startedAt;

  Duration elapsed = Duration.zero;

  double simulatedUnits = 0;

  @override
  void initState() {
    super.initState();

    // Existing booking/session response ko support karega.
    final existingSession = widget.booking['session'];

    if (existingSession is Map) {
      session = Map<String, dynamic>.from(
        existingSession,
      );

      if (session?['status']
              ?.toString()
              .toLowerCase() ==
          'started') {
        startedAt = DateTime.now();
        startTimer();
      }
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  dynamic get bookingId {
    return widget.booking['id'] ??
        widget.booking['booking_id'];
  }

  dynamic get sessionId {
    return session?['id'];
  }

  String value(
    Map<String, dynamic>? data,
    List<String> keys,
    String fallback,
  ) {
    if (data == null) return fallback;

    for (final key in keys) {
      final item = data[key];

      if (item != null &&
          item.toString().trim().isNotEmpty) {
        return item.toString();
      }
    }

    return fallback;
  }

  double numberValue(
    Map<String, dynamic>? data,
    List<String> keys,
  ) {
    if (data == null) return 0;

    for (final key in keys) {
      final value = double.tryParse(
        data[key]?.toString() ?? '',
      );

      if (value != null) {
        return value;
      }
    }

    return 0;
  }

  String get stationName {
    final station =
        widget.booking['station'];

    if (station is Map) {
      return station['station_name']
              ?.toString() ??
          station['name']?.toString() ??
          'Charging Station';
    }

    return widget.booking['station_name']
            ?.toString() ??
        'Charging Station';
  }

  String get portName {
    final port =
        widget.booking['port'];

    if (port is Map) {
      return port['port_name']
              ?.toString() ??
          port['name']?.toString() ??
          'Charging Port';
    }

    return widget.booking['port_name']
            ?.toString() ??
        'Charging Port';
  }

  double get rate {
    return numberValue(
      session,
      [
        'price_per_unit',
        'rate',
      ],
    );
  }

  double get finalAmount {
    final backendAmount =
        numberValue(
      session,
      [
        'total_amount',
      ],
    );

    if (backendAmount > 0) {
      return backendAmount;
    }

    return simulatedUnits * rate;
  }

  void startTimer() {
    timer?.cancel();

    timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (!mounted ||
            startedAt == null) {
          return;
        }

        final now = DateTime.now();

        setState(() {
          elapsed =
              now.difference(startedAt!);

          // Demo/live UI estimation.
          if (!completed &&
              rate > 0) {
            simulatedUnits =
                elapsed.inMinutes / 10;
          }
        });
      },
    );
  }

  Future<void> startCharging() async {
    if (bookingId == null) {
      showMessage(
        'Charging booking ID not available',
      );
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      final response =
          await ApiService.startChargingSession(
        chargingBookingId: bookingId,
      );

      if (!mounted) return;

      if (response['status'] == true) {
        final data =
            response['session'];

        if (data is Map) {
          session =
              Map<String, dynamic>.from(
            data,
          );
        }

        startedAt = DateTime.now();
        simulatedUnits = 0;

        startTimer();

        showMessage(
          'Charging started successfully',
        );
      } else {
        showMessage(
          response['message'] ??
              'Unable to start charging',
        );
      }
    } catch (e) {
      if (!mounted) return;

      showMessage(
        'Unable to start charging',
      );
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  Future<void> refreshSession() async {
    if (sessionId == null) return;

    setState(() {
      loading = true;
    });

    try {
      final response =
          await ApiService.getChargingSession(
        sessionId,
      );

      if (!mounted) return;

      if (response['status'] == true) {
        final data =
            response['session'];

        if (data is Map) {
          session =
              Map<String, dynamic>.from(
            data,
          );
        }

        final status =
            session?['status']
                    ?.toString()
                    .toLowerCase() ??
                '';

        if (status == 'completed') {
          completed = true;
          timer?.cancel();
        }
      } else {
        showMessage(
          response['message'] ??
              'Unable to refresh session',
        );
      }
    } catch (e) {
      if (!mounted) return;

      showMessage(
        'Unable to refresh session',
      );
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  Future<void> completeCharging() async {
    if (sessionId == null) {
      showMessage(
        'Charging session ID not available',
      );
      return;
    }

    final currentUnits =
        numberValue(
      session,
      [
        'units_consumed',
      ],
    );

    final units = currentUnits > 0
        ? currentUnits
        : simulatedUnits > 0
            ? simulatedUnits
            : 0.1;

    setState(() {
      loading = true;
    });

    try {
      final response =
          await ApiService
              .completeChargingSession(
        sessionId: sessionId,
        unitsConsumed: double.parse(
          units.toStringAsFixed(2),
        ),
      );

      if (!mounted) return;

if (response['status'] == true) {
  final data =
      response['session'];

  if (data is Map) {
    session =
        Map<String, dynamic>.from(
      data,
    );
  }

  final summary =
      response['charging_summary'];

  double amount = 0;

  if (summary is Map) {
    simulatedUnits =
        double.tryParse(
              summary['units_consumed']
                      ?.toString() ??
                  '',
            ) ??
            units;

    amount =
        double.tryParse(
              summary['amount']
                      ?.toString() ??
                  '',
            ) ??
            0;
  } else {
    simulatedUnits = units;
  }

  completed = true;
  timer?.cancel();

  if (!mounted) return;

  await Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (_) =>
          ChargingPaymentScreen(
        chargingSessionId:
            sessionId,
        amount: amount,
      ),
    ),
  );
}else {
        showMessage(
          response['message'] ??
              'Unable to complete charging',
        );
      }
    } catch (e) {
      if (!mounted) return;

      showMessage(
        'Unable to complete charging',
      );
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  Future<void> showCompletedDialog(
    Map<String, dynamic> response,
  ) async {
    final summary =
        response['charging_summary'];

    final amount =
        summary is Map
            ? double.tryParse(
                  summary['amount']
                          ?.toString() ??
                      '',
                ) ??
                finalAmount
            : finalAmount;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          backgroundColor:
              AppColors.card,
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              24,
            ),
          ),
          title: const Row(
            children: [
              Icon(
                LucideIcons
                    .circleCheck,
                color:
                    AppColors
                        .primaryGreen,
              ),
              SizedBox(width: 10),
              Text(
                'Charging Complete',
              ),
            ],
          ),
          content: Column(
            mainAxisSize:
                MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'Energy Used: ${simulatedUnits.toStringAsFixed(2)} units',
              ),
              const SizedBox(height: 8),
              Text(
                'Amount: ₹${amount.toStringAsFixed(2)}',
                style:
                    const TextStyle(
                  color:
                      AppColors
                          .primaryGreen,
                  fontWeight:
                      FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                );
              },
              child:
                  const Text(
                'DONE',
              ),
            ),
          ],
        );
      },
    );
  }

  void showMessage(
    String message,
  ) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  String formattedDuration(
    Duration duration,
  ) {
    final hours =
        duration.inHours
            .toString()
            .padLeft(
          2,
          '0',
        );

    final minutes =
        duration.inMinutes
                .remainder(60)
                .toString()
                .padLeft(
              2,
              '0',
            );

    final seconds =
        duration.inSeconds
                .remainder(60)
                .toString()
                .padLeft(
              2,
              '0',
            );

    return '$hours:$minutes:$seconds';
  }

  bool get isRunning {
    final status =
        session?['status']
                ?.toString()
                .toLowerCase() ??
            '';

    return status == 'started' &&
        !completed;
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          AppColors.background,

      appBar: AppBar(
        backgroundColor:
            Colors.transparent,
        elevation: 0,

        leading: IconButton(
          onPressed: () {
            Navigator.pop(
              context,
            );
          },
          icon: const Icon(
            LucideIcons.arrowLeft,
          ),
        ),

        title: const Text(
          'Charging Session',
          style: TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
        ),

        actions: [
          IconButton(
            onPressed: loading
                ? null
                : refreshSession,
            icon: const Icon(
              LucideIcons.refreshCw,
            ),
          ),
        ],
      ),

      body: SafeArea(
        child:
            SingleChildScrollView(
          padding:
              const EdgeInsets.all(
            20,
          ),
          child: Column(
            children: [
              stationCard(),

              const SizedBox(
                height: 20,
              ),

              liveStatusCard(),

              const SizedBox(
                height: 20,
              ),

              sessionStats(),

              const SizedBox(
                height: 20,
              ),

              energyCard(),

              const SizedBox(
                height: 25,
              ),

              actionButton(),

              const SizedBox(
                height: 20,
              ),

              if (!completed)
                const Text(
                  'Keep this screen open while charging',
                  style:
                      TextStyle(
                    color:
                        Colors.white38,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget stationCard() {
    return Container(
      width:
          double.infinity,
      padding:
          const EdgeInsets.all(
        20,
      ),
      decoration:
          BoxDecoration(
        color:
            AppColors.card,
        borderRadius:
            BorderRadius.circular(
          24,
        ),
      ),
      child:
          Row(
        children: [
          Container(
            height:
                62,
            width:
                62,
            decoration:
                BoxDecoration(
              color: AppColors
                  .primaryGreen
                  .withValues(
                alpha: .12,
              ),
              borderRadius:
                  BorderRadius.circular(
                18,
              ),
            ),
            child:
                const Icon(
              LucideIcons
                  .batteryCharging,
              color:
                  AppColors
                      .primaryGreen,
              size:
                  34,
            ),
          ),

          const SizedBox(
            width: 14,
          ),

          Expanded(
            child:
                Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  stationName,
                  maxLines:
                      1,
                  overflow:
                      TextOverflow
                          .ellipsis,
                  style:
                      const TextStyle(
                    fontSize:
                        18,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  portName,
                  style:
                      const TextStyle(
                    color:
                        Colors.white54,
                    fontSize:
                        12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget liveStatusCard() {
    final title =
        completed
            ? 'Charging Completed'
            : isRunning
                ? 'Charging in Progress'
                : 'Ready to Charge';

    final icon =
        completed
            ? LucideIcons
                .circleCheck
            : isRunning
                ? LucideIcons
                    .zap
                : LucideIcons
                    .plugZap;

    return Container(
      width:
          double.infinity,
      padding:
          const EdgeInsets.symmetric(
        vertical: 28,
        horizontal: 20,
      ),
      decoration:
          BoxDecoration(
        color: AppColors
            .primaryGreen
            .withValues(
          alpha:
              completed ? .08 : .12,
        ),
        borderRadius:
            BorderRadius.circular(
          26,
        ),
        border:
            Border.all(
          color: AppColors
              .primaryGreen
              .withValues(
            alpha: .18,
          ),
        ),
      ),
      child:
          Column(
        children: [
          Container(
            height:
                85,
            width:
                85,
            decoration:
                BoxDecoration(
              shape:
                  BoxShape.circle,
              color: AppColors
                  .primaryGreen
                  .withValues(
                alpha: .12,
              ),
            ),
            child:
                Icon(
              icon,
              color:
                  AppColors
                      .primaryGreen,
              size:
                  45,
            ),
          ),

          const SizedBox(
            height: 16,
          ),

          Text(
            title,
            style:
                const TextStyle(
              fontSize:
                  21,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: 8,
          ),

          if (isRunning)
            Text(
              formattedDuration(
                elapsed,
              ),
              style:
                  const TextStyle(
                color: AppColors
                    .primaryGreen,
                fontSize:
                    30,
                fontWeight:
                    FontWeight.bold,
                letterSpacing:
                    1.5,
              ),
            )
          else
            Text(
              completed
                  ? 'Session finished successfully'
                  : 'Start your EV charging session',
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                color:
                    Colors.white54,
              ),
            ),
        ],
      ),
    );
  }

  Widget sessionStats() {
    final bookingDate =
        widget.booking[
                'booking_date']
            ?.toString() ??
            '-';

    final startTime =
        widget.booking[
                'start_time']
            ?.toString() ??
            '-';

    final endTime =
        widget.booking[
                'end_time']
            ?.toString() ??
            '-';

    return Row(
      children: [
        Expanded(
          child: statCard(
            icon:
                LucideIcons.calendarDays,
            title:
                'Date',
            value:
                bookingDate,
          ),
        ),

        const SizedBox(
          width: 10,
        ),

        Expanded(
          child: statCard(
            icon:
                LucideIcons.clock3,
            title:
                'Slot',
            value:
                '$startTime - $endTime',
          ),
        ),
      ],
    );
  }

  Widget statCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding:
          const EdgeInsets.all(
        15,
      ),
      decoration:
          BoxDecoration(
        color:
            AppColors.card,
        borderRadius:
            BorderRadius.circular(
          18,
        ),
      ),
      child:
          Column(
        crossAxisAlignment:
            CrossAxisAlignment
                .start,
        children: [
          Icon(
            icon,
            color:
                AppColors
                    .primaryGreen,
            size:
                21,
          ),
          const SizedBox(
            height: 9,
          ),
          Text(
            title,
            style:
                const TextStyle(
              color:
                  Colors.white38,
              fontSize:
                  11,
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          Text(
            value,
            maxLines:
                2,
            overflow:
                TextOverflow
                    .ellipsis,
            style:
                const TextStyle(
              fontWeight:
                  FontWeight.bold,
              fontSize:
                  12,
            ),
          ),
        ],
      ),
    );
  }

  Widget energyCard() {
    final units =
        numberValue(
              session,
              [
                'units_consumed',
              ],
            ) >
            0
        ? numberValue(
            session,
            [
              'units_consumed',
            ],
          )
        : simulatedUnits;

    final amount =
        finalAmount;

    return Container(
      width:
          double.infinity,
      padding:
          const EdgeInsets.all(
        20,
      ),
      decoration:
          BoxDecoration(
        color:
            AppColors.card,
        borderRadius:
            BorderRadius.circular(
          22,
        ),
      ),
      child:
          Column(
        children: [
          Row(
            children: [
              const Icon(
                LucideIcons
                    .zap,
                color:
                    AppColors
                        .primaryGreen,
              ),
              const SizedBox(
                width: 10,
              ),
              const Expanded(
                child: Text(
                  'Energy & Cost',
                  style:
                      TextStyle(
                    fontSize:
                        18,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 20,
          ),

          Row(
            children: [
              Expanded(
                child: energyValue(
                  'Energy Used',
                  '${units.toStringAsFixed(2)} kWh',
                ),
              ),
              Expanded(
                child: energyValue(
                  'Rate',
                  '₹${rate.toStringAsFixed(2)} / unit',
                ),
              ),
              Expanded(
                child: energyValue(
                  'Amount',
                  '₹${amount.toStringAsFixed(2)}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget energyValue(
    String title,
    String value,
  ) {
    return Column(
      children: [
        Text(
          title,
          textAlign:
              TextAlign.center,
          style:
              const TextStyle(
            color:
                Colors.white38,
            fontSize:
                11,
          ),
        ),
        const SizedBox(
          height: 7,
        ),
        Text(
          value,
          textAlign:
              TextAlign.center,
          style:
              const TextStyle(
            color:
                AppColors.primaryGreen,
            fontWeight:
                FontWeight.bold,
            fontSize:
                13,
          ),
        ),
      ],
    );
  }

  Widget actionButton() {
    String text;
    IconData icon;
    VoidCallback? action;

    if (loading) {
      text = 'PROCESSING...';
      icon = LucideIcons.loaderCircle;
      action = null;
    } else if (completed) {
      text = 'CHARGING COMPLETED';
      icon = LucideIcons.circleCheck;
      action = null;
    } else if (isRunning) {
      text = 'COMPLETE CHARGING';
      icon = LucideIcons.square;
      action = completeCharging;
    } else {
      text = 'START CHARGING';
      icon = LucideIcons.zap;
      action = startCharging;
    }

    return SizedBox(
      width:
          double.infinity,
      height:
          58,
      child:
          ElevatedButton.icon(
        onPressed:
            action,
        icon: loading
            ? const SizedBox(
                height:
                    20,
                width:
                    20,
                child:
                    CircularProgressIndicator(
                  strokeWidth:
                      2,
                ),
              )
            : Icon(icon),
        label:
            Text(
          text,
          style:
              const TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
        ),
        style:
            ElevatedButton.styleFrom(
          backgroundColor:
              completed
                  ? Colors.white12
                  : AppColors
                      .primaryGreen,
          foregroundColor:
              completed
                  ? Colors.white54
                  : Colors.black,
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              19,
            ),
          ),
        ),
      ),
    );
  }
}