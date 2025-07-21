// lib/screens/admin/volunteer_management/volunteer_details_screen.dart
import 'package:flutter/material.dart';
import 'package:nssapp/models/event_model.dart';
import 'package:nssapp/models/user_model.dart';
import 'package:nssapp/providers/attendance_provider.dart';
import 'package:nssapp/providers/event_provider.dart';
import 'package:nssapp/providers/volunteer_provider.dart';
import 'package:nssapp/utils/constants.dart';
import 'package:nssapp/widgets/common/custom_button.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class VolunteerDetailsScreen extends StatefulWidget {
  const VolunteerDetailsScreen({Key? key}) : super(key: key);

  @override
  State<VolunteerDetailsScreen> createState() => _VolunteerDetailsScreenState();
}

class _VolunteerDetailsScreenState extends State<VolunteerDetailsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  UserModel? _volunteer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Initialize providers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EventProvider>().initListeners();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Get volunteer from arguments
    final volunteer = ModalRoute.of(context)?.settings.arguments as UserModel?;
    if (volunteer != null && _volunteer == null) {
      setState(() {
        _volunteer = volunteer;
      });
      
      // Load attendance data for this volunteer
      context.read<AttendanceProvider>().getVolunteerAttendance(volunteer.id);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _removeVolunteer(UserModel volunteer) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Volunteer'),
        content: Text('Are you sure you want to remove ${volunteer.name} from NSS?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        // Delete the volunteer
        await context.read<VolunteerProvider>().rejectVolunteer(volunteer.id);
        
        if (!mounted) return;
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Volunteer removed successfully'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Go back to volunteer list
        Navigator.pop(context);
      } catch (e) {
        if (!mounted) return;
        
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error removing volunteer: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _makeAdmin(UserModel volunteer) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Make Admin'),
        content: Text('Are you sure you want to make ${volunteer.name} an admin?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        // Make volunteer an admin
        await context.read<VolunteerProvider>().makeAdmin(volunteer.id);
        
        if (!mounted) return;
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppConstants.successAdminAdded),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error making admin: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventProvider = Provider.of<EventProvider>(context);
    final attendanceProvider = Provider.of<AttendanceProvider>(context);
    
    if (_volunteer == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    // Calculate attendance percentage
    final attendancePercentage = attendanceProvider.attendancePercentage;
    
    // Get events the volunteer has participated in
    final participatedEvents = eventProvider.events
        .where((event) => event.approvedParticipants.contains(_volunteer!.id))
        .toList();
    
    // Get events the volunteer has registered for but not approved yet
    final pendingEvents = eventProvider.events
        .where((event) => 
            event.registeredParticipants.contains(_volunteer!.id) &&
            !event.approvedParticipants.contains(_volunteer!.id) &&
            !event.isPast)
        .toList();
    
    // Get all past events the volunteer participated in
    final pastEvents = participatedEvents
        .where((event) => event.isPast)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Volunteer Details'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'make_admin') {
                _makeAdmin(_volunteer!);
              } else if (value == 'remove') {
                _removeVolunteer(_volunteer!);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'make_admin',
                child: Row(
                  children: [
                    Icon(Icons.admin_panel_settings, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Make Admin'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'remove',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Remove Volunteer'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Volunteer Profile
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Profile Header
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Theme.of(context).primaryColor,
                            child: Text(
                              _volunteer!.name.substring(0, 1),
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _volunteer!.name,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Volunteer ID: ${_volunteer!.volunteerId}',
                                  style: const TextStyle(
                                    color: Colors.black54,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _volunteer!.email,
                                  style: const TextStyle(
                                    color: Colors.black54,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Volunteer Details
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            _buildDetailRow('Department', _volunteer!.department),
                            const Divider(),
                            _buildDetailRow('Blood Group', _volunteer!.bloodGroup),
                            const Divider(),
                            _buildDetailRow('Place', _volunteer!.place),
                            const Divider(),
                            _buildDetailRow(
                              'Joined On',
                              DateFormat('MMM dd, yyyy').format(_volunteer!.createdAt),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Attendance Stats
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              context,
                              value: '${attendancePercentage.toStringAsFixed(1)}%',
                              label: 'Attendance',
                              color: _getAttendanceColor(attendancePercentage),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildStatCard(
                              context,
                              value: participatedEvents.length.toString(),
                              label: 'Events Participated',
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Events Tab
                TabBar(
                  controller: _tabController,
                  labelColor: Theme.of(context).primaryColor,
                  tabs: const [
                    Tab(
                      text: 'Upcoming Events',
                    ),
                    Tab(
                      text: 'Pending Approval',
                    ),
                    Tab(
                      text: 'Past Events',
                    ),
                  ],
                ),
                
                // Events TabView
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Upcoming Events Tab
                      _buildEventList(
                        participatedEvents.where((event) => event.isUpcoming || event.isOngoing).toList(),
                        'No upcoming events',
                      ),
                      
                      // Pending Events Tab
                      _buildEventList(
                        pendingEvents,
                        'No pending approvals',
                      ),
                      
                      // Past Events Tab
                      _buildEventList(
                        pastEvents,
                        'No past events',
                        isPast: true,
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
            Navigator.pushNamed(context, '/admin/attendance-management');
          },
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEventList(List<EventModel> events, String emptyMessage, {bool isPast = false}) {
    if (events.isEmpty) {
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
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        final dateFormat = DateFormat('MMM dd, yyyy');
        
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(
              event.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(dateFormat.format(event.startDate)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(event.location),
                  ],
                ),
              ],
            ),
            isThreeLine: true,
            trailing: isPast
                ? _buildAttendanceIndicator(_volunteer!.id, event)
                : _getEventStatusIndicator(event),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/admin/event-details',
                arguments: event,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildAttendanceIndicator(String volunteerId, EventModel event) {
    // Get attendance from the provider
    final attendances = context.read<AttendanceProvider>().volunteerAttendance;
    
    // Check if the volunteer was present for this event
    final eventAttendance = attendances.where(
      (attendance) => attendance.eventId == event.id && attendance.volunteerId == volunteerId
    ).toList();
    
    final isPresent = eventAttendance.isNotEmpty ? eventAttendance.first.isPresent : false;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isPresent ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isPresent ? Colors.green : Colors.red,
        ),
      ),
      child: Text(
        isPresent ? 'Present' : 'Absent',
        style: TextStyle(
          color: isPresent ? Colors.green : Colors.red,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _getEventStatusIndicator(EventModel event) {
    if (event.isOngoing) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.orange),
        ),
        child: const Text(
          'Ongoing',
          style: TextStyle(
            color: Colors.orange,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.blue),
        ),
        child: const Text(
          'Upcoming',
          style: TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
  }

  Color _getAttendanceColor(double percentage) {
    if (percentage >= 75) {
      return Colors.green;
    } else if (percentage >= 60) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}