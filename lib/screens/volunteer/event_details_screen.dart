import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nssapp/models/event_model.dart';
import 'package:nssapp/models/user_model.dart';
import 'package:nssapp/utils/constants.dart';
import 'package:nssapp/widgets/common/custom_button.dart';


class VolunteerEventDetailsScreen extends StatefulWidget {
  const VolunteerEventDetailsScreen({Key? key}) : super(key: key);

  @override
  State<VolunteerEventDetailsScreen> createState() => _VolunteerEventDetailsScreenState();
}

class _VolunteerEventDetailsScreenState extends State<VolunteerEventDetailsScreen> {
  bool _isRegistering = false;
  
  // Mock user for UI development
  final UserModel _currentUser = UserModel.getMockVolunteers().first;

  Future<void> _registerForEvent(EventModel event) async {
    setState(() {
      _isRegistering = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isRegistering = false;
    });

    if (!mounted) return;

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(AppConstants.successParticipationRequested),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // Get event from arguments or use a mock event for UI development
    final event = ModalRoute.of(context)?.settings.arguments as EventModel? ??
        EventModel.getMockEvents().first;

    final dateFormat = DateFormat('EEEE, MMM dd, yyyy');
    final timeFormat = DateFormat('hh:mm a');
    
    final isRegistered = event.registeredParticipants.contains(_currentUser.id);
    final isApproved = event.approvedParticipants.contains(_currentUser.id);
    final isPast = event.isPast;
    final isOngoing = event.isOngoing;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Status
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: _getStatusColor(isPast, isOngoing, isRegistered, isApproved),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _getStatusText(isPast, isOngoing, isRegistered, isApproved),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            
            // Event Title
            Text(
              event.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Event Date and Time
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: Theme.of(context).primaryColor,
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dateFormat.format(event.startDate),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${timeFormat.format(event.startDate)} - ${timeFormat.format(event.endDate)}',
                            style: const TextStyle(
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            
            // Event Location
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: Theme.of(context).primaryColor,
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Location',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            event.location,
                            style: const TextStyle(
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            
            // Participants
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.people,
                      color: Theme.of(context).primaryColor,
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Participants',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${event.approvedParticipants.length}/${event.maxParticipants} volunteers registered',
                            style: const TextStyle(
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Event Description
            const Text(
              'Description',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              event.description,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            
            // Registration Button
            if (!isPast && !isRegistered)
              CustomButton(
                text: 'Register for Event',
                isLoading: _isRegistering,
                onPressed: () => _registerForEvent(event),
              ),
              
            // Registered but not approved
            if (isRegistered && !isApproved)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.info,
                      color: Colors.orange,
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Registration Pending',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Your registration is pending approval from the admin.',
                            style: TextStyle(
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
            // Registered and approved
            if (isApproved && !isPast)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green,
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Registration Approved',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Your registration has been approved. Make sure to attend on time!',
                            style: TextStyle(
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(bool isPast, bool isOngoing, bool isRegistered, bool isApproved) {
    if (isPast) {
      return Colors.grey;
    } else if (isOngoing) {
      return Colors.orange;
    } else if (isRegistered && isApproved) {
      return Colors.green;
    } else if (isRegistered) {
      return Colors.orange;
    } else {
      return Theme.of(context).primaryColor;
    }
  }

  String _getStatusText(bool isPast, bool isOngoing, bool isRegistered, bool isApproved) {
    if (isPast) {
      return 'Event Completed';
    } else if (isOngoing) {
      return 'Event Ongoing';
    } else if (isRegistered && isApproved) {
      return 'Registered & Approved';
    } else if (isRegistered) {
      return 'Registration Pending Approval';
    } else {
      return 'Registration Open';
    }
  }
}