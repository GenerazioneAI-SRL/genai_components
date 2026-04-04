import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/cl_theme_provider.dart';

/// A card widget with icon, title, subtitle and optional accent color border.
///
/// The accent color renders as a 2px top border strip when provided.
///
/// ```dart
/// CLCard(
///   title: 'Courses',
///   subtitle: '12 active',
///   icon: FontAwesomeIcons.bookOpen,
///   color: Colors.blue,
///   onTap: () {},
/// )
/// ```
class CLCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final Color? accentColor;

  const CLCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.onTap,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = CLThemeProvider.of(context);

    final cardContent = GestureDetector(
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(theme.radiusLg),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F2E2E38),
              blurRadius: 16,
              offset: Offset(0, 4),
              spreadRadius: -4,
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(theme.lg),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(theme.md),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(theme.radiusMd),
                  color: color,
                ),
                child: FaIcon(
                  icon,
                  color: Colors.white,
                  size: theme.xl,
                ),
              ),
              SizedBox(width: theme.md),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.heading5,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      subtitle,
                      style: theme.bodyLabel,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (accentColor == null) return cardContent;

    return ClipRRect(
      borderRadius: BorderRadius.circular(theme.radiusLg),
      child: Stack(
        children: [
          cardContent,
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 2,
              color: accentColor,
            ),
          ),
        ],
      ),
    );
  }
}
