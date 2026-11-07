import 'package:flutter/material.dart';
import '../services/location_service.dart';
import '../theme/app_theme.dart';

class LocationCheckerCard extends StatefulWidget {
  final String pickupSpot;
  final Function(LocationVerificationResult) onVerified;
  final LocationVerificationResult? initialResult;

  const LocationCheckerCard({
    super.key,
    required this.pickupSpot,
    required this.onVerified,
    this.initialResult,
  });

  @override
  State<LocationCheckerCard> createState() => _LocationCheckerCardState();
}

class _LocationCheckerCardState extends State<LocationCheckerCard> {
  final LocationService _locationService = LocationService();
  bool _isChecking = false;
  LocationVerificationResult? _result;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _result = widget.initialResult;
  }

  Future<void> _checkLocation({AggieLandmark? preset}) async {
    setState(() {
      _isChecking = true;
      _errorMessage = null;
    });

    try {
      await Future.delayed(const Duration(milliseconds: 600)); // Smooth UI transition
      final res = await _locationService.verifyBookingLocation(
        pickupSpot: widget.pickupSpot,
        customLat: preset?.latitude,
        customLng: preset?.longitude,
      );

      setState(() {
        _result = res;
        _isChecking = false;
      });

      widget.onVerified(res);
    } catch (e) {
      setState(() {
        _isChecking = false;
        _errorMessage = 'Could not verify location: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _result != null && _result!.isVerified
            ? const Color(0xFFF0FDF4)
            : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _result != null && _result!.isVerified
              ? const Color(0xFF86EFAC)
              : const Color(0xFFCBD5E1),
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _result != null && _result!.isVerified
                      ? const Color(0xFF22C55E).withValues(alpha: 0.15)
                      : AppTheme.aggieMaroon.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _result != null && _result!.isVerified
                      ? Icons.verified_user
                      : Icons.my_location,
                  size: 20,
                  color: _result != null && _result!.isVerified
                      ? const Color(0xFF16A34A)
                      : AppTheme.aggieMaroon,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _result != null && _result!.isVerified
                          ? 'Location Verified ✅'
                          : 'Aggie Location Verification',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: _result != null && _result!.isVerified
                            ? const Color(0xFF15803D)
                            : AppTheme.aggieMaroonDark,
                      ),
                    ),
                    Text(
                      'Pickup: ${widget.pickupSpot}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (_result != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Distance to Pickup:',
                        style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                      Text(
                        '${_result!.distanceToPickupMiles.toStringAsFixed(2)} miles',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Current Zone:',
                        style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                      Flexible(
                        child: Text(
                          _result!.zoneName,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E293B),
                          ),
                          textAlign: TextAlign.end,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'GPS Coordinates:',
                        style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                      ),
                      Text(
                        '${_result!.latitude.toStringAsFixed(4)}, ${_result!.longitude.toStringAsFixed(4)}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontFamily: 'monospace',
                          color: Color(0xFF475569),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],

          if (_errorMessage != null) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
          ],

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isChecking ? null : () => _checkLocation(),
                  icon: _isChecking
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Icon(
                          _result != null ? Icons.refresh : Icons.near_me,
                          size: 16,
                        ),
                  label: Text(
                    _isChecking
                        ? 'Verifying Location...'
                        : (_result != null ? 'Re-verify GPS' : 'Verify My Location'),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _result != null && _result!.isVerified
                        ? const Color(0xFF15803D)
                        : AppTheme.aggieMaroon,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              PopupMenuButton<AggieLandmark>(
                tooltip: 'Select Campus Location',
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                onSelected: (landmark) => _checkLocation(preset: landmark),
                itemBuilder: (context) {
                  return LocationService.popularLandmarks.map((lm) {
                    return PopupMenuItem<AggieLandmark>(
                      value: lm,
                      child: Row(
                        children: [
                          const Icon(Icons.location_on, size: 16, color: AppTheme.aggieMaroon),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              lm.name,
                              style: const TextStyle(fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.tune, size: 16, color: Color(0xFF475569)),
                      SizedBox(width: 4),
                      Text('Campus', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

