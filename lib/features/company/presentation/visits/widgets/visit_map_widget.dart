// lib/core/widgets/visit_map_widget.dart
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class VisitMapWidget extends StatefulWidget {
  final LatLng checkInPosition;
  final LatLng? checkOutPosition;
  final String checkInTime;
  final String? checkOutTime;
  final String? checkInAddress;
  final String? checkOutAddress;
  final bool showCurrentLocation;
  final bool isDarkMode;

  const VisitMapWidget({
    super.key,
    required this.checkInPosition,
    this.checkOutPosition,
    required this.checkInTime,
    this.checkOutTime,
    this.checkInAddress,
    this.checkOutAddress,
    this.showCurrentLocation = false,
    this.isDarkMode = false,
  });

  @override
  State<VisitMapWidget> createState() => _VisitMapWidgetState();
}

class _VisitMapWidgetState extends State<VisitMapWidget> {
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};
  double _currentZoom = 15;
  final Set<Polyline> _polylines = {};
  LatLngBounds? _bounds;

  @override
  void initState() {
    super.initState();
    _setupMap();
  }

  void _setupMap() {
    // Add check-in marker
    _markers.add(
      Marker(
        markerId: const MarkerId('checkIn'),
        position: widget.checkInPosition,
        infoWindow: InfoWindow(
          title: 'Check-In',
          snippet: '${widget.checkInTime}\n${widget.checkInAddress ?? ''}',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ),
    );

    // Add check-out marker if available
    if (widget.checkOutPosition != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('checkOut'),
          position: widget.checkOutPosition!,
          infoWindow: InfoWindow(
            title: 'Check-Out',
            snippet: '${widget.checkOutTime}\n${widget.checkOutAddress ?? ''}',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );

      // Add polyline between points
      _polylines.add(
        Polyline(
          polylineId: const PolylineId('route'),
          points: [widget.checkInPosition, widget.checkOutPosition!],
          color: Colors.blue,
          width: 3,
        ),
      );

      // Calculate bounds for both points
      _bounds = LatLngBounds(
        southwest: LatLng(
          min(widget.checkInPosition.latitude, widget.checkOutPosition!.latitude),
          min(widget.checkInPosition.longitude, widget.checkOutPosition!.longitude),
        ),
        northeast: LatLng(
          max(widget.checkInPosition.latitude, widget.checkOutPosition!.latitude),
          max(widget.checkInPosition.longitude, widget.checkOutPosition!.longitude),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            SizedBox(
              height: 250,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: widget.checkInPosition,
                  zoom: _currentZoom,
                ),
                markers: _markers,
                polylines: _polylines,
                onMapCreated: (controller) {
                  _mapController = controller;
                  if (_bounds != null) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _mapController.animateCamera(
                        CameraUpdate.newLatLngBounds(_bounds!, 50),
                      );
                      _currentZoom = _getBoundsZoomLevel(_bounds!);
                    });
                  }
                },
                onCameraMove: (position) {
                  _currentZoom = position.zoom;
                },
                myLocationEnabled: widget.showCurrentLocation,
                myLocationButtonEnabled: false, // We'll add custom button
                zoomControlsEnabled: true, // Disable default controls
                mapToolbarEnabled: true,
              ),
            ),
            Positioned(
              right: 16,
              bottom: 16,
              child: Column(
                children: [
                  FloatingActionButton.small(
                    heroTag: 'zoomIn',
                    onPressed: _zoomIn,
                    child: const Icon(Icons.add),
                  ),
                  const SizedBox(height: 8),
                  FloatingActionButton.small(
                    heroTag: 'zoomOut',
                    onPressed: _zoomOut,
                    child: const Icon(Icons.remove),
                  ),
                  const SizedBox(height: 8),
                  if (widget.showCurrentLocation)
                    FloatingActionButton.small(
                      heroTag: 'myLocation',
                      onPressed: _goToMyLocation,
                      child: const Icon(Icons.my_location),
                    ),
                ],
              ),
            ),
          ],
        ),
        if (widget.checkOutPosition != null) ...[
          const SizedBox(height: 8),
          Text(
            'Distance: ${_calculateDistance(widget.checkInPosition, widget.checkOutPosition!).toStringAsFixed(2)} km',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ],
    );
  }

  double _calculateDistance(LatLng start, LatLng end) {
    const earthRadius = 6371.0; // km
    final lat1 = start.latitude * (pi / 180);
    final lon1 = start.longitude * (pi / 180);
    final lat2 = end.latitude * (pi / 180);
    final lon2 = end.longitude * (pi / 180);

    final dLat = lat2 - lat1;
    final dLon = lon2 - lon1;

    final a = pow(sin(dLat / 2), 2) + cos(lat1) * cos(lat2) * pow(sin(dLon / 2), 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }


  void _zoomIn() async {
    await _mapController.animateCamera(
      CameraUpdate.zoomIn(),
    );
    _currentZoom = await _mapController.getZoomLevel();
  }

  void _zoomOut() async {
    await _mapController.animateCamera(
      CameraUpdate.zoomOut(),
    );
    _currentZoom = await _mapController.getZoomLevel();
  }

  void _goToMyLocation() async {
    // Implement location service integration if needed
    await _mapController.animateCamera(
      CameraUpdate.newLatLng(widget.checkInPosition),
    );
  }

  double _getBoundsZoomLevel(LatLngBounds bounds) {
    // Calculate appropriate zoom level for bounds
    final double scale = MediaQuery.of(context).size.width / 300;
    return (16 - log(scale) / log(2));
  }
}