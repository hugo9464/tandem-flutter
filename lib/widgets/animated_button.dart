import 'package:flutter/material.dart';

class AnimatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final double? elevation;
  final bool enabled;

  const AnimatedButton({
    super.key,
    required this.child,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.padding,
    this.borderRadius,
    this.elevation,
    this.enabled = true,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _rippleController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rippleAnimation;
  
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
    
    _rippleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rippleController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.enabled) {
      setState(() => _isPressed = true);
      _scaleController.forward();
      _rippleController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.enabled) {
      setState(() => _isPressed = false);
      _scaleController.reverse();
      _rippleController.reset();
      widget.onPressed?.call();
    }
  }

  void _handleTapCancel() {
    if (widget.enabled) {
      setState(() => _isPressed = false);
      _scaleController.reverse();
      _rippleController.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = widget.backgroundColor ?? theme.colorScheme.primary;
    final foregroundColor = widget.foregroundColor ?? theme.colorScheme.onPrimary;
    final borderRadius = widget.borderRadius ?? BorderRadius.circular(12);
    
    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _rippleAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              boxShadow: widget.elevation != null
                  ? [
                      BoxShadow(
                        color: backgroundColor.withValues(alpha: 0.3),
                        offset: Offset(0, widget.elevation! * 0.5),
                        blurRadius: widget.elevation! * 2,
                        spreadRadius: 0,
                      ),
                    ]
                  : null,
            ),
            child: Material(
              color: backgroundColor.withValues(
                alpha: widget.enabled ? 1.0 : 0.5,
              ),
              borderRadius: borderRadius,
              child: Stack(
                children: [
                  // Ripple effect
                  if (_isPressed)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: borderRadius,
                          color: Colors.white.withValues(
                            alpha: 0.1 * _rippleAnimation.value,
                          ),
                        ),
                      ),
                    ),
                  // Button content
                  GestureDetector(
                    onTapDown: _handleTapDown,
                    onTapUp: _handleTapUp,
                    onTapCancel: _handleTapCancel,
                    child: Container(
                      padding: widget.padding ?? 
                          const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        borderRadius: borderRadius,
                      ),
                      child: Center(
                        child: DefaultTextStyle(
                          style: TextStyle(
                            color: foregroundColor.withValues(
                              alpha: widget.enabled ? 1.0 : 0.5,
                            ),
                            fontWeight: FontWeight.w600,
                          ),
                          child: widget.child,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class FloatingAnimatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double size;
  final bool mini;

  const FloatingAnimatedButton({
    super.key,
    required this.child,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.size = 56.0,
    this.mini = false,
  });

  @override
  State<FloatingAnimatedButton> createState() => _FloatingAnimatedButtonState();
}

class _FloatingAnimatedButtonState extends State<FloatingAnimatedButton>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));
    
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = widget.backgroundColor ?? theme.colorScheme.primary;
    final foregroundColor = widget.foregroundColor ?? theme.colorScheme.onPrimary;
    final size = widget.mini ? 40.0 : widget.size;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: backgroundColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: backgroundColor.withValues(alpha: 0.3),
                    offset: const Offset(0, 4),
                    blurRadius: 8,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    _controller.forward().then((_) {
                      _controller.reverse();
                      widget.onPressed?.call();
                    });
                  },
                  borderRadius: BorderRadius.circular(size / 2),
                  child: Center(
                    child: IconTheme(
                      data: IconThemeData(
                        color: foregroundColor,
                        size: size * 0.4,
                      ),
                      child: widget.child,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}