import 'package:flutter/material.dart';
import 'package:my_diabeticapp/providers/connectivity_provider.dart';
import 'package:provider/provider.dart';


class OfflineBanner extends StatelessWidget {
  const OfflineBanner({
    super.key,
    this.showAlways = false,
  });

  final bool showAlways;

  @override
  Widget build(BuildContext context) {
    final connectivityProvider = Provider.of<ConnectivityProvider>(context);
    final isOffline = !connectivityProvider.isOnline;

    if (!isOffline && !showAlways) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      color: isOffline ? Colors.red.shade700 : Colors.green.shade700,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isOffline ? Icons.cloud_off : Icons.cloud_done,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            isOffline
                ? 'You are offline. Some features may be limited.'
                : 'You are back online!',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}