import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_diabeticapp/models/test_result.dart';

class HistoryCard extends StatelessWidget {
  final TestResult result;
  final VoidCallback? onTap;

  const HistoryCard({
    super.key,
    required this.result,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _buildStatusIcon(),
              const SizedBox(width: 16),
              _buildDateInfo(),
              _buildValueInfo(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIcon() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: result.isNormal == true
            ? Colors.green.withOpacity(0.1) 
            : Colors.orange.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        result.isNormal == true ? Icons.check_circle : Icons.warning,
        color: result.isNormal == true ? Colors.green : Colors.orange,
      ),
    );
  }

  Widget _buildDateInfo() {
    final timestamp = result.timestamp;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            timestamp != null ? DateFormat('EEEE, MMM dd').format(timestamp) : '-',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            timestamp != null ? DateFormat('h:mm a').format(timestamp) : '',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValueInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '${result.sugarLevel.toStringAsFixed(1)} mg/dL',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          result.isNormal == true ? 'Normal' : 'High',
          style: TextStyle(
            color: result.isNormal == true ? Colors.green : Colors.orange,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}