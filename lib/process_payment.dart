import 'package:flutter/material.dart';
import 'homepage.dart';

class ProcessPaymentPage extends StatefulWidget {
  const ProcessPaymentPage({super.key});

  @override
  State<ProcessPaymentPage> createState() => _ProcessPaymentPageState();
}

class _ProcessPaymentPageState extends State<ProcessPaymentPage> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          body: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Image(image: AssetImage('assets/waiting.png')),
                const SizedBox(
                  height: 10,
                ),
                const Text(
                  "We are in the process of confirming your payment,\nthank you for your understanding.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const HomePage()),
                  ),
                  child: const Text('Go to Homepage'),
                ),
              ],
            ),
          ),
        ),
        onWillPop: () async {
          // Show a confirmation dialog
          bool shouldClose = await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Confirm'),
                content: const Text('Are you sure you want to exit?'),
                actions: <Widget>[
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('No'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const HomePage()),
                    ),
                    child: const Text('Yes'),
                  ),
                ],
              );
            },
          );
          return shouldClose;
        });
  }
}
