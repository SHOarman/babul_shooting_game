import 'dart:math';
import 'package:flutter/material.dart';
import '../controllers/game_controller.dart';

// ==================== AIM LINE PAINTER ====================
class AimLinePainter extends CustomPainter {
  final Offset start;
  final Offset? end;
  final double boardWidth;
  final double boardHeight;
  final double bubbleRadius;
  final Color aimColor;
  final List<List<BubbleGridItem>>? grid;
  final double gridOffsetY;

  AimLinePainter({
    required this.start,
    required this.end,
    required this.boardWidth,
    required this.boardHeight,
    required this.bubbleRadius,
    required this.aimColor,
    this.grid,
    this.gridOffsetY = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (end == null) return;

    final double dx = end!.dx - start.dx;
    final double dy = end!.dy - start.dy;

    if (dy >= -10) return;

    final double length = sqrt(dx * dx + dy * dy);
    if (length < 15) return;

    final double dirX = dx / length;
    final double dirY = dy / length;

    final double bubbleDiameter = bubbleRadius * 2.0;
    final double minX = 10.0 + bubbleRadius;
    final double maxX = boardWidth - 10.0 - bubbleRadius;
    const double minY = 10.0;

    final Paint mainPaint = Paint()
      ..color = aimColor.withValues(alpha: 0.85)
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    final Paint bouncePaint = Paint()
      ..color = aimColor.withValues(alpha: 0.95)
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    final List<Offset> activeBubbles = [];
    if (grid != null) {
      for (int r = 0; r < grid!.length; r++) {
        final bool isEven = r % 2 == 0;
        final double rowIndent = isEven ? 0.0 : bubbleRadius;
        final double cellY = gridOffsetY + (r * (bubbleDiameter * 0.86)) + bubbleRadius;

        for (int c = 0; c < grid![r].length; c++) {
          if (grid![r][c].color != null) {
            final double cellX = 10.0 + rowIndent + (c * bubbleDiameter) + bubbleRadius;
            activeBubbles.add(Offset(cellX, cellY));
          }
        }
      }
    }

    // ==================== RAY TRACE CALCULATION ====================
    double curX = start.dx;
    double curY = start.dy;
    double currentDirX = dirX;
    double currentDirY = dirY;

    final List<Offset> firstSegmentPoints = [start];
    final List<Offset> secondSegmentPoints = [];
    bool hasBounced = false;
    Offset bouncePoint = Offset.zero;

    final double hitDistanceSq = pow(bubbleDiameter * 0.80, 2).toDouble();

    for (int step = 0; step < 280; step++) {
      curX += currentDirX * 4.0;
      curY += currentDirY * 4.0;

      if (!hasBounced) {
        if (curX <= minX) {
          curX = minX;
          currentDirX = -currentDirX;
          hasBounced = true;
          bouncePoint = Offset(curX, curY);
          firstSegmentPoints.add(bouncePoint);
          secondSegmentPoints.add(bouncePoint);
          continue;
        } else if (curX >= maxX) {
          curX = maxX;
          currentDirX = -currentDirX;
          hasBounced = true;
          bouncePoint = Offset(curX, curY);
          firstSegmentPoints.add(bouncePoint);
          secondSegmentPoints.add(bouncePoint);
          continue;
        }
      }

      bool hitBubble = false;
      for (final bubble in activeBubbles) {
        final double bDx = curX - bubble.dx;
        final double bDy = curY - bubble.dy;
        if (bDx * bDx + bDy * bDy <= hitDistanceSq) {
          hitBubble = true;
          break;
        }
      }

      final Offset curPoint = Offset(curX, curY);
      if (hasBounced) {
        secondSegmentPoints.add(curPoint);
      } else {
        firstSegmentPoints.add(curPoint);
      }

      if (hitBubble || curY <= (minY + gridOffsetY + bubbleRadius)) {
        break;
      }
    }

    // ==================== DRAW AIM PATH ====================
    _drawPolylineDotted(canvas, firstSegmentPoints, mainPaint);

    if (hasBounced && secondSegmentPoints.length > 1) {
      _drawPolylineDotted(canvas, secondSegmentPoints, bouncePaint);

      canvas.drawCircle(
        bouncePoint,
        5.0,
        Paint()..color = aimColor,
      );
    }
  }

  // ==================== DOTTED LINE DRAWING ====================
  void _drawPolylineDotted(Canvas canvas, List<Offset> points, Paint paint) {
    if (points.length < 2) return;

    const double dashLen = 7.0;
    const double spaceLen = 7.0;
    double distanceAccum = 12.0;

    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      final double segDist = sqrt(pow(p2.dx - p1.dx, 2) + pow(p2.dy - p1.dy, 2));
      if (segDist <= 0.01) continue;

      final double uX = (p2.dx - p1.dx) / segDist;
      final double uY = (p2.dy - p1.dy) / segDist;

      double cur = 0.0;
      while (cur < segDist) {
        final double advance = min(dashLen, segDist - cur);
        if (distanceAccum % (dashLen + spaceLen) < dashLen) {
          canvas.drawLine(
            Offset(p1.dx + uX * cur, p1.dy + uY * cur),
            Offset(p1.dx + uX * (cur + advance), p1.dy + uY * (cur + advance)),
            paint,
          );
        }
        cur += advance;
        distanceAccum += advance;
      }
    }
  }

  @override
  bool shouldRepaint(covariant AimLinePainter oldDelegate) {
    return oldDelegate.start != start ||
        oldDelegate.end != end ||
        oldDelegate.boardWidth != boardWidth ||
        oldDelegate.boardHeight != boardHeight ||
        oldDelegate.aimColor != aimColor ||
        oldDelegate.grid != grid;
  }
}
