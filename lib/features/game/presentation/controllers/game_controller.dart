import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/services/sound_service.dart';
import '../../domain/usecases/save_level_result_usecase.dart';
import '../widgets/bubble_widget.dart';

class BubbleGridItem {
  BubbleColor? color;
  BubbleGridItem(this.color);
}

// ==================== GAME CONTROLLER ====================
class GameController extends GetxController with GetSingleTickerProviderStateMixin {
  final int level;
  final SaveLevelResultUseCase _saveLevelResultUseCase;

  GameController({
    this.level = 1,
    SaveLevelResultUseCase? saveLevelResultUseCase,
  }) : _saveLevelResultUseCase = saveLevelResultUseCase ?? Get.find<SaveLevelResultUseCase>();

  // ==================== GAMEPLAY STATE ====================
  late final RxInt movesRemaining;
  final RxInt currentScore = 0.obs;
  late final int targetScore;

  final RxInt currentStarsEarned = 0.obs;
  final RxString comboBannerText = ''.obs;

  late final Rx<BubbleColor> currentShooterColor;
  late final Rx<BubbleColor> nextShooterColor;

  final Rx<Offset?> aimPosition = Rx<Offset?>(null);
  final RxBool isShooting = false.obs;
  final RxBool isGameOver = false.obs;
  final Rx<Offset?> movingBubblePosition = Rx<Offset?>(null);

  final int totalRows = 12;
  final RxDouble gridOffsetY = 0.0.obs;
  final RxList<List<BubbleGridItem>> grid = <List<BubbleGridItem>>[].obs;

  static const List<BubbleColor> availableColors = [
    BubbleColor.red,
    BubbleColor.yellow,
    BubbleColor.teal,
    BubbleColor.skyBlue,
    BubbleColor.purple,
  ];

  @override
  void onInit() {
    super.onInit();
    isGameOver.value = false;
    isShooting.value = false;
    aimPosition.value = null;
    movesRemaining = (35 + min(level * 2, 15).toInt()).obs;
    currentScore.value = 0;
    targetScore = 1200 + (level * 300);
    gridOffsetY.value = 0.0;
    currentStarsEarned.value = 0;

    final Random random = Random();
    currentShooterColor = availableColors[random.nextInt(availableColors.length)].obs;
    nextShooterColor = availableColors[random.nextInt(availableColors.length)].obs;

    _generateLevelGrid();
  }

  // ==================== LEVEL GRID GENERATION ====================
  void _generateLevelGrid() {
    grid.clear();
    gridOffsetY.value = 0.0;

    final int fillRows = level <= 3 ? 3 : 4;

    for (int r = 0; r < totalRows; r++) {
      final int cols = (r % 2 == 0) ? 8 : 7;
      final List<BubbleGridItem> row = [];

      for (int c = 0; c < cols; c++) {
        if (r < fillRows) {
          final color = _getColorForLevel(level, r, c, cols);
          row.add(BubbleGridItem(color));
        } else {
          row.add(BubbleGridItem(null));
        }
      }
      grid.add(row);
    }
  }

  BubbleColor _getColorForLevel(int level, int r, int c, int cols) {
    final double mid = (cols - 1) / 2.0;
    final double distFromCenter = (c - mid).abs();

    switch (level) {
      case 1:
        if (r < 2) {
          return c < 4 ? BubbleColor.red : BubbleColor.yellow;
        } else {
          return c < 4 ? BubbleColor.teal : BubbleColor.skyBlue;
        }

      case 2:
        const colors = [BubbleColor.red, BubbleColor.yellow, BubbleColor.teal, BubbleColor.skyBlue];
        return colors[(r + c) % colors.length];

      case 3:
        final int dist = distFromCenter.round();
        const colors = [BubbleColor.yellow, BubbleColor.teal, BubbleColor.purple, BubbleColor.skyBlue];
        return colors[(dist + r) % colors.length];

      case 4:
        if (distFromCenter <= (2.4 - (r * 0.55))) {
          return (r + c) % 2 == 0 ? BubbleColor.yellow : BubbleColor.teal;
        } else {
          final int wingStep = (c < mid ? (mid - c).round() : (c - mid).round()) + r;
          const wingColors = [BubbleColor.purple, BubbleColor.skyBlue, BubbleColor.red];
          return wingColors[wingStep % wingColors.length];
        }

      case 5:
        final int diamondDist = (r - 2).abs() + (c - mid).abs().round();
        if (diamondDist <= 2) {
          return BubbleColor.yellow;
        } else if (diamondDist <= 4) {
          return BubbleColor.teal;
        } else {
          return BubbleColor.purple;
        }

      case 6:
        final double leftPeakDist = (c - 2.0).abs();
        final double rightPeakDist = (c - (cols - 3.0)).abs();
        final double minPeakDist = min(leftPeakDist, rightPeakDist);
        if (minPeakDist < 1.4) {
          return BubbleColor.skyBlue;
        } else if (minPeakDist < 2.5) {
          return BubbleColor.red;
        } else {
          return BubbleColor.purple;
        }

      case 7:
        if (r == 0) return BubbleColor.yellow;
        const pillarColors = [BubbleColor.teal, BubbleColor.purple, BubbleColor.red, BubbleColor.skyBlue];
        return pillarColors[c % pillarColors.length];

      case 8:
        final double radius = sqrt(pow(c - mid, 2) + pow(r - 1.5, 2));
        if (radius < 1.8) {
          return BubbleColor.yellow;
        } else if (radius < 3.2) {
          return BubbleColor.teal;
        } else {
          return BubbleColor.purple;
        }

      case 9:
        final int zigzag = ((c + (r % 2 == 0 ? r : -r)) % 5).abs();
        return availableColors[zigzag % availableColors.length];

      case 10:
        final int symC = c < cols / 2 ? c : (cols - 1 - c);
        return availableColors[(r * 2 + symC * 2) % availableColors.length];

      default:
        final int symCol = c < cols / 2 ? c : (cols - 1 - c);
        final int colorIdx = ((r * 3) + (symCol * 2) + level) % availableColors.length;
        return availableColors[colorIdx];
    }
  }

  double get dangerRowIndex => 7.8;

  void swapBubbles() {
    if (isGameOver.value || isShooting.value) return;
    SoundService.playBounce();
    final temp = currentShooterColor.value;
    currentShooterColor.value = nextShooterColor.value;
    nextShooterColor.value = temp;
  }

  void updateAim(Offset? position) {
    if (isGameOver.value || isShooting.value) return;
    aimPosition.value = position;
  }

  // ==================== SHOOTING & COLLISION ====================
  void shoot(Offset startPos, double boardWidth, double boardHeight, double bubbleDiameter) async {
    if (isGameOver.value || isShooting.value || aimPosition.value == null || movesRemaining.value <= 0) return;

    final Offset aim = aimPosition.value!;
    final double dx = aim.dx - startPos.dx;
    final double dy = aim.dy - startPos.dy;

    if (dy >= -10) {
      aimPosition.value = null;
      return;
    }

    isShooting.value = true;
    final double length = sqrt(dx * dx + dy * dy);
    double dirX = dx / length;
    double dirY = dy / length;

    double curX = startPos.dx;
    double curY = startPos.dy;
    const double speed = 20.0;

    bool collided = false;

    final double minWallX = 10.0 + (bubbleDiameter / 2);
    final double maxWallX = boardWidth - 10.0 - (bubbleDiameter / 2);

    for (int step = 0; step < 200; step++) {
      curX += dirX * speed;
      curY += dirY * speed;

      if (curX <= minWallX) {
        curX = minWallX;
        dirX = -dirX;
        SoundService.playBounce();
      } else if (curX >= maxWallX) {
        curX = maxWallX;
        dirX = -dirX;
        SoundService.playBounce();
      }

      movingBubblePosition.value = Offset(curX, curY);
      await Future.delayed(const Duration(milliseconds: 8));

      for (int r = 0; r < grid.length; r++) {
        final bool isEven = r % 2 == 0;
        final double rowIndent = isEven ? 0.0 : (bubbleDiameter / 2);
        final double cellY = gridOffsetY.value + (r * (bubbleDiameter * 0.86)) + (bubbleDiameter / 2);

        for (int c = 0; c < grid[r].length; c++) {
          if (grid[r][c].color != null) {
            final double cellX = 10.0 + rowIndent + (c * bubbleDiameter) + (bubbleDiameter / 2);
            final double dist = sqrt(pow(curX - cellX, 2) + pow(curY - cellY, 2));

            if (dist <= bubbleDiameter * 0.80) {
              collided = true;
              break;
            }
          }
        }
        if (collided) break;
      }

      if (!collided && curY <= (gridOffsetY.value + (bubbleDiameter / 2))) {
        collided = true;
        break;
      }

      if (collided) break;
    }

    movingBubblePosition.value = null;

    final Point<int> bestCell = _findBestCellForPlacement(curX, curY, bubbleDiameter);
    grid[bestCell.x][bestCell.y].color = currentShooterColor.value;

    grid.refresh();

    _checkMatchesAndPop(bestCell.x, bestCell.y, currentShooterColor.value);

    gridOffsetY.value += (bubbleDiameter * 0.07);

    movesRemaining.value--;

    currentShooterColor.value = nextShooterColor.value;
    final Random random = Random();
    nextShooterColor.value = availableColors[random.nextInt(availableColors.length)];

    bool allCleared = true;
    for (var row in grid) {
      for (var cell in row) {
        if (cell.color != null) {
          allCleared = false;
          break;
        }
      }
      if (!allCleared) break;
    }

    final double dangerLineY = bubbleDiameter * 0.86 * dangerRowIndex;
    bool dangerCrossed = false;
    for (int r = 0; r < totalRows; r++) {
      final double cellBottom = gridOffsetY.value + (r * (bubbleDiameter * 0.86)) + bubbleDiameter;
      for (int c = 0; c < grid[r].length; c++) {
        if (grid[r][c].color != null && cellBottom >= dangerLineY) {
          dangerCrossed = true;
          break;
        }
      }
      if (dangerCrossed) break;
    }

    if (allCleared || currentScore.value >= targetScore) {
      _showWinDialog();
      return;
    } else if (dangerCrossed) {
      _showGameOverDialog(reason: 'Danger Line Crossed!');
      return;
    } else if (movesRemaining.value <= 0) {
      _showGameOverDialog(reason: 'Out of Moves!');
      return;
    }

    aimPosition.value = null;
    isShooting.value = false;
  }

  Point<int> _findBestCellForPlacement(double hitX, double hitY, double bubbleDiameter) {
    int bestR = 0;
    int bestC = 0;
    double minDistance = double.infinity;

    for (int r = 0; r < totalRows; r++) {
      final bool isEven = r % 2 == 0;
      final double rowIndent = isEven ? 0.0 : (bubbleDiameter / 2);
      final double cellY = gridOffsetY.value + (r * (bubbleDiameter * 0.86)) + (bubbleDiameter / 2);

      for (int c = 0; c < grid[r].length; c++) {
        if (grid[r][c].color == null) {
          final double cellX = 10.0 + rowIndent + (c * bubbleDiameter) + (bubbleDiameter / 2);
          final double dist = sqrt(pow(hitX - cellX, 2) + pow(hitY - cellY, 2));

          final bool isAdjacentToBubble = r == 0 || _hasOccupiedNeighbor(r, c);

          if (isAdjacentToBubble && dist < minDistance) {
            minDistance = dist;
            bestR = r;
            bestC = c;
          }
        }
      }
    }

    return Point(bestR, bestC);
  }

  bool _hasOccupiedNeighbor(int r, int c) {
    for (var n in _getNeighbors(r, c)) {
      if (grid[n.x][n.y].color != null) return true;
    }
    return false;
  }

  // ==================== MATCHING & POPPING ====================
  void _checkMatchesAndPop(int startR, int startC, BubbleColor targetColor) {
    final Set<String> matched = {};
    final List<Point<int>> queue = [Point(startR, startC)];
    matched.add('$startR,$startC');

    while (queue.isNotEmpty) {
      final Point<int> current = queue.removeLast();
      final List<Point<int>> neighbors = _getNeighbors(current.x, current.y);

      for (var n in neighbors) {
        final String key = '${n.x},${n.y}';
        if (!matched.contains(key)) {
          if (grid[n.x][n.y].color == targetColor) {
            matched.add(key);
            queue.add(n);
          }
        }
      }
    }

    if (matched.length >= 3) {
      final int count = matched.length;

      if (count >= 4) {
        SoundService.playMegaCombo();

        if (currentStarsEarned.value < 1) {
          currentStarsEarned.value = 1;
        } else if (count >= 6 && currentStarsEarned.value < 2) {
          currentStarsEarned.value = 2;
        }

        comboBannerText.value = '💥 ${count}x MEGA COMBO! ★ STAR UNLOCKED!';
        Future.delayed(const Duration(milliseconds: 2200), () {
          if (comboBannerText.value.startsWith('💥 $count')) {
            comboBannerText.value = '';
          }
        });
      } else {
        SoundService.playPop();
      }

      for (var key in matched) {
        final parts = key.split(',');
        final r = int.parse(parts[0]);
        final c = int.parse(parts[1]);
        grid[r][c].color = null;
      }
      grid.refresh();

      final int basePoints = count * 250;
      final int comboBonus = count >= 4 ? count * 300 : 0;
      final int earned = basePoints + comboBonus;
      currentScore.value += earned;

      _updateStarsFromScore();
      _dropOrphanBubbles();
    }
  }

  void _dropOrphanBubbles() {
    final Set<String> connectedToCeiling = {};
    final List<Point<int>> queue = [];

    for (int c = 0; c < grid[0].length; c++) {
      if (grid[0][c].color != null) {
        connectedToCeiling.add('0,$c');
        queue.add(Point(0, c));
      }
    }

    while (queue.isNotEmpty) {
      final Point<int> current = queue.removeLast();
      for (var n in _getNeighbors(current.x, current.y)) {
        final key = '${n.x},${n.y}';
        if (!connectedToCeiling.contains(key) && grid[n.x][n.y].color != null) {
          connectedToCeiling.add(key);
          queue.add(n);
        }
      }
    }

    int droppedCount = 0;
    for (int r = 1; r < totalRows; r++) {
      for (int c = 0; c < grid[r].length; c++) {
        if (grid[r][c].color != null && !connectedToCeiling.contains('$r,$c')) {
          grid[r][c].color = null;
          droppedCount++;
        }
      }
    }

    if (droppedCount > 0) {
      grid.refresh();
      currentScore.value += droppedCount * 350;
      SoundService.playCombo();
      _updateStarsFromScore();
    }
  }

  void _updateStarsFromScore() {
    final double scoreRatio = currentScore.value / targetScore;
    if (scoreRatio >= 1.0) {
      currentStarsEarned.value = 3;
    } else if (scoreRatio >= 0.70 && currentStarsEarned.value < 2) {
      currentStarsEarned.value = 2;
    } else if (scoreRatio >= 0.40 && currentStarsEarned.value < 1) {
      currentStarsEarned.value = 1;
    }
  }

  List<Point<int>> _getNeighbors(int r, int c) {
    final List<Point<int>> neighbors = [];
    final bool isEven = r % 2 == 0;

    final List<List<int>> offsets = isEven
        ? [
            [-1, -1], [-1, 0],
            [0, -1], [0, 1],
            [1, -1], [1, 0],
          ]
        : [
            [-1, 0], [-1, 1],
            [0, -1], [0, 1],
            [1, 0], [1, 1],
          ];

    for (var o in offsets) {
      final int nr = r + o[0];
      final int nc = c + o[1];
      if (nr >= 0 && nr < totalRows) {
        final int maxCols = (nr % 2 == 0 ? 8 : 7);
        if (nc >= 0 && nc < maxCols) {
          neighbors.add(Point(nr, nc));
        }
      }
    }
    return neighbors;
  }

  int _calculateStars() {
    final double scoreRatio = currentScore.value / targetScore;
    int fromScore = 1;
    if (scoreRatio >= 1.0) {
      fromScore = 3;
    } else if (scoreRatio >= 0.70) {
      fromScore = 2;
    }
    return max(currentStarsEarned.value, fromScore);
  }

  // ==================== DIALOGS & GAME OVER ====================
  void _showWinDialog() {
    if (isGameOver.value) return;
    isGameOver.value = true;
    isShooting.value = false;
    aimPosition.value = null;

    SoundService.playWin();

    final int starsEarned = _calculateStars();

    try {
      _saveLevelResultUseCase.execute(
        level: level,
        stars: starsEarned,
        score: currentScore.value,
      ).catchError((e) {
        debugPrint('[Save Progress Error] $e');
        return null as dynamic;
      });
    } catch (e) {
      debugPrint('[Save Progress Note] $e');
    }

    Get.dialog(
      Dialog(
        backgroundColor: const Color(0xFF161E42),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  final bool active = index < starsEarned;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Icon(
                      Icons.star_rounded,
                      size: index == 1 ? 52 : 42,
                      color: active ? const Color(0xFFFFD043) : const Color(0xFF2C3766),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 12),
              const Text(
                'Level Complete!',
                style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              Text(
                'Earned $starsEarned ${starsEarned == 1 ? "Star" : "Stars"}! ★',
                style: const TextStyle(color: Color(0xFFFFD043), fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                'Score: ${currentScore.value} / $targetScore',
                style: const TextStyle(color: Color(0xFF98A7C7), fontSize: 15),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFDBB3A),
                  foregroundColor: const Color(0xFF131938),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                ),
                onPressed: () {
                  if (Get.isDialogOpen == true) {
                    Get.back();
                  }
                  Get.back(result: {'won': true, 'stars': starsEarned, 'level': level});
                },
                child: const Text('Continue', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  void _showGameOverDialog({String reason = 'Out of Moves!'}) {
    if (isGameOver.value) return;
    isGameOver.value = true;
    isShooting.value = false;
    aimPosition.value = null;

    SoundService.playLose();

    Get.dialog(
      Dialog(
        backgroundColor: const Color(0xFF161E42),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.sentiment_dissatisfied_rounded, size: 68, color: Color(0xFFFF6565)),
              const SizedBox(height: 12),
              Text(
                reason,
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              Text(
                'Score: ${currentScore.value} / $targetScore',
                style: const TextStyle(color: Color(0xFF98A7C7), fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFDBB3A),
                  foregroundColor: const Color(0xFF131938),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                ),
                onPressed: () {
                  if (Get.isDialogOpen == true) {
                    Get.back();
                  }
                  onInit();
                },
                child: const Text('Try Again', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  if (Get.isDialogOpen == true) {
                    Get.back();
                  }
                  Get.back();
                },
                child: const Text(
                  'Select Level',
                  style: TextStyle(color: Color(0xFF98A7C7), fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}
