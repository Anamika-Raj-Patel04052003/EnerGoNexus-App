import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../services/api_service.dart';

class AddMoneyScreen extends StatefulWidget {
  const AddMoneyScreen({
    super.key,
  });

  @override
  State<AddMoneyScreen> createState() => _AddMoneyScreenState();
}

class _AddMoneyScreenState extends State<AddMoneyScreen> {
  final TextEditingController amountController =
      TextEditingController();

  bool loading = false;

  double get amount {
    return double.tryParse(
          amountController.text.trim(),
        ) ??
        0;
  }

  double get cashback {
    if (amount <= 0) {
      return 0;
    }

    return amount * 0.05;
  }

  double get totalCredit {
    return amount + cashback;
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  void onAmountChanged(String value) {
    setState(() {});
  }

  Future<void> startDummyRazorpay() async {
    if (amount < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please enter a valid amount",
          ),
        ),
      );

      return;
    }

    setState(() {
      loading = true;
    });

    await Future.delayed(
      const Duration(milliseconds: 700),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      loading = false;
    });

    final paymentSuccessful =
        await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: AppColors.card,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(
                      alpha: .12,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet,
                    color: AppColors.primaryGreen,
                    size: 30,
                  ),
                ),

                const SizedBox(height: 15),

                const Text(
                  "Razorpay Checkout",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  "Dummy payment gateway",
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 22),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "Amount to Pay",
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        "₹${amount.toStringAsFixed(2)}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(
                        context,
                        true,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          AppColors.primaryGreen,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text(
                      "SIMULATE PAYMENT SUCCESS",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(
                        context,
                        false,
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(
                        color: Colors.white24,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text(
                      "CANCEL",
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted) {
      return;
    }

    if (paymentSuccessful == true) {
      await rechargeWallet();
    }
  }

  Future<void> rechargeWallet() async {
    setState(() {
      loading = true;
    });

    try {
      final response =
          await ApiService.addMoneyToWallet(
        amount: amount,
      );

      if (!mounted) {
        return;
      }

      if (response["status"] == true) {
        final rechargeAmount =
            double.tryParse(
                  response["recharge_amount"]?.toString() ?? "",
                ) ??
                amount;

        final cashbackAmount =
            double.tryParse(
                  response["cashback"]?.toString() ?? "",
                ) ??
                (rechargeAmount * 0.05);

        final creditedAmount =
            double.tryParse(
                  response["credited_amount"]?.toString() ?? "",
                ) ??
                (rechargeAmount + cashbackAmount);

        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              backgroundColor: AppColors.card,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: const Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Payment Successful",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                      ),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  receiptRow(
                    "Recharge",
                    "₹${rechargeAmount.toStringAsFixed(2)}",
                  ),

                  receiptRow(
                    "5% Cashback",
                    "+ ₹${cashbackAmount.toStringAsFixed(2)}",
                  ),

                  const Divider(
                    color: Colors.white12,
                  ),

                  receiptRow(
                    "Wallet Credit",
                    "₹${creditedAmount.toStringAsFixed(2)}",
                    highlight: true,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "DONE",
                  ),
                ),
              ],
            );
          },
        );

        if (!mounted) {
          return;
        }

        Navigator.pop(
          context,
          true,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response["message"] ??
                  "Wallet recharge failed",
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Recharge failed: $e",
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

  Widget receiptRow(
    String title,
    String value, {
    bool highlight = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 12,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: highlight
                    ? Colors.white
                    : Colors.white54,
                fontSize: 13,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: highlight
                  ? AppColors.primaryGreen
                  : Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget quickAmount(double value) {
    return Expanded(
      child: GestureDetector(
        onTap: loading
            ? null
            : () {
                amountController.text =
                    value.toStringAsFixed(0);

                setState(() {});
              },
        child: Container(
          margin: const EdgeInsets.only(
            right: 8,
          ),
          padding: const EdgeInsets.symmetric(
            vertical: 13,
          ),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: Colors.white10,
            ),
          ),
          child: Text(
            "₹${value.toStringAsFixed(0)}",
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget summaryRow(
    String title,
    String value, {
    bool green = false,
    bool large = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 10,
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 13,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: green
                  ? AppColors.primaryGreen
                  : Colors.white,
              fontSize: large ? 18 : 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Add Money",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius:
                    BorderRadius.circular(25),
                border: Border.all(
                  color: AppColors.primaryGreen
                      .withValues(
                    alpha: .18,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Recharge your wallet",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 7),

                  const Text(
                    "Add money securely and get 5% cashback.",
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),

                  const SizedBox(height: 25),

                  TextField(
                    controller: amountController,
                    keyboardType:
                        const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: onAmountChanged,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      prefixText: "₹ ",
                      prefixStyle:
                          const TextStyle(
                        color:
                            AppColors.primaryGreen,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      hintText: "Enter amount",
                      hintStyle:
                          const TextStyle(
                        color: Colors.white30,
                        fontSize: 18,
                      ),
                      filled: true,
                      fillColor: Colors.black26,
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(18),
                        borderSide:
                            const BorderSide(
                          color:
                              AppColors.primaryGreen,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  Row(
                    children: [
                      quickAmount(100),
                      quickAmount(500),
                      quickAmount(1000),
                      quickAmount(2000),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.darkGreen.withValues(
                  alpha: .30,
                ),
                borderRadius:
                    BorderRadius.circular(20),
                border: Border.all(
                  color:
                      AppColors.primaryGreen.withValues(
                    alpha: .18,
                  ),
                ),
              ),
              child: Column(
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.local_offer,
                        color:
                            AppColors.primaryGreen,
                        size: 20,
                      ),
                      SizedBox(width: 9),
                      Text(
                        "5% Cashback",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  summaryRow(
                    "Amount",
                    "₹${amount.toStringAsFixed(2)}",
                  ),

                  summaryRow(
                    "Cashback",
                    "+ ₹${cashback.toStringAsFixed(2)}",
                    green: true,
                  ),

                  const Divider(
                    color: Colors.white12,
                  ),

                  summaryRow(
                    "Total Wallet Credit",
                    "₹${totalCredit.toStringAsFixed(2)}",
                    green: true,
                    large: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed:
                    loading
                        ? null
                        : startDummyRazorpay,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      AppColors.primaryGreen,
                  foregroundColor: Colors.black,
                  disabledBackgroundColor:
                      Colors.white10,
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(20),
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
                    : const Text(
                        "CONTINUE TO PAYMENT",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 15),

            const Row(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock_outline,
                  color: Colors.white38,
                  size: 15,
                ),
                SizedBox(width: 6),
                Text(
                  "Secure payment powered by Razorpay",
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}