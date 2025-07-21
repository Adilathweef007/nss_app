import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nssapp/models/event_model.dart';
import 'package:nssapp/models/user_model.dart';
import 'package:nssapp/utils/constants.dart';
import 'package:nssapp/widgets/common/custom_button.dart';


class AdminEventDetailsScreen extends StatefulWidget {
  const AdminEventDetailsScreen({Key? key}) : super(key: key);

  @override
  State<AdminEventDetailsScreen> createState() => _AdminEventDetailsScreenState();
}

class _AdminEventDetailsScreenState extends State<AdminEventDetailsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showDeleteConfirmation(BuildContext context, EventModel event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: Text('Are you sure you want to delete "${event.title}"?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Delete event
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(AppConstants.successEventDeleted),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _approveParticipant(String volunteerId) async {
    setState(() {
      _isLoading = true;
    });
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      _isLoading = false;
    });
    
    if (!mounted) return;
    
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(AppConstants.successParticipationApproved),
        backgroundColor: Colors.green,
      ),
    );
  }
  
  Future<void> _rejectParticipant(String volunteerId) async {
    setState(() {
      _isLoading = true;
    });
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      _isLoading = false;
    });
    
    if (!mounted) return;
    
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(AppConstants.successParticipationRejected),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get event from arguments or use a mock event for UI development
    final event = ModalRoute.of(context)?.settings.arguments as EventModel? ??
        EventModel.getMockEvents().first;

    final dateFormat = DateFormat('EEEE, MMM dd, yyyy');
    final timeFormat = DateFormat('hh:mm a');
    
    // Get registered volunteers who aren't approved yet
    final pendingVolunteers = UserModel.getMockVolunteers()
        .where((volunteer) => 
            event.registeredParticipants.contains(volunteer.id) &&
            !event.approvedParticipants.contains(volunteer.id))
        .toList();
    
    // Get approved volunteers
    final approvedVolunteers = UserModel.getMockVolunteers()
        .where((volunteer) => event.approvedParticipants.contains(volunteer.id))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Navigate to edit event
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteConfirmation(context, event),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Event Details
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Event Status
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        decoration: BoxDecoration(
                          color: _getStatusColor(event),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _getStatusText(event),
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
                                      '${event.approvedParticipants.length}/${event.maxParticipants} volunteers approved',
                                      style: const TextStyle(
                                        color: Colors.black54,
                                      ),
                                    ),
                                    if (pendingVolunteers.isNotEmpty)
                                      Text(
                                        '${pendingVolunteers.length} pending approval',
                                        style: const TextStyle(
                                          color: Colors.orange,
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
                    ],
                  ),
                ),
                
                // Participants Tab
                TabBar(
                  controller: _tabController,
                  labelColor: Theme.of(context).primaryColor,
                  tabs: [
                    Tab(
                      text: 'Pending (${pendingVolunteers.length})',
                    ),
                    Tab(
                      text: 'Approved (${approvedVolunteers.length})',
                    ),
                  ],
                ),
                
                // Participants TabView
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Pending Tab
                      _buildParticipantList(
                        pendingVolunteers,
                        'No pending participants',
                        showActions: true,
                      ),
                      
                      // Approved Tab
                      _buildParticipantList(
                        approvedVolunteers,
                        'No approved participants',
                        showActions: false,
                      ),
                    ],
                  ),
                ),
              ],
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: CustomButton(
          text: 'Mark Attendance',
          onPressed: () {
            Navigator.pushNamed(
              context,
              '/admin/attendance-management',
              arguments: event,
            );
          },
        ),
      ),
    );
  }

  Widget _buildParticipantList(List<UserModel> volunteers, String emptyMessage, {required bool showActions}) {
    if (volunteers.isEmpty) {
      return Center(
        child: Text(
          emptyMessage,
          style: const TextStyle(
            color: Colors.grey,
          ),
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: volunteers.length,
      itemBuilder: (context, index) {
        final volunteer = volunteers[index];
        
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              child: Text(
                volunteer.name.substring(0, 1),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              volunteer.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('ID: ${volunteer.volunteerId}'),
                Text('Department: ${volunteer.department}'),
              ],
            ),
            isThreeLine: true,
            trailing: showActions
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check_circle, color: Colors.green),
                        onPressed: () => _approveParticipant(volunteer.id),
                      ),
                      IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.red),
                        onPressed: () => _rejectParticipant(volunteer.id),
                      ),
                    ],
                  )
                : null,
            onTap: () {
              Navigator.pushNamed(
                context,
                '/admin/volunteer-details',
                arguments: volunteer,
              );
            },
          ),
        );
      },
    );
  }

  Color _getStatusColor(EventModel event) {
    if (event.isPast) {
      return Colors.grey;
    } else if (event.isOngoing) {
      return Colors.orange;
    } else {
      return Theme.of(context).primaryColor;
    }
  }

  String _getStatusText(EventModel event) {
    if (event.isPast) {
      return 'Event Completed';
    } else if (event.isOngoing) {
      return 'Event Ongoing';
    } else {
      return 'Event Upcoming';
    }
  }
}