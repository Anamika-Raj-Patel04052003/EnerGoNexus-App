import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../widgets/animated_ev_background.dart';

class ChargingPaymentScreen extends StatefulWidget {
  final dynamic chargingSessionId;
  final double amount;
  final String stationName;

  const ChargingPaymentScreen({
    super.key,
    required this.chargingSessionId,
    required this.amount,
    required this.stationName,
  });

  @override
  State<ChargingPaymentScreen> createState() =>
      _ChargingPaymentScreenState();
}

class _ChargingPaymentScreenState
    extends State<ChargingPaymentScreen> {
  String selectedMethod = "Wallet";

  bool loading = false;

  Future<void> payNow() async {
    if (loading) return;

    setState(() {
      loading = true;
    });

    /*
      Backend integration next step.

      Payment methods:
      Wallet
      UPI / Razorpay
      Card
      Cash

      Backend endpoint:
      /payment/charging
    */

    await Future.delayed(
      const Duration(milliseconds: 500),
    );

    if (!mounted) return;

    setState(() {
      loading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "$selectedMethod payment flow ready",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      body: AnimatedEVBackground(
        child: SafeArea(
          child: Column(
            children: [
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
                        "Charging Payment",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
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
                      // STATION SUMMARY
                      // =================================================

                      Container(
                        width: double.infinity,
                        padding:
                            const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius:
                              BorderRadius.circular(25),
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
                                  height: 55,
                                  width: 55,
                                  decoration:
                                      BoxDecoration(
                                    color: AppColors
                                        .primaryGreen
                                        .withOpacity(.14),
                                    borderRadius:
                                        BorderRadius.circular(
                                      16,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.ev_station,
                                    color: AppColors
                                        .primaryGreen,
                                    size: 30,
                                  ),
                                ),
                                const SizedBox(
                                    width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,
                                    children: [
                                      const Text(
                                        "Charging Station",
                                        style: TextStyle(
                                          color: Colors
                                              .white54,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(
                                          height: 4),
                                      Text(
                                        widget.stationName,
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
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            const Divider(
                              color: Colors.white10,
                            ),

                            const SizedBox(height: 15),

                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment
                                      .spaceBetween,
                              children: [
                                const Text(
                                  "Total Amount",
                                  style:
                                      TextStyle(
                                    color:
                                        Colors.white60,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  "₹${widget.amount.toStringAsFixed(2)}",
                                  style:
                                      const TextStyle(
                                    color: AppColors
                                        .primaryGreen,
                                    fontSize: 26,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      // =================================================
                      // PAYMENT METHOD
                      // =================================================

                      const Text(
                        "Select Payment Method",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 15),

                      paymentOption(
                        title: "EnerGo Wallet",
                        subtitle:
                            "Pay from your wallet balance",
                        icon:
                            Icons.account_balance_wallet,
                        value: "Wallet",
                      ),

                      paymentOption(
                        title: "Online Payment",
                        subtitle:
                            "UPI / Card / Net Banking",
                        icon: Icons.payment,
                        value: "Online",
                      ),

                      paymentOption(
                        title: "Cash",
                        subtitle:
                            "Pay at the charging station",
                        icon: Icons.money,
                        value: "Cash",
                      ),

                      const SizedBox(height: 20),

                      // =================================================
                      // PAYMENT INFO
                      // =================================================

                      Container(
                        width: double.infinity,
                        padding:
                            const EdgeInsets.all(17),
                        decoration: BoxDecoration(
                          color: AppColors
                              .darkGreen
                              .withOpacity(.28),
                          borderRadius:
                              BorderRadius.circular(18),
                          border: Border.all(
                            color: AppColors
                                .primaryGreen
                                .withOpacity(.14),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.lock_outline,
                              color: AppColors
                                  .primaryGreen,
                              size: 22,
                            ),
                            const SizedBox(
                                width: 12),
                            const Expanded(
                              child: Text(
                                "Your payment details are securely processed through EnerGo.",
                                style: TextStyle(
                                  color:
                                      Colors.white60,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      // =================================================
                      // PAY BUTTON
                      // =================================================

                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed:
                              loading ? null : payNow,
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
                                  BorderRadius.circular(
                                20,
                              ),
                            ),
                          ),
                          child: loading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child:
                                      CircularProgressIndicator(
                                    color: Colors.black,
                                  ),
                                )
                              : Text(
                                  selectedMethod ==
                                          "Online"
                                      ? "PAY WITH RAZORPAY"
                                      : "PAY NOW",
                                  style:
                                      const TextStyle(
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
            ],
          ),
        ),
      ),
    );
  }

  Widget paymentOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required String value,
  }) {
    final selected = selectedMethod == value;

    return GestureDetector(
      onTap: loading
          ? null
          : () {
              setState(() {
                selectedMethod = value;
              });
            },
      child: Container(
        margin:
            const EdgeInsets.only(bottom: 15),
        padding:
            const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primaryGreen
                  .withOpacity(.15)
              : AppColors.card,
          borderRadius:
              BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? AppColors.primaryGreen
                : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Container(
              height: 45,
              width: 45,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen
                    .withOpacity(.12),
                borderRadius:
                    BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color:
                    AppColors.primaryGreen,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style:
                        const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style:
                        const TextStyle(
                      color: Colors.white54,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            Radio<String>(
              value: value,
              groupValue:
                  selectedMethod,
              onChanged: loading
                  ? null
                  : (value) {
                      if (value == null) return;

                      setState(() {
                        selectedMethod =
                            value;
                      });
                    },
            ),
          ],
        ),
      ),
    );
  }
}