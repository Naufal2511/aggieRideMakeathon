import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../services/seed_data_service.dart';
import '../widgets/tamu_otp_dialog.dart';

class OfferRideScreen extends StatefulWidget {
  const OfferRideScreen({super.key});

  @override
  State<OfferRideScreen> createState() => _OfferRideScreenState();
}

class _OfferRideScreenState extends State<OfferRideScreen> {
  final _formKey = GlobalKey<FormState>();
  final _originController = TextEditingController(text: 'The Barracks Townhomes');
  final _destController = TextEditingController(text: 'H-E-B (Jones Crossing)');
  final _pickupSpotController = TextEditingController(text: 'Clubhouse Pool Circle');
  final _notesController = TextEditingController(text: 'Sunday afternoon grocery restocking trip. Plenty of trunk space!');

  String _departureDate = 'Sunday, Nov 9';
  String _departureTime = '1:00 PM';
  String _category = 'Groceries';
  int _seats = 3;
  int _contribution = 2; // $2
  bool _isRecurring = false;
  final List<String> _selectedRecurringDays = ['Mon', 'Wed', 'Fri'];

  final List<String> _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  void dispose() {
    _originController.dispose();
    _destController.dispose();
    _pickupSpotController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submitRide(AppState appState) {
    if (!_formKey.currentState!.validate()) return;

    if (_isRecurring && _selectedRecurringDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one recurring day.')),
      );
      return;
    }

    appState.offerRide(
      origin: _originController.text.trim(),
      destination: _destController.text.trim(),
      departureDate: _departureDate,
      departureTime: _departureTime,
      seats: _seats,
      contribution: _contribution,
      category: _category,
      pickupSpot: _pickupSpotController.text.trim(),
      notes: _notesController.text.trim(),
      isRecurring: _isRecurring,
      recurringDays: _isRecurring ? _selectedRecurringDays : [],
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final currentUser = appState.currentUser;
    final isVerified = currentUser?.isTamuVerified ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Offer a Ride', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Verification Warning Banner if not verified
              if (!isVerified) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Color(0xFFB45309)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'TAMU Verification Required',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF92400E)),
                            ),
                            const Text(
                              'Drivers must verify an active @tamu.edu address to post rides on AggieRide.',
                              style: TextStyle(fontSize: 11.5, color: Color(0xFF78350F)),
                            ),
                            const SizedBox(height: 6),
                            InkWell(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => const TamuOtpDialog(),
                                );
                              },
                              child: const Text(
                                'Verify Now →',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.aggieMaroon),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Origin Input & Chips
              const Text('Starting Location', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _originController,
                decoration: const InputDecoration(
                  hintText: 'e.g. Park West, The Barracks...',
                  prefixIcon: Icon(Icons.trip_origin, color: Colors.green, size: 20),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Origin is required' : null,
              ),
              const SizedBox(height: 6),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: SeedDataService.popularOrigins.take(4).map((loc) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ActionChip(
                        label: Text(loc, style: const TextStyle(fontSize: 11)),
                        onPressed: () => _originController.text = loc,
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 16),

              // Destination Input & Chips
              const Text('Destination', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _destController,
                decoration: const InputDecoration(
                  hintText: 'e.g. Walmart, H-E-B, Target, Campus...',
                  prefixIcon: Icon(Icons.location_on, color: AppTheme.aggieMaroon, size: 20),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Destination is required' : null,
              ),
              const SizedBox(height: 6),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: SeedDataService.popularDestinations.take(4).map((loc) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ActionChip(
                        label: Text(loc, style: const TextStyle(fontSize: 11)),
                        onPressed: () => _destController.text = loc,
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 16),

              // Date & Time Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Departure Date', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 6),
                        InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 30)),
                            );
                            if (picked != null) {
                              setState(() {
                                _departureDate = '${picked.month}/${picked.day}/${picked.year}';
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.outlineVariant),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 16, color: AppTheme.aggieMaroon),
                                const SizedBox(width: 8),
                                Text(_departureDate, style: const TextStyle(fontSize: 12.5)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Departure Time', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 6),
                        InkWell(
                          onTap: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: const TimeOfDay(hour: 13, minute: 0),
                            );
                            if (picked != null) {
                              setState(() {
                                _departureTime = picked.format(context);
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.outlineVariant),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.access_time, size: 16, color: AppTheme.aggieMaroon),
                                const SizedBox(width: 8),
                                Text(_departureTime, style: const TextStyle(fontSize: 12.5)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Category and Seats
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Trip Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 6),
                        Container(
                          height: 48,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.outlineVariant),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _category,
                              isExpanded: true,
                              items: ['Shopping', 'Groceries', 'Campus', 'Dining', 'Pharmacy'].map((c) {
                                return DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 13)));
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _category = val);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Available Seats', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 6),
                        Container(
                          height: 48,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.outlineVariant),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                icon: const Icon(Icons.remove, size: 18),
                                onPressed: _seats > 1 ? () => setState(() => _seats--) : null,
                              ),
                              Text('$_seats seat${_seats > 1 ? "s" : ""}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                icon: const Icon(Icons.add, size: 18),
                                onPressed: _seats < 6 ? () => setState(() => _seats++) : null,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Fuel Contribution Slider
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Suggested Fuel Share', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  Text(
                    _contribution == 0 ? 'Free (Aggies ride free!)' : '\$$_contribution per passenger',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: _contribution == 0 ? AppTheme.statusGreen : AppTheme.aggieMaroon,
                    ),
                  ),
                ],
              ),
              Slider(
                value: _contribution.toDouble(),
                min: 0,
                max: 8,
                divisions: 8,
                activeColor: AppTheme.aggieMaroon,
                label: _contribution == 0 ? 'Free' : '\$$_contribution',
                onChanged: (val) => setState(() => _contribution = val.toInt()),
              ),

              const SizedBox(height: 10),

              // Pickup Spot
              const Text('Meeting / Pickup Spot', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _pickupSpotController,
                decoration: const InputDecoration(
                  hintText: 'e.g. Leasing office circle, clubhouse, lobby...',
                  prefixIcon: Icon(Icons.pin_drop_outlined, size: 20),
                ),
              ),

              const SizedBox(height: 16),

              // Notes
              const Text('Notes & Trunk Room', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: 'e.g. Plenty of room for grocery bags, returning in 1 hr...',
                ),
              ),

              const SizedBox(height: 16),

              // Recurring Schedule Switch & Chips
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Recurring Ride Schedule', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                subtitle: const Text('Repeats on specific weekdays for campus commutes', style: TextStyle(fontSize: 11.5, color: Colors.grey)),
                value: _isRecurring,
                activeColor: AppTheme.aggieMaroon,
                onChanged: (val) => setState(() => _isRecurring = val),
              ),

              if (_isRecurring) ...[
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  children: _weekdays.map((day) {
                    final selected = _selectedRecurringDays.contains(day);
                    return FilterChip(
                      label: Text(day, style: TextStyle(fontSize: 11, color: selected ? Colors.white : Colors.black87)),
                      selected: selected,
                      selectedColor: AppTheme.aggieMaroon,
                      checkmarkColor: Colors.white,
                      onSelected: (val) {
                        setState(() {
                          if (val) {
                            _selectedRecurringDays.add(day);
                          } else {
                            _selectedRecurringDays.remove(day);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ],

              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isVerified
                      ? () => _submitRide(appState)
                      : () {
                          showDialog(
                            context: context,
                            builder: (_) => const TamuOtpDialog(),
                          );
                        },
                  icon: Icon(isVerified ? Icons.add_circle : Icons.verified_user, size: 20),
                  label: Text(
                    isVerified ? 'Publish Ride to Feed' : 'Verify @tamu.edu to Offer Ride',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

