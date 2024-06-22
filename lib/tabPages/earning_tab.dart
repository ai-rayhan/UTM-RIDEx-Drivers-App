import 'package:drivers_app/infoHandler/app_info.dart';
import 'package:drivers_app/mainScreens/trips_history_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EarningstabPage extends StatefulWidget {
  const EarningstabPage({Key? key}) : super(key: key);

  @override
  State<EarningstabPage> createState() => _EarningstabPageState();
}

class _EarningstabPageState extends State<EarningstabPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(255, 183, 182, 182),
      child: Column(
        children: [
          //earnings
          Container(
            color: Colors.black,
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 80),
              child: Column(
                children: [
                  const Text(
                    "Your Earnings:",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    "RM " +
                        Provider.of<AppInfo>(context, listen: false)
                            .driverTotalEarnings,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 56,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          //total number trips
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (c) => TripsHistoryScreen()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Row(
                  children: [
                    Image.asset(
                      "images/car_logo.png",
                      width: 100,
                    ),
                    const SizedBox(
                      width: 6,
                    ),
                    const Text(
                      "Trips Completed",
                      style: TextStyle(
                        color: Colors.black54,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        child: Text(
                          Provider.of<AppInfo>(context, listen: false)
                              .allTripsHistoryInformationList
                              .length
                              .toString(),
                          textAlign: TextAlign.end,
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
