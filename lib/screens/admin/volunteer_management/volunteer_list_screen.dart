import 'package:flutter/material.dart';
import 'package:nssapp/models/user_model.dart';

class VolunteerListScreen extends StatefulWidget {
  const VolunteerListScreen({Key? key}) : super(key: key);

  @override
  State<VolunteerListScreen> createState() => _VolunteerListScreenState();
}

class _VolunteerListScreenState extends State<VolunteerListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  List<UserModel> _filteredVolunteers = [];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _filteredVolunteers = UserModel.getMockVolunteers();
    
    _searchController.addListener(_onSearchChanged);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredVolunteers = UserModel.getMockVolunteers().where((volunteer) {
        return volunteer.name.toLowerCase().contains(query) ||
            volunteer.volunteerId.toLowerCase().contains(query) ||
            volunteer.department.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Volunteer Management'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Approved'),
            Tab(text: 'Pending'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search volunteers...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              ),
            ),
          ),
          
          // Volunteer Tabs
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Approved Volunteers Tab
                _buildVolunteerList(
                  _filteredVolunteers.where((volunteer) => volunteer.isApproved).toList(),
                  'No approved volunteers found',
                ),
                
                // Pending Volunteers Tab
                _buildVolunteerList(
                  UserModel.getMockPendingVolunteers(),
                  'No pending volunteer approvals',
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to adding a new volunteer (manual registration)
          Navigator.pushNamed(context, '/signup');
        },
        child: const Icon(Icons.person_add),
      ),
    );
  }

  Widget _buildVolunteerList(List<UserModel> volunteers, String emptyMessage) {
    if (volunteers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.people_outline,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: volunteers.length,
      itemBuilder: (context, index) {
        final volunteer = volunteers[index];
        return Card(
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
                Text('Dept: ${volunteer.department}'),
              ],
            ),
            isThreeLine: true,
            trailing: IconButton(
              icon: const Icon(Icons.arrow_forward_ios, size: 16),
              onPressed: () {
                // Navigate to volunteer details
                Navigator.pushNamed(
                  context, 
                  '/admin/volunteer-details',
                  arguments: volunteer,
                );
              },
            ),
            onTap: () {
              // Navigate to volunteer details
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
}