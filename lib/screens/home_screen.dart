import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sms/providers/visitor_provider.dart';
import 'add_visitor_screen.dart';
import 'complaint_screen.dart';
import 'visitor_log_screen.dart';

// ── Palette ───────────────────────────────────────────────────────────────────
const _navy = Color(0xFF0D1B2A);
const _navyMid = Color(0xFF1A2E42);
const _navyLight = Color(0xFF243B55);
const _amber = Color(0xFFE8A020);
const _amberLight = Color(0xFFFAC75A);
const _surface = Color(0xFFF4F5F7);
const _cardBg = Color(0xFFFFFFFF);
const _textPrimary = Color(0xFF0D1B2A);
const _textSecondary = Color(0xFF5A6A7A);
const _textMuted = Color(0xFF8FA0B0);
const _divider = Color(0xFFE4E8ED);

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: _surface,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _HeroHeader()),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
            sliver: SliverToBoxAdapter(child: _QuickActions()),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
            sliver: SliverToBoxAdapter(child: _ActivitySection()),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 36)),
        ],
      ),
    );
  }
}

// ── Hero Header ───────────────────────────────────────────────────────────────

class _HeroHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: _navy),
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // Geometric background pattern
            Positioned.fill(child: _GeometricPattern()),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _greeting().toUpperCase(),
                            style: const TextStyle(
                              color: _amber,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2.0,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Sunrise Heights',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                              height: 1.1,
                            ),
                          ),
                          const Text(
                            'Society Management',
                            style: TextStyle(
                              color: Color(0xFF7A9AB8),
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                      // Avatar / notification area
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: _navyLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.12),
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.person_outline_rounded,
                          color: Colors.white70,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Stat strip
                  Row(
                    children: [
                      _StatPill(
                        value: '12',
                        label: 'Today\'s visitors',
                        icon: Icons.people_outline_rounded,
                      ),
                      const SizedBox(width: 10),
                      _StatPill(
                        value: '3',
                        label: 'Open complaints',
                        icon: Icons.report_gmailerrorred_outlined,
                        highlight: true,
                      ),
                      const SizedBox(width: 10),
                      _StatPill(
                        value: '1',
                        label: 'Notice',
                        icon: Icons.campaign_outlined,
                      ),
                    ],
                  ),
                  // Pending sync indicator
                  Consumer<VisitorProvider>(
                    builder: (context, provider, _) {
                      final count = provider.pendingSyncCount;
                      if (count == 0) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: _amber.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _amber.withOpacity(0.3),
                              width: 0.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 11,
                                height: 11,
                                child: CircularProgressIndicator(
                                  strokeWidth: 1.5,
                                  color: _amberLight,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '$count ${count == 1 ? 'entry' : 'entries'} pending sync',
                                style: const TextStyle(
                                  color: _amberLight,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }
}

class _StatPill extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final bool highlight;

  const _StatPill({
    required this.value,
    required this.label,
    required this.icon,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: highlight
              ? _amber.withOpacity(0.12)
              : Colors.white.withOpacity(0.07),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: highlight
                ? _amber.withOpacity(0.35)
                : Colors.white.withOpacity(0.10),
            width: 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 15,
              color: highlight ? _amberLight : const Color(0xFF7A9AB8),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                color: highlight ? _amberLight : Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                height: 1.0,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF5A7A99),
                fontSize: 10,
                fontWeight: FontWeight.w400,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Geometric Pattern (SVG-like using CustomPainter) ─────────────────────────

class _GeometricPattern extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _PatternPainter());
  }
}

class _PatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    // Large circle top-right
    canvas.drawCircle(Offset(size.width + 20, -10), 120, paint);
    canvas.drawCircle(Offset(size.width + 20, -10), 80, paint);

    // Grid lines — vertical
    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Diagonal accent line
    final accentPaint = Paint()
      ..color = _amber.withOpacity(0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawLine(
      Offset(size.width * 0.55, 0),
      Offset(size.width * 0.8, size.height),
      accentPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Quick Actions ─────────────────────────────────────────────────────────────

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(title: 'Quick actions'),
        const SizedBox(height: 14),
        Row(
          children: [
            _PrimaryActionCard(
              label: 'Log visitor',
              sublabel: 'Add entry',
              icon: Icons.person_add_rounded,
              color: _navy,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddVisitorScreen()),
              ),
            ),
            const SizedBox(width: 12),
            _PrimaryActionCard(
              label: 'Raise complaint',
              sublabel: 'New issue',
              icon: Icons.report_rounded,
              color: const Color(0xFF7B2D14),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ComplaintScreen()),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PrimaryActionCard extends StatelessWidget {
  final String label;
  final String sublabel;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _PrimaryActionCard({
    required this.label,
    required this.sublabel,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.30),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const SizedBox(height: 16),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                sublabel,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.55),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Activity / Browse Section ─────────────────────────────────────────────────

class _ActivitySection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(title: 'Browse'),
        const SizedBox(height: 14),
        _BrowseRow(
          icon: Icons.list_alt_rounded,
          iconBg: const Color(0xFFEEF2FF),
          iconColor: const Color(0xFF3730A3),
          title: 'Visitor log',
          subtitle: 'View & search all entries',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const VisitorLogScreen()),
          ),
        ),
        const _RowDivider(),
        _BrowseRow(
          icon: Icons.campaign_rounded,
          iconBg: const Color(0xFFFFF7ED),
          iconColor: const Color(0xFFC2410C),
          title: 'Notices',
          subtitle: 'Society announcements',
          trailing: _Badge(label: '1 new', color: const Color(0xFFC2410C)),
          onTap: () {},
        ),
        const _RowDivider(),
        _BrowseRow(
          icon: Icons.bar_chart_rounded,
          iconBg: const Color(0xFFF0FDF4),
          iconColor: const Color(0xFF15803D),
          title: 'Reports',
          subtitle: 'Monthly summaries',
          trailing: _Badge(label: 'Soon', color: _textMuted),
          onTap: () {},
        ),
      ],
    );
  }
}

class _BrowseRow extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback onTap;

  const _BrowseRow({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 13),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _textPrimary,
                      letterSpacing: -0.1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: _textSecondary),
                  ),
                ],
              ),
            ),
            if (trailing != null) ...[trailing!, const SizedBox(width: 8)],
            const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: _textMuted,
            ),
          ],
        ),
      ),
    );
  }
}

class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 0,
      thickness: 0.5,
      color: _divider,
      indent: 58,
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

// ── Shared widgets ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: _textMuted,
        letterSpacing: 1.2,
      ),
    );
  }
}
