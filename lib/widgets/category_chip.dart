import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../theme/app_theme.dart';

class CategoryChip extends StatelessWidget {
  final HabitCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: isSelected
              ? AppTheme.accentGreen
              : isDark
                  ? AppTheme.bgCardLight
                  : AppTheme.bgCardLightAlt,
          border: Border.all(
            color: isSelected
                ? AppTheme.accentGreen
                : isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.black.withValues(alpha: 0.06),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              category.icon,
              size: 18,
              color: isSelected
                  ? Colors.white
                  : isDark
                      ? AppTheme.textSecondary
                      : AppTheme.textSecondaryLight,
            ),
            const SizedBox(width: 6),
            Text(
              category.label,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : isDark
                        ? AppTheme.textSecondary
                        : AppTheme.textSecondaryLight,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
