import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/constants/app_colors.dart';
import '../../services/api_service.dart';
import 'charging_station_detail_screen.dart';

class ChargingStationScreen extends StatefulWidget {
  const ChargingStationScreen({super.key});

  @override
  State<ChargingStationScreen> createState() =>
      _ChargingStationScreenState();
}

class _ChargingStationScreenState
    extends State<ChargingStationScreen> {
  bool loading = true;
  String searchQuery = '';

  List<Map<String, dynamic>> stations = [];

  @override
  void initState() {
    super.initState();
    loadStations();
  }

  Future<void> loadStations() async {
    setState(() {
      loading = true;
    });

    try {
      final response =
          await ApiService.getChargingStations();

      if (!mounted) return;

      if (response['status'] == true) {
        final data =
            response['stations'] ??
            response['data'] ??
            [];

        if (data is List) {
          stations = data
              .whereType<Map>()
              .map(
                (item) =>
                    Map<String, dynamic>.from(item),
              )
              .toList();
        }
      } else {
        showMessage(
          response['message'] ??
              'Unable to load charging stations',
        );
      }
    } catch (e) {
      if (!mounted) return;

      showMessage(
        'Unable to load charging stations',
      );
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> get filteredStations {
    if (searchQuery.trim().isEmpty) {
      return stations;
    }

    final query =
        searchQuery.trim().toLowerCase();

    return stations.where((station) {
      final name =
          station['station_name']
                  ?.toString()
                  .toLowerCase() ??
              '';

      final city =
          station['city']
                  ?.toString()
                  .toLowerCase() ??
              '';

      final address =
          station['address']
                  ?.toString()
                  .toLowerCase() ??
              '';

      final chargerType =
          station['charger_type']
                  ?.toString()
                  .toLowerCase() ??
              '';

      return name.contains(query) ||
          city.contains(query) ||
          address.contains(query) ||
          chargerType.contains(query);
    }).toList();
  }

  String textValue(
    Map<String, dynamic> station,
    String key,
    String fallback,
  ) {
    final value = station[key];

    if (value == null ||
        value.toString().trim().isEmpty) {
      return fallback;
    }

    return value.toString();
  }

  double numberValue(
    Map<String, dynamic> station,
    String key,
  ) {
    return double.tryParse(
          station[key]?.toString() ?? '',
        ) ??
        0;
  }

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  Future<void> openStation(
    Map<String, dynamic> station,
  ) async {
    final id = station['id'];

    if (id == null) {
      showMessage(
        'Station ID not available',
      );
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ChargingStationDetailScreen(
          stationId: id,
        ),
      ),
    );

    await loadStations();
  }

  @override
  Widget build(BuildContext context) {
    final visibleStations =
        filteredStations;

    return Scaffold(
      backgroundColor:
          AppColors.background,

      appBar: AppBar(
        backgroundColor:
            Colors.transparent,
        elevation: 0,

        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            LucideIcons.arrowLeft,
          ),
        ),

        title: const Text(
          'Charging Stations',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed:
                loading
                    ? null
                    : loadStations,
            icon: const Icon(
              LucideIcons.refreshCw,
            ),
          ),
        ],
      ),

      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(
                20,
                8,
                20,
                12,
              ),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },

                style: const TextStyle(
                  color: Colors.white,
                ),

                decoration:
                    InputDecoration(
                  hintText:
                      'Search station, city or charger...',
                  hintStyle:
                      const TextStyle(
                    color: Colors.white38,
                  ),

                  prefixIcon:
                      const Icon(
                    LucideIcons.search,
                    color: Colors.white54,
                  ),

                  suffixIcon:
                      searchQuery.isEmpty
                          ? null
                          : IconButton(
                              onPressed: () {
                                setState(() {
                                  searchQuery = '';
                                });
                              },
                              icon:
                                  const Icon(
                                LucideIcons.x,
                              ),
                            ),

                  filled: true,

                  fillColor:
                      AppColors.card,

                  border:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(
                      18,
                    ),
                    borderSide:
                        BorderSide.none,
                  ),
                ),
              ),
            ),

            Padding(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration:
                        BoxDecoration(
                      color: AppColors
                          .primaryGreen
                          .withValues(
                        alpha: .10,
                      ),
                      borderRadius:
                          BorderRadius.circular(
                        12,
                      ),
                    ),
                    child: Row(
                      mainAxisSize:
                          MainAxisSize.min,
                      children: [
                        const Icon(
                          LucideIcons
                              .mapPin,
                          size: 16,
                          color: AppColors
                              .primaryGreen,
                        ),
                        const SizedBox(
                          width: 6,
                        ),
                        Text(
                          '${visibleStations.length} stations',
                          style:
                              const TextStyle(
                            color: AppColors
                                .primaryGreen,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  const Text(
                    'Nearby',
                    style:
                        TextStyle(
                      color:
                          Colors.white54,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            Expanded(
              child: loading
                  ? const Center(
                      child:
                          CircularProgressIndicator(),
                    )
                  : RefreshIndicator(
                      onRefresh:
                          loadStations,
                      color:
                          AppColors
                              .primaryGreen,
                      child:
                          visibleStations
                                  .isEmpty
                              ? ListView(
                                  children: const [
                                    SizedBox(
                                      height:
                                          180,
                                    ),
                                    Center(
                                      child:
                                          Column(
                                        children: [
                                          Icon(
                                            LucideIcons
                                                .batteryCharging,
                                            size:
                                                55,
                                            color:
                                                Colors.white24,
                                          ),
                                          SizedBox(
                                            height:
                                                15,
                                          ),
                                          Text(
                                            'No charging stations found',
                                            style:
                                                TextStyle(
                                              color:
                                                  Colors.white54,
                                              fontSize:
                                                  16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              : ListView.builder(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  padding:
                                      const EdgeInsets.fromLTRB(
                                    20,
                                    5,
                                    20,
                                    30,
                                  ),
                                  itemCount:
                                      visibleStations.length,
                                  itemBuilder:
                                      (
                                    context,
                                    index,
                                  ) {
                                    final station =
                                        visibleStations[
                                            index];

                                    return stationCard(
                                      station,
                                    );
                                  },
                                ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget stationCard(
    Map<String, dynamic> station,
  ) {
    final name = textValue(
      station,
      'station_name',
      'Charging Station',
    );

    final city = textValue(
      station,
      'city',
      'Unknown City',
    );

    final address = textValue(
      station,
      'address',
      'Address unavailable',
    );

    final chargerType =
        textValue(
      station,
      'charger_type',
      'EV Charger',
    );

    final status = textValue(
      station,
      'status',
      'Active',
    );

    final totalPorts =
        numberValue(
          station,
          'total_ports',
        ).toInt();

    final availablePorts =
        numberValue(
          station,
          'available_ports',
        ).toInt();

    final price = numberValue(
      station,
      'price_per_unit',
    );

    final isAvailable =
        availablePorts > 0 &&
            status.toLowerCase() !=
                'inactive';

    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 14,
      ),

      decoration:
          BoxDecoration(
        color: AppColors.card,
        borderRadius:
            BorderRadius.circular(
          22,
        ),
        border: Border.all(
          color: AppColors
              .primaryGreen
              .withValues(
            alpha: .08,
          ),
        ),
      ),

      child: Material(
        color:
            Colors.transparent,

        child: InkWell(
          borderRadius:
              BorderRadius.circular(
            22,
          ),

          onTap: () {
            openStation(station);
          },

          child: Padding(
            padding:
                const EdgeInsets.all(
              16,
            ),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Row(
                  children: [
                    Container(
                      height: 58,
                      width: 58,

                      decoration:
                          BoxDecoration(
                        color: AppColors
                            .primaryGreen
                            .withValues(
                          alpha: .10,
                        ),
                        borderRadius:
                            BorderRadius.circular(
                          17,
                        ),
                      ),

                      child: const Icon(
                        LucideIcons
                            .batteryCharging,
                        color: AppColors
                            .primaryGreen,
                        size: 31,
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
                            name,
                            maxLines: 1,
                            overflow:
                                TextOverflow
                                    .ellipsis,

                            style:
                                const TextStyle(
                              fontSize: 17,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          const SizedBox(
                            height: 5,
                          ),

                          Text(
                            city,
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

                    Container(
                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 9,
                        vertical: 6,
                      ),

                      decoration:
                          BoxDecoration(
                        color: isAvailable
                            ? Colors.green
                                .withValues(
                                alpha: .10,
                              )
                            : Colors.red
                                .withValues(
                                alpha: .10,
                              ),

                        borderRadius:
                            BorderRadius.circular(
                          10,
                        ),
                      ),

                      child: Text(
                        isAvailable
                            ? 'Available'
                            : 'Busy',
                        style:
                            TextStyle(
                          color: isAvailable
                              ? Colors.greenAccent
                              : Colors.redAccent,
                          fontSize: 11,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: 14,
                ),

                Text(
                  address,
                  maxLines: 2,
                  overflow:
                      TextOverflow.ellipsis,
                  style:
                      const TextStyle(
                    color:
                        Colors.white60,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),

                const SizedBox(
                  height: 14,
                ),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    infoChip(
                      LucideIcons
                          .plugZap,
                      chargerType,
                    ),

                    infoChip(
                      LucideIcons
                          .batteryCharging,
                      '$availablePorts/$totalPorts ports',
                    ),

                    infoChip(
                      LucideIcons
                          .indianRupee,
                      '₹${price.toStringAsFixed(2)}/unit',
                    ),
                  ],
                ),

                const SizedBox(
                  height: 15,
                ),

                Row(
                  children: [
                    Expanded(
                      child: Text(
                        isAvailable
                            ? 'Ready for charging'
                            : 'Currently unavailable',
                        style:
                            TextStyle(
                          color:
                              isAvailable
                                  ? AppColors
                                      .primaryGreen
                                  : Colors.white38,
                          fontSize:
                              12,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ),

                    const Icon(
                      LucideIcons
                          .arrowRight,
                      size: 18,
                      color: Colors.white54,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget infoChip(
    IconData icon,
    String text,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),

      decoration:
          BoxDecoration(
        color: Colors.black26,
        borderRadius:
            BorderRadius.circular(
          10,
        ),
      ),

      child: Row(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color:
                AppColors.primaryGreen,
          ),

          const SizedBox(
            width: 5,
          ),

          Text(
            text,
            style:
                const TextStyle(
              color:
                  Colors.white70,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}