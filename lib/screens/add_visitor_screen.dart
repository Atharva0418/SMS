import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../data/models/visitor_model.dart';
import '../providers/visitor_provider.dart';

const _navy = Color(0xFF0D1B2A);
const _navyLight = Color(0xFF243B55);
const _amber = Color(0xFFE8A020);
const _amberLight = Color(0xFFFAC75A);
const _surface = Color(0xFFF4F5F7);
const _cardBg = Color(0xFFFFFFFF);
const _textPrimary = Color(0xFF0D1B2A);
const _textSecondary = Color(0xFF5A6A7A);
const _textMuted = Color(0xFF8FA0B0);
const _border = Color(0xFFE4E8ED);
const _focusBorder = Color(0xFF0D1B2A);
const _errorColor = Color(0xFFB91C1C);

class AddVisitorScreen extends StatefulWidget {
  const AddVisitorScreen({super.key});

  @override
  State<AddVisitorScreen> createState() => _AddVisitorScreenState();
}

class _AddVisitorScreenState extends State<AddVisitorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _flatCtrl = TextEditingController();
  late final DateTime _entryTime;
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _entryTime = DateTime.now();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _flatCtrl.dispose();
    super.dispose();
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour < 12 ? 'AM' : 'PM';
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
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}  ·  $hour:$minute $period';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final visitor = VisitorModel(
      name: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      flatNumber: int.parse(_flatCtrl.text.trim()),
    );

    final success = await context.read<VisitorProvider>().addVisitor(visitor);

    if (!mounted) return;

    if (success) {
      _showSuccessSheet();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.read<VisitorProvider>().errorMessage ??
                'Something went wrong',
          ),
          backgroundColor: _errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  void _showSuccessSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: _border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Color(0xFF15803D),
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Visitor logged',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: _textPrimary,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${_nameCtrl.text.trim()} has been recorded visiting Flat ${_flatCtrl.text.trim()}',
              style: const TextStyle(
                fontSize: 13,
                color: _textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                style: FilledButton.styleFrom(
                  backgroundColor: _navy,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'Done',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _nameCtrl.clear();
                  _phoneCtrl.clear();
                  _flatCtrl.clear();
                  setState(() => _currentStep = 0);
                },
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'Log another visitor',
                  style: TextStyle(
                    fontSize: 15,
                    color: _textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<VisitorProvider>().isLoading;

    return Scaffold(
      backgroundColor: _surface,
      body: CustomScrollView(
        slivers: [
          // ── Hero header — matches home & complaint screens ──────────────
          SliverToBoxAdapter(child: _buildHeroHeader(context)),

          // ── Form body ──────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            sliver: SliverToBoxAdapter(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Entry time chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: _navy.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.access_time_rounded,
                            size: 13,
                            color: _textSecondary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _formatTime(_entryTime),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: _textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Section label
                    const Text(
                      'VISITOR DETAILS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _textMuted,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Visitor name
                    _FieldLabel(label: 'Visitor name'),
                    const SizedBox(height: 8),
                    _StyledField(
                      controller: _nameCtrl,
                      hint: 'e.g. Rahul Mehta',
                      keyboardType: TextInputType.name,
                      textCapitalization: TextCapitalization.words,
                      prefixIcon: Icons.person_outline_rounded,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Name is required';
                        }
                        if (v.trim().length < 2) {
                          return 'Name must be at least 2 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Phone number
                    _FieldLabel(label: 'Phone number'),
                    const SizedBox(height: 8),
                    _StyledField(
                      controller: _phoneCtrl,
                      hint: '10-digit mobile number',
                      keyboardType: TextInputType.phone,
                      prefixIcon: Icons.phone_outlined,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Phone number is required';
                        }
                        if (!RegExp(r'^\d{10}$').hasMatch(v.trim())) {
                          return 'Enter a valid 10-digit number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Flat number
                    _FieldLabel(label: 'Visiting flat'),
                    const SizedBox(height: 8),
                    _StyledField(
                      controller: _flatCtrl,
                      hint: 'e.g. 304',
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.apartment_outlined,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
                    const SizedBox(height: 36),

                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      child: GestureDetector(
                        onTap: isLoading ? null : _submit,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
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
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Log visitor',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.1,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Icon(
                                        Icons.arrow_forward_rounded,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Navy hero header — identical structure to home_screen & complaint_screen
  Widget _buildHeroHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: _navy),
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Positioned.fill(child: _GeometricPattern()),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Back button
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
                  // Title block
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'LOG VISITOR'.toUpperCase(),
                        style: const TextStyle(
                          color: _amber,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'New entry',
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
                  // Icon badge
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
                      Icons.person_add_rounded,
                      color: Colors.white70,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: _textPrimary,
        letterSpacing: -0.1,
      ),
    );
  }
}

class _StyledField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final IconData prefixIcon;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;

  const _StyledField({
    required this.controller,
    required this.hint,
    required this.keyboardType,
    required this.prefixIcon,
    this.validator,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      inputFormatters: inputFormatters,
      validator: validator,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: _textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: _textMuted,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 14, right: 10),
          child: Icon(prefixIcon, color: _textMuted, size: 20),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        filled: true,
        fillColor: _cardBg,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _focusBorder, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _errorColor, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _errorColor, width: 1.5),
        ),
        errorStyle: const TextStyle(fontSize: 12, color: _errorColor),
      ),
    );
  }
}

// ── Geometric pattern (shared across all screens) ─────────────────────────────

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
