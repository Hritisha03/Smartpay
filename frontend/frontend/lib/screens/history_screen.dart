import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Transaction History"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ListTile(
            leading: Icon(Icons.arrow_upward, color: Colors.red),
            title: Text("Paid ₹500"),
            subtitle: Text("To Rahul"),
            trailing: Text("Success"),
          ),
          Divider(),

          ListTile(
            leading: Icon(Icons.arrow_downward, color: Colors.green),
            title: Text("Received ₹1,000"),
            subtitle: Text("From Amit"),
            trailing: Text("Success"),
          ),
          Divider(),

          ListTile(
            leading: Icon(Icons.arrow_upward, color: Colors.red),
            title: Text("Paid ₹250"),
            subtitle: Text("To Neha"),
            trailing: Text("Success"),
          ),
        ],
      ),
    );
  }
}
