class GoogleMapsConfig {
  // 🗺️ YOUR 5 GOOGLE MAPS LIVE API KEYS
  static const String mapsJsKey = "AIzaSyDp3mkbKShGs1ZHGrQ8By3sDquvoTaymzs";
  static const String distanceMatrixKey = "AIzaSyBLzwkJ9lP3D3ATPlh0DZcUGBYHfdfFJnw";
  static const String geocodingKey = "AIzaSyAcKoTO9wNATYfLsiEQoBfnqD1XPitSH_4";
  static const String directionsKey = "AIzaSyBTXyneFGHad09sTmkvFBekC2B1CpfjiB0";
  static const String roadsKey = "AIzaSyCUvnIZXg8jgLhy65SA3Gev37tyXjycHsI";

  // DEFAULT EV SUPERHUB COORDINATES (BHOPAL MATRIX)
  static const double defaultLat = 23.259933;
  static const double defaultLng = 77.412615;

  // 4 CENTRAL EV SUPERHUBS
  static const Map<String, dynamic> hubs = {
    'MP_NAGAR': {
      'name': 'EnerGo Central SuperHub',
      'lat': 23.2332,
      'lng': 77.4343,
      'address': 'Zone 1, MP Nagar, Bhopal',
    },
    'ISBT': {
      'name': 'Bhopal Express Hub (ISBT)',
      'lat': 23.2415,
      'lng': 77.4475,
      'address': 'ISBT Commercial Terminal, Bhopal',
    },
    'AIRPORT': {
      'name': 'Airport Rapid Solar Hub',
      'lat': 23.2875,
      'lng': 77.3378,
      'address': 'Raja Bhoj Airport Terminal, VIP Road',
    },
    'ARERA': {
      'name': 'Arera Green Solar Station',
      'lat': 23.2156,
      'lng': 77.4298,
      'address': 'Arera Colony, E-3 Commercial Area',
    },
  };
}