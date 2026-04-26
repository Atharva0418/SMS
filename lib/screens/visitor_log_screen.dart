import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../core/local/hive_service.dart';
import '../data/models/visitor_model.dart';

// ── Palette (shared with home / add-visitor) ──────────────────────────────────
const _navy = Color(0xFF0D1B2A);
const _surface = Color(0xFFF4F5F7);
const _cardBg = Color(0xFFFFFFFF);
const _textPrimary = Color(0xFF0D1B2A);
const _textSecondary = Color(0xFF5A6A7A);
const _textMuted = Color(0xFF8FA0B0);
const _divider = Color(0xFFE4E8ED);
const _amber = Color(0xFFE8A020);
const _amberLight = Color(0xFFFAC75A);
const _amberBg = Color(0xFFFFF7ED);
const _greenBg = Color(0xFFF0FDF4);
const _greenText = Color(0xFF15803D);
const _navyBg = Color(0xFFEEF2FF);
const _navyText = Color(0xFF3730A3);

class VisitorLogScreen extends StatefulWidget {
  const VisitorLogScreen({super.key});

  @override
  State<VisitorLogScreen> createState() => _VisitorLogScreenState();
}

class _VisitorLogScreenState extends State<VisitorLogScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverAppBar(
            pinned: true,
            expandedHeight: 110,
            backgroundColor: _navy,
            surfaceTintColor: Colors.transparent,
            systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.light,
            ),
            leading: IconButton(
              icon: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(20, 0, 20, 56),
              title: const Text(
                'Visitor log',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              background: Container(
                color: _navy,
                child: CustomPaint(painter: _NavyPatternPainter()),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(44),
              child: Container(
                color: _navy,
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: _amber,
                  indicatorWeight: 2.5,
                  indicatorSize: TabBarIndicatorSize.label,
                  labelColor: Colors.white,
                  unselectedLabelColor: const Color(0xFF7A9AB8),
                  labelStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                  tabs: const [
                    Tab(text: 'Synced'),
                    Tab(text: 'Pending'),
                  ],
                ),
              ),
            ),
          ),
        ],
        body: ValueListenableBuilder(
          valueListenable: HiveService.visitorBox.listenable(),
          builder: (context, box, _) {
            final all = box.values.toList()
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

            final synced = all.where((v) => v.isSynced).toList();
            final pending = all.where((v) => !v.isSynced).toList();

            return TabBarView(
              controller: _tabController,
              children: [
                _VisitorList(
                  visitors: synced,
                  emptyMessage: 'No synced entries yet',
                  emptySubtext:
                      'Entries will appear here once they\nupload to the server.',
                  isSynced: true,
                ),
                _VisitorList(
                  visitors: pending,
                  emptyMessage: 'No pending entries',
                  emptySubtext:
                      'All visitor entries have been\nsynced to the server.',
                  isSynced: false,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ── List ──────────────────────────────────────────────────────────────────────

class _VisitorList extends StatelessWidget {
  final List<VisitorModel> visitors;
  final String emptyMessage;
  final String emptySubtext;
  final bool isSynced;

  const _VisitorList({
    required this.visitors,
    required this.emptyMessage,
    required this.emptySubtext,
    required this.isSynced,
  });

  @override
  Widget build(BuildContext context) {
    if (visitors.isEmpty) {
      return _EmptyState(
        message: emptyMessage,
        subtext: emptySubtext,
        icon: isSynced ? Icons.cloud_done_outlined : Icons.cloud_off_outlined,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: visitors.length,
      itemBuilder: (context, index) =>
          _VisitorCard(visitor: visitors[index], isSynced: isSynced),
    );
  }
}

// ── Card ──────────────────────────────────────────────────────────────────────

class _VisitorCard extends StatelessWidget {
  final VisitorModel visitor;
  final bool isSynced;

  const _VisitorCard({required this.visitor, required this.isSynced});

  String _formatTime(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  String _initials(String name) {
    return name
        .trim()
        .split(' ')
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w[0].toUpperCase())
        .join();
  }

  @override
  Widget build(BuildContext context) {
    final initials = _initials(visitor.name);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSynced ? _divider : _amber.withOpacity(0.45),
          width: isSynced ? 1 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSynced ? _navyBg : _amberBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  initials,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isSynced ? _navyText : const Color(0xFFC2410C),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    visitor.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _textPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      _MiniChip(
                        label: 'Flat ${visitor.flatNumber}',
                        color: _navy,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        visitor.phone,
                        style: const TextStyle(
                          fontSize: 11,
                          color: _textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_formatDate(visitor.createdAt)}  ·  ${_formatTime(visitor.createdAt)}',
                    style: const TextStyle(fontSize: 11, color: _textMuted),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),
            _SyncBadge(isSynced: isSynced),
          ],
        ),
      ),
    );
  }
}

// ── Sync badge ────────────────────────────────────────────────────────────────

class _SyncBadge extends StatelessWidget {
  final bool isSynced;
  const _SyncBadge({required this.isSynced});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isSynced ? _greenBg : _amberBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSynced ? Icons.cloud_done_outlined : Icons.cloud_off_outlined,
            size: 12,
            color: isSynced ? _greenText : const Color(0xFFC2410C),
          ),
          const SizedBox(width: 4),
          Text(
            isSynced ? 'Synced' : 'Pending',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isSynced ? _greenText : const Color(0xFFC2410C),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Mini chip ─────────────────────────────────────────────────────────────────

class _MiniChip extends StatelessWidget {
  final String label;
  final Color color;
  const _MiniChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(5),
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

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final String message;
  final String subtext;
  final IconData icon;
  const _EmptyState({
    required this.message,
    required this.subtext,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: _navy.withOpacity(0.06),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, size: 30, color: _textMuted),
            ),
            const SizedBox(height: 18),
            Text(
              message,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: _textPrimary,
                letterSpacing: -0.2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              subtext,
              style: const TextStyle(
                fontSize: 13,
                color: _textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Header pattern painter ────────────────────────────────────────────────────

class _NavyPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    final accentPaint = Paint()
      ..color = _amber.withOpacity(0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawLine(
      Offset(size.width * 0.6, 0),
      Offset(size.width, size.height * 0.9),
      accentPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
