import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../models/user_model.dart';
import '../models/user_role.dart';
import '../providers/auth_provider.dart';
import '../widgets/bavya_footer.dart';
import '../widgets/brand_logo.dart';
import '../widgets/gradient_button.dart';
import 'role_dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _identityController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _inlineError;

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final rawInput = _identityController.text.trim();
    final password = _passwordController.text;

    setState(() {
      _isLoading = true;
      _inlineError = null;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.login(
      identity: rawInput,
      password: password,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      final user = authProvider.currentUser;
      final detectedRole = user?.currentRoleEnum ?? UserRole.driver;

      // Deduplicate distinct operational roles
      final distinctRoles = user != null
          ? user.roles.map((c) => UserRole.fromCode(c)).toSet().toList()
          : <UserRole>[];

      // If user has multiple distinct roles assigned from API, allow workspace selection
      if (distinctRoles.length > 1 && user != null) {
        _showRoleSelectionSheet(user, distinctRoles);
      } else {
        _navigateToDashboard(detectedRole, user?.name ?? rawInput);
      }
    } else {
      final err = authProvider.errorMessage ?? 'Authentication failed. Please verify credentials.';
      setState(() => _inlineError = err);
      _showSnackBar(err, isError: true);
    }
  }

  void _showRoleSelectionSheet(UserModel user, List<UserRole> distinctRoles) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.line,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Select Operational Workspace',
                  style: AppTypography.title(color: AppColors.ink).copyWith(fontSize: 18),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your account has multiple authorized roles. Choose your active role:',
                  style: AppTypography.caption(color: AppColors.inkLight),
                ),
                const SizedBox(height: 16),
                ...distinctRoles.map((role) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: InkWell(
                      onTap: () async {
                        Navigator.pop(context);
                        final auth = Provider.of<AuthProvider>(context, listen: false);
                        await auth.switchRole(role);
                        _navigateToDashboard(role, user.name);
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: role.color.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: role.color.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: role.color.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(role.icon, color: role.color, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    role.title,
                                    style: AppTypography.roleLabel(color: AppColors.ink)
                                        .copyWith(fontSize: 14),
                                  ),
                                  Text(
                                    role.subtitle,
                                    style: AppTypography.caption(color: AppColors.muted)
                                        .copyWith(fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 14,
                              color: AppColors.muted,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  void _navigateToDashboard(UserRole role, String userName) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => RoleDashboardScreen(
          role: role,
          userId: userName,
          scope: role.scopeOptions.first,
        ),
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTypography.caption(color: Colors.white).copyWith(fontSize: 13),
        ),
        backgroundColor: isError ? AppColors.danger : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  void dispose() {
    _identityController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight > 32.0 ? constraints.maxHeight - 32.0 : 0.0,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      const SizedBox(height: 8),

                // Top Govt Partner Badge
                const GovtEmblemBadge(isDark: false),
                const SizedBox(height: 18),

                // Brand Logo & Accent Bar
                const BrandLogo(
                  height: 52,
                  subtitle: 'Noble Transit & Fleet Operations',
                  showAccentLine: true,
                ),

                const SizedBox(height: 28),

                // Unified Sign In Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: AppColors.purple.withValues(alpha: 0.18),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.purple.withValues(alpha: 0.08),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Card Header
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.purple.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.lock_outline_rounded,
                                color: AppColors.purple,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Operations Sign In',
                                    style: AppTypography.title(color: AppColors.ink)
                                        .copyWith(fontSize: 16, fontWeight: FontWeight.w700),
                                  ),
                                  Text(
                                    'Universal staff & field crew portal',
                                    style: AppTypography.caption(color: AppColors.muted)
                                        .copyWith(fontSize: 11.5),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 22),

                        // Mobile Number / Employee ID Field
                        Text(
                          'Mobile Number / Employee ID',
                          style: AppTypography.roleLabel(color: AppColors.ink)
                              .copyWith(fontSize: 12.5),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _identityController,
                          keyboardType: TextInputType.text,
                          style: AppTypography.body(color: AppColors.ink),
                          decoration: InputDecoration(
                            hintText: 'Enter 10-digit mobile or Employee ID',
                            prefixIcon: const Icon(
                              Icons.badge_outlined,
                              size: 20,
                              color: AppColors.purple,
                            ),
                            prefixIconConstraints:
                                const BoxConstraints(minWidth: 44, minHeight: 0),
                          ),
                          onChanged: (_) {
                            if (_inlineError != null) setState(() => _inlineError = null);
                          },
                          validator: (value) {
                            final text = value?.trim() ?? '';
                            if (text.isEmpty) {
                              return 'Please enter your mobile number or employee ID';
                            }
                            final digitsOnly = text.replaceAll(RegExp(r'\D'), '');
                            // Valid 10-digit mobile (6-9 starting)
                            if (digitsOnly.length == 10 && RegExp(r'^[6-9]').hasMatch(digitsOnly)) {
                              return null;
                            }
                            // Valid 12-digit mobile starting with 91
                            if (digitsOnly.length == 12 &&
                                digitsOnly.startsWith('91') &&
                                RegExp(r'^[6-9]').hasMatch(digitsOnly.substring(2))) {
                              return null;
                            }
                            // Valid 11-digit mobile starting with 0
                            if (digitsOnly.length == 11 &&
                                digitsOnly.startsWith('0') &&
                                RegExp(r'^[6-9]').hasMatch(digitsOnly.substring(1))) {
                              return null;
                            }
                            // Plain 10 digits with invalid starting digit
                            if (RegExp(r'^\d+$').hasMatch(text) &&
                                text.length == 10 &&
                                !RegExp(r'^[6-9]').hasMatch(text)) {
                              return 'Enter a valid 10-digit mobile (starting with 6, 7, 8, or 9)';
                            }
                            // Employee ID / User ID
                            if (text.length < 2) {
                              return 'Employee ID / User ID must be at least 2 characters';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 18),

                        // Password Field
                        Text(
                          'Access Password',
                          style: AppTypography.roleLabel(color: AppColors.ink)
                              .copyWith(fontSize: 12.5),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          style: AppTypography.body(color: AppColors.ink),
                          decoration: InputDecoration(
                            hintText: 'Enter account password',
                            prefixIcon: const Icon(
                              Icons.lock_rounded,
                              size: 20,
                              color: AppColors.purple,
                            ),
                            prefixIconConstraints:
                                const BoxConstraints(minWidth: 44, minHeight: 0),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded,
                                size: 20,
                                color: AppColors.muted,
                              ),
                              onPressed: () {
                                setState(() => _obscurePassword = !_obscurePassword);
                              },
                            ),
                          ),
                          onChanged: (_) {
                            if (_inlineError != null) setState(() => _inlineError = null);
                          },
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your account password';
                            }
                            return null;
                          },
                        ),

                        if (_inlineError != null) ...[
                          const SizedBox(height: 14),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.danger.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: AppColors.danger.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline_rounded,
                                  color: AppColors.danger,
                                  size: 18,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _inlineError!,
                                    style: AppTypography.caption(color: AppColors.danger).copyWith(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 24),

                        // Gradient Login Action Button
                        GradientButton(
                          text: 'Sign In',
                          icon: Icons.login_rounded,
                          isLoading: _isLoading,
                          gradientColors: const [
                            AppColors.purple,
                            AppColors.deepPurple,
                          ],
                          onPressed: _handleLogin,
                        ),

                        const SizedBox(height: 16),

                        // API-based Role Detection Banner
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.bg,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.line),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.verified_user_outlined,
                                size: 15,
                                color: AppColors.muted,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Role & assigned jurisdiction are automatically verified upon login',
                                  style: AppTypography.caption(color: AppColors.muted)
                                      .copyWith(fontSize: 11),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                // Footer pinned to bottom of screen
                const SizedBox(height: 20),
                const BavyaFooter(isDark: false),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      );
    },
  ),
),
);
  }
}
