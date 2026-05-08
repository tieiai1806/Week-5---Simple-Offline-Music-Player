import 'package:flutter/material.dart';

class ProgressBarCustom extends StatelessWidget {
  final Duration position;
  final Duration duration;
  final Function(Duration) onSeek;

  const ProgressBarCustom({
    super.key,
    required this.position,
    required this.duration,
    required this.onSeek,
  });

  @override
  Widget build(BuildContext context) {
    final double maxMilliseconds = duration.inMilliseconds.toDouble();
    final double currentMilliseconds = position.inMilliseconds.toDouble();

    return Column(
      children: [
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            activeTrackColor: const Color(0xFF1DB954),
            inactiveTrackColor: Colors.white10,
            thumbColor: Colors.white,
            overlayColor: const Color(0xFF1DB954).withOpacity(0.3),
            trackShape: const RectangularSliderTrackShape(),
          ),
          child: Slider(
            value: currentMilliseconds.clamp(0.0, maxMilliseconds > 0 ? maxMilliseconds : 0.1),
            min: 0.0,
            max: maxMilliseconds > 0 ? maxMilliseconds : 0.1,
            onChanged: (value) {
              onSeek(Duration(milliseconds: value.toInt()));
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(position),
                style: const TextStyle(color: Color(0xFFB3B3B3), fontSize: 12),
              ),
              Text(
                _formatDuration(duration),
                style: const TextStyle(color: Color(0xFFB3B3B3), fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}