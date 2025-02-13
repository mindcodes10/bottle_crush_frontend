import 'dart:math';
import 'package:flutter/material.dart';

class CustomElevatedButton extends StatefulWidget {
  final String buttonText;
  final Future<void> Function() onPressed;
  final double? width;
  final double? height;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;
  final Icon? icon;

  const CustomElevatedButton({
    super.key,
    required this.buttonText,
    required this.onPressed,
    this.width,
    this.height,
    this.backgroundColor = Colors.blue,
    this.textColor = Colors.white,
    this.borderColor,
    this.icon,
  });

  @override
  State<CustomElevatedButton> createState() => _CustomElevatedButtonState();
}

class _CustomElevatedButtonState extends State<CustomElevatedButton> {
  bool _isLoading = false;

  void _handlePress() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await widget.onPressed();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        width: widget.width ?? 200,
        height: widget.height ?? 50,
        child: ElevatedButton(
          onPressed: _handlePress, // Keep the button active during loading
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.backgroundColor,
            padding: const EdgeInsets.symmetric(
              vertical: 10.0,
              horizontal: 15.0,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
              side: widget.borderColor != null
                  ? BorderSide(color: widget.borderColor!, width: 2.0)
                  : BorderSide.none,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isLoading)
                const DottedCircularProgressIndicator(),
              if (!_isLoading && widget.icon != null) ...[
                widget.icon!,
                const SizedBox(width: 8.0),
              ],
              const SizedBox(width: 8.0),
              Text(
                widget.buttonText,
                style: TextStyle(
                  color: widget.textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DottedCircularProgressIndicator extends StatefulWidget {
  const DottedCircularProgressIndicator({super.key});

  @override
  State<DottedCircularProgressIndicator> createState() =>
      _DottedCircularProgressIndicatorState();
}

class _DottedCircularProgressIndicatorState
    extends State<DottedCircularProgressIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 14),
      vsync: this,
      // Loop the animation indefinitely
      lowerBound: 0,
      upperBound: 2 * pi,
    )..repeat();

    _animation = Tween<double>(begin: 0, end: 2 * pi).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 20,
      width: 20,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return CustomPaint(
            painter: _DottedProgressPainter(angle: _animation.value),
          );
        },
      ),
    );
  }
}

class _DottedProgressPainter extends CustomPainter {
  final double angle;

  _DottedProgressPainter({required this.angle});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final double radius = size.width / 2;
    const double dottedLength = 5.0;
    const double gapLength = 3.0;

    for (double currentAngle = 0.0; currentAngle < 2 * pi; currentAngle += (dottedLength + gapLength) / radius) {
      final double x = radius + radius * cos(currentAngle + angle); // Apply rotation angle
      final double y = radius + radius * sin(currentAngle + angle);
      canvas.drawCircle(Offset(x, y), 1.0, paint); // Draw dotted circle
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
