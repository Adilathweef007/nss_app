import 'package:flutter/material.dart';
import 'package:nssapp/models/event_model.dart';
import 'package:nssapp/models/user_model.dart';
import 'package:nssapp/widgets/common/event_card.dart';

class VolunteerEventListScreen extends StatefulWidget {
  const VolunteerEventListScreen({Key? key}) : super(key: key);

  @override
  State<VolunteerEventListScreen> createState() => _VolunteerEventListScreenState();
}

class _VolunteerEventListScreenState extends State<VolunteerEventListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Mock user for UI development
  final UserModel _currentUser = UserModel.getMockVolunteers().first;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Events'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Registered'),
            Tab(text: 'Past'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildUpcomingEventsTab(),
          _buildRegisteredEventsTab(),
          _buildPastEventsTab(),
        ],
      ),
    );
  }

  Widget _buildUpcomingEventsTab() {
    final upcomingEvents = EventModel.getMockEvents()
        .where((event) => event.isUpcoming)
        .toList();

    return _buildEventsList(
      upcomingEvents,
      isRegisteredList: upcomingEvents
          .map((event) => event.registeredParticipants.contains(_currentUser.id))
          .toList(),
      emptyMessage: 'No upcoming events available',
    );
  }

  Widget _buildRegisteredEventsTab() {
    final registeredEvents = EventModel.getMockEvents()
        .where((event) => 
            event.registeredParticipants.contains(_currentUser.id) && 
            (event.isUpcoming || event.isOngoing))
        .toList();

    return _buildEventsList(
      registeredEvents,
      isRegisteredList: List.filled(registeredEvents.length, true),
      isOngoingList: registeredEvents.map((event) => event.isOngoing).toList(),
      emptyMessage: 'You haven\'t registered for any events yet',
    );
  }

  Widget _buildPastEventsTab() {
    final pastEvents = EventModel.getMockEvents()
        .where((event) => event.isPast)
        .toList();

    return _buildEventsList(
      pastEvents,
      isPastList: List.filled(pastEvents.length, true),
      emptyMessage: 'No past events available',
    );
  }

  Widget _buildEventsList(
    List<EventModel> events, {
    List<bool>? isRegisteredList,
    List<bool>? isOngoingList,
    List<bool>? isPastList,
    required String emptyMessage,
  }) {
    if (events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.event_busy,
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
      itemCount: events.length,
      itemBuilder: (context, index) {
        return EventCard(
          event: events[index],
          isRegistered: isRegisteredList?[index] ?? false,
          isOngoing: isOngoingList?[index] ?? false,
          isPast: isPastList?[index] ?? false,
          onTap: () {
            Navigator.pushNamed(
              context,
              '/volunteer/event-details',
              arguments: events[index],
            );
          },
        );
      },
    );
  }
}