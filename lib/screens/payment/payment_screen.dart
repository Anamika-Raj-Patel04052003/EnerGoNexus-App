import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../services/api_service.dart';

import 'payment_success_screen.dart';

class PaymentScreen extends StatefulWidget {
  final dynamic rideId;
  final double amount;

  const PaymentScreen({
    super.key,
    required this.rideId,
    required this.amount,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String selectedMethod = "Wallet";
  bool loading = false;

  Future<void> makePayment() async {
    if (loading) return;

    setState(() {
      loading = true;
    });

    try {
      Map<String, dynamic> response;

      // ======================================================
      // WALLET PAYMENT
      // ======================================================

      if (selectedMethod == "Wallet") {
        response = await ApiService.walletPayRide(
          rideId: widget.rideId,
        );
      }

      // ======================================================
      // CASH PAYMENT
      // ======================================================

      else if (selectedMethod == "Cash") {
        response = await ApiService.payRide(
          rideId: widget.rideId,
          paymentMethod: "Cash",
        );
      }

      // ======================================================
      // ONLINE PAYMENT
      // ======================================================

      else {
        // ----------------------------------------------------
        // DUMMY RAZORPAY FLOW
        // ----------------------------------------------------

        final razorpaySuccess =
            await showDummyRazorpay();

        if (!razorpaySuccess) {
          return;
        }

        // Dummy Razorpay success ke baad
        // backend ko UPI payment mark karenge.

        response = await ApiService.payRide(
          rideId: widget.rideId,
          paymentMethod: "UPI",
        );
      }

      // ======================================================
      // PAYMENT RESULT
      // ======================================================

      if (!mounted) return;

      if (response["status"] == true) {
        final payment = response["payment"];

        dynamic paymentId;

        if (payment is Map) {
          paymentId = payment["id"];
        }

        // Fallback agar backend direct payment_id bheje.
        paymentId ??= response["payment_id"];

        if (paymentId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Payment successful, but payment ID was not received.",
              ),
            ),
          );

          return;
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentSuccessScreen(
              rideId: widget.rideId,
              paymentId: paymentId,
              amount: widget.amount,
              paymentMethod: selectedMethod,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response["message"] ?? "Payment failed",
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint(
        "PAYMENT ERROR: $e",
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Unable to process payment",
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  // ==========================================================
  // DUMMY RAZORPAY
  // ==========================================================

  Future<bool> showDummyRazorpay() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            "Razorpay",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.payment,
                size: 55,
                color: AppColors.primaryGreen,
              ),
              const SizedBox(height: 15),
              const Text(
                "Dummy Razorpay Checkout",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                "Pay ₹${widget.amount}",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGreen,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text(
                "CANCEL",
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    AppColors.primaryGreen,
                foregroundColor: Colors.black,
              ),
              child: const Text(
                "SIMULATE SUCCESS",
              ),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Payment",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            // ==================================================
            // AMOUNT
            // ==================================================

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),

              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius:
                    BorderRadius.circular(25),
                border: Border.all(
                  color: AppColors.primaryGreen.withValues(
  alpha: .20,
),
                ),
              ),

              child: Column(
                children: [
                  const Text(
                    "Total Ride Fare",
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "₹${widget.amount}",
                    style: const TextStyle(
                      color: AppColors.primaryGreen,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              "Select Payment Method",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            // ==================================================
            // WALLET
            // ==================================================

RadioGroup<String>(
  groupValue: selectedMethod,

  onChanged: (value) {
    if (loading) {
      return;
    }

    setState(() {
      selectedMethod = value ?? selectedMethod;
    });
  },

  child: Column(
    children: [
      paymentOption(
        title: "Wallet",
        subtitle:
            "Pay directly from your EnerGo wallet",
        icon: Icons.account_balance_wallet,
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
            "Pay cash to the driver",
        icon: Icons.money,
        value: "Cash",
      ),
    ],
  ),
),
            const Spacer(),

            // ==================================================
            // PAY BUTTON
            // ==================================================

            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton(
                onPressed:
                    loading ? null : makePayment,

                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      AppColors.primaryGreen,
                  foregroundColor:
                      Colors.black,

                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(20),
                  ),
                ),

                child: loading
                    ? const CircularProgressIndicator(
                        color: Colors.black,
                      )
                    : Text(
                        selectedMethod == "Online"
                            ? "PAY WITH RAZORPAY"
                            : "PAY NOW",
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
      ),
    );
  }

  Widget paymentOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required String value,
  }) {
    final isSelected =
        selectedMethod == value;

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
          color: isSelected
             ? AppColors.primaryGreen.withValues(
    alpha: .15,
  )
: AppColors.card,

          borderRadius:
              BorderRadius.circular(20),

          border: Border.all(
            color: isSelected
                ? AppColors.primaryGreen
                : Colors.transparent,
          ),
        ),

        child: Row(
          children: [
            Icon(
              icon,
              color:
                  AppColors.primaryGreen,
              size: 32,
            ),

            const SizedBox(width: 15),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  Text(
                    title,
                    style:
                        const TextStyle(
                      fontSize: 17,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    subtitle,
                    style:
                        const TextStyle(
                      color: Colors.white60,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

        Radio<String>(
  value: value,
),
          ],
        ),
      ),
    );
  }
}