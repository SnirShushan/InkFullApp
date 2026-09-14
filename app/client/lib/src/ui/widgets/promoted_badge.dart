import 'package:flutter/material.dart';
import 'package:ink/src/utils/colors.dart';

class PromotedBadge extends StatelessWidget {
  const PromotedBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: promotedBadgeColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'מקודם',
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

bool isPromotedFlag(String? value) =>
    value == '1' || value == 'true';
