import 'package:flutter/material.dart';
import 'package:tunner/core/theme/app_theme.dart';
import 'package:tunner/features/tuner/domain/models/pitch_result.dart';

class NoteDisplay extends StatefulWidget {
  final PitchResult result;

  const NoteDisplay({super.key, required this.result});

  @override
  State<NoteDisplay> createState() => _NoteDisplayState();
}

class _NoteDisplayState extends State<NoteDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _glowAnim = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(NoteDisplay old) {
    super.didUpdateWidget(old);
    if (widget.result.isTuned && widget.result.hasSignal &&
        widget.result.noteName != '-') {
      if (!_glowController.isAnimating) {
        _glowController.repeat(reverse: true);
      }
    } else {
      _glowController.stop();
      _glowController.value = 0.2;
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  String get _noteKey =>
      '${widget.result.noteName}${widget.result.isSharp}${widget.result.octave}';

  @override
  Widget build(BuildContext context) {
    final bool active =
        widget.result.hasSignal && widget.result.noteName != '-';
    final Color noteColor = _noteColor(widget.result);

    return SizedBox(
      height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Glow de fondo cuando afinado
          if (active && widget.result.isTuned)
            AnimatedBuilder(
              animation: _glowAnim,
              builder: (ctx, child) => Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.tunedGlow.withValues(
                          alpha: _glowAnim.value * 0.6),
                      blurRadius: 50 * _glowAnim.value,
                      spreadRadius: 10 * _glowAnim.value,
                    ),
                  ],
                ),
              ),
            ),

          // Nota principal con AnimatedSwitcher
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            transitionBuilder: (child, anim) => ScaleTransition(
              scale: Tween<double>(begin: 0.85, end: 1.0).animate(
                CurvedAnimation(parent: anim, curve: Curves.easeOut),
              ),
              child: FadeTransition(opacity: anim, child: child),
            ),
            child: active
                ? _NoteText(
                    key: ValueKey(_noteKey),
                    noteName: widget.result.noteName,
                    isSharp: widget.result.isSharp,
                    octave: widget.result.octave,
                    color: noteColor,
                  )
                : _IdleMicIcon(key: const ValueKey('idle')),
          ),

          // Badge AFINADO
          if (active)
            Positioned(
              bottom: 4,
              child: AnimatedOpacity(
                opacity: widget.result.isTuned ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.tuned.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.tuned.withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                  child: const Text(
                    'AFINADO',
                    style: TextStyle(
                      color: AppColors.tuned,
                      fontSize: 10,
                      letterSpacing: 3,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _noteColor(PitchResult r) {
    if (!r.hasSignal || r.noteName == '-') return AppColors.inactive;
    if (r.isTuned) return AppColors.tuned;
    if (r.isAbove) return AppColors.sharp;
    return AppColors.flat;
  }
}

class _NoteText extends StatelessWidget {
  final String noteName;
  final bool isSharp;
  final int octave;
  final Color color;

  const _NoteText({
    super.key,
    required this.noteName,
    required this.isSharp,
    required this.octave,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    // Base note letter (without the #)
    final String baseLetter = isSharp ? noteName.replaceAll('#', '') : noteName;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nota principal
        Text(
          baseLetter,
          style: TextStyle(
            fontSize: 100,
            fontWeight: FontWeight.w200,
            color: color,
            height: 1,
            letterSpacing: -2,
          ),
        ),
        // Superíndices: # y octava
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isSharp)
                Text(
                  '#',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w300,
                    color: AppColors.sharp,
                    height: 1,
                  ),
                )
              else
                const SizedBox(height: 28),
              const SizedBox(height: 4),
              Text(
                octave.toString(),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w300,
                  color: color.withValues(alpha: 0.6),
                  height: 1,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _IdleMicIcon extends StatefulWidget {
  const _IdleMicIcon({super.key});

  @override
  State<_IdleMicIcon> createState() => _IdleMicIconState();
}

class _IdleMicIconState extends State<_IdleMicIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (ctx, child) => Opacity(
        opacity: 0.3 + _ctrl.value * 0.4,
        child: const Icon(
          Icons.mic_outlined,
          size: 64,
          color: AppColors.inactive,
        ),
      ),
    );
  }
}
