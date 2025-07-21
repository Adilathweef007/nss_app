// lib/screens/admin/volunteer_management/attendance_management_screen.dart
import 'package:flutter/material.dart';
import 'package:nssapp/models/event_model.dart';
import 'package:nssapp/models/user_model.dart';
import 'package:nssapp/providers/attendance_provider.dart';
import 'package:nssapp/providers/event_provider.dart';
import 'package:nssapp/providers/user_provider.dart';
import 'package:nssapp/providers/volunteer_provider.dart';
import 'package:nssapp/utils/constants.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AttendanceManagementScreen extends StatefulWidget {
  const AttendanceManagementScreen({Key? key}) : super(key: key);

  @override
  State<AttendanceManagementScreen> createState() => _AttendanceManagementScreenState();
}

class _AttendanceManagementScreenState extends State<AttendanceManagementScreen> {
  EventModel? _selectedEvent;
  bool _isLoading = false;
  final Map<String, bool> _attendanceStatus = {};
  List<UserModel> _approvedVolunteers = []; // Changed to non-final
  
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadEventData();
  }
  
  void _loadEventData() {
    // Check if we have an event passed as an argument
    final eventArg = ModalRoute.of(context)?.settings.arguments as EventModel?;
    
    if (eventArg != null) {
      setState(() {
        _selectedEvent = eventArg;
      });
      _loadVolunteers();
      return;
    }
    
    // Otherwise, get the first event from the provider
    final events = context.read<EventProvider>().events;
    if (events.isNotEmpty && _selectedEvent == null) {
      setState(() {
        _selectedEvent = events.first;
      });
      _loadVolunteers();
    }
  }
  
  void _loadVolunteers() {
    if (_selectedEvent == null) return;
    
    setState(() {
      _isLoading = true;
    });
    
    // Get attendance for this event
    context.read<AttendanceProvider>().getEventAttendance(_selectedEvent!.id);
    
    // Get approved volunteers for this event
    final approvedIds = _selectedEvent!.approvedParticipants;
    if (approvedIds.isEmpty) {
      setState(() {
        _approvedVolunteers.clear();
        _isLoading = false;
      });
      return;
    }
    
    final allVolunteers = context.read<VolunteerProvider>().approvedVolunteers;
    
    setState(() {
      _approvedVolunteers = allVolunteers
          .where((volunteer) => approvedIds.contains(volunteer.id))
          .toList();
      
      // Initialize attendance status
      final attendances = context.read<AttendanceProvider>().eventAttendance;
      
      for (final volunteer in _approvedVolunteers) {
        final attendance = attendances
            .where((a) => a.volunteerId == volunteer.id)
            .toList();
        
        if (attendance.isNotEmpty) {
          _attendanceStatus[volunteer.id] = attendance.first.isPresent;
        } else {
          _attendanceStatus[volunteer.id] = false; // Default to absent
        }
      }
      
      _isLoading = false;
    });
  }
  
  void _saveAttendance() {
    if (_selectedEvent == null) return;
    
    setState(() {
      _isLoading = true;
    });
    
    final userId = context.read<UserProvider>().currentUser?.id;
    if (userId == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }
    
    // Use the batch mark attendance method
    context.read<AttendanceProvider>().batchMarkAttendance(
      _selectedEvent!.id,
      _attendanceStatus,
      userId,
    ).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppConstants.successAttendanceMarked),
          backgroundColor: Colors.green,
        ),
      );
      
      setState(() {
        _isLoading = false;
      });
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $error'),
          backgroundColor: Colors.red,
        ),
      );
      
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final eventProvider = Provider.of<EventProvider>(context);
    final attendanceProvider = Provider.of<AttendanceProvider>(context);
    
    // If still loading from providers, show loading indicator
    if (eventProvider.isLoading || attendanceProvider.isLoading || _isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Management'),
      ),
      body: _buildBody(eventProvider.events),
      floatingActionButton: _approvedVolunteers.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _saveAttendance,
              icon: const Icon(Icons.save),
              label: const Text('Save Attendance'),
            )
          : null,
    );
  }
  
  Widget _buildBody(List<EventModel> events) {
    if (events.isEmpty) {
      return const Center(
        child: Text('No events available for attendance marking'),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Event Selector
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Event',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButton<String>(
                  value: _selectedEvent?.id,
                  isExpanded: true,
                  underline: Container(),
                  hint: const Text('Select an event'),
                  items: events.map((event) {
                    return DropdownMenuItem<String>(
                      value: event.id,
                      child: Text(event.title),
                    );
                  }).toList(),
                  onChanged: (eventId) {
                    if (eventId != null) {
                      setState(() {
                        _selectedEvent = events.firstWhere((e) => e.id == eventId);
                      });
                      _loadVolunteers();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        
        // Event Details
        if (_selectedEvent != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedEvent!.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(DateFormat('MMM dd, yyyy').format(_selectedEvent!.startDate)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(_selectedEvent!.location),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.people, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text('${_selectedEvent!.approvedParticipants.length} approved participants'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        
        const SizedBox(height: 16),
        
        // Attendance List Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Participant Attendance',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (_approvedVolunteers.isNotEmpty) 
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () {
                      setState(() {
                        for (final volunteer in _approvedVolunteers) {
                          _attendanceStatus[volunteer.id] = true;
                        }
                      });
                    },
                    icon: const Icon(Icons.check_circle, size: 16),
                    label: const Text('Mark All Present'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        
        if (_approvedVolunteers.isEmpty)
          const Expanded(
            child: Center(
              child: Text(
                'No approved participants for this event',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _approvedVolunteers.length,
              itemBuilder: (context, index) {
                final volunteer = _approvedVolunteers[index];
                final isPresent = _attendanceStatus[volunteer.id] ?? false;
                
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
                    subtitle: Text('ID: ${volunteer.volunteerId}'),
                    trailing: Switch(
                      value: isPresent,
                      activeColor: Colors.green,
                      onChanged: (value) {
                        setState(() {
                          _attendanceStatus[volunteer.id] = value;
                        });
                      },
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}