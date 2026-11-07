import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/ride_model.dart';
import '../models/user_model.dart';
import '../services/location_service.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import 'location_checker_card.dart';
import 'tamu_otp_dialog.dart';

class RideDetailSheet extends StatelessWidget {
  final RideModel ride;

  const RideDetailSheet({super.key, required this.ride});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final driver = appState.getDriver(ride.driverId);
    final currentUser = appState.currentUser;
    final isMyRide = currentUser?.userId == ride.driverId;

    // Check existing request
    final existingReq = appState.requests.cast<dynamic>().firstWhere(
      (r) => r.rideId == ride.rideId && r.passengerId == currentUser?.userId,
      orElse: () => null,
    );

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 12,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD4D4D8),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Category & Close Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    ride.category,
                    style: const TextStyle(
                      color: AppTheme.aggieMaroon,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.close, size: 20, color: Colors.grey),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Date and Time
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 14, color: AppTheme.aggieMaroon),
                const SizedBox(width: 6),
                Text(
                  '${ride.departureDate} at ${ride.departureTime}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ],
            ),

            if (ride.isRecurring) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E8FF),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Repeats every ${ride.recurringDays.join(", ")}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B21A8),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 14),

            // Route Details Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainer,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.trip_origin, size: 16, color: Colors.green),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          ride.origin,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                        ),
                      ),
                    ],
                  ),
                  if (ride.pickupSpot.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.only(left: 24, top: 2, bottom: 6),
                      child: Text(
                        'Pickup: ${ride.pickupSpot}',
                        style: const TextStyle(fontSize: 11.5, color: Color(0xFF6B7280)),
                      ),
                    ),
                  ],
                  const Padding(
                    padding: EdgeInsets.only(left: 7),
                    child: SizedBox(
                      height: 12,
                      child: VerticalDivider(color: Colors.grey, width: 2),
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: AppTheme.aggieMaroon),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          ride.destination,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: AppTheme.aggieMaroon,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Driver Card
            const Text(
              'Driver Details',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF374151)),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundImage: AppTheme.getAvatarImage(driver.avatar),
                          ),
                          if (driver.isTamuVerified)
                            const Positioned(
                              bottom: 0,
                              right: 0,
                              child: Icon(Icons.verified, size: 16, color: AppTheme.statusGreen),
                            ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  driver.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  driver.classYear,
                                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                                ),
                              ],
                            ),
                            Text(
                              driver.major,
                              style: const TextStyle(fontSize: 11.5, color: Color(0xFF4B5563)),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                const Icon(Icons.star, size: 13, color: Color(0xFFF59E0B)),
                                const SizedBox(width: 3),
                                Text(
                                  '${driver.rating} (${driver.reviewsCount} reviews)',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (driver.carModel != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.directions_car, size: 15, color: Color(0xFF4B5563)),
                          const SizedBox(width: 6),
                          Text(
                            driver.carModel!,
                            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (driver.bio.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      '"${driver.bio}"',
                      style: const TextStyle(fontSize: 11.5, fontStyle: FontStyle.italic, color: Color(0xFF6B7280)),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Seats and Fuel Contribution
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Available Seats', style: TextStyle(fontSize: 11, color: Colors.grey)),
                        const SizedBox(height: 2),
                        Text(
                          '${ride.availableSeats} of ${ride.totalSeats} open',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Fuel Share', style: TextStyle(fontSize: 11, color: Colors.grey)),
                        const SizedBox(height: 2),
                        Text(
                          ride.contribution == 0 ? 'Free' : '\$${ride.contribution} per rider',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.statusGreen),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            if (ride.notes.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'Notes & Trunk Space',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF374151)),
              ),
              const SizedBox(height: 4),
              Text(
                ride.notes,
                style: const TextStyle(fontSize: 12, color: Color(0xFF4B5563)),
              ),
            ],

            const SizedBox(height: 16),

            // Action Button
            _buildActionButton(context, appState, isMyRide, existingReq),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    AppState appState,
    bool isMyRide,
    dynamic existingReq,
  ) {
    if (isMyRide) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.pop(context);
            appState.setTab(3); // My Rides
          },
          icon: const Icon(Icons.manage_accounts, size: 18),
          label: const Text('Manage My Ride'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.aggieMaroon,
            foregroundColor: Colors.white,
          ),
        ),
      );
    }

    if (existingReq != null) {
      if (existingReq.status == 'PENDING') {
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              appState.setTab(3);
            },
            icon: const Icon(Icons.hourglass_top, size: 18),
            label: const Text('Request Sent (Pending Approval)'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.statusAmber,
              foregroundColor: Colors.white,
            ),
          ),
        );
      } else if (existingReq.status == 'ACCEPTED') {
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              appState.setTab(3);
            },
            icon: const Icon(Icons.check_circle, size: 18),
            label: const Text("You're Confirmed! (Seat Reserved)"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.statusGreen,
              foregroundColor: Colors.white,
            ),
          ),
        );
      }
    }

    if (ride.availableSeats <= 0) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: null,
          icon: const Icon(Icons.event_busy, size: 18),
          label: const Text('Ride is Full'),
        ),
      );
    }

    // Default: Request to join
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _handleRequestToJoin(context, appState),
        icon: const Icon(Icons.waving_hand, size: 18),
        label: const Text('Request to Join Ride'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.aggieMaroon,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  void _handleRequestToJoin(BuildContext context, AppState appState) {
    final currentUser = appState.currentUser;
    if (currentUser == null) return;

    if (!currentUser.isTamuVerified) {
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (_) => const TamuOtpDialog(),
      );
      return;
    }

    final driver = appState.getDriver(ride.driverId);

    showDialog(
      context: context,
      builder: (dlgContext) => _BookingRequestDialog(
        ride: ride,
        driver: driver,
        appState: appState,
        onSubmitted: (message, locationResult) {
          Navigator.pop(dlgContext);
          Navigator.pop(context);
          appState.requestRide(
            ride: ride,
            message: message,
            locationResult: locationResult,
          );
        },
      ),
    );
  }
}

class _BookingRequestDialog extends StatefulWidget {
  final RideModel ride;
  final UserModel driver;
  final AppState appState;
  final Function(String message, LocationVerificationResult? locationResult) onSubmitted;

  const _BookingRequestDialog({
    required this.ride,
    required this.driver,
    required this.appState,
    required this.onSubmitted,
  });

  @override
  State<_BookingRequestDialog> createState() => _BookingRequestDialogState();
}

class _BookingRequestDialogState extends State<_BookingRequestDialog> {
  late final TextEditingController _noteController;
  LocationVerificationResult? _locationResult;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(
      text: 'Howdy ${widget.driver.name.split(" ")[0]}! Can I join your trip to ${widget.ride.destination}?',
    );
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(widget.driver.avatar),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ride with ${widget.driver.name}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          'To ${widget.ride.destination}',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Location Verification Card
              LocationCheckerCard(
                pickupSpot: widget.ride.pickupSpot,
                onVerified: (res) {
                  setState(() => _locationResult = res);
                },
              ),
              const SizedBox(height: 16),

              const Text(
                'Note for Driver (Optional):',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _noteController,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: 'e.g. Bringing one grocery tote bag...',
                  contentPadding: EdgeInsets.all(12),
                ),
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => widget.onSubmitted(
                      _noteController.text.trim(),
                      _locationResult,
                    ),
                    icon: const Icon(Icons.send, size: 16),
                    label: const Text('Confirm & Send Request'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.aggieMaroon,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

