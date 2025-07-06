import 'package:flutter/material.dart';
import 'dart:async';

class NetworkStatusWidget extends StatefulWidget {
  const NetworkStatusWidget({Key? key}) : super(key: key);

  @override
  State<NetworkStatusWidget> createState() => _NetworkStatusWidgetState();
}

class _NetworkStatusWidgetState extends State<NetworkStatusWidget> {
  bool _isOnline = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _checkConnection();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _checkConnection());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _checkConnection() {
    // In a real app, you would check actual network connectivity
    // For now, we'll just simulate it
    setState(() {
      _isOnline = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isOnline) {
      return const SizedBox.shrink();
    }

    return Container(
      color: Colors.red,
      padding: const EdgeInsets.all(8),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off, color: Colors.white, size: 16),
          SizedBox(width: 8),
          Text(
            'Aucune connexion internet',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}