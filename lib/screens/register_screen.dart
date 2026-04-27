import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

const _navy = Color(0xFF0D1B2A);
const _amber = Color(0xFFE8A020);
const _surface = Color(0xFFF4F5F7);
const _cardBg = Color(0xFFFFFFFF);
const _textPri = Color(0xFF0D1B2A);
const _textSec = Color(0xFF5A6A7A);
const _textMuted = Color(0xFF8FA0B0);
const _border = Color(0xFFE4E8ED);
const _error = Color(0xFFB91C1C);

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _flatCtrl = TextEditingController();
  String _role = 'RESIDENT';
  bool _obscure = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _flatCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await context.read<AuthProvider>().register(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
      role: _role,
      flatNumber: _role == 'RESIDENT' && _flatCtrl.text.isNotEmpty
          ? int.tryParse(_flatCtrl.text.trim())
          : null,
    );

    if (context.mounted) {
      Navigator.popUntil(context, (route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: _surface,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              color: _navy,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(28, 20, 28, 32),
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
                          ),
                          child: const Icon(
                            Icons.arrow_back_rounded,
                            color: Colors.white70,
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CREATE ACCOUNT',
                            style: TextStyle(
                              color: _amber,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Register',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverToBoxAdapter(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (auth.errorMessage != null) ...[
                      _ErrorBanner(message: auth.errorMessage!),
                      const SizedBox(height: 16),
                    ],

                    _Label('Full name'),
                    const SizedBox(height: 8),
                    _Field(
                      controller: _nameCtrl,
                      hint: 'e.g. Rahul Mehta',
                      icon: Icons.person_outline_rounded,
                      textCapitalization: TextCapitalization.words,
                      validator: (v) => (v == null || v.trim().length < 2)
                          ? 'Name is required'
                          : null,
                    ),

                    const SizedBox(height: 16),
                    _Label('Email'),
                    const SizedBox(height: 8),
                    _Field(
                      controller: _emailCtrl,
                      hint: 'you@example.com',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => (v == null || !v.contains('@'))
                          ? 'Enter a valid email'
                          : null,
                    ),

                    const SizedBox(height: 16),
                    _Label('Password'),
                    const SizedBox(height: 8),
                    _Field(
                      controller: _passCtrl,
                      hint: 'Min. 6 characters',
                      icon: Icons.lock_outline_rounded,
                      obscure: _obscure,
                      suffix: IconButton(
                        icon: Icon(
                          _obscure
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: _textMuted,
                          size: 20,
                        ),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                      validator: (v) => (v == null || v.length < 6)
                          ? 'At least 6 characters'
                          : null,
                    ),

                    const SizedBox(height: 16),
                    _Label('Role'),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: _cardBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _border),
                      ),
                      child: DropdownButtonFormField<String>(
                        value: _role,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          border: InputBorder.none,
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'RESIDENT',
                            child: Text('Resident'),
                          ),
                          DropdownMenuItem(
                            value: 'STAFF',
                            child: Text('Staff'),
                          ),
                        ],
                        onChanged: (v) => setState(() => _role = v!),
                      ),
                    ),

                    if (_role == 'RESIDENT') ...[
                      const SizedBox(height: 16),
                      _Label('Flat number'),
                      const SizedBox(height: 8),
                      _Field(
                        controller: _flatCtrl,
                        hint: 'e.g. 304',
                        icon: Icons.apartment_outlined,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Flat number is required for residents'
                            : null,
                      ),
                    ],

                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: auth.isLoading ? null : _submit,
                        style: FilledButton.styleFrom(
                          backgroundColor: _navy,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13),
                          ),
                        ),
                        child: auth.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Create account',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
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

class _Label extends StatelessWidget {
  final String label;
  const _Label(this.label);
  @override
  Widget build(BuildContext context) => Text(
    label,
    style: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: _textPri,
    ),
  );
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final bool obscure;
  final Widget? suffix;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  const _Field({
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,
    this.obscure = false,
    this.suffix,
    this.inputFormatters,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      obscureText: obscure,
      inputFormatters: inputFormatters,
      validator: validator,
      style: const TextStyle(
        fontSize: 15,
        color: _textPri,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: _textMuted, fontSize: 14),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 14, right: 10),
          child: Icon(icon, color: _textMuted, size: 20),
        ),
        prefixIconConstraints: const BoxConstraints(),
        suffixIcon: suffix,
        filled: true,
        fillColor: _cardBg,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: _ob(const BorderSide(color: _border)),
        enabledBorder: _ob(const BorderSide(color: _border)),
        focusedBorder: _ob(const BorderSide(color: _navy, width: 1.5)),
        errorBorder: _ob(const BorderSide(color: _error)),
        focusedErrorBorder: _ob(const BorderSide(color: _error, width: 1.5)),
      ),
    );
  }

  OutlineInputBorder _ob(BorderSide s) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: s,
  );
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: _error.withOpacity(0.08),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: _error.withOpacity(0.3)),
    ),
    child: Row(
      children: [
        const Icon(Icons.error_outline, color: _error, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            message,
            style: const TextStyle(color: _error, fontSize: 13),
          ),
        ),
      ],
    ),
  );
}
