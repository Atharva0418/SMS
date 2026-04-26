import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../core/local/hive_service.dart';
import '../data/models/visitor_model.dart';

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
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3C3489),
        foregroundColor: Colors.white,
        title: const Text(
          'Visitor log',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
          tabs: const [
            Tab(text: 'Synced'),
            Tab(text: 'Pending'),
          ],
        ),
      ),
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
                emptyMessage: 'No synced entries yet.',
                emptySubtext:
                    'Entries will appear here once they\nupload to the server.',
                isSynced: true,
              ),
              _VisitorList(
                visitors: pending,
                emptyMessage: 'No pending entries.',
                emptySubtext:
                    'All visitor entries have been\nsynced to the server.',
                isSynced: false,
              ),
            ],
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// List
// ---------------------------------------------------------------------------

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
      return _EmptyState(message: emptyMessage, subtext: emptySubtext);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: visitors.length,
      itemBuilder: (context, index) =>
          _VisitorCard(visitor: visitors[index], isSynced: isSynced),
    );
  }
}

// ---------------------------------------------------------------------------
// Card
// ---------------------------------------------------------------------------

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
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSynced
              ? Colors.black.withOpacity(0.07)
              : const Color(0xFFE8A800).withOpacity(0.5),
          width: isSynced ? 1 : 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: isSynced
                    ? const Color(0xFFEEEDFE)
                    : const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(21),
              ),
              child: Center(
                child: Text(
                  initials,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSynced
                        ? const Color(0xFF534AB7)
                        : const Color(0xFF8A6000),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Name + flat + date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    visitor.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Flat ${visitor.flatNumber}  ·  ${visitor.phone}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_formatDate(visitor.createdAt)}  ·  ${_formatTime(visitor.createdAt)}',
                    style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Sync status badge
            _SyncBadge(isSynced: isSynced),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sync badge
// ---------------------------------------------------------------------------

class _SyncBadge extends StatelessWidget {
  final bool isSynced;
  const _SyncBadge({required this.isSynced});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: isSynced ? const Color(0xFFE1F5EE) : const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSynced ? Icons.cloud_done_outlined : Icons.cloud_off_outlined,
            size: 12,
            color: isSynced ? const Color(0xFF0F6E56) : const Color(0xFF8A6000),
          ),
          const SizedBox(width: 4),
          Text(
            isSynced ? 'Synced' : 'Pending',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isSynced
                  ? const Color(0xFF0F6E56)
                  : const Color(0xFF8A6000),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  final String message;
  final String subtext;
  const _EmptyState({required this.message, required this.subtext});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.list_alt_outlined, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Color(0xFF555555),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtext,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }
}
