// lib/screens/admin/admin_dashboard.dart
import 'package:flutter/material.dart';
import 'package:nssapp/models/user_model.dart';
import 'package:nssapp/providers/event_provider.dart';
import 'package:nssapp/providers/user_provider.dart';
import 'package:nssapp/providers/volunteer_provider.dart';
import 'package:provider/provider.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;
  final List<String> _titles = [
    'Dashboard', 
    'Volunteers', 
    'Events', 
    'Admins', 
    'Profile'
  ];
  
  @override
  void initState() {
    super.initState();
    
    // Initialize providers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EventProvider>().initListeners();
      context.read<VolunteerProvider>().initListeners();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final eventProvider = Provider.of<EventProvider>(context);
    final volunteerProvider = Provider.of<VolunteerProvider>(context);
    
    final currentUser = userProvider.currentUser;
    
    // If user is not loaded, show loading indicator
    if (currentUser == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
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
      drawer: _buildDrawer(currentUser),
      body: _buildBody(
        currentUser,
        eventProvider,
        volunteerProvider,
      ),
    );
  }

  Drawer _buildDrawer(UserModel currentAdmin) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Text(
                    currentAdmin.name.substring(0, 1),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  currentAdmin.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  currentAdmin.email,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          _buildDrawerItem(
            icon: Icons.dashboard,
            title: 'Dashboard',
            index: 0,
          ),
          _buildDrawerItem(
            icon: Icons.people,
            title: 'Volunteer Management',
            index: 1,
          ),
          _buildDrawerItem(
            icon: Icons.event,
            title: 'Event Management',
            index: 2,
          ),
          _buildDrawerItem(
            icon: Icons.admin_panel_settings,
            title: 'Admin Management',
            index: 3,
          ),
          _buildDrawerItem(
            icon: Icons.person,
            title: 'Profile',
            index: 4,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              // Sign out and navigate to login screen
              context.read<UserProvider>().signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required int index,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: _selectedIndex == index ? Theme.of(context).primaryColor : null,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: _selectedIndex == index ? Theme.of(context).primaryColor : null,
          fontWeight: _selectedIndex == index ? FontWeight.bold : null,
        ),
      ),
      selected: _selectedIndex == index,
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        Navigator.pop(context);
      },
    );
  }

  Widget _buildBody(
    UserModel currentAdmin,
    EventProvider eventProvider,
    VolunteerProvider volunteerProvider,
  ) {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboardTab(
          currentAdmin, 
          eventProvider, 
          volunteerProvider
        );
      case 1:
        // Navigate to Volunteer Management
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushNamed(context, '/admin/volunteers');
        });
        return Container();
      case 2:
        // Navigate to Event Management
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushNamed(context, '/admin/events');
        });
        return Container();
      case 3:
        // Navigate to Admin Management
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushNamed(context, '/admin/admins');
        });
        return Container();
      case 4:
        // Navigate to Profile
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushNamed(context, '/admin/profile');
        });
        return Container();
      default:
        return _buildDashboardTab(
          currentAdmin, 
          eventProvider, 
          volunteerProvider
        );
    }
  }

  Widget _buildDashboardTab(
    UserModel currentAdmin,
    EventProvider eventProvider,
    VolunteerProvider volunteerProvider,
  ) {
    // Get statistics for dashboard
    final isLoading = eventProvider.isLoading || volunteerProvider.isLoading;
    
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    final pendingVolunteers = volunteerProvider.pendingVolunteers;
    final approvedVolunteers = volunteerProvider.approvedVolunteers;
    final admins = volunteerProvider.admins;
    
    final events = eventProvider.events;
    final upcomingEvents = eventProvider.upcomingEvents;
    final ongoingEvents = eventProvider.ongoingEvents;
    final pastEvents = eventProvider.pastEvents;

    return RefreshIndicator(
      onRefresh: () async {
        // Refresh data
        context.read<EventProvider>().initListeners();
        context.read<VolunteerProvider>().initListeners();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Card(
              color: Theme.of(context).primaryColor,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.admin_panel_settings,
                        color: Colors.blue,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Welcome Admin!',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'You have ${pendingVolunteers.length} pending approvals',
                            style: const TextStyle(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Quick Actions
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            // Quick Actions Grid
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildQuickActionCard(
                  context,
                  icon: Icons.how_to_reg,
                  title: 'Approve Volunteers',
                  onTap: () {
                    Navigator.pushNamed(context, '/admin/pending-approvals');
                  },
                ),
                _buildQuickActionCard(
                  context,
                  icon: Icons.event_available,
                  title: 'Create Event',
                  onTap: () {
                    Navigator.pushNamed(context, '/admin/create-event');
                  },
                ),
                _buildQuickActionCard(
                  context,
                  icon: Icons.fact_check,
                  title: 'Mark Attendance',
                  onTap: () {
                    Navigator.pushNamed(context, '/admin/attendance-management');
                  },
                ),
                _buildQuickActionCard(
                  context,
                  icon: Icons.person_add,
                  title: 'Add Admin',
                  onTap: () {
                    Navigator.pushNamed(context, '/admin/add-admin');
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Statistics Section
            const Text(
              'Overview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            // Volunteers Statistics
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.people,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Volunteers',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatColumn(
                          value: (approvedVolunteers.length + pendingVolunteers.length).toString(),
                          label: 'Total',
                          color: Colors.blue,
                        ),
                        _buildStatColumn(
                          value: approvedVolunteers.length.toString(),
                          label: 'Approved',
                          color: Colors.green,
                        ),
                        _buildStatColumn(
                          value: pendingVolunteers.length.toString(),
                          label: 'Pending',
                          color: Colors.orange,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Events Statistics
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.event,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Events',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatColumn(
                          value: events.length.toString(),
                          label: 'Total',
                          color: Colors.blue,
                        ),
                        _buildStatColumn(
                          value: upcomingEvents.length.toString(),
                          label: 'Upcoming',
                          color: Colors.green,
                        ),
                        _buildStatColumn(
                          value: ongoingEvents.length.toString(),
                          label: 'Ongoing',
                          color: Colors.orange,
                        ),
                        _buildStatColumn(
                          value: pastEvents.length.toString(),
                          label: 'Past',
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Recent Pending Approvals
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Pending Approvals',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (pendingVolunteers.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/admin/pending-approvals');
                    },
                    child: const Text('View All'),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            
            if (pendingVolunteers.isNotEmpty)
              ...pendingVolunteers.take(3).map((volunteer) => 
                Card(
                  margin: const EdgeInsets.only(bottom: 12),
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
                    title: Text(volunteer.name),
                    subtitle: Text(volunteer.department),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          onPressed: () async {
                            await context.read<VolunteerProvider>().approveVolunteer(volunteer.id);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () async {
                            await context.read<VolunteerProvider>().rejectVolunteer(volunteer.id);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ).toList()
            else
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: Text(
                      'No pending approvals',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatColumn({
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
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
        ),
      ],
    );
  }
}