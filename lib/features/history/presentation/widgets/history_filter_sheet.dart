import 'package:flutter/material.dart';

class HistoryFilterSheet extends StatelessWidget {
  final bool isTamil;
  final String selectedFilter;
  final ValueChanged<String> onFilterSelected;

  const HistoryFilterSheet({
    super.key,
    required this.isTamil,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  static void show(
    BuildContext context, {
    required bool isTamil,
    required String selectedFilter,
    required ValueChanged<String> onFilterSelected,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      backgroundColor: Colors.white,
      builder: (context) => HistoryFilterSheet(
        isTamil: isTamil,
        selectedFilter: selectedFilter,
        onFilterSelected: onFilterSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filters = [
      {'key': 'ALL', 'label': isTamil ? 'அனைத்தும்' : 'All Complaints'},
      {'key': 'PENDING', 'label': isTamil ? 'பரிசீலனையில்' : 'Pending'},
      {
        'key': 'ACTION TAKEN',
        'label': isTamil ? 'நடவடிக்கை எடுக்கப்பட்டது' : 'Action Taken'
      },
      {'key': 'RESOLVED', 'label': isTamil ? 'தீர்வு காணப்பட்டது' : 'Resolved'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isTamil ? 'நிலையின்படி வடிகட்டவும்' : 'Filter by Status',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C0000),
            ),
          ),
          const SizedBox(height: 16),
          Column(
            children: filters.map((item) {
              final key = item['key'] as String;
              final label = item['label'] as String;
              final isSelected = selectedFilter == key;

              return ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                tileColor: isSelected
                    ? const Color(0xFF750000).withValues(alpha: 0.08)
                    : Colors.transparent,
                title: Text(
                  label,
                  style: TextStyle(
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected
                        ? const Color(0xFF750000)
                        : const Color(0xFF2C0000),
                  ),
                ),
                trailing: isSelected
                    ? const Icon(
                        Icons.check_circle_rounded,
                        color: Color(0xFF750000),
                      )
                    : null,
                onTap: () {
                  onFilterSelected(key);
                  Navigator.of(context).pop();
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
