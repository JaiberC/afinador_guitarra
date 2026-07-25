import 'dart:math';
import 'package:flutter/material.dart';
import 'package:tunner/core/theme/app_theme.dart';
import 'package:tunner/features/tuner/presentation/screens/tuner_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _arcController;
  late AnimationController _fadeController;
  late AnimationController _logoController;
  late AnimationController _glowController;

  late Animation<double> _arcSweep;
  late Animation<double> _fadeIn;
  late Animation<double> _logoScale;
  late Animation<double> _glowPulse;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _logoScale = CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    );

    _arcController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _arcSweep = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _arcController, curve: Curves.easeOut),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _glowPulse = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeIn = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    _runSequence();
  }

  Future<void> _runSequence() async {
    await Future.delayed(const Duration(milliseconds: 200));
    await _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 100));
    await _arcController.forward();
    _glowController.repeat(reverse: true);
    await Future.delayed(const Duration(milliseconds: 1000));
    _glowController.stop();
    await _fadeController.forward();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (ctx, anim, secAnim) => const TunerScreen(),
          transitionsBuilder: (ctx, anim, secAnim, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
    }
  }

  @override
  void dispose() {
    _arcController.dispose();
    _fadeController.dispose();
    _logoController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeIn,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              // Logo + arco de afinación
              SizedBox(
                width: 220,
                height: 220,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Arco de afinación animado (detrás del logo)
                    AnimatedBuilder(
                      animation: _arcSweep,
                      builder: (ctx, child) => CustomPaint(
                        size: const Size(220, 220),
                        painter: _TunerArcPainter(
                          progress: _arcSweep.value,
                          glowOpacity: _glowPulse.value,
                        ),
                      ),
                    ),
                    // Logo del oso
                    ScaleTransition(
                      scale: _logoScale,
                      child: Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.surface,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.brandGlow,
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Image.asset(
                          'assets/logo_jaco_dev.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),
              // Nombre de la app
              ScaleTransition(
                scale: _logoScale,
                child: const Text(
                  'TUNNER',
                  style: TextStyle(
                    color: AppColors.onBackground,
                    fontSize: 36,
                    fontWeight: FontWeight.w200,
                    letterSpacing: 14,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ScaleTransition(
                scale: _logoScale,
                child: const Text(
                  'Afinador cromático',
                  style: TextStyle(
                    color: AppColors.onSurface,
                    fontSize: 13,
                    letterSpacing: 3,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
              const Spacer(flex: 3),
              // Footer de marca
              ScaleTransition(
                scale: _logoScale,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/logo_jaco_dev.png',
                        width: 36,
                        height: 36,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 6),
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: 'Ja',
                              style: TextStyle(
                                color: AppColors.onSurface,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1,
                              ),
                            ),
                            TextSpan(
                              text: 'CO',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1,
                              ),
                            ),
                            TextSpan(
                              text: ' dev',
                              style: TextStyle(
                                color: AppColors.onSurface,
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TunerArcPainter extends CustomPainter {
  final double progress;
  final double glowOpacity;

  static const double _arcSpan = pi * 0.85;
  static const double _arcStart = pi + (pi - _arcSpan) / 2;

  _TunerArcPainter({required this.progress, required this.glowOpacity});

  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    final double cy = size.height / 2 + 10;
    final double radius = size.width * 0.46;

    // Arco de fondo
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: radius),
      _arcStart,
      _arcSpan,
      false,
      Paint()
        ..color = AppColors.inactive
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    if (progress <= 0) return;

    // Arco de progreso con gradiente corporativo
    final sweepAngle = _arcSpan * progress;
    final gradient = SweepGradient(
      startAngle: _arcStart,
      endAngle: _arcStart + sweepAngle,
      colors: const [
        AppColors.flat,
        AppColors.sharp,
        AppColors.tuned,
      ],
      stops: const [0.0, 0.5, 1.0],
    );

    final Rect arcRect =
        Rect.fromCircle(center: Offset(cx, cy), radius: radius);

    // Glow del arco
    canvas.drawArc(
      arcRect,
      _arcStart,
      sweepAngle,
      false,
      Paint()
        ..color = AppColors.primary.withValues(alpha: 0.25 * glowOpacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    // Arco principal
    canvas.drawArc(
      arcRect,
      _arcStart,
      sweepAngle,
      false,
      Paint()
        ..shader = gradient.createShader(arcRect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );

    // Ticks del arco
    const List<double> tickFractions = [0.0, 0.25, 0.5, 0.75, 1.0];
    for (final frac in tickFractions) {
      if (frac > progress) break;
      final double angle = _arcStart + frac * _arcSpan;
      final bool isCenter = frac == 0.5;
      final double inner = radius - (isCenter ? 14 : 8);
      final double outer = radius + 3;
      canvas.drawLine(
        Offset(cx + inner * cos(angle), cy + inner * sin(angle)),
        Offset(cx + outer * cos(angle), cy + outer * sin(angle)),
        Paint()
          ..color = isCenter ? AppColors.tuned : AppColors.onSurface
          ..strokeWidth = isCenter ? 2.0 : 1.5
          ..strokeCap = StrokeCap.round,
      );
    }

    // Aguja en el centro (afinado)
    if (progress >= 0.95) {
      final double needleAngle = _arcStart + 0.5 * _arcSpan;
      final double needleLen = radius - 20;
      canvas.drawLine(
        Offset(cx, cy),
        Offset(
            cx + needleLen * cos(needleAngle), cy + needleLen * sin(needleAngle)),
        Paint()
          ..color = AppColors.tuned.withValues(alpha: glowOpacity)
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round,
      );
      canvas.drawCircle(
        Offset(cx, cy),
        5,
        Paint()
          ..color = AppColors.tuned.withValues(alpha: glowOpacity)
          ..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(_TunerArcPainter old) =>
      old.progress != progress || old.glowOpacity != glowOpacity;
}
