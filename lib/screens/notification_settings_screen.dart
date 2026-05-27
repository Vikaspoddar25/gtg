import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gtg/theme/app_colors.dart';

/// Notification settings screen — WhatsApp & Push toggle switches.
/// Matches video frames 70-71.
class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _whatsappEnabled = true;
  bool _pushEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: Column(
            children: [
              // App bar
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go('/settings');
                          }
                        },
                        child: const Icon(Icons.chevron_left, size: 32),
                      ),
                      const Expanded(
                        child: Text(
                          'Settings',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 32),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1, color: AppColors.divider),

              // Toggle items
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      // WhatsApp Messages
                      _ToggleRow(
                        title: 'WhatsApp Messages',
                        subtitle: 'Get updates from us on WhatsApp',
                        value: _whatsappEnabled,
                        activeColor: const Color(0xFF4CAF50),
                        onChanged: (v) =>
                            setState(() => _whatsappEnabled = v),
                      ),
                      const Divider(height: 32, color: AppColors.divider),
                      // Push Notifications
                      _ToggleRow(
                        title: 'Push Notifications',
                        subtitle:
                            'Turn on to get live route updates & offers',
                        value: _pushEnabled,
                        activeColor: AppColors.primary,
                        onChanged: (v) =>
                            setState(() => _pushEnabled = v),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final Color activeColor;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.activeColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: Colors.white,
          activeTrackColor: activeColor,
          inactiveThumbColor: Colors.white,
          inactiveTrackColor: AppColors.primary,
        ),
      ],
    );
  }
}
