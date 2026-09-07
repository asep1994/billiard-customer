import 'package:flutter/material.dart';

class FacilityInfo {
  const FacilityInfo(this.icon, this.label);

  final IconData icon;
  final String label;
}

const facilityInfo = <String, FacilityInfo>{
  'parking': FacilityInfo(Icons.local_parking, 'Parkir Gratis'),
  'ac': FacilityInfo(Icons.ac_unit, 'AC Ruangan'),
  'food_drink': FacilityInfo(Icons.restaurant, 'Makanan & Minuman'),
  'wifi': FacilityInfo(Icons.wifi, 'WiFi Gratis'),
};
