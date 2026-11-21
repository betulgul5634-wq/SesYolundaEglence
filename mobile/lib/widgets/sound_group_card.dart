import 'package:flutter/material.dart';
import '../models/sound_group.dart';

class SoundGroupCard extends StatelessWidget {
  final SoundStage stage;
  final VoidCallback? onTap;

  const SoundGroupCard({
    super.key,
    required this.stage,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isLocked = onTap == null;
    final Color cardColor = isLocked ? const Color(0xFFB0BEC5) : Color(stage.colorHex);
    final Color textColor = isLocked ? Colors.white60 : Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: isLocked
              ? []
              : [
                  BoxShadow(
                    color: cardColor.withAlpha(100),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  )
                ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(40),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  stage.emoji,
                  style: const TextStyle(fontSize: 34),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stage.phoneme,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    stage.categoryTitle,
                    style: TextStyle(
                      color: textColor.withAlpha(200),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            if (isLocked)
              const Icon(Icons.lock_rounded, color: Colors.white54, size: 28)
            else
              Row(
                children: [
                  const Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 24),
                  Text(
                    '${stage.starsCollected}/15',
                    style: TextStyle(color: textColor, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
