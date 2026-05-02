import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../data/models/complaint_model.dart';
import '../providers/complaint_provider.dart';

// ── Palette (mirrors home_screen.dart) ───────────────────────────────────────
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

// ─────────────────────────────────────────────────────────────────────────────
// Entry point
// ─────────────────────────────────────────────────────────────────────────────

class ComplaintScreen extends StatefulWidget {
  const ComplaintScreen({super.key});

  @override
  State<ComplaintScreen> createState() => _ComplaintScreenState();
}

class _ComplaintScreenState extends State<ComplaintScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
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
      // FIX: use Consumer<ComplaintProvider> instead of ValueListenableBuilder
      // on the raw Hive box. The provider fetches from the server on startup
      // so new devices (or reinstalled apps) always see their real complaints.
      body: Consumer<ComplaintProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final all = provider.complaints;
          final synced = all.where((c) => c.isSynced).toList();
          final pending = all.where((c) => !c.isSynced).toList();

          return CustomScrollView(
            slivers: [
              // ── Hero header ──────────────────────────────────────────────
              SliverToBoxAdapter(
                child: _ComplaintHeader(
                  tabController: _tabController,
                  syncedCount: synced.length,
                  pendingCount: pending.length,
                ),
              ),
              // ── Tab content ──────────────────────────────────────────────
              SliverFillRemaining(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _ComplaintList(
                      complaints: synced,
                      emptyMessage: 'No synced complaints yet.',
                      emptySubtext:
                      'Complaints will appear here once they\nupload to the server.',
                    ),
                    _ComplaintList(
                      complaints: pending,
                      emptyMessage: 'No pending complaints.',
                      emptySubtext:
                      'All complaints have been\nsynced to the server.',
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const _AddComplaintScreen()),
        ),
        backgroundColor: _navy,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'New complaint',
          style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.2),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hero Header
// ─────────────────────────────────────────────────────────────────────────────

class _ComplaintHeader extends StatelessWidget {
  final TabController tabController;
  final int syncedCount;
  final int pendingCount;

  const _ComplaintHeader({
    required this.tabController,
    required this.syncedCount,
    required this.pendingCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: _navy),
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Positioned.fill(child: _GeometricPattern()),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 20, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.09),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.12),
                              width: 1,
                            ),
                          ),
                          child: const Icon(
                            Icons.arrow_back_rounded,
                            color: Colors.white70,
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'COMPLAINTS'.toUpperCase(),
                            style: const TextStyle(
                              color: _amber,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2.0,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Sunrise Heights',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                              height: 1.1,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _navyLight,
                          borderRadius: BorderRadius.circular(11),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.12),
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.report_gmailerrorred_outlined,
                          color: Colors.white70,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                // Stat pills
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      _StatPill(
                        value: '$syncedCount',
                        label: 'Synced',
                        icon: Icons.cloud_done_outlined,
                      ),
                      const SizedBox(width: 10),
                      _StatPill(
                        value: '$pendingCount',
                        label: 'Pending sync',
                        icon: Icons.cloud_off_outlined,
                        highlight: pendingCount > 0,
                      ),
                      const SizedBox(width: 10),
                      _StatPill(
                        value: '${syncedCount + pendingCount}',
                        label: 'Total',
                        icon: Icons.list_alt_rounded,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Tab bar
                TabBar(
                  controller: tabController,
                  indicatorColor: _amber,
                  indicatorWeight: 3,
                  labelColor: Colors.white,
                  unselectedLabelColor: const Color(0xFF5A7A99),
                  labelStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                  dividerColor: Colors.white.withOpacity(0.08),
                  tabs: const [
                    Tab(text: 'Synced'),
                    Tab(text: 'Pending'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Reused stat pill ──────────────────────────────────────────────────────────

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

// ── Geometric Pattern ─────────────────────────────────────────────────────────

class _GeometricPattern extends StatelessWidget {
  @override
  Widget build(BuildContext context) => CustomPaint(painter: _PatternPainter());
}

class _PatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    canvas.drawCircle(Offset(size.width + 20, -10), 120, paint);
    canvas.drawCircle(Offset(size.width + 20, -10), 80, paint);

    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

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

// ─────────────────────────────────────────────────────────────────────────────
// List
// ─────────────────────────────────────────────────────────────────────────────

class _ComplaintList extends StatelessWidget {
  final List<ComplaintModel> complaints;
  final String emptyMessage;
  final String emptySubtext;

  const _ComplaintList({
    required this.complaints,
    required this.emptyMessage,
    required this.emptySubtext,
  });

  @override
  Widget build(BuildContext context) {
    if (complaints.isEmpty) {
      return _EmptyState(message: emptyMessage, subtext: emptySubtext);
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      itemCount: complaints.length,
      itemBuilder: (context, index) =>
          _ComplaintCard(complaint: complaints[index]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Card
// ─────────────────────────────────────────────────────────────────────────────

class _ComplaintCard extends StatelessWidget {
  final ComplaintModel complaint;

  const _ComplaintCard({required this.complaint});

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour < 12 ? 'AM' : 'PM';
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}  $hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final isSynced = complaint.isSynced;
    final statusColor = _statusColor(complaint.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSynced ? _divider : _amber.withOpacity(0.40),
          width: isSynced ? 1 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: _navy.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: _navy.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Flat ${complaint.flatNumber}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _navy,
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    complaint.status,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(height: 0.5, color: _divider),
            const SizedBox(height: 10),
            Text(
              complaint.description,
              style: const TextStyle(
                fontSize: 13,
                height: 1.5,
                color: _textPrimary,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  isSynced
                      ? Icons.cloud_done_outlined
                      : Icons.cloud_off_outlined,
                  size: 13,
                  color: isSynced ? _textMuted : _amber,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDate(complaint.createdAt),
                  style: const TextStyle(fontSize: 11, color: _textMuted),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'OPEN':
        return const Color(0xFFB94A2C);
      case 'IN_PROGRESS':
        return const Color(0xFF185FA5);
      case 'RESOLVED':
        return const Color(0xFF0F6E56);
      default:
        return _textMuted;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty state
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final String message;
  final String subtext;

  const _EmptyState({required this.message, required this.subtext});

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
              child: const Icon(
                Icons.report_off_outlined,
                size: 30,
                color: _textMuted,
              ),
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
              style: const TextStyle(fontSize: 12, color: _textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Add complaint form (unchanged logic, kept inline)
// ─────────────────────────────────────────────────────────────────────────────

class _AddComplaintScreen extends StatefulWidget {
  const _AddComplaintScreen();

  @override
  State<_AddComplaintScreen> createState() => _AddComplaintScreenState();
}

class _AddComplaintScreenState extends State<_AddComplaintScreen> {
  final _formKey = GlobalKey<FormState>();
  final _flatCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  @override
  void dispose() {
    _flatCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final complaint = ComplaintModel(
      flatNumber: int.parse(_flatCtrl.text.trim()),
      description: _descCtrl.text.trim(),
    );

    final success = await context.read<ComplaintProvider>().addComplaint(
      complaint,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Complaint submitted'),
          backgroundColor: const Color(0xFF0F6E56),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.read<ComplaintProvider>().errorMessage ??
                'Something went wrong',
          ),
          backgroundColor: const Color(0xFFB94A2C),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<ComplaintProvider>().isLoading;

    return Scaffold(
      backgroundColor: _surface,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(color: _navy),
              child: SafeArea(
                bottom: false,
                child: Stack(
                  children: [
                    Positioned.fill(child: _GeometricPattern()),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.09),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.12),
                                  width: 1,
                                ),
                              ),
                              child: const Icon(
                                Icons.arrow_back_rounded,
                                color: Colors.white70,
                                size: 18,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'NEW COMPLAINT'.toUpperCase(),
                                style: const TextStyle(
                                  color: _amber,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 2.0,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Report an issue',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverToBoxAdapter(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DETAILS'.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _textMuted,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _NavyTextField(
                      controller: _flatCtrl,
                      label: 'Flat number',
                      icon: Icons.home_outlined,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Flat number is required';
                        }
                        if (int.tryParse(v.trim()) == null) {
                          return 'Enter a valid flat number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    _NavyTextField(
                      controller: _descCtrl,
                      label: 'Description',
                      icon: Icons.notes_rounded,
                      maxLines: 5,
                      keyboardType: TextInputType.multiline,
                      textCapitalization: TextCapitalization.sentences,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Description is required';
                        }
                        if (v.trim().length < 10) {
                          return 'Please provide more detail (at least 10 characters)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      child: GestureDetector(
                        onTap: isLoading ? null : _submit,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          decoration: BoxDecoration(
                            color: isLoading ? _navyLight : _navy,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: _navy.withOpacity(0.35),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Center(
                            child: isLoading
                                ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                                : const Text(
                              'Submit complaint',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared themed text field ───────────────────────────────────────────────────

class _NavyTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final int maxLines;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final String? Function(String?)? validator;

  const _NavyTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      validator: validator,
      style: const TextStyle(
        fontSize: 14,
        color: _textPrimary,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: _textSecondary, fontSize: 13),
        prefixIcon: Icon(icon, color: _textMuted, size: 20),
        filled: true,
        fillColor: _cardBg,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _divider, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _navy, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFB94A2C), width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFB94A2C), width: 1.5),
        ),
      ),
    );
  }
}