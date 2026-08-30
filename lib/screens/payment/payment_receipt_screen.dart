import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../services/api_service.dart';

class PaymentReceiptScreen extends StatefulWidget {
  final dynamic rideId;
  final dynamic paymentId;
  final double amount;
  final String paymentMethod;

  const PaymentReceiptScreen({
    super.key,
    required this.rideId,
    required this.paymentId,
    required this.amount,
    required this.paymentMethod,
  });

  @override
  State<PaymentReceiptScreen> createState() =>
      _PaymentReceiptScreenState();
}

class _PaymentReceiptScreenState
    extends State<PaymentReceiptScreen> {
  bool loading = true;
  bool downloading = false;

  String receiptNumber = "Loading...";
  String transactionId = "Loading...";
  String receiptStatus = "Loading...";
  String receiptAmount = "0.00";
  String receiptMethod = "-";
  String paidAt = "-";

  String customerName = "-";
  String customerMobile = "-";

  String serviceType = "-";
  String serviceName = "-";
  String serviceCategory = "-";

  String stationName = "-";
  String stationAddress = "-";

  String serviceDate = "-";
  String serviceTime = "-";

  Map<String, dynamic>? receiptData;

  @override
  void initState() {
    super.initState();

    loadReceipt();
  }

  // ============================================================
  // LOAD RECEIPT
  // ============================================================

  Future<void> loadReceipt() async {
    if (!mounted) return;

    setState(() {
      loading = true;
    });

    try {
      final response =
          await ApiService.getPaymentReceipt(
        widget.paymentId,
      );

      if (!mounted) return;

      if (response["status"] == true) {
        final receipt = response["receipt"];

        if (receipt is Map) {
          receiptData =
              Map<String, dynamic>.from(receipt);

          // ------------------------------------------------------
          // RECEIPT
          // ------------------------------------------------------

          receiptNumber =
              receipt["receipt_no"]
                      ?.toString() ??
                  "N/A";

          // ------------------------------------------------------
          // CUSTOMER
          // ------------------------------------------------------

          final customer =
              receipt["customer"];

          if (customer is Map) {
            customerName =
                customer["name"]
                        ?.toString() ??
                    "-";

            customerMobile =
                customer["mobile"]
                        ?.toString() ??
                    "-";
          }

          // ------------------------------------------------------
          // SERVICE
          // ------------------------------------------------------

          serviceType =
              receipt["service_type"]
                      ?.toString() ??
                  "-";

          final service =
              receipt["service"];

          if (service is Map) {
            serviceName =
                service["name"]
                        ?.toString() ??
                    "-";

            serviceCategory =
                service["type"]
                        ?.toString() ??
                    "-";

            serviceDate =
                service["date"]
                        ?.toString() ??
                    "-";

            serviceTime =
                service["time"]
                        ?.toString() ??
                    "-";
          }

          // ------------------------------------------------------
          // STATION
          // ------------------------------------------------------

          final station =
              receipt["station"];

          if (station is Map) {
            stationName =
                station["name"]
                        ?.toString() ??
                    "-";

            stationAddress =
                station["address"]
                        ?.toString() ??
                    "-";
          }

          // ------------------------------------------------------
          // PAYMENT
          // ------------------------------------------------------

          final payment =
              receipt["payment"];

          if (payment is Map) {
            receiptAmount =
                payment["amount"]
                        ?.toString() ??
                    "0.00";

            receiptMethod =
                payment["method"]
                        ?.toString() ??
                    "-";

            transactionId =
                payment["transaction_id"]
                        ?.toString() ??
                    "N/A";

            receiptStatus =
                payment["status"]
                        ?.toString() ??
                    "Unknown";

            paidAt =
                payment["paid_at"]
                        ?.toString() ??
                    "-";
          }
        }
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: Text(
              response["message"] ??
                  "Unable to load receipt",
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
            "Unable to load receipt: $e",
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
  // DOWNLOAD RECEIPT
  // ============================================================

  Future<void> downloadReceipt() async {
    if (widget.paymentId == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content:
              Text("Payment ID is missing"),
        ),
      );

      return;
    }

    setState(() {
      downloading = true;
    });

    try {
      final response =
          await ApiService.downloadPaymentReceipt(
        widget.paymentId,
      );

      if (!mounted) return;

      if (response["status"] == true) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              "Receipt PDF received successfully",
            ),
          ),
        );

        // PDF bytes are returned by the API.
        // Actual file saving/opening can be
        // connected here later.
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: Text(
              response["message"] ??
                  "Unable to download receipt",
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
            "Receipt download failed: $e",
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          downloading = false;
        });
      }
    }
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
          "Payment Receipt",
          style: TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
        ),
      ),

      body: loading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: loadReceipt,

              child:
                  SingleChildScrollView(
                physics:
                    const AlwaysScrollableScrollPhysics(),

                padding:
                    const EdgeInsets.all(20),

                child: Column(
                  children: [
                    // ==================================================
                    // RECEIPT HEADER
                    // ==================================================

                    Container(
                      width:
                          double.infinity,

                      padding:
                          const EdgeInsets.all(25),

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
                        children: [
                          Container(
                            height: 64,
                            width: 64,

                            decoration:
                                BoxDecoration(
                              color: AppColors
                                  .primaryGreen
                                  .withValues(
                                alpha: .10,
                              ),
                              borderRadius:
                                  BorderRadius.circular(
                                18,
                              ),
                            ),

                            child: const Icon(
                              Icons.receipt_long,
                              color:
                                  AppColors.primaryGreen,
                              size: 34,
                            ),
                          ),

                          const SizedBox(
                            height: 15,
                          ),

                          const Text(
                            "EnerGo Payment Receipt",
                            textAlign:
                                TextAlign.center,
                            style:
                                TextStyle(
                              fontSize: 22,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          const SizedBox(
                            height: 8,
                          ),

                          Text(
                            receiptNumber,
                            style:
                                const TextStyle(
                              color:
                                  Colors.white54,
                              fontSize: 12,
                            ),
                          ),

                          const SizedBox(
                            height: 20,
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
                              color: Colors.black12,
                              borderRadius:
                                  BorderRadius.circular(
                                18,
                              ),
                            ),

                            child: Column(
                              children: [
                                const Text(
                                  "Amount Paid",
                                  style:
                                      TextStyle(
                                    color:
                                        Colors.white60,
                                    fontSize: 13,
                                  ),
                                ),

                                const SizedBox(
                                  height: 7,
                                ),

                                Text(
                                  "₹$receiptAmount",
                                  style:
                                      const TextStyle(
                                    color: AppColors
                                        .primaryGreen,
                                    fontSize: 30,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(
                                  height: 8,
                                ),

                                statusBadge(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    // ==================================================
                    // PAYMENT DETAILS
                    // ==================================================

                    sectionTitle(
                      "Payment Details",
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    detailsCard(
                      children: [
                        receiptRow(
                          "Transaction ID",
                          transactionId,
                        ),
                        receiptRow(
                          "Payment Method",
                          receiptMethod,
                        ),
                        receiptRow(
                          "Payment Status",
                          receiptStatus,
                          valueColor:
                              AppColors.primaryGreen,
                        ),
                        receiptRow(
                          "Paid At",
                          paidAt,
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 25,
                    ),

                    // ==================================================
                    // CUSTOMER
                    // ==================================================

                    sectionTitle(
                      "Customer Details",
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    detailsCard(
                      children: [
                        receiptRow(
                          "Name",
                          customerName,
                        ),
                        receiptRow(
                          "Mobile",
                          customerMobile,
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 25,
                    ),

                    // ==================================================
                    // SERVICE DETAILS
                    // ==================================================

                    sectionTitle(
                      "Service Details",
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    detailsCard(
                      children: [
                        receiptRow(
                          "Service Type",
                          serviceType,
                        ),
                        receiptRow(
                          "Service",
                          serviceName,
                        ),
                        receiptRow(
                          "Category",
                          serviceCategory,
                        ),
                        receiptRow(
                          "Date",
                          serviceDate,
                        ),
                        receiptRow(
                          "Time",
                          serviceTime,
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 25,
                    ),

                    // ==================================================
                    // STATION DETAILS
                    // ==================================================

                    if (stationName != "-") ...[
                      sectionTitle(
                        "Station Details",
                      ),

                      const SizedBox(
                        height: 12,
                      ),

                      detailsCard(
                        children: [
                          receiptRow(
                            "Station",
                            stationName,
                          ),
                          receiptRow(
                            "Address",
                            stationAddress,
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 25,
                      ),
                    ],

                    // ==================================================
                    // RIDE DETAILS
                    // ==================================================

                    sectionTitle(
                      "Reference",
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    detailsCard(
                      children: [
                        receiptRow(
                          "Ride ID",
                          widget.rideId
                              .toString(),
                        ),
                        receiptRow(
                          "Payment ID",
                          widget.paymentId
                              .toString(),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 30,
                    ),

                    // ==================================================
                    // REFRESH
                    // ==================================================

                    SizedBox(
                      width:
                          double.infinity,
                      height: 55,

                      child:
                          ElevatedButton.icon(
                        onPressed: loading
                            ? null
                            : loadReceipt,

                        icon:
                            const Icon(
                          Icons.refresh,
                        ),

                        label:
                            const Text(
                          "REFRESH RECEIPT",
                          style:
                              TextStyle(
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

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
                              20,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 15,
                    ),

                    // ==================================================
                    // DOWNLOAD
                    // ==================================================

                    SizedBox(
                      width:
                          double.infinity,
                      height: 55,

                      child:
                          OutlinedButton.icon(
                        onPressed:
                            downloading
                                ? null
                                : downloadReceipt,

                        icon:
                            downloading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child:
                                        CircularProgressIndicator(
                                      strokeWidth:
                                          2,
                                    ),
                                  )
                                : const Icon(
                                    Icons.download,
                                  ),

                        label: Text(
                          downloading
                              ? "DOWNLOADING..."
                              : "DOWNLOAD RECEIPT",
                          style:
                              const TextStyle(
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        style:
                            OutlinedButton
                                .styleFrom(
                          foregroundColor:
                              AppColors
                                  .primaryGreen,

                          side:
                              const BorderSide(
                            color:
                                AppColors.primaryGreen,
                          ),

                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(
                              20,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 25,
                    ),

                    const Text(
                      "Thank you for using EnerGoNexus",
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
              ),
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
  // DETAILS CARD
  // ============================================================

  Widget detailsCard({
    required List<Widget> children,
  }) {
    return Container(
      width:
          double.infinity,

      padding:
          const EdgeInsets.all(18),

      decoration:
          BoxDecoration(
        color:
            AppColors.card,

        borderRadius:
            BorderRadius.circular(20),
      ),

      child: Column(
        children: children,
      ),
    );
  }

  // ============================================================
  // RECEIPT ROW
  // ============================================================

  Widget receiptRow(
    String title,
    String value, {
    Color? valueColor,
  }) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 16,
      ),

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Expanded(
            child: Text(
              title,
              style:
                  const TextStyle(
                color:
                    Colors.white54,
                fontSize: 13,
              ),
            ),
          ),

          const SizedBox(
            width: 15,
          ),

          Expanded(
            child: Text(
              value,
              textAlign:
                  TextAlign.right,
              style:
                  TextStyle(
                color:
                    valueColor ??
                        Colors.white,
                fontSize: 14,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STATUS BADGE
  // ============================================================

  Widget statusBadge() {
    final status =
        receiptStatus.toLowerCase();

    final isSuccess =
        status == "success";

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 7,
      ),

      decoration:
          BoxDecoration(
        color: isSuccess
            ? Colors.green.withValues(
                alpha: .12,
              )
            : Colors.red.withValues(
                alpha: .12,
              ),

        borderRadius:
            BorderRadius.circular(30),
      ),

      child: Row(
        mainAxisSize:
            MainAxisSize.min,

        children: [
          Icon(
            isSuccess
                ? Icons.check_circle
                : Icons.error,
            size: 15,
            color: isSuccess
                ? Colors.greenAccent
                : Colors.redAccent,
          ),

          const SizedBox(
            width: 6,
          ),

          Text(
            receiptStatus,
            style:
                TextStyle(
              color: isSuccess
                  ? Colors.greenAccent
                  : Colors.redAccent,
              fontWeight:
                  FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}