// lib/screens/volunteer/volunteer_dashboard.dart
import 'package:flutter/material.dart';
import 'package:nssapp/models/event_model.dart';
import 'package:nssapp/models/user_model.dart';
import 'package:nssapp/providers/attendance_provider.dart';
import 'package:nssapp/providers/event_provider.dart';
import 'package:nssapp/providers/user_provider.dart';
import 'package:nssapp/widgets/common/event_card.dart';
import 'package:provider/provider.dart';

class VolunteerDashboard extends StatefulWidget {
  const VolunteerDashboard({Key? key}) : super(key: key);

  @override
  State<VolunteerDashboard> createState() => _VolunteerDashboardState();
}

class _VolunteerDashboardState extends State<VolunteerDashboard> {
  int _selectedIndex = 0;
  final List<String> _titles = ['Dashboard', 'Events', 'Attendance', 'Profile'];
  
  @override
  void initState() {
    super.initState();
    // Initialize event provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EventProvider>().initListeners();
    });
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) {
      return; // Don't navigate if already on the selected tab
    }

    if (index == 0) {
      // Dashboard tab
      setState(() {
        _selectedIndex = index;
      });
    } else if (index == 1) {
      // Events tab
      Navigator.pushNamed(context, '/volunteer/events');
    } else if (index == 2) {
      // Attendance tab
      Navigator.pushNamed(context, '/volunteer/attendance');
    } else if (index == 3) {
      // Profile tab
      Navigator.pushNamed(context, '/volunteer/profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final eventProvider = Provider.of<EventProvider>(context);
    
    final currentUser = userProvider.currentUser;
    
    // If user is not loaded, show loading indicator
    if (currentUser == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    final upcomingEvents = eventProvider.upcomingEvents;
    final ongoingEvents = eventProvider.ongoingEvents;
    
    // Get events where the current user is registered
    final registeredEvents = eventProvider.events
        .where((event) => event.registeredParticipants.contains(currentUser.id))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Show notifications
            },
          ),
        ],
      ),
      body: _selectedIndex == 0
          ? _buildDashboardTab(
              context,
              currentUser: currentUser,
              upcomingEvents: upcomingEvents,
              ongoingEvents: ongoingEvents,
              registeredEvents: registeredEvents,
            )
          : Container(),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.how_to_reg),
            label: 'Attendance',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }

  // Dashboard Tab Content
  Widget _buildDashboardTab(
    BuildContext context, {
    required UserModel currentUser,
    required List<EventModel> upcomingEvents,
    required List<EventModel> ongoingEvents,
    required List<EventModel> registeredEvents,
  }) {
    final attendanceProvider = Provider.of<AttendanceProvider>(context, listen: false);
    final attendancePercentage = attendanceProvider.attendancePercentage;

    return RefreshIndicator(
      onRefresh: () async {
        // Refresh data
        context.read<EventProvider>().initListeners();
        context.read<AttendanceProvider>().getVolunteerAttendance(currentUser.id);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Theme.of(context).primaryColor,
                      child: Text(
                        currentUser.name.substring(0, 1),
                        style: const TextStyle(
                          fontSize: 24,
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
                            'Welcome, ${currentUser.name}!',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Volunteer ID: ${currentUser.volunteerId}',
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
            
            // Quick Stats
            Row(
              children: [
                _buildStatCard(
                  context,
                  icon: Icons.event_available,
                  value: registeredEvents.length.toString(),
                  label: 'Registered Events',
                ),
                const SizedBox(width: 16),
                _buildStatCard(
                  context,
                  icon: Icons.how_to_reg,
                  value: '${attendancePercentage.toStringAsFixed(1)}%',
                  label: 'Attendance',
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Ongoing Events Section
            if (ongoingEvents.isNotEmpty) ...[
              const Text(
                'Ongoing Events',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ...ongoingEvents.map((event) => EventCard(
                event: event,
                isOngoing: true,
                isRegistered: event.registeredParticipants.contains(currentUser.id),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/volunteer/event-details',
                    arguments: event,
                  );
                },
              )),
              const SizedBox(height: 24),
            ],
            
            // Upcoming Events Section
            if (upcomingEvents.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Upcoming Events',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/volunteer/events');
                    },
                    child: const Text('See All'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...upcomingEvents.take(3).map((event) => EventCard(
                event: event,
                isRegistered: event.registeredParticipants.contains(currentUser.id),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/volunteer/event-details',
                    arguments: event,
                  );
                },
              )),
            ],
            
            // No events message
            if (upcomingEvents.isEmpty && ongoingEvents.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.event_busy,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No events scheduled at the moment',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                icon,
                size: 32,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
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
        ),
      ),
    );
  }
}


