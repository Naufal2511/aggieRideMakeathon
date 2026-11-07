import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/ride_model.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import 'ride_detail_sheet.dart';

class RideCard extends StatelessWidget {
  final RideModel ride;

  const RideCard({super.key, required this.ride});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final driver = appState.getDriver(ride.driverId);
    final isFree = ride.contribution == 0;
    final isFull = ride.availableSeats <= 0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFEBE0DF), width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => RideDetailSheet(ride: ride),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Category + Recurring + Date/Time
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      _buildCategoryChip(ride.category),
                      if (ride.isRecurring) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEDE9FE),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.repeat, size: 11, color: Color(0xFF6D28D9)),
                              const SizedBox(width: 3),
                              Text(
                                ride.recurringDays.join(', '),
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF6D28D9),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.schedule, size: 13, color: Color(0xFF757575)),
                      const SizedBox(width: 4),
                      Text(
                        '${ride.departureDate} • ${ride.departureTime}',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF616161),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Route Display: Origin -> Destination
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pin Timeline
                  Column(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.aggieMaroon, width: 2.5),
                        ),
                      ),
                      Container(
                        width: 2,
                        height: 24,
                        color: const Color(0xFFD6D3D1),
                      ),
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: AppTheme.aggieMaroon,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),

                  // Route Names
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ride.origin,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF262626),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (ride.pickupSpot.isNotEmpty) ...[
                          const SizedBox(height: 1),
                          Text(
                            'Pickup: ${ride.pickupSpot}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF737373),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 6),
                        Text(
                          ride.destination,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.aggieMaroon,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),
              const Divider(height: 1, color: Color(0xFFF3ECEB)),
              const SizedBox(height: 10),

              // Footer: Driver info + Seats + Contribution
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Driver Info
                  Row(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 17,
                            backgroundImage: AppTheme.getAvatarImage(driver.avatar),
                            backgroundColor: AppTheme.primaryContainer,
                          ),
                          if (driver.isTamuVerified)
                            const Positioned(
                              right: -1,
                              bottom: -1,
                              child: Icon(
                                Icons.verified,
                                size: 14,
                                color: AppTheme.statusGreen,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                driver.name,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1F2937),
                                ),
                              ),
                              if (driver.classYear.isNotEmpty) ...[
                                const SizedBox(width: 4),
                                Text(
                                  driver.classYear,
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    color: Color(0xFF71717A),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(Icons.star, size: 12, color: Color(0xFFF59E0B)),
                              const SizedBox(width: 2),
                              Text(
                                '${driver.rating}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF4B5563),
                                ),
                              ),
                              Text(
                                ' • ${driver.ridesOffered} rides',
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  color: Color(0xFF9CA3AF),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Seats and Price Pills
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: isFull ? const Color(0xFFFEE2E2) : const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.airline_seat_recline_normal,
                              size: 13,
                              color: isFull ? Colors.red : const Color(0xFF4B5563),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              isFull ? 'FULL' : '${ride.availableSeats} seat${ride.availableSeats > 1 ? "s" : ""}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: isFull ? Colors.red : const Color(0xFF374151),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isFree ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isFree ? 'Free' : '\$${ride.contribution} split',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: isFree ? const Color(0xFF166534) : const Color(0xFFB45309),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    Color bg;
    Color fg;

    switch (category.toLowerCase()) {
      case 'shopping':
        bg = const Color(0xFFDBEAFE);
        fg = const Color(0xFF1E40AF);
        break;
      case 'groceries':
        bg = const Color(0xFFDCFCE7);
        fg = const Color(0xFF166534);
        break;
      case 'campus':
        bg = AppTheme.primaryContainer;
        fg = AppTheme.aggieMaroon;
        break;
      case 'dining':
        bg = const Color(0xFFFFEDD5);
        fg = const Color(0xFFC2410C);
        break;
      case 'pharmacy':
        bg = const Color(0xFFF3E8FF);
        fg = const Color(0xFF6B21A8);
        break;
      default:
        bg = const Color(0xFFF3F4F6);
        fg = const Color(0xFF374151);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        category,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}

