import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../services/api_service.dart';
import 'add_money_screen.dart';
import 'wallet_transaction_history_screen.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({
    super.key,
  });

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  bool loading = true;

  double balance = 0;
  double totalRecharge = 0;
  double totalSpent = 0;
  double cashbackEarned = 0;

  List<Map<String, dynamic>> transactions = [];

  @override
  void initState() {
    super.initState();
    loadWallet();
  }

  // ============================================================
  // LOAD WALLET
  // ============================================================

  Future<void> loadWallet() async {
    if (!mounted) return;

    setState(() {
      loading = true;
    });

    try {
      final response = await ApiService.getWalletHistory();

      if (!mounted) return;

      if (response["status"] == true) {
        final summary = response["wallet_summary"];

        if (summary is Map) {
          balance =
              double.tryParse(
                summary["current_balance"]?.toString() ?? "",
              ) ??
              0;

          totalRecharge =
              double.tryParse(
                summary["total_recharge"]?.toString() ?? "",
              ) ??
              0;

          totalSpent =
              double.tryParse(
                summary["total_spent"]?.toString() ?? "",
              ) ??
              0;

          cashbackEarned =
              double.tryParse(
                summary["cashback_earned"]?.toString() ?? "",
              ) ??
              0;
        }

        final recent = response["recent_transactions"];

        if (recent is List) {
          transactions = recent
              .whereType<Map>()
              .map(
                (item) =>
                    Map<String, dynamic>.from(item),
              )
              .toList();
        } else {
          transactions = [];
        }
      } else {
        transactions = [];

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response["message"] ??
                  "Unable to load wallet",
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Unable to load wallet: $e",
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
  // OPEN ADD MONEY
  // ============================================================

  Future<void> openAddMoney() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const AddMoneyScreen(),
      ),
    );

    if (!mounted) return;

    if (result == true) {
      await loadWallet();
    }
  }

  // ============================================================
  // MONEY FORMAT
  // ============================================================

  String money(dynamic value) {
    final amount =
        double.tryParse(
          value?.toString() ?? "",
        ) ??
        0;

    return amount.toStringAsFixed(2);
  }

  // ============================================================
  // TRANSACTION AMOUNT
  // ============================================================

  String transactionAmount(
    Map<String, dynamic> transaction,
  ) {
    final type =
        transaction["type"]
            ?.toString()
            .toLowerCase() ??
        "";

    final amount = money(
      transaction["amount"],
    );

    if (type == "credit") {
      return "+ ₹$amount";
    }

    return "- ₹$amount";
  }

  // ============================================================
  // TRANSACTION COLOR
  // ============================================================

  Color transactionColor(
    Map<String, dynamic> transaction,
  ) {
    final type =
        transaction["type"]
            ?.toString()
            .toLowerCase() ??
        "";

    if (type == "credit") {
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

    final type =
        transaction["type"]
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

    if (type == "debit") {
      return Icons.arrow_upward;
    }

    return Icons.arrow_downward;
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
          "My Wallet",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: loadWallet,
              child: SingleChildScrollView(
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
                      width: double.infinity,
                      padding:
                          const EdgeInsets.all(25),

                      decoration:
                          BoxDecoration(
                        color: AppColors.card,
                        borderRadius:
                            BorderRadius.circular(25),
                        border: Border.all(
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
                            "Available Balance",
                            style: TextStyle(
                              color:
                                  Colors.white60,
                              fontSize: 16,
                            ),
                          ),

                          const SizedBox(
                            height: 10,
                          ),

                          Text(
                            "₹ ${money(balance)}",
                            style:
                                const TextStyle(
                              color: Colors.white,
                              fontSize: 35,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          const SizedBox(
                            height: 8,
                          ),

                          Text(
                            "Cashback earned: ₹${money(cashbackEarned)}",
                            style:
                                const TextStyle(
                              color:
                                  Colors.greenAccent,
                              fontSize: 12,
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),

                          const SizedBox(
                            height: 20,
                          ),

                          SizedBox(
                            width: double.infinity,
                            child:
                                ElevatedButton(
                              onPressed:
                                  openAddMoney,

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
                                    18,
                                  ),
                                ),
                              ),

                              child:
                                  const Text(
                                "ADD MONEY",
                                style:
                                    TextStyle(
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      height: 25,
                    ),

                    // ==================================================
                    // STATISTICS
                    // ==================================================

                    Row(
                      children: [
                        Expanded(
                          child:
                              walletStatCard(
                            title: "Recharge",
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
                              walletStatCard(
                            title: "Spent",
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
                              walletStatCard(
                            title: "Cashback",
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

                    // ==================================================
                    // PAYMENT METHODS
                    // ==================================================

                    sectionTitle(
                      "Payment Methods",
                    ),

                    const SizedBox(
                      height: 15,
                    ),

                    walletTile(
                      icon: Icons
                          .account_balance_wallet,
                      title:
                          "Wallet Balance",
                      subtitle:
                          "Use wallet for rides and charging",
                    ),

                    walletTile(
                      icon: Icons.payment,
                      title:
                          "Online Payment",
                      subtitle:
                          "UPI / Card / Net Banking",
                    ),

                    walletTile(
                      icon: Icons.money,
                      title:
                          "Cash Payment",
                      subtitle:
                          "Pay directly where cash is supported",
                    ),

                    const SizedBox(
                      height: 30,
                    ),

                    // ==================================================
                    // RECENT TRANSACTIONS
                    // ==================================================

                    Align(
                      alignment:
                          Alignment.centerLeft,
                      child: Text(
                        "Recent Transactions",
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
                      emptyTransactions()
                    else
                      ...transactions
                          .take(5)
                          .map(
                            (transaction) =>
                                transactionCard(
                              transaction,
                            ),
                          ),

                    const SizedBox(
                      height: 20,
                    ),

                    // ==================================================
                    // HISTORY
                    // ==================================================

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child:
                          ElevatedButton(
                     onPressed: () async {
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) =>
          const WalletTransactionHistoryScreen(),
    ),
  );

  if (!mounted) return;

  await loadWallet();
},

                        style:
                            ElevatedButton
                                .styleFrom(
                          backgroundColor:
                              Colors.white10,
                          foregroundColor:
                              Colors.white,
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(
                              20,
                            ),
                          ),
                        ),

                        child: const Text(
                          "VIEW TRANSACTION HISTORY",
                          style:
                              TextStyle(
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
    );
  }

  // ============================================================
  // STAT CARD
  // ============================================================

  Widget walletStatCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        vertical: 16,
        horizontal: 8,
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
            size: 22,
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
  // SECTION TITLE
  // ============================================================

  Widget sectionTitle(
    String title,
  ) {
    return Align(
      alignment:
          Alignment.centerLeft,
      child: Text(
        title,
        style:
            const TextStyle(
          fontSize: 20,
          fontWeight:
              FontWeight.bold,
        ),
      ),
    );
  }

  // ============================================================
  // PAYMENT METHOD TILE
  // ============================================================

  Widget walletTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 15,
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
            height: 52,
            width: 52,

            decoration:
                BoxDecoration(
              color:
                  AppColors.primaryGreen
                      .withValues(
                alpha: .12,
              ),
              borderRadius:
                  BorderRadius.circular(
                15,
              ),
            ),

            child: Icon(
              icon,
              color:
                  AppColors.primaryGreen,
              size: 28,
            ),
          ),

          const SizedBox(
            width: 15,
          ),

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

                const SizedBox(
                  height: 4,
                ),

                Text(
                  subtitle,
                  style:
                      const TextStyle(
                    color:
                        Colors.white60,
                    fontSize: 12,
                  ),
                ),
              ],
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
    final description =
        transaction["description"]
            ?.toString() ??
        "Transaction";

    final date =
        transaction["date"]
            ?.toString() ??
        "";

    final amount =
        transactionAmount(
      transaction,
    );

    final color =
        transactionColor(
      transaction,
    );

    final icon =
        transactionIcon(
      transaction,
    );

    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 15,
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
            height: 45,
            width: 45,

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
              size: 22,
            ),
          ),

          const SizedBox(
            width: 12,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  description,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style:
                      const TextStyle(
                    color:
                        Colors.white,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: 4,
                ),

                Text(
                  date,
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
            amount,
            style:
                TextStyle(
              color: color,
              fontSize: 16,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EMPTY TRANSACTIONS
  // ============================================================

  Widget emptyTransactions() {
    return Container(
      width: double.infinity,

      padding:
          const EdgeInsets.symmetric(
        vertical: 35,
        horizontal: 20,
      ),

      decoration:
          BoxDecoration(
        color: AppColors.card,
        borderRadius:
            BorderRadius.circular(20),
      ),

      child: const Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            color: Colors.white30,
            size: 42,
          ),

          SizedBox(
            height: 12,
          ),

          Text(
            "No transactions yet",
            style:
                TextStyle(
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
            "Your wallet activity will appear here.",
            textAlign:
                TextAlign.center,
            style:
                TextStyle(
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