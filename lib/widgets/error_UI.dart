import 'package:asgard_task/ProductModule/Data_Layer/product_blocs/product_state.dart';
import 'package:flutter/material.dart';

class ErrorUI extends StatelessWidget {
  final String message;
  final IconData icon;
  final Color color;
  final VoidCallback onRetry;

  const ErrorUI({
    Key? key,
    required this.message,
    required this.icon,
    required this.color,
    required this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use WidgetsBinding to trigger the dialog immediately after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showErrorDialog(context);
    });

    return const SizedBox
        .shrink(); // This widget doesn't need to display anything
  }

  void _showErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Icon(
            icon,
            size: 40,
            color: color,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  onRetry(); // Retry action
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      },
    );
  }
}
