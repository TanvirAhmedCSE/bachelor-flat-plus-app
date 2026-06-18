import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../app/theme.dart';

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
  final _flatNameCtrl = TextEditingController();
  final _flatCodeCtrl = TextEditingController();

  bool _loading = false;
  bool _obscure = true;
  bool _isCreating = true;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _flatNameCtrl.dispose();
    _flatCodeCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    String? error;
    if (_isCreating) {
      error = await AuthService.registerAndCreateFlat(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text.trim(),
        name: _nameCtrl.text.trim(),
        flatName: _flatNameCtrl.text.trim(),
      );
    } else {
      error = await AuthService.registerAndJoinFlat(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text.trim(),
        name: _nameCtrl.text.trim(),
        flatCode: _flatCodeCtrl.text.trim(),
      );
    }

    if (mounted) setState(() => _loading = false);

    if (error != null) {
      setState(() => _error = _parseError(error!));
    } else {
      if (mounted) Navigator.pushReplacementNamed(context, '/verify-email');
    }
  }

  String _parseError(String e) {
    if (e.contains('email-already-in-use'))
      return 'This email is already registered.';
    if (e.contains('weak-password'))
      return 'Password must be at least 6 characters.';
    if (e.contains('Flat not found'))
      return 'Flat not found! Check your Flat Code.';
    return 'Registration failed. Please try again.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            //  top bar
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 20,
                      color: AppColors.textPrimary,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 4, 24, 32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // header
                      const Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Manage your flat with your roommates.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 32),

                      //  toggle
                      _buildToggle(),
                      const SizedBox(height: 32),

                      //  personal info
                      _SectionLabel(label: 'Personal Info'),
                      const SizedBox(height: 16),

                      _buildField(
                        controller: _nameCtrl,
                        label: 'Full Name',
                        hint: 'Your full name',
                        icon: Icons.person_outline,
                        action: TextInputAction.next,
                        capitalize: TextCapitalization.words,
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Enter your name'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      _buildField(
                        controller: _emailCtrl,
                        label: 'Email Address',
                        hint: 'you@example.com',
                        icon: Icons.email_outlined,
                        action: TextInputAction.next,
                        keyboard: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Enter your email';
                          if (!v.contains('@')) return 'Enter a valid email';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // password field
                      _FieldLabel(label: 'Password'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _passCtrl,
                        obscureText: _obscure,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _submit(),
                        decoration: InputDecoration(
                          hintText: 'Min. 6 characters',
                          prefixIcon: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            child: Icon(
                              Icons.lock_outline,
                              size: 20,
                              color: AppColors.textHint,
                            ),
                          ),
                          prefixIconConstraints: const BoxConstraints(
                            minWidth: 0,
                            minHeight: 0,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscure
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              size: 20,
                              color: AppColors.textHint,
                            ),
                            onPressed: () =>
                                setState(() => _obscure = !_obscure),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Enter a password';
                          if (v.length < 6) return 'At least 6 characters';
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),

                      //  flat section
                      _SectionLabel(
                        label: _isCreating ? 'Flat Details' : 'Flat Code',
                      ),
                      const SizedBox(height: 16),
                      _buildFlatField(),
                      const SizedBox(height: 32),

                      //  error
                      if (_error != null) ...[
                        _buildError(),
                        const SizedBox(height: 20),
                      ],

                      //  submit
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: _loading
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : Text(
                                  _isCreating
                                      ? 'Create Flat & Register'
                                      : 'Join Flat & Register',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: 0.2,
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
      ),
    );
  }

  //  reusable field builder
  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required FormFieldValidator<String> validator,
    TextInputAction action = TextInputAction.next,
    TextInputType keyboard = TextInputType.text,
    TextCapitalization capitalize = TextCapitalization.none,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label: label),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboard,
          textInputAction: action,
          textCapitalization: capitalize,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Icon(icon, size: 20, color: AppColors.textHint),
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 0,
              minHeight: 0,
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildToggle() {
    return Row(
      children: [
        _ToggleCard(
          icon: Icons.add_home_rounded,
          title: 'নতুন Flat',
          subtitle: 'তৈরি করব',
          selected: _isCreating,
          color: AppColors.primary,
          onTap: () => setState(() => _isCreating = true),
        ),
        const SizedBox(width: 12),
        _ToggleCard(
          icon: Icons.login_rounded,
          title: 'Flat-এ',
          subtitle: 'Join করব',
          selected: !_isCreating,
          color: AppColors.accent,
          onTap: () => setState(() => _isCreating = false),
        ),
      ],
    );
  }

  Widget _buildFlatField() {
    if (_isCreating) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildField(
            controller: _flatNameCtrl,
            label: 'Flat এর নাম',
            hint: 'যেমন: Green Villa Flat',
            icon: Icons.home_outlined,
            capitalize: TextCapitalization.words,
            validator: (v) => _isCreating && (v == null || v.trim().isEmpty)
                ? 'Enter flat name'
                : null,
          ),
          const SizedBox(height: 12),
          _buildInfoBanner(
            icon: Icons.info_outline_rounded,
            color: AppColors.primaryFaint,
            iconColor: AppColors.primary,
            text:
                'Register করলে একটা Flat Code পাবে। সেটা বন্ধুদের দিলে তারা Join করতে পারবে।',
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildField(
            controller: _flatCodeCtrl,
            label: 'Flat Code',
            hint: 'যেমন: FLAT-A3X9',
            icon: Icons.vpn_key_outlined,
            capitalize: TextCapitalization.characters,
            validator: (v) => !_isCreating && (v == null || v.trim().isEmpty)
                ? 'Enter flat code'
                : null,
          ),
          const SizedBox(height: 12),
          _buildInfoBanner(
            icon: Icons.info_outline_rounded,
            color: AppColors.secondaryFaint,
            iconColor: AppColors.secondary,
            text: 'Flat Code টা তোমার Flat-এর Admin এর কাছ থেকে নাও।',
          ),
        ],
      );
    }
  }

  Widget _buildInfoBanner({
    required IconData icon,
    required Color color,
    required Color iconColor,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: iconColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 13, color: iconColor, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: AppColors.error,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _error!,
              style: const TextStyle(
                color: AppColors.error,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//  private widgets

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}

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
        color: AppColors.textSecondary,
      ),
    );
  }
}

class _ToggleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _ToggleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          decoration: BoxDecoration(
            color: selected ? color : AppColors.customWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? color : AppColors.divider,
              width: selected ? 2 : 1,
            ),
            boxShadow: selected ? AppColors.cardShadow : [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: selected
                      ? Colors.white.withValues(alpha: 0.2)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: selected ? Colors.white : AppColors.textHint,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : AppColors.textPrimary,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: selected
                      ? Colors.white.withValues(alpha: 0.8)
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
