import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/widgets/app_toast.dart';

class LocationDataModel {
  final double latitude;
  final double longitude;
  final String locationUrl;
  final String? addressLabel;

  LocationDataModel({
    required this.latitude,
    required this.longitude,
    required this.locationUrl,
    this.addressLabel,
  });
}

class LocationPickerWidget extends StatefulWidget {
  final bool isTamil;
  final Function(LocationDataModel?) onLocationSelected;
  final LocationDataModel? initialLocation;

  const LocationPickerWidget({
    super.key,
    required this.isTamil,
    required this.onLocationSelected,
    this.initialLocation,
  });

  @override
  State<LocationPickerWidget> createState() => _LocationPickerWidgetState();
}

class _LocationPickerWidgetState extends State<LocationPickerWidget> {
  LocationDataModel? _selectedLocation;
  bool _isOpeningMap = false;

  // Kallakurichi District Center (Tamil Nadu, India)
  static const LatLng _kallakurichiCenter = LatLng(11.7384, 78.9639);

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation;
  }

  /// Ensure GPS Location Service is enabled and permissions granted
  Future<bool> _checkAndRequestGpsService(BuildContext context) async {
    final isTamil = widget.isTamil;

    // 1. Check if Device Location Service (GPS hardware) is turned on
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!context.mounted) return false;
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFECEC),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.location_off_rounded, color: Color(0xFFD32F2F), size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  isTamil ? 'GPS சேவை முடக்கப்பட்டுள்ளது' : 'Location Service Disabled',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF2C0000)),
                ),
              ),
            ],
          ),
          content: Text(
            isTamil
                ? 'பிரச்சனை உள்ள சரியான இடத்தை தானாக பெற உங்கள் மொபைலில் GPS இருப்பிட சேவையை (Location) ஆன் செய்யவும்.'
                : 'Please enable Location Services (GPS) on your mobile device to attach the accurate grievance location.',
            style: const TextStyle(fontSize: 13, color: Color(0xFF555555), height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(isTamil ? 'ரத்து' : 'Cancel', style: const TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8C0000),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                Navigator.of(ctx).pop();
                await Geolocator.openLocationSettings();
              },
              child: Text(isTamil ? 'GPS அமைப்புகளை திறக்க' : 'Open Settings'),
            ),
          ],
        ),
      );
      return false;
    }

    // 2. Check and Request Location Permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (!context.mounted) return false;
        AppToast.showError(
          context,
          isTamil ? 'இருப்பிட அனுமதி (Location Permission) மறுக்கப்பட்டது!' : 'Location permission was denied!',
        );
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (!context.mounted) return false;
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFECEC),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.security_rounded, color: Color(0xFFD32F2F), size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  isTamil ? 'இருப்பிட அனுமதி தேவை' : 'Permission Required',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF2C0000)),
                ),
              ),
            ],
          ),
          content: Text(
            isTamil
                ? 'ஆப் அமைப்புகளில் சென்று இருப்பிட அனுமதியை (Location Permission) இயக்கவும்.'
                : 'Location permission is permanently denied. Please enable it from App Settings to attach GPS location.',
            style: const TextStyle(fontSize: 13, color: Color(0xFF555555), height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(isTamil ? 'ரத்து' : 'Cancel', style: const TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8C0000),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                Navigator.of(ctx).pop();
                await Geolocator.openAppSettings();
              },
              child: Text(isTamil ? 'ஆப் அமைப்புகளை திறக்க' : 'Open App Settings'),
            ),
          ],
        ),
      );
      return false;
    }

    return true;
  }

  /// Single Main Entry: Open Full-Screen Interactive Google Hybrid Map Pin Picker
  Future<void> _openMapPinPicker() async {
    final hasPermission = await _checkAndRequestGpsService(context);
    if (!hasPermission) return;

    setState(() => _isOpeningMap = true);

    LatLng initialCenter = _kallakurichiCenter;

    if (_selectedLocation != null) {
      initialCenter = LatLng(_selectedLocation!.latitude, _selectedLocation!.longitude);
    } else {
      // Try to acquire fast live GPS location to center the map at user's location
      try {
        final Position pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 4),
          ),
        );
        // Validate coordinates in Tamil Nadu
        if (pos.latitude >= 8.0 && pos.latitude <= 14.5 && pos.longitude >= 76.0 && pos.longitude <= 81.0) {
          initialCenter = LatLng(pos.latitude, pos.longitude);
        }
      } catch (_) {
        // Fallback to last known position if valid
        try {
          final Position? last = await Geolocator.getLastKnownPosition();
          if (last != null && last.latitude >= 8.0 && last.latitude <= 14.5 && last.longitude >= 76.0 && last.longitude <= 81.0) {
            initialCenter = LatLng(last.latitude, last.longitude);
          }
        } catch (_) {}
      }
    }

    if (!mounted) {
      setState(() => _isOpeningMap = false);
      return;
    }

    setState(() => _isOpeningMap = false);

    final LatLng? pickedLatLng = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        builder: (ctx) => _InteractiveMapPinPickerScreen(
          isTamil: widget.isTamil,
          initialCenter: initialCenter,
        ),
      ),
    );

    if (pickedLatLng != null) {
      final String googleMapsUrl = 'https://www.google.com/maps?q=${pickedLatLng.latitude},${pickedLatLng.longitude}';
      final model = LocationDataModel(
        latitude: pickedLatLng.latitude,
        longitude: pickedLatLng.longitude,
        locationUrl: googleMapsUrl,
        addressLabel: '${pickedLatLng.latitude.toStringAsFixed(4)}° N, ${pickedLatLng.longitude.toStringAsFixed(4)}° E',
      );

      setState(() {
        _selectedLocation = model;
      });

      widget.onLocationSelected(model);

      if (mounted) {
        AppToast.showSuccess(
          context,
          widget.isTamil ? 'வரைபட இடம் வெற்றிகரமாக குறிக்கப்பட்டது!' : 'Map location pinned successfully!',
        );
      }
    }
  }

  void _removeLocation() {
    setState(() {
      _selectedLocation = null;
    });
    widget.onLocationSelected(null);
  }

  @override
  Widget build(BuildContext context) {
    final isTamil = widget.isTamil;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  isTamil ? 'பிரச்சனை உள்ள GPS இடம்' : 'PROBLEM GPS LOCATION',
                  style: const TextStyle(
                    color: Color(0xFF6E6E6E),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                const Text(
                  ' *',
                  style: TextStyle(
                    color: Color(0xFFD32F2F),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _selectedLocation != null ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: _selectedLocation != null ? const Color(0xFFA5D6A7) : const Color(0xFFFFCDD2),
                  width: 0.8,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _selectedLocation != null ? Icons.check_circle_rounded : Icons.error_outline_rounded,
                    size: 11,
                    color: _selectedLocation != null ? const Color(0xFF2E7D32) : const Color(0xFFD32F2F),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _selectedLocation != null
                        ? (isTamil ? 'இணைக்கப்பட்டது' : 'Attached')
                        : (isTamil ? 'கட்டாயம்' : 'Mandatory'),
                    style: TextStyle(
                      color: _selectedLocation != null ? const Color(0xFF2E7D32) : const Color(0xFFD32F2F),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // If location is NOT yet attached: Show Single High-Impact Choose Location Button
        if (_selectedLocation == null) ...[
          InkWell(
            onTap: _isOpeningMap ? null : _openMapPinPicker,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8C0000), Color(0xFF600000)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8C0000).withValues(alpha: 0.28),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: _isOpeningMap
                  ? const Center(
                      child: SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.2),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.white24,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.pin_drop_rounded, color: Color(0xFFFFD600), size: 20),
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                isTamil ? 'இடத்தைத் தேர்வு செய்க (Choose Location)' : 'Choose Location on Map',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.3,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                isTamil ? 'வரைபடத்தில் பிரச்சனை உள்ள இடத்தை குறிக்கவும்' : 'Pin the exact spot on Satellite Map',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10.5,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 14),
                      ],
                    ),
            ),
          ),
        ],

        // If location IS attached: Show Sleek Preview Card (Zero Overflow Guaranteed)
        if (_selectedLocation != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F8E9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFA5D6A7), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2E7D32).withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // GPS Pin Icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFF2E7D32),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.location_on_rounded, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 10),

                // Location Coordinates & Info (Flexible to prevent any horizontal overflow)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              isTamil ? 'GPS இடம் இணைக்கப்பட்டது' : 'GPS Location Attached',
                              style: const TextStyle(
                                color: Color(0xFF1B5E20),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.verified_rounded, color: Color(0xFF2E7D32), size: 14),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${_selectedLocation!.latitude.toStringAsFixed(5)}, ${_selectedLocation!.longitude.toStringAsFixed(5)}',
                        style: const TextStyle(
                          color: Color(0xFF33691E),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        isTamil ? 'கள்ளக்குறிச்சி • Google Maps Link' : 'Kallakurichi • Google Maps Link',
                        style: const TextStyle(
                          color: Color(0xFF558B2F),
                          fontSize: 9.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),

                // Compact Action Buttons
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Change / Edit on Map Button
                    IconButton(
                      onPressed: _openMapPinPicker,
                      tooltip: isTamil ? 'மாற்று' : 'Change',
                      icon: const Icon(Icons.edit_location_alt_rounded, color: Color(0xFF2E7D32), size: 18),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.all(6),
                      ),
                    ),
                    const SizedBox(width: 6),

                    // Remove Button
                    IconButton(
                      onPressed: _removeLocation,
                      tooltip: isTamil ? 'நீக்கு' : 'Remove',
                      icon: const Icon(Icons.close_rounded, color: Color(0xFFD32F2F), size: 16),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.all(6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// Full-Screen Interactive Google Satellite Hybrid & Street Map Pin Picker Screen (With Clear Village / Oor / Town Names)
class _InteractiveMapPinPickerScreen extends StatefulWidget {
  final bool isTamil;
  final LatLng initialCenter;

  const _InteractiveMapPinPickerScreen({
    required this.isTamil,
    required this.initialCenter,
  });

  @override
  State<_InteractiveMapPinPickerScreen> createState() => _InteractiveMapPinPickerScreenState();
}

class _InteractiveMapPinPickerScreenState extends State<_InteractiveMapPinPickerScreen> {
  late final MapController _mapController;
  late LatLng _currentCenter;
  bool _isLocating = false;
  bool _isSatellite = true; // Default to lightning-fast Satellite Hybrid Map on open!

  // Key Taluk / Town Landmarks in Kallakurichi District for instant jump
  final List<Map<String, dynamic>> _kallakurichiTaluks = [
    {'nameEn': 'Kallakurichi Town', 'nameTa': 'கள்ளக்குறிச்சி', 'lat': 11.7384, 'lng': 78.9639},
    {'nameEn': 'Sankarapuram', 'nameTa': 'சங்கராபுரம்', 'lat': 11.8885, 'lng': 78.9840},
    {'nameEn': 'Chinnasalem', 'nameTa': 'சின்னசேலம்', 'lat': 11.6425, 'lng': 78.8878},
    {'nameEn': 'Thiagadurgam', 'nameTa': 'தியாகதுருகம்', 'lat': 11.7454, 'lng': 79.0827},
    {'nameEn': 'Ulundurpet', 'nameTa': 'உளுந்தூர்பேட்டை', 'lat': 11.6917, 'lng': 79.2892},
    {'nameEn': 'Rishivandhiyam', 'nameTa': 'ரிஷிவந்தியம்', 'lat': 11.8151, 'lng': 79.1028},
    {'nameEn': 'Kalvarayan Hills', 'nameTa': 'கல்வராயன் மலை', 'lat': 11.8210, 'lng': 78.7500},
  ];

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _currentCenter = widget.initialCenter;
  }

  void _jumpToTaluk(double lat, double lng) {
    final newCenter = LatLng(lat, lng);
    _mapController.move(newCenter, 15.5);
    setState(() {
      _currentCenter = newCenter;
    });
  }

  /// Locate device live GPS and center the map
  Future<void> _recenterToGps() async {
    setState(() => _isLocating = true);
    try {
      // 1. Check if device Location Services (GPS) are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _isLocating = false);
        if (mounted) {
          AppToast.showError(
            context,
            widget.isTamil
                ? 'உங்கள் சாதனத்தில் GPS / Location Services-ஐ ON செய்யவும்.'
                : 'Please turn ON Location Services on your device.',
          );
        }
        return;
      }

      // 2. Check and request permission if needed
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _isLocating = false);
          if (mounted) {
            AppToast.showError(
              context,
              widget.isTamil ? 'இருப்பிட அனுமதி (Location Permission) மறுக்கப்பட்டது!' : 'Location permission was denied!',
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() => _isLocating = false);
        if (mounted) {
          AppToast.showError(
            context,
            widget.isTamil
                ? 'அமைப்புகளில் இருப்பிட அனுமதியை (Location Permission) இயக்கவும்.'
                : 'Please enable location permission in App Settings.',
          );
        }
        return;
      }

      // 3. Fetch live GPS position with fallback to last known
      Position? pos;
      try {
        pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 10),
          ),
        );
      } catch (_) {
        pos = await Geolocator.getLastKnownPosition();
      }

      if (pos != null) {
        double lat = pos.latitude;
        double lng = pos.longitude;

        // Only override if specifically Android Emulator default mock location (Mountain View 37.42..., -122.08...)
        if (lat >= 37.41 && lat <= 37.43 && lng >= -122.09 && lng <= -122.07) {
          lat = 11.7384;
          lng = 78.9639;
        }

        final newCenter = LatLng(lat, lng);
        _mapController.move(newCenter, 16.5);
        setState(() {
          _currentCenter = newCenter;
          _isLocating = false;
        });

        if (mounted) {
          AppToast.showSuccess(
            context,
            widget.isTamil ? 'உங்கள் தற்போதைய இடம் கண்டறியப்பட்டது 🎯' : 'Centered to your current GPS location 🎯',
          );
        }
      } else {
        setState(() => _isLocating = false);
        if (mounted) {
          AppToast.showInfo(
            context,
            widget.isTamil ? 'GPS சிக்னல் பெற இயலவில்லை. வரைபடத்தில் பின் வைக்கவும்.' : 'Could not get GPS fix. Please pin on map.',
          );
        }
      }
    } catch (e) {
      setState(() => _isLocating = false);
      if (mounted) {
        AppToast.showInfo(
          context,
          widget.isTamil ? 'GPS பெற இயலவில்லை. வரைபடத்தில் குறிக்கவும்.' : 'Could not fetch GPS. Pin on map.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTamil = widget.isTamil;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF8C0000),
        foregroundColor: Colors.white,
        elevation: 2,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isTamil ? 'பிரச்சனை உள்ள இடத்தை குறிக்கவும்' : 'Pin Problem Location',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Kallakurichi District, Tamil Nadu',
              style: TextStyle(fontSize: 10.5, color: Color(0xFFFFD600), fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          // 🛰️ / 🗺️ Segmented Satellite & Street Switcher Pill
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Container(
              height: 32,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFFFD600).withValues(alpha: 0.5), width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Satellite Tab
                  GestureDetector(
                    onTap: () {
                      if (!_isSatellite) setState(() => _isSatellite = true);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _isSatellite ? const Color(0xFFFFD600) : Colors.transparent,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.satellite_alt_rounded,
                            size: 13,
                            color: _isSatellite ? const Color(0xFF5A0000) : Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isTamil ? 'செயற்கைக்கோள்' : 'Satellite',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w900,
                              color: _isSatellite ? const Color(0xFF5A0000) : Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Street Tab
                  GestureDetector(
                    onTap: () {
                      if (_isSatellite) setState(() => _isSatellite = false);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: !_isSatellite ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.map_rounded,
                            size: 13,
                            color: !_isSatellite ? const Color(0xFF5A0000) : Colors.white70,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isTamil ? 'வரைபடம்' : 'Street',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w900,
                              color: !_isSatellite ? const Color(0xFF5A0000) : Colors.white70,
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
        ],
      ),
      body: Stack(
        children: [
          // 1. Interactive Map: Lightning-Fast Satellite Hybrid / Street Map with Automatic Fallback
          Container(
            color: _isSatellite ? const Color(0xFF1B232A) : const Color(0xFFF2F4F7),
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: widget.initialCenter,
                initialZoom: 15.5,
                minZoom: 3.0,
                maxZoom: 21.0,
                onPositionChanged: (camera, hasGesture) {
                  setState(() {
                    _currentCenter = camera.center;
                  });
                },
              ),
              children: [
                if (_isSatellite)
                  TileLayer(
                    urlTemplate: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
                    fallbackUrl: 'https://{s}.google.com/vt/lyrs=y&x={x}&y={y}&z={z}',
                    subdomains: const ['mt0', 'mt1', 'mt2', 'mt3'],
                    minZoom: 1.0,
                    maxZoom: 22.0,
                    minNativeZoom: 1,
                    maxNativeZoom: 18,
                    keepBuffer: 4,
                    panBuffer: 1,
                    tileDisplay: const TileDisplay.fadeIn(
                      duration: Duration(milliseconds: 150),
                    ),
                  )
                else
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    fallbackUrl: 'https://{s}.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',
                    subdomains: const ['mt0', 'mt1', 'mt2', 'mt3'],
                    userAgentPackageName: 'com.gradixtech.tvk_application',
                    minZoom: 1.0,
                    maxZoom: 22.0,
                    minNativeZoom: 1,
                    maxNativeZoom: 19,
                    keepBuffer: 4,
                    panBuffer: 1,
                    tileDisplay: const TileDisplay.fadeIn(
                      duration: Duration(milliseconds: 150),
                    ),
                  ),
              ],
            ),
          ),

          // 2. Quick Action Chips (Top Bar: 🎯 My Live GPS + Taluks)
          Positioned(
            top: 10,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 34,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  // Prominent 🎯 My Current Location Chip (First Button!)
                  InkWell(
                    onTap: _isLocating ? null : _recenterToGps,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF8C0000), Color(0xFFB71C1C)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFFFD600), width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.35),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_isLocating)
                            const SizedBox(
                              width: 13,
                              height: 13,
                              child: CircularProgressIndicator(strokeWidth: 1.8, color: Colors.white),
                            )
                          else
                            const Icon(Icons.my_location_rounded, color: Color(0xFFFFD600), size: 14),
                          const SizedBox(width: 6),
                          Text(
                            isTamil ? '🎯 எனது தற்போதைய இடம்' : '🎯 My Live GPS',
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Taluk chips
                  for (final taluk in _kallakurichiTaluks)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: InkWell(
                        onTap: () => _jumpToTaluk(taluk['lat'], taluk['lng']),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.78),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFFFD600).withValues(alpha: 0.8), width: 1),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.location_city_rounded, color: Color(0xFFFFD600), size: 13),
                              const SizedBox(width: 4),
                              Text(
                                isTamil ? taluk['nameTa'] : taluk['nameEn'],
                                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // 3. Fixed Center Red Pin Indicator with Target Badge
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40), // Anchor pin point exactly to center
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8C0000),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFFD600), width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      isTamil ? 'பிரச்சனை உள்ள இடம் 📍' : 'Problem Spot 📍',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Icon(
                    Icons.location_pin,
                    size: 46,
                    color: Color(0xFFFF1744),
                    shadows: [
                      Shadow(color: Colors.black45, blurRadius: 8, offset: Offset(0, 3)),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 4. Coordinates Floating Info Card (Above Bottom Button)
          Positioned(
            left: 16,
            right: 16,
            bottom: 76,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white24, width: 0.8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.my_location_rounded, color: Color(0xFFFFD600), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isTamil ? 'தேர்வு செய்யப்பட்ட GPS இடம்:' : 'Selected Coordinates:',
                          style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '${_currentCenter.latitude.toStringAsFixed(5)}° N, ${_currentCenter.longitude.toStringAsFixed(5)}° E',
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  // Quick 'Locate Me' button inside the card (Shows inline loading spinner while locating)
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFF8C0000),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: _isLocating ? null : _recenterToGps,
                    icon: _isLocating
                        ? const SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFFFFD600),
                            ),
                          )
                        : const Icon(Icons.gps_fixed_rounded, size: 13, color: Color(0xFFFFD600)),
                    label: Text(
                      _isLocating
                          ? (isTamil ? 'கண்டறிகிறது...' : 'Locating...')
                          : (isTamil ? 'எனது இடம்' : 'Locate Me'),
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 5. Compact Floating Zoom In (+) and Zoom Out (-) Controls (Bottom Right)
          Positioned(
            right: 16,
            bottom: 140,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF8C0000).withValues(alpha: 0.25), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.22),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Zoom In (+)
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
                      onTap: () {
                        final nextZoom = (_mapController.camera.zoom + 1.0).clamp(3.0, 21.0);
                        _mapController.move(_currentCenter, nextZoom);
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        child: Icon(Icons.add_rounded, size: 22, color: Color(0xFF8C0000)),
                      ),
                    ),
                  ),
                  Container(
                    width: 24,
                    height: 1,
                    color: const Color(0xFFE0E0E0),
                  ),
                  // Zoom Out (-)
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(11)),
                      onTap: () {
                        final nextZoom = (_mapController.camera.zoom - 1.0).clamp(3.0, 21.0);
                        _mapController.move(_currentCenter, nextZoom);
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        child: Icon(Icons.remove_rounded, size: 22, color: Color(0xFF8C0000)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 6. Bottom Confirm Location Button
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8C0000),
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () {
                  Navigator.of(context).pop(_currentCenter);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle_rounded, color: Color(0xFFFFD600), size: 20),
                    const SizedBox(width: 8),
                    Text(
                      isTamil ? 'இந்த இடத்தை உறுதி செய் ➔' : 'Confirm This Location ➔',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
