import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../services/api_service.dart';

class WalletTransactionHistoryScreen extends StatefulWidget {
  const WalletTransactionHistoryScreen({
    super.key,
  });

  @override
  State<WalletTransactionHistoryScreen> createState() =>
      _WalletTransactionHistoryScreenState();
}

class _WalletTransactionHistoryScreenState
    extends State<WalletTransactionHistoryScreen> {
  bool loading = true;

  double currentBalance = 0;
  double totalRecharge = 0;
  double totalSpent = 0;
  double cashbackEarned = 0;

  List<Map<String, dynamic>> transactions = [];

  @override
  void initState() {
    super.initState();

    loadHistory();
  }

  // ============================================================
  // LOAD HISTORY
  // ============================================================

  Future<void> loadHistory() async {
    if (!mounted) return;

    setState(() {
      loading = true;
    });

    try {
      final response =
          await ApiService.getWalletHistory();

      if (!mounted) return;

      if (response["status"] == true) {
        final summary =
            response["wallet_summary"];

        if (summary is Map) {
          currentBalance =
              double.tryParse(
                    summary["current_balance"]
                            ?.toString() ??
                        "",
                  ) ??
                  0;

          totalRecharge =
              double.tryParse(
                    summary["total_recharge"]
                            ?.toString() ??
                        "",
                  ) ??
                  0;

          totalSpent =
              double.tryParse(
                    summary["total_spent"]
                            ?.toString() ??
                        "",
                  ) ??
                  0;

          cashbackEarned =
              double.tryParse(
                    summary["cashback_earned"]
                            ?.toString() ??
                        "",
                  ) ??
                  0;
        }

        final history =
            response["recent_transactions"];

        if (history is List) {
          transactions = history
              .whereType<Map>()
              .map(
                (item) =>
                    Map<String, dynamic>.from(
                  item,
                ),
              )
              .toList();
        } else {
          transactions = [];
        }
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: Text(
              response["message"] ??
                  "Unable to load transaction history",
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            "Unable to load history: $e",
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

  // ============================================================
  // MONEY FORMAT
  // ============================================================

  String money(dynamic value) {
    return (double.tryParse(
              value?.toString() ?? "",
            ) ??
            0)
        .toStringAsFixed(2);
  }

  // ============================================================
  // TRANSACTION TYPE
  // ============================================================

  bool isCredit(
    Map<String, dynamic> transaction,
  ) {
    return transaction["type"]
            ?.toString()
            .toLowerCase() ==
        "credit";
  }

  // ============================================================
  // TRANSACTION COLOR
  // ============================================================

  Color transactionColor(
    Map<String, dynamic> transaction,
  ) {
    if (isCredit(transaction)) {
      return Colors.greenAccent;
    }

    return Colors.redAccent;
  }

  // ============================================================
  // TRANSACTION ICON
  // ============================================================

  IconData transactionIcon(
    Map<String, dynamic> transaction,
  ) {
    final description =
        transaction["description"]
                ?.toString()
                .toLowerCase() ??
            "";

    if (description.contains("cashback")) {
      return Icons.local_offer;
    }

    if (description.contains("recharge")) {
      return Icons.add_circle_outline;
    }

    if (description.contains("ride")) {
      return Icons.directions_car;
    }

    if (description.contains("charging")) {
      return Icons.ev_station;
    }

    if (isCredit(transaction)) {
      return Icons.arrow_downward;
    }

    return Icons.arrow_upward;
  }

  // ============================================================
  // TRANSACTION DESCRIPTION
  // ============================================================

  String description(
    Map<String, dynamic> transaction,
  ) {
    return transaction["description"]
            ?.toString() ??
        "Transaction";
  }

  // ============================================================
  // TRANSACTION DATE
  // ============================================================

  String transactionDate(
    Map<String, dynamic> transaction,
  ) {
    return transaction["date"]
            ?.toString() ??
        "";
  }

  // ============================================================
  // TRANSACTION AMOUNT
  // ============================================================

  String transactionAmount(
    Map<String, dynamic> transaction,
  ) {
    final amount =
        money(transaction["amount"]);

    if (isCredit(transaction)) {
      return "+ ₹$amount";
    }

    return "- ₹$amount";
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          AppColors.background,

      appBar: AppBar(
        backgroundColor:
            Colors.transparent,
        elevation: 0,

        title: const Text(
          "Transaction History",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: loading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: loadHistory,

              child:
                  SingleChildScrollView(
                physics:
                    const AlwaysScrollableScrollPhysics(),

                padding:
                    const EdgeInsets.all(20),

                child: Column(
                  children: [
                    // ==================================================
                    // BALANCE CARD
                    // ==================================================

                    Container(
                      width:
                          double.infinity,

                      padding:
                          const EdgeInsets.all(22),

                      decoration:
                          BoxDecoration(
                        color:
                            AppColors.card,

                        borderRadius:
                            BorderRadius.circular(
                          25,
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

                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [
                          const Text(
                            "Current Wallet Balance",
                            style: TextStyle(
                              color:
                                  Colors.white60,
                              fontSize: 14,
                            ),
                          ),

                          const SizedBox(
                            height: 8,
                          ),

                          Text(
                            "₹${money(currentBalance)}",
                            style:
                                const TextStyle(
                              color:
                                  Colors.white,
                              fontSize: 32,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    // ==================================================
                    // SUMMARY
                    // ==================================================

                    Row(
                      children: [
                        Expanded(
                          child:
                              summaryCard(
                            title:
                                "Recharge",
                            value:
                                "₹${money(totalRecharge)}",
                            icon:
                                Icons.add_circle,
                          ),
                        ),

                        const SizedBox(
                          width: 10,
                        ),

                        Expanded(
                          child:
                              summaryCard(
                            title:
                                "Spent",
                            value:
                                "₹${money(totalSpent)}",
                            icon:
                                Icons.remove_circle,
                          ),
                        ),

                        const SizedBox(
                          width: 10,
                        ),

                        Expanded(
                          child:
                              summaryCard(
                            title:
                                "Cashback",
                            value:
                                "₹${money(cashbackEarned)}",
                            icon:
                                Icons.local_offer,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 30,
                    ),

                    Align(
                      alignment:
                          Alignment.centerLeft,

                      child: Text(
                        "All Transactions",
                        style:
                            const TextStyle(
                          fontSize: 20,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 15,
                    ),

                    if (transactions.isEmpty)
                      emptyHistory()
                    else
                      ...transactions.map(
                        (transaction) =>
                            transactionCard(
                          transaction,
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  // ============================================================
  // SUMMARY CARD
  // ============================================================

  Widget summaryCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        vertical: 16,
        horizontal: 6,
      ),

      decoration:
          BoxDecoration(
        color: AppColors.card,

        borderRadius:
            BorderRadius.circular(18),
      ),

      child: Column(
        children: [
          Icon(
            icon,
            color:
                AppColors.primaryGreen,
            size: 21,
          ),

          const SizedBox(
            height: 8,
          ),

          Text(
            value,
            textAlign:
                TextAlign.center,
            style:
                const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: 4,
          ),

          Text(
            title,
            textAlign:
                TextAlign.center,
            style:
                const TextStyle(
              color: Colors.white54,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TRANSACTION CARD
  // ============================================================

  Widget transactionCard(
    Map<String, dynamic> transaction,
  ) {
    final color =
        transactionColor(
      transaction,
    );

    final icon =
        transactionIcon(
      transaction,
    );

    return Container(
      width:
          double.infinity,

      margin:
          const EdgeInsets.only(
        bottom: 14,
      ),

      padding:
          const EdgeInsets.all(18),

      decoration:
          BoxDecoration(
        color: AppColors.card,

        borderRadius:
            BorderRadius.circular(20),
      ),

      child: Row(
        children: [
          Container(
            height: 46,
            width: 46,

            decoration:
                BoxDecoration(
              color: color.withValues(
                alpha: .10,
              ),

              borderRadius:
                  BorderRadius.circular(
                14,
              ),
            ),

            child: Icon(
              icon,
              color: color,
              size: 23,
            ),
          ),

          const SizedBox(
            width: 13,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  description(
                    transaction,
                  ),

                  maxLines: 1,

                  overflow:
                      TextOverflow.ellipsis,

                  style:
                      const TextStyle(
                    color:
                        Colors.white,
                    fontWeight:
                        FontWeight.bold,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(
                  height: 5,
                ),

                Text(
                  transactionDate(
                    transaction,
                  ),

                  style:
                      const TextStyle(
                    color:
                        Colors.white54,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            width: 10,
          ),

          Text(
            transactionAmount(
              transaction,
            ),

            style:
                TextStyle(
              color: color,
              fontSize: 15,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EMPTY HISTORY
  // ============================================================

  Widget emptyHistory() {
    return Container(
      width:
          double.infinity,

      padding:
          const EdgeInsets.symmetric(
        vertical: 45,
        horizontal: 20,
      ),

      decoration:
          BoxDecoration(
        color:
            AppColors.card,

        borderRadius:
            BorderRadius.circular(20),
      ),

      child: const Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            color: Colors.white30,
            size: 45,
          ),

          SizedBox(
            height: 12,
          ),

          Text(
            "No transactions yet",
            style: TextStyle(
              color:
                  Colors.white70,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          SizedBox(
            height: 5,
          ),

          Text(
            "Your wallet transactions will appear here.",
            textAlign:
                TextAlign.center,
            style: TextStyle(
              color:
                  Colors.white38,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}