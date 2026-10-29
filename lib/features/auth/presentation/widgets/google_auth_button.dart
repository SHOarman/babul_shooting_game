import 'package:flutter/material.dart';

class GoogleAuthButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final bool isLoading;

  const GoogleAuthButton({
    super.key,
    this.text = 'Sign up with Google',
    this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF131938),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF131938)),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildGoogleIcon(),
                  const SizedBox(width: 12),
                  Text(
                    text,
                    style: const TextStyle(
                      color: Color(0xFF131938),
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildGoogleIcon() {
    return SizedBox(
      width: 24,
      height: 24,
      child: CustomPaint(
        painter: _GoogleGLogoPainter(),
      ),
    );
  }
}

class _GoogleGLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    final Paint blue = Paint()..color = const Color(0xFF4285F4);
    final Paint red = Paint()..color = const Color(0xFFEA4335);
    final Paint yellow = Paint()..color = const Color(0xFFFBBC05);
    final Paint green = Paint()..color = const Color(0xFF34A853);

    final Rect rect = Rect.fromLTWH(0, 0, w, h);
    final double strokeWidth = w * 0.22;

    // Red (Top arc)
    final Paint redStroke = Paint()
      ..color = red.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawArc(rect.deflate(strokeWidth / 2), 3.14159 * 1.25, 3.14159 * 0.75, false, redStroke);

    // Yellow (Left arc)
    final Paint yellowStroke = Paint()
      ..color = yellow.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawArc(rect.deflate(strokeWidth / 2), 3.14159 * 0.75, 3.14159 * 0.5, false, yellowStroke);

    // Green (Bottom arc)
    final Paint greenStroke = Paint()
      ..color = green.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawArc(rect.deflate(strokeWidth / 2), 3.14159 * 0.2, 3.14159 * 0.55, false, greenStroke);

    // Blue (Right arc & crossbar)
    final Paint blueStroke = Paint()
      ..color = blue.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawArc(rect.deflate(strokeWidth / 2), -0.2, 3.14159 * 0.35, false, blueStroke);

    final Paint blueFill = Paint()..color = blue.color;
    canvas.drawRect(
      Rect.fromLTWH(w * 0.48, h * 0.40, w * 0.48, strokeWidth),
      blueFill,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

