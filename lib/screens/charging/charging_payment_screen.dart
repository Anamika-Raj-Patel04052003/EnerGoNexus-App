import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/constants/app_colors.dart';
import '../../services/api_service.dart';
import '../payment/payment_success_screen.dart';

class ChargingPaymentScreen extends StatefulWidget {
  final dynamic chargingSessionId;
  final double amount;

  const ChargingPaymentScreen({
    super.key,
    required this.chargingSessionId,
    required this.amount,
  });

  @override
  State<ChargingPaymentScreen> createState() =>
      _ChargingPaymentScreenState();
}

class _ChargingPaymentScreenState
    extends State<ChargingPaymentScreen> {
  String selectedMethod = 'Wallet';
  bool loading = false;

  Future<void> makePayment() async {
    if (loading) return;

    setState(() {
      loading = true;
    });

    try {
      Map<String, dynamic> response;

      // ==========================================================
      // WALLET
      // ==========================================================

      if (selectedMethod == 'Wallet') {
        response =
            await ApiService.chargingPayment(
          chargingSessionId:
              widget.chargingSessionId,
          paymentMethod: 'Wallet',
        );
      }

      // ==========================================================
      // CASH
      // ==========================================================

      else if (selectedMethod == 'Cash') {
        response =
            await ApiService.chargingPayment(
          chargingSessionId:
              widget.chargingSessionId,
          paymentMethod: 'Cash',
        );
      }

      // ==========================================================
      // UPI
      // ==========================================================

      else if (selectedMethod == 'UPI') {
        final success =
            await showDummyOnlinePayment(
          'UPI',
        );

        if (!success) {
          return;
        }

        response =
            await ApiService.chargingPayment(
          chargingSessionId:
              widget.chargingSessionId,
          paymentMethod: 'UPI',
        );
      }

      // ==========================================================
      // CARD
      // ==========================================================

      else {
        final success =
            await showDummyOnlinePayment(
          'Card',
        );

        if (!success) {
          return;
        }

        response =
            await ApiService.chargingPayment(
          chargingSessionId:
              widget.chargingSessionId,
          paymentMethod: 'Card',
        );
      }

      if (!mounted) return;

      if (response['status'] == true) {
        final payment =
            response['payment'];

        dynamic paymentId;

        if (payment is Map) {
          paymentId =
              payment['id'];
        }

        paymentId ??=
            response['payment_id'];

        if (paymentId == null) {
          showMessage(
            'Payment successful, but payment ID was not received.',
          );
          return;
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                PaymentSuccessScreen(
              rideId: null,
              paymentId:
                  paymentId,
              amount:
                  widget.amount,
              paymentMethod:
                  selectedMethod,
            ),
          ),
        );
      } else {
        showMessage(
          response['message'] ??
              'Payment failed',
        );
      }
    } catch (e) {
      if (!mounted) return;

      showMessage(
        'Unable to process payment',
      );
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  Future<bool> showDummyOnlinePayment(
    String method,
  ) async {
    return await showModalBottomSheet<bool>(
          context: context,
          backgroundColor:
              AppColors.card,
          shape:
              const RoundedRectangleBorder(
            borderRadius:
                BorderRadius.vertical(
              top: Radius.circular(
                28,
              ),
            ),
          ),
          builder: (_) {
            return SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.all(
                  22,
                ),
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    Container(
                      height: 55,
                      width: 55,
                      decoration:
                          BoxDecoration(
                        color: AppColors
                            .primaryGreen
                            .withValues(
                          alpha: .10,
                        ),
                        borderRadius:
                            BorderRadius
                                .circular(
                          16,
                        ),
                      ),
                      child:
                          Icon(
                        method == 'UPI'
                            ? LucideIcons
                                .smartphone
                            : LucideIcons
                                .creditCard,
                        color: AppColors
                            .primaryGreen,
                        size: 28,
                      ),
                    ),

                    const SizedBox(
                      height: 15,
                    ),

                    Text(
                      '$method Payment',
                      style:
                          const TextStyle(
                        fontSize: 20,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    Text(
                      'Pay ₹${widget.amount.toStringAsFixed(2)} securely.',
                      textAlign:
                          TextAlign.center,
                      style:
                          const TextStyle(
                        color:
                            Colors.white54,
                      ),
                    ),

                    const SizedBox(
                      height: 22,
                    ),

                    SizedBox(
                      width:
                          double.infinity,
                      height: 52,
                      child:
                          ElevatedButton(
                        onPressed: () {
                          Navigator.pop(
                            context,
                            true,
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
                                BorderRadius
                                    .circular(
                              17,
                            ),
                          ),
                        ),
                        child:
                            const Text(
                          'PAY NOW',
                          style:
                              TextStyle(
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    SizedBox(
                      width:
                          double.infinity,
                      height: 52,
                      child:
                          OutlinedButton(
                        onPressed: () {
                          Navigator.pop(
                            context,
                            false,
                          );
                        },
                        style:
                            OutlinedButton
                                .styleFrom(
                          foregroundColor:
                              Colors.white70,
                          side:
                              const BorderSide(
                            color:
                                Colors.white12,
                          ),
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(
                              17,
                            ),
                          ),
                        ),
                        child:
                            const Text(
                          'CANCEL',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ) ??
        false;
  }

  void showMessage(
    String message,
  ) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content:
            Text(message),
      ),
    );
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
          'Charging Payment',
          style: TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
        ),
      ),

      body: SafeArea(
        child:
            SingleChildScrollView(
          padding:
              const EdgeInsets.all(
            20,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment
                    .start,
            children: [
              Container(
                width:
                    double.infinity,
                padding:
                    const EdgeInsets.all(
                  24,
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
                    Column(
                  children: [
                    const Icon(
                      LucideIcons
                          .batteryCharging,
                      color: AppColors
                          .primaryGreen,
                      size: 55,
                    ),

                    const SizedBox(
                      height: 15,
                    ),

                    const Text(
                      'Charging Amount',
                      style:
                          TextStyle(
                        color:
                            Colors.white54,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    Text(
                      '₹${widget.amount.toStringAsFixed(2)}',
                      style:
                          const TextStyle(
                        fontSize: 34,
                        fontWeight:
                            FontWeight.bold,
                        color: AppColors
                            .primaryGreen,
                      ),
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    Text(
                      'Session #${widget.chargingSessionId}',
                      style:
                          const TextStyle(
                        color:
                            Colors.white38,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 28,
              ),

              const Text(
                'Choose Payment Method',
                style:
                    TextStyle(
                  fontSize: 20,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(
                height: 14,
              ),

              paymentOption(
                method: 'Wallet',
                icon:
                    LucideIcons.wallet,
                subtitle:
                    'Pay using wallet balance',
              ),

              paymentOption(
                method: 'UPI',
                icon:
                    LucideIcons
                        .smartphone,
                subtitle:
                    'Google Pay / PhonePe / UPI',
              ),

              paymentOption(
                method: 'Card',
                icon:
                    LucideIcons
                        .creditCard,
                subtitle:
                    'Debit or Credit Card',
              ),

              paymentOption(
                method: 'Cash',
                icon:
                    LucideIcons.banknote,
                subtitle:
                    'Pay directly at supported station',
              ),

              const SizedBox(
                height: 28,
              ),

              Container(
                width:
                    double.infinity,
                padding:
                    const EdgeInsets.all(
                  18,
                ),
                decoration:
                    BoxDecoration(
                  color: AppColors
                      .primaryGreen
                      .withValues(
                    alpha: .06,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    18,
                  ),
                  border:
                      Border.all(
                    color: AppColors
                        .primaryGreen
                        .withValues(
                      alpha: .15,
                    ),
                  ),
                ),
                child:
                    Row(
                  children: [
                    const Icon(
                      LucideIcons
                          .shieldCheck,
                      color: AppColors
                          .primaryGreen,
                    ),

                    const SizedBox(
                      width: 10,
                    ),

                    const Expanded(
                      child: Text(
                        'Your charging payment is securely processed.',
                        style:
                            TextStyle(
                          color:
                              Colors.white60,
                          fontSize:
                              12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 22,
              ),

              SizedBox(
                width:
                    double.infinity,
                height: 58,
                child:
                    ElevatedButton(
                  onPressed:
                      loading
                          ? null
                          : makePayment,
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
                        19,
                      ),
                    ),
                  ),
                  child: loading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child:
                              CircularProgressIndicator(
                            strokeWidth:
                                2,
                            color:
                                Colors.black,
                          ),
                        )
                      : Text(
                          'PAY ₹${widget.amount.toStringAsFixed(2)}',
                          style:
                              const TextStyle(
                            fontWeight:
                                FontWeight.bold,
                            fontSize:
                                16,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget paymentOption({
    required String method,
    required IconData icon,
    required String subtitle,
  }) {
    final selected =
        selectedMethod ==
            method;

    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 11,
      ),
      child:
          Material(
        color:
            Colors.transparent,
        child:
            InkWell(
          borderRadius:
              BorderRadius.circular(
            19,
          ),
          onTap: () {
            setState(() {
              selectedMethod =
                  method;
            });
          },
          child:
              Container(
            padding:
                const EdgeInsets.all(
              16,
            ),
            decoration:
                BoxDecoration(
              color:
                  AppColors.card,
              borderRadius:
                  BorderRadius.circular(
                19,
              ),
              border:
                  Border.all(
                color: selected
                    ? AppColors
                        .primaryGreen
                    : Colors.white10,
                width:
                    selected
                        ? 1.5
                        : 1,
              ),
            ),
            child:
                Row(
              children: [
                Container(
                  height:
                      48,
                  width:
                      48,
                  decoration:
                      BoxDecoration(
                    color: AppColors
                        .primaryGreen
                        .withValues(
                      alpha: .10,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      14,
                    ),
                  ),
                  child:
                      Icon(
                    icon,
                    color: AppColors
                        .primaryGreen,
                  ),
                ),

                const SizedBox(
                  width: 13,
                ),

                Expanded(
                  child:
                      Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      Text(
                        method,
                        style:
                            const TextStyle(
                          fontWeight:
                              FontWeight.bold,
                          fontSize:
                              16,
                        ),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Text(
                        subtitle,
                        style:
                            const TextStyle(
                          color:
                              Colors.white54,
                          fontSize:
                              11,
                        ),
                      ),
                    ],
                  ),
                ),

                Icon(
                  selected
                      ? LucideIcons
                          .circleCheck
                      : LucideIcons
                          .circle,
                  color: selected
                      ? AppColors
                          .primaryGreen
                      : Colors.white24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}