import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../models/user_role.dart';
import '../providers/auth_provider.dart';
import '../widgets/bavya_footer.dart';
import '../widgets/brand_logo.dart';
import '../widgets/role_badge_pill.dart';
import 'login_screen.dart';
import 'role_dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _accentBarAnimation;
  late Animation<double> _rolesSlideAnimation;
  late Animation<double> _footerFadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    // 1. Logo & Badge fade + subtle bounce scale (0.0 -> 0.55)
    _logoFadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.55, curve: Curves.easeOut),
    );
    _logoScaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.60, curve: Curves.easeOutBack),
      ),
    );

    // 2. 4-color accent bar expands (0.35 -> 0.70)
    _accentBarAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.35, 0.70, curve: Curves.easeInOutCubic),
    );

    // 3. Roles section slides up smoothly (0.50 -> 0.85)
    _rolesSlideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.50, 0.85, curve: Curves.easeOutCubic),
      ),
    );

    // 4. Progress indicator & Footer fade in (0.70 -> 1.0)
    _footerFadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.70, 1.0, curve: Curves.easeIn),
    );

    _controller.forward();

    // Await session restoration and ensure smooth splash experience
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final startTime = DateTime.now();

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      // Wait for session restoration from secure vault to complete
      while (authProvider.isLoading && mounted) {
        await Future.delayed(const Duration(milliseconds: 50));
      }
    } catch (_) {}

    // Ensure splash displays for at least 2.5 seconds for branding effect
    final elapsed = DateTime.now().difference(startTime);
    const minSplashDuration = Duration(milliseconds: 2500);
    if (elapsed < minSplashDuration) {
      await Future.delayed(minSplashDuration - elapsed);
    }

    _navigateToNext();
  }

  void _navigateToNext() {
    if (!mounted) return;

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.isAuthenticated && authProvider.currentUser != null) {
        final user = authProvider.currentUser!;
        final role = user.currentRoleEnum;
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                RoleDashboardScreen(
              role: role,
              userId: user.name,
              scope: role.scopeOptions.first,
            ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOut,
                ),
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
        return;
      }
    } catch (_) {}

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // ── Premium Dark Gradient Background ─────────────────────────
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: AppColors.splashGradient,
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // ── Ambient Glow Circle Top-Right (Purple / Magenta) ──────────
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.magenta.withValues(alpha: 0.35),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ── Ambient Glow Circle Bottom-Left (Amber / Orange) ──────────
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.orange.withValues(alpha: 0.25),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ── Main Content Layout ──────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                children: [
                  const SizedBox(height: 12),

                  // 1. Govt Emblem Header
                  FadeTransition(
                    opacity: _logoFadeAnimation,
                    child: const GovtEmblemBadge(isDark: true),
                  ),

                  const Spacer(flex: 2),

                  // 2. Central Hero Branding & Logos
                  FadeTransition(
                    opacity: _logoFadeAnimation,
                    child: ScaleTransition(
                      scale: _logoScaleAnimation,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Brand Icon with Glowing Ring
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  Colors.white.withValues(alpha: 0.15),
                                  Colors.white.withValues(alpha: 0.05),
                                ],
                              ),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.25),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.brightMagenta.withValues(alpha: 0.3),
                                  blurRadius: 30,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Image.asset(
                              'assets/images/bavya-icon-final.png',
                              height: 64,
                              width: 64,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) => Image.asset(
                                'assets/images/bavya-icon.png',
                                height: 64,
                                width: 64,
                                fit: BoxFit.contain,
                                errorBuilder: (ctx, err, stack) => const Icon(
                                  Icons.emergency_rounded,
                                  color: Colors.white,
                                  size: 48,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Brand Wordmark
                          Image.asset(
                            'assets/images/bavya-wordmark.png',
                            height: 38,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => Text(
                              'BAVYA',
                              style: AppTypography.h1(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                              ).copyWith(letterSpacing: 3),
                            ),
                          ),

                          const SizedBox(height: 10),

                          // App Title
                          Text(
                            'MAHAPRASTHANAM',
                            textAlign: TextAlign.center,
                            style: AppTypography.h2(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ).copyWith(
                              fontSize: 24,
                              letterSpacing: 2.5,
                            ),
                          ),

                          const SizedBox(height: 6),

                          // Subtitle Tagline
                          Text(
                            'Fleet Logistics & Noble Transit Operations',
                            textAlign: TextAlign.center,
                            style: AppTypography.subtitle(
                              color: Colors.white.withValues(alpha: 0.8),
                            ).copyWith(fontSize: 13, letterSpacing: 0.4),
                          ),

                          const SizedBox(height: 18),

                          // Expanding Official 4-Color Accent Bar
                          AnimatedBuilder(
                            animation: _accentBarAnimation,
                            builder: (context, child) {
                              return SizedBox(
                                width: 160 * _accentBarAnimation.value,
                                child: const BavyaAccentLine(height: 4.5),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(flex: 2),

                  // 3. Role-Based Access Preview Cards
                  AnimatedBuilder(
                    animation: _rolesSlideAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _rolesSlideAnimation.value),
                        child: Opacity(
                          opacity: _controller.value < 0.5
                              ? 0.0
                              : ((_controller.value - 0.5) / 0.35).clamp(0.0, 1.0),
                          child: child,
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.07),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.12),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.lock_outline_rounded,
                                size: 13,
                                color: AppColors.amber,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'ROLE-BASED SECURE ACCESS',
                                style: AppTypography.badge(
                                  color: AppColors.amber,
                                ).copyWith(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // 3 Role Pills
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: const [
                              UserRole.driver,
                              UserRole.fleetManager,
                              UserRole.districtManager,
                            ].map((role) {
                              return RoleBadgePill(
                                role: role,
                                isCompact: size.width < 380,
                                isDark: true,
                                onTap: _navigateToNext,
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(flex: 1),

                  // 4. Loading Progress Indicator & Interactive Skip Button
                  FadeTransition(
                    opacity: _footerFadeAnimation,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Animated progress bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: SizedBox(
                            width: 180,
                            height: 3,
                            child: LinearProgressIndicator(
                              backgroundColor: Colors.white.withValues(alpha: 0.15),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.amber,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        Text(
                          'Initializing Operations Hub...',
                          style: AppTypography.caption(
                            color: Colors.white.withValues(alpha: 0.7),
                          ).copyWith(fontSize: 11.5),
                        ),

                        const SizedBox(height: 16),

                        // Skip / Continue Tap Action
                        TextButton.icon(
                          onPressed: _navigateToNext,
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            backgroundColor: Colors.white.withValues(alpha: 0.10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: Colors.white.withValues(alpha: 0.18),
                              ),
                            ),
                          ),
                          icon: const Text(
                            'Continue to Login',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          label: const Icon(
                            Icons.arrow_forward_rounded,
                            size: 15,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(flex: 1),

                  // 5. Footer Attribution
                  FadeTransition(
                    opacity: _footerFadeAnimation,
                    child: const BavyaFooter(isDark: true),
                  ),

                  const SizedBox(height: 4),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
