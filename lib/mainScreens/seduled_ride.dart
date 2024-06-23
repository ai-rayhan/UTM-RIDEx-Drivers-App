import 'dart:convert';
import 'package:drivers_app/global/global.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class DatabaseService {
  final String databaseUrl =
      'https://friendly-folio-425114-v9-default-rtdb.firebaseio.com/';

  Future<void> scheduleRide(Map<String, dynamic> rideData) async {
    final url = Uri.parse('$databaseUrl/rides.json');
    await http.post(url, body: json.encode(rideData));
  }

  Future<List<Map<String, dynamic>>> getScheduledRides() async {
    final url = Uri.parse('$databaseUrl/rides.json');
    final response = await http.get(url);
    final extractedData = json.decode(response.body) as Map<String, dynamic>;
    List<Map<String, dynamic>> rides = [];
    extractedData.forEach((rideId, rideData) {
      rides.add({
        'id': rideId,
        ...rideData,
      });
    });
    return rides;
  }

  Future<void> confirmDriver(String rideId, String driverId, String driverName,
      String vehicleName) async {
    final url = Uri.parse('$databaseUrl/rides/$rideId.json');
    await http.patch(url,
        body: json.encode({
          'confirmedDriver': driverId,
          'driverName': driverName,
          'vehicleName': vehicleName,
          'status': 'confirmed',
        }));
  }

  Future<void> sendProposal(
      String rideId, String driverId, Map<String, dynamic> proposalData) async {
    final url = Uri.parse('$databaseUrl/rides/$rideId/proposals.json');
    final response = await http.get(url);
    final existingProposals =
        json.decode(response.body) as Map<String, dynamic>?;

    if (existingProposals != null &&
        existingProposals.values
            .any((proposal) => proposal['driverId'] == driverId)) {
      throw Exception('You have already sent a proposal for this ride.');
    }

    await http.post(url, body: json.encode(proposalData));
  }
}

class UpCommingTripScreen extends StatefulWidget {
  @override
  _UpCommingTripScreenState createState() => _UpCommingTripScreenState();
}

class _UpCommingTripScreenState extends State<UpCommingTripScreen> {
  final DatabaseService database = DatabaseService();
  Future<List<Map<String, dynamic>>>? _ridesFuture;
  bool _isLoading = false;
  final String driverId = onlineDriverData
      .id!; // This should be the actual driver's ID from the global context or user session

  @override
  void initState() {
    super.initState();
    _fetchRides();
  }

  void _fetchRides() {
    setState(() {
      _ridesFuture = database.getScheduledRides();
    });
  }

  void _sendProposal(String rideId) async {
    setState(() {
      _isLoading = true;
    });
    try {
      await database.sendProposal(rideId, driverId, {
        "driverId": driverId,
        "driverName":
            onlineDriverData!.name!, // Replace with actual driver name
        "vehicleName": onlineDriverData.car_model! +
            " " +
            onlineDriverData.car_number!, // Replace with actual vehicle name
      });
      _fetchRides();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Proposal sent successfully'),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to send Proposal: $e'),
      ));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orangeAccent,
        title: const Text('Up Coming Trips'),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                const SizedBox(height: 20),
                Expanded(
                  child: FutureBuilder(
                    future: _ridesFuture,
                    builder: (context,
                        AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('No rides available'));
                      }

                      final rides = snapshot.data!;

                      return ListView.builder(
                        itemCount: rides.length,
                        itemBuilder: (context, index) {
                          final ride = rides[index];
                          final proposals = ride['proposals'] ?? {};
                          final hasSentProposal = proposals.values.any(
                              (proposal) => proposal['driverId'] == driverId);
                          final isConfirmed = ride['status'] == 'confirmed';

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${ride['rideType']}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Scheduled Time: ${DateTime.parse(ride['scheduledTime']).toLocal()}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Status: ${ride['status']}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Pickup Location: ${ride['pickupLocation']}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Dropping Point: ${ride['droppingPoint']}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  if (!isConfirmed && !hasSentProposal)
                                    ElevatedButton(
                                      onPressed: () {
                                        _sendProposal(ride['id']);
                                      },
                                      child: const Text("Send Proposal"),
                                    ),
                                  if (isConfirmed)
                                    const Text(
                                      'Ride confirmed',
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  if (hasSentProposal && !isConfirmed)
                                    const Text(
                                      'Proposal sent',
                                      style: TextStyle(
                                        color: Colors.orange,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
