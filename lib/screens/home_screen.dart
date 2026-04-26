import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sms/providers/visitor_provider.dart';
import 'add_visitor_screen.dart';
import 'complaint_screen.dart';
import 'visitor_log_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionLabel('Features'),
                    const SizedBox(height: 10),
                    _FeatureGrid(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
      decoration: const BoxDecoration(
        color: Color(0xFF3C3489),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Good ${_greeting()}',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 4),
          const Text(
            'Society Management',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: const [
              Expanded(
                child: _StatCard(value: '12', label: 'Visitors today'),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _StatCard(value: '3', label: 'Open complaints'),
              ),
            ],
          ),

          // Add inside _Header's Column, after the stat row:
          Consumer<VisitorProvider>(
            builder: (context, provider, _) {
              final count = provider.pendingSyncCount;
              if (count == 0) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$count ${count == 1 ? 'entry' : 'entries'} pending sync',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'morning';
    if (hour < 17) return 'afternoon';
    return 'evening';
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  const _StatCard({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: Colors.grey[500],
        letterSpacing: 0.8,
      ),
    );
  }
}

class _FeatureGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final features = [
      _FeatureItem(
        title: 'Visitor entry',
        subtitle: 'Log new visitors',
        iconColor: const Color(0xFF534AB7),
        iconBg: const Color(0xFFEEEDFE),
        icon: Icons.person_add_outlined,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddVisitorScreen()),
        ),
      ),
      _FeatureItem(
        title: 'Complaints',
        subtitle: 'Raise an issue',
        iconColor: const Color(0xFF993C1D),
        iconBg: const Color(0xFFFAECE7),
        icon: Icons.report_outlined,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ComplaintScreen()),
        ),
      ),
      _FeatureItem(
        title: 'Visitor log',
        subtitle: 'View all entries',
        iconColor: const Color(0xFF0F6E56),
        iconBg: const Color(0xFFE1F5EE),
        icon: Icons.list_alt_outlined,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const VisitorLogScreen()),
        ),
      ),
      _FeatureItem(
        title: 'Notices',
        subtitle: 'Society updates',
        iconColor: const Color(0xFF185FA5),
        iconBg: const Color(0xFFE6F1FB),
        icon: Icons.campaign_outlined,
        onTap: () {}, // SMS-6+
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.3,
      children: features.map((f) => _FeatureCard(item: f)).toList(),
    );
  }
}

class _FeatureItem {
  final String title;
  final String subtitle;
  final Color iconColor;
  final Color iconBg;
  final IconData icon;
  final VoidCallback onTap;

  const _FeatureItem({
    required this.title,
    required this.subtitle,
    required this.iconColor,
    required this.iconBg,
    required this.icon,
    required this.onTap,
  });
}

class _FeatureCard extends StatelessWidget {
  final _FeatureItem item;
  const _FeatureCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black.withOpacity(0.07)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: item.iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(item.icon, color: item.iconColor, size: 20),
            ),
            const Spacer(),
            Text(
              item.title,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 2),
            Text(
              item.subtitle,
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}
